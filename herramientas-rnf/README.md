# Herramientas de verificación de RNF

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Creado** | 16 de noviembre de 2026 |
| **Para qué** | Montar de una sola vez el entorno aislado y las herramientas que faltaban para verificar RNF |
| **Probado** | Sí, en la máquina de Andrés: Windows 11, PowerShell 5.1, Docker Desktop 28.4.0 |

---

## 0. Por qué esto existe

Tres medidas estaban bloqueadas por el mismo motivo operativo y no por falta de criterio:

| Bloqueo | Consecuencia |
| --- | --- |
| No había PostgreSQL aislado | Los 20 usuarios de JMeter (RNF-01, 03, 04, 06) no se podían correr sin cargar la base compartida |
| No había análisis estático | [H-05](../A4-hallazgos-rnf.md) abierto, y RNF-20 sostenido solo con cobertura |
| No había monitoreo de uptime | RNF-18 medido con una ventana de **208 segundos**, que no demuestra «uptime ≥ 95 %» |

> ⚠️ **El malentendido que hay que evitar.** Los contenedores `sigra-backend` y `sigra-frontend`
> que ya estaban corriendo **no sirven** para medir rendimiento. `docker inspect sigra-backend`
> muestra `DB_URL=jdbc:postgresql://aws-0-us-east-1.pooler.supabase.com`: ese backend es local en
> el proceso, pero **su base de datos es la misma que usa el despliegue de Render**. Cargarlo con
> 20 usuarios sería una prueba de carga en producción. De ahí el `sigra-pg-rnf` de esta carpeta.

---

## 1. Levantar todo

```powershell
powershell -ExecutionPolicy Bypass -File "mantenimiento-rnf\herramientas-rnf\levantar.ps1"
```

Es idempotente: se puede volver a correr. Para rehacer la base desde cero, `-Recrear`.

| Servicio | Puerto | Para qué |
| --- | --- | --- |
| `sigra-pg-rnf` | **5433** | PostgreSQL 16 aislado, con el esquema y los seeds cargados |
| `sonarqube` | **9000** | Mantenibilidad y análisis estático ([H-05](../A4-hallazgos-rnf.md)) |
| `uptime-kuma` | **3001** | Uptime real del backend en Render (RNF-18) |

Puertos elegidos para no chocar con `sigra-backend` (8080) ni `sigra-frontend` (4200).

**Resultado esperado de la primera corrida** (verificado el 16-nov):

```
      Tablas en el schema sigra : 20
      Usuarios sembrados        : 4
  SonarQube    http://localhost:9000    -> {"status":"UP"}  version 26.11.0
  Uptime Kuma  http://localhost:3001    -> HTTP 200
```

### Lo que el script avisa y es normal

`seed-asignaturas-roles.sql` **falla, y está previsto**. Es un seed del 6 de octubre que inserta en
`sigra.matricula` sin `fecha_matricula`, columna que la migración RF-08 del 11 de octubre dejó
`NOT NULL`. Está registrado como **ERR-021** en
[`registros-equipo-rnf.md`](../registros-equipo-rnf.md). No afecta a la medición de RNF: los seeds
de autenticación, asignaturas y semestres sí cargan, y son los que JMeter necesita.

### Credenciales sembradas

| Correo | Rol |
| --- | --- |
| `admin.bruno@uco.net.co` | ADMINISTRADOR |
| `profesor.bruno@uco.net.co` | PROFESOR |
| `estudiante.bruno@uco.net.co` | ESTUDIANTE |
| `profesor.bloqueo@uco.net.co` | PROFESOR *(para probar el bloqueo de RF-04)* |

Contraseña de todas: la del CI, `PasswordSeguro123*`. **Son credenciales de prueba desechables de
una base local; no se usan en ningún entorno real.**

---

## 2. Levantar el backend contra esta base

Se levanta un **segundo** backend en el puerto **8081**, sin tocar el de 8080 que ya tienes.

### 2.1 La forma recomendada: reusar la imagen Docker

No hace falta Gradle. La imagen `sigra-backend:local` que ya construiste **no lleva `.env` dentro**
(se verificó: `/app` solo contiene `app.jar`), así que toda la configuración entra por variables de
entorno y **no hay ninguna ambigüedad de precedencia con el `.env` que apunta a Supabase**.

Todo en una línea:

```powershell
docker run -d --name sigra-backend-rnf --network sigra-rnf -p 8081:8081 -e DB_URL="jdbc:postgresql://sigra-pg-rnf:5432/postgres?currentSchema=sigra" -e DB_USERNAME=postgres -e DB_PASSWORD=rnf_local_solo_pruebas -e JWT_SECRET=rnf_local_jwt_secret_con_al_menos_32_chars_x -e JWT_EXPIRATION_MS=3600000 -e SERVER_PORT=8081 -e JPA_DDL_AUTO=validate -e CORS_ALLOWED_ORIGINS="http://localhost:4200,http://127.0.0.1:4200" sigra-backend:local
```

Fíjate en `sigra-pg-rnf:5432`, **no** `127.0.0.1:5433`: dentro de la red de Docker los
contenedores se ven por su nombre y por el puerto interno.

Tarda unos 20 segundos. Comprobar:

```powershell
Invoke-WebRequest http://127.0.0.1:8081/actuator/health -UseBasicParsing
```

Para rehacerlo: `docker rm -f sigra-backend-rnf` y volver a lanzar. Si cambiaste el código,
reconstruye la imagen primero.

### 2.2 Si prefieres Gradle

Desde `software4-SIGRA-backend\SIGRA`. Funciona porque las variables de entorno del sistema
**tienen más precedencia** que el `spring.config.import` del `.env` (posición 8 contra 10-13 en el
orden de configuración externalizada de Spring Boot), pero depende de ese detalle; la vía de Docker
no depende de nada.

```powershell
$env:DB_URL            = 'jdbc:postgresql://127.0.0.1:5433/postgres?currentSchema=sigra'
$env:DB_USERNAME       = 'postgres'
$env:DB_PASSWORD       = 'rnf_local_solo_pruebas'
$env:JWT_SECRET        = 'rnf_local_jwt_secret_con_al_menos_32_chars_x'
$env:JWT_EXPIRATION_MS = '3600000'
$env:SERVER_PORT       = '8081'
$env:JPA_DDL_AUTO      = 'validate'
.\gradlew bootRun
```

### 2.3 ⚠️ El baseline NO alcanza para arrancar: falta una tabla

**Con solo `SIGRA_SCHEMA_CURRENT.sql`, el backend no arranca.** Falla así:

```
SchemaManagementException: Schema validation: missing table [historial_auditoria]
```

El baseline crea 19 tablas y las entidades JPA esperan 20. La que falta la crea una migración
aparte que **no está integrada en el baseline**:

```powershell
Get-Content -Raw -Encoding UTF8 "..\..\software4-SIGRA-backend\docs\db\RF19_historial_auditoria_migration.sql" | docker exec -i -e PGPASSWORD=rnf_local_solo_pruebas sigra-pg-rnf psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f -
```

Después de aplicarla hay 20 tablas y el backend arranca. Está registrado como **ERR-022** en
[`registros-equipo-rnf.md`](../registros-equipo-rnf.md); el `levantar.ps1` ya la aplica solo.

> **Por qué esto importa más de lo que parece.** `JPA_DDL_AUTO=validate` hace que el backend se
> niegue a arrancar si el esquema no coincide con las entidades. Que no arranque desde el baseline
> del repositorio significa que **nadie puede reconstruir el entorno desde el repositorio**, y eso
> explica por qué todo el equipo apunta a Supabase: no es comodidad, es que la alternativa estaba
> rota. Es la causa de fondo del riesgo que señalamos en [H-02](../A4-hallazgos-rnf.md).

### 2.4 Comprobación de que de verdad usa la base local

No basta con que responda `UP`: hay que probar que no está hablando con Supabase. Esta prueba es
decisiva y no rompe nada, porque un login correcto reinicia el contador:

```powershell
# 1. contador antes
docker exec -e PGPASSWORD=rnf_local_solo_pruebas sigra-pg-rnf psql -U postgres -d postgres -t -A -c "SELECT intentos_fallidos FROM sigra.usuario WHERE correo_institucional='admin.bruno@uco.net.co'"

# 2. un login con clave incorrecta contra 8081  -> debe responder 401

# 3. contador despues: si subio, el backend esta usando ESTA base
```

Resultado obtenido el 16 de noviembre: **0 → 1** tras el 401, y **1 → 0** tras un login correcto.

**De paso quedó verificado en ejecución, no solo por pruebas unitarias:**

| Requisito | Evidencia en ejecución |
| --- | --- |
| **RNF-16** (auditar autenticaciones exitosas **y fallidas**) | `sigra.historial_auditoria` registró `LOGIN_FALLIDO` y `LOGIN_EXITOSO`, con fecha y hora, rol, acción y detalle |
| **RNF-15** (token expira ≤ 60 min) | La respuesta del login trae `expiraEn: 3600` segundos = 60 min exactos |
| **RNF-10** (nunca devolver la contraseña) | La respuesta solo trae `token`, `tipo`, `expiraEn` y `usuario`; ningún campo de contraseña ni hash |
| **RF-04** (contador de intentos fallidos) | Sube con el fallo y se reinicia con el éxito |

---

## 3. JMeter con 20 usuarios — RNF-01, 03, 04, 06

Desde `mantenimiento-rnf`:

```powershell
..\apache-jmeter-5.6.3\bin\jmeter.bat -n -t jmeter\RNF-01-06-rendimiento.jmx -l jmeter\resultados\rnf01-06-local.jtl -e -o jmeter\resultados\rnf01-06-local-reporte -Jhost=127.0.0.1 -Jpuerto=8081 -Jprotocol=http -Jusuarios=20 -Jrampa=20 -Jiteraciones=5 -Jcorreo=admin.bruno@uco.net.co -Jclave=PasswordSeguro123*
```

> En PowerShell va **todo en una línea**. Si necesitas partirlo, el carácter de continuación es la
> comilla invertida `` ` ``, no `\`.

El veredicto se lee en `jmeter\resultados\rnf01-06-local-reporte\index.html`, tabla *Statistics*,
columna **`95th pct`** (y `90th pct` para RNF-06, porque el SRS pide 90 % ahí). Criterios y
umbrales en [`../jmeter/README.md`](../jmeter/README.md).

---

## 4. SonarQube — configuración completa · H-05 y RNF-20

**Estado al 16 de noviembre: ya está configurado y escaneado.** Lo que sigue documenta cómo quedó,
para que puedas rehacerlo o entenderlo.

### 4.1 Credenciales — importante, `admin/admin` ya no funciona

| | |
| --- | --- |
| **URL** | `http://localhost:9000` |
| **Usuario** | `rnf` |
| **Contraseña** | `SigraRnf2026*` |
| **Permisos** | miembro de `sonar-administrators` |

> **Por qué hay un usuario `rnf` y no se usa `admin`.** Al montarlo, `admin/admin` funcionó durante
> unos minutos y después empezó a responder **401**, tanto por API como en el formulario de login.
> El intento de cambiar su contraseña devuelve `old_password_incorrect`, así que la contraseña por
> defecto dejó de ser válida —SonarQube la invalida tras el primer uso— y **la cuenta `admin` quedó
> inaccesible**. La salida fue crear un usuario propio con el token que ya se había generado.
> Es además mejor práctica: un usuario nombrado en lugar de la cuenta compartida por defecto.
>
> Si algún día necesitas recuperar `admin`, hay que reiniciar su contraseña desde la base de datos
> interna de SonarQube, que en esta configuración vive dentro del contenedor.

### 4.2 Generar un token

Dos vías. Por la interfaz: *arriba a la derecha → My Account → Security → Generate Token*, tipo
**User Token**, sin expiración para pruebas locales.

O por API, que es lo que se hizo:

```powershell
curl.exe -s -u "rnf:SigraRnf2026*" -X POST "http://localhost:9000/api/user_tokens/generate" -d "name=rnf-auditoria"
```

Guarda el valor: **SonarQube no lo vuelve a mostrar.**

### 4.3 Proyecto y puerta de calidad alineada al SRS

Esto es lo que convierte a SonarQube en un instrumento de RNF y no en un tablero decorativo: la
puerta tiene las condiciones del **SRS**, no las que vienen por defecto.

```powershell
$U = "rnf:SigraRnf2026*"
curl.exe -s -u $U -X POST "http://localhost:9000/api/projects/create" -d "name=SIGRA backend&project=sigra-backend"
curl.exe -s -u $U -X POST "http://localhost:9000/api/qualitygates/create" -d "name=SIGRA RNF-20"
curl.exe -s -u $U -X POST "http://localhost:9000/api/qualitygates/create_condition" -d "gateName=SIGRA RNF-20&metric=coverage&op=LT&error=70"
curl.exe -s -u $U -X POST "http://localhost:9000/api/qualitygates/create_condition" -d "gateName=SIGRA RNF-20&metric=sqale_rating&op=GT&error=2"
curl.exe -s -u $U -X POST "http://localhost:9000/api/qualitygates/create_condition" -d "gateName=SIGRA RNF-20&metric=reliability_rating&op=GT&error=2"
curl.exe -s -u $U -X POST "http://localhost:9000/api/qualitygates/create_condition" -d "gateName=SIGRA RNF-20&metric=security_rating&op=GT&error=2"
curl.exe -s -u $U -X POST "http://localhost:9000/api/qualitygates/select" -d "gateName=SIGRA RNF-20&projectKey=sigra-backend"
```

| Condición | Valor | De dónde sale |
| --- | --- | --- |
| `coverage < 70` → falla | **70 %** | **RNF-20 (a)** textual |
| `sqale_rating > 2` → falla | peor que **B** | Criterio nuestro: el SRS no fija letra |
| `reliability_rating > 2` → falla | peor que **B** | Criterio nuestro |
| `security_rating > 2` → falla | peor que **B** | Criterio nuestro |

Las tres últimas **no** son exigencias del SRS y hay que presentarlas así. Son el umbral que **nos
damos nosotros** para que la palabra «mantenibilidad» tenga un número detrás.

### 4.4 Ejecutar el escaneo

El `build.gradle` **no** trae el plugin de Sonar, y no vamos a agregarlo: sería un PR al
repositorio del producto que no nos corresponde abrir. Se usa el escáner en Docker, que no toca
nada:

```powershell
cd software4-SIGRA-backend\SIGRA
.\gradlew compileJava testClasses jacocoTestReport
$tok = "TU_TOKEN"
docker run --rm --network sigra-rnf -v "${PWD}:/usr/src" sonarsource/sonar-scanner-cli "-Dsonar.host.url=http://sonarqube:9000" "-Dsonar.token=$tok" "-Dsonar.projectKey=sigra-backend" "-Dsonar.sources=src/main" "-Dsonar.tests=src/test" "-Dsonar.java.binaries=build/classes/java/main" "-Dsonar.java.test.binaries=build/classes/java/test" "-Dsonar.coverage.jacoco.xmlReportPaths=build/reports/jacoco/test/jacocoTestReport.xml"
```

> ⚠️ **Cada `-Dsonar...` va entre comillas dobles.** Sin ellas PowerShell parte el argumento y el
> escáner falla con `Unrecognized option: .host.url=http://sonarqube:9000`. Comprobado.
>
> Y fíjate en `http://sonarqube:9000`, **no** `localhost`: el escáner corre dentro de la red
> `sigra-rnf` y ahí el servidor se llama por el nombre del contenedor.

Tarda ~5 minutos la primera vez.

### 4.5 Resultado obtenido el 16 de noviembre

| Métrica | Valor | Lectura |
| --- | --- | --- |
| **Puerta de calidad** | **OK** | Pasa las cuatro condiciones |
| **Mantenibilidad** | **A** | Es el dato que RNF-20 no tenía |
| **Deuda técnica** | **15 minutos** | Sobre 14 422 líneas |
| Cobertura (según Sonar) | **90,5 %** | Concuerda con el 92,39 % de JaCoCo |
| Fiabilidad · Seguridad | **A** · **A** | |
| Bugs · Vulnerabilidades | **0** · **0** | |
| Code smells | **3** | |
| Security hotspots | **0** | |
| Duplicación | **0,5 %** | |
| Complejidad ciclomática | 1 282 | |

**Cierra [H-05](../A4-hallazgos-rnf.md)** y da a RNF-20 un respaldo que la cobertura sola no daba.

> ⚠️ **No confundas estos ceros con «no hay vulnerabilidades».** Sonar reporta **0
> vulnerabilidades de código** y en el registro del escaneo dice literalmente
> `Dependency analysis skipped`: **no analizó las dependencias.** Trivy, sobre la misma imagen,
> encontró **4 CRITICAL y 10 HIGH** en librerías Java. Son dos preguntas distintas y hay que
> contestarlas por separado:
>
> | Pregunta | Herramienta |
> | --- | --- |
> | ¿El código que escribimos tiene fallos? | **SonarQube** → 0 bugs, 0 vulnerabilidades |
> | ¿Las librerías que usamos tienen CVE conocidos? | **Trivy / Dependency-Check** → 4 CRITICAL, 10 HIGH |
>
> Presentar solo el tablero de Sonar y decir «cero vulnerabilidades» sería un informe falso.

### 4.6 Qué mirar en el tablero, y en qué orden

`http://localhost:9000/dashboard?id=sigra-backend`

1. **Quality Gate** arriba: `Passed` o `Failed`. Es el veredicto de una ojeada.
2. **Maintainability**: la letra y la deuda. Es el dato para RNF-20.
3. **Reliability** y **Security**: letras.
4. **Security Hotspots**: puntos a revisar a mano. **No son vulnerabilidades confirmadas** y no hay
   que llamarlas así.
5. **Coverage**: contrástala con la de JaCoCo. Si difieren mucho, el `xmlReportPaths` no se leyó.

---

## 5. Uptime Kuma — configuración · RNF-18

**Haz esto primero si vas con poco tiempo.** Es el único servicio que mejora solo con las horas:
cada hora encendido es una hora de ventana real para RNF-18.

> **Esta configuración no se puede automatizar.** Kuma no expone una API REST para el alta inicial
> —usa socket.io— así que el primer usuario **hay que crearlo en el navegador**. Al 16 de noviembre
> **todavía no está creado**: `GET /` responde 302 hacia la pantalla de instalación.

### 5.1 Crear el usuario (una vez)

1. Abre `http://localhost:3001`. Te lleva a la pantalla de *Create your admin account*.
2. Usuario y contraseña a tu elección. **Anótalos**: no hay recuperación por correo.
3. No pide correo ni verificación.

### 5.2 Monitor del backend — el que importa

*→ Add New Monitor*, y rellena exactamente esto:

| Campo | Valor |
| --- | --- |
| **Monitor Type** | `HTTP(s)` |
| **Friendly Name** | `SIGRA backend (Render) — RNF-18` |
| **URL** | `https://software4-sigra-backend.onrender.com/actuator/health` |
| **Heartbeat Interval** | `60` segundos |
| **Retries** | `1` |
| **Request Timeout** | `30` segundos |
| **Accepted Status Codes** | `200-299` |
| *Advanced → Certificate Expiry* | déjalo activado: avisa si el certificado TLS va a caducar |

Guarda con *Save*.

> **Por qué 60 segundos y no menos.** Con 60 s tienes 1 440 muestras al día: suficiente para un
> porcentaje creíble, y no es tráfico agresivo contra un servicio de plan gratuito. Bajarlo a 20 s
> no mejora el dato y sí el ruido.
>
> **Por qué `/actuator/health` y no la raíz.** La raíz podría responder 200 con el servicio
> degradado por detrás. El health check de Spring reporta `UP` solo si la aplicación y su base
> responden. Es el único endpoint expuesto a propósito (`application.yaml`,
> `management.endpoints.web.exposure.include: health`).

### 5.3 Monitor del frontend — opcional

Igual, con nombre `SIGRA frontend (Vercel)` y URL `https://sigra.vercel.app/login`.

### 5.4 Qué mirar, y cuándo

Entra al monitor y mira la fila de porcentajes de arriba:

| Dato | Para qué |
| --- | --- |
| **Uptime 24h** | **Es la cifra de RNF-18.** Umbral: ≥ 95 % |
| Uptime 30d | Para el informe final, si llega a acumularse |
| Avg. Ping | Contexto, no es umbral de ningún RNF |
| Lista de eventos | Cada caída, con hora de inicio y fin |

**No mires nada antes de 24 horas.** Con dos horas encendido el porcentaje no dice nada más de lo
que ya dijo la sonda de JMeter, y es el mismo error de ventana corta que ya tuvimos que declarar.

> ⚠️ **La reserva que hay que escribir siempre junto al porcentaje.** Kuma mide **desde este
> portátil**. Si se suspende o pierde red, el hueco se cuenta como caída del servicio y el dato
> sale **sesgado a la baja**. Anota siempre la ventana real junto al número, y revisa la lista de
> eventos: una «caída» de madrugada que coincide con el portátil dormido no es una caída de SIGRA.
>
> **La lista de eventos es también la fuente del MTTR.** Si alguna vez hay una caída real, el
> tiempo entre el evento de bajada y el de subida es el dato que hoy no tenemos para RNF-18.

---

## 5-bis. PostgreSQL aislado — no hay nada que configurar

`levantar.ps1` ya lo deja con el esquema (20 tablas) y 4 usuarios sembrados. Solo conviene saber
cómo mirarlo:

```powershell
# conectarse
docker exec -it -e PGPASSWORD=rnf_local_solo_pruebas sigra-pg-rnf psql -U postgres -d postgres

# los roles sembrados
docker exec -e PGPASSWORD=rnf_local_solo_pruebas sigra-pg-rnf psql -U postgres -d postgres -c "SELECT u.correo_institucional, u.estado, CASE WHEN a.id IS NOT NULL THEN 'ADMINISTRADOR' WHEN p.id IS NOT NULL THEN 'PROFESOR' WHEN e.id IS NOT NULL THEN 'ESTUDIANTE' END AS rol FROM sigra.usuario u LEFT JOIN sigra.administrador a ON a.id=u.id LEFT JOIN sigra.profesor p ON p.id=u.id LEFT JOIN sigra.estudiante e ON e.id=u.id"

# la auditoria, que es la evidencia de ejecucion de RNF-16
docker exec -e PGPASSWORD=rnf_local_solo_pruebas sigra-pg-rnf psql -U postgres -d postgres -c "SELECT fecha_hora, rol_usuario, accion, tipo_entidad FROM sigra.historial_auditoria ORDER BY fecha_hora DESC LIMIT 20"
```

Dentro de `psql`: `\dt sigra.*` lista las tablas, `\d sigra.usuario` describe una, `\q` sale.

---

## 6. Lo que NO está aquí, y por qué

| Herramienta | Para qué sería | Por qué no está |
| --- | --- | --- |
| **OWASP ZAP** | RNF-14, RNF-17 y las cabeceras de OBS-02 | Es un escaneo activo. **No se lanza contra el despliegue del equipo sin autorización escrita**: contra `sigra-pg-rnf` + el backend de 8081 sí se puede |
| **Lighthouse CI** | RNF-08 con tiempo real y RNF-21 automatizado | Se corre con `npx`, no necesita contenedor: `npx -y @lhci/cli autorun --collect.url=https://sigra.vercel.app/login` |
| **Trivy / Dependency-Check** | H-01 sin permiso de admin | `.\gradlew dependencyCheckAnalyze` ya funciona: el plugin está aplicado en `build.gradle:5` |
| **DefectDojo** | Consolidar los hallazgos de todas las anteriores en un tablero | Propuesta para la retrospectiva. Montarlo ahora sería una herramienta más que nadie alcanza a usar |

---

## 7. Apagar

```powershell
docker compose -f "mantenimiento-rnf\herramientas-rnf\docker-compose.yml" stop
```

`stop` conserva los datos. **No uses `down -v`** si quieres mantener el historial de Uptime Kuma,
que es justamente la evidencia de RNF-18 que se acumula con el tiempo.

---

[Guía del rol](../GUIA-TRABAJO-RNF.md) · [A3 Criterios](../A3-criterios-verificacion.md) · [A4 Hallazgos](../A4-hallazgos-rnf.md) · [A6 Semáforo](../A6-semaforo-rnf.md) · [JMeter](../jmeter/README.md)
