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

**Estado al 16 de noviembre: el backend está configurado y escaneado; el frontend no.** Lo que
sigue documenta cómo quedó, para que puedas rehacerlo o entenderlo.

> **Si solo quieres correrlo, es un comando.** `escanear-sonar.ps1` hace el escaneo y **baja la
> evidencia a `evidencias/`**, que es la parte que no hay que olvidar: el tablero vive dentro del
> volumen `sonarqube-data` y si el volumen se borra, la evidencia de H-05 se va con él.
>
> ```powershell
> powershell -ExecutionPolicy Bypass -File "mantenimiento-rnf\herramientas-rnf\escanear-sonar.ps1" -Proyecto ambos -Token "squ_..." -Version "2026-11-16"
> ```
>
> | Parámetro | Para qué |
> | --- | --- |
> | `-Proyecto` | `backend`, `frontend`, `ambos` o `evidencias` (solo volver a bajar los JSON) |
> | `-Token` | El token de usuario. También lo lee de `$env:SONAR_TOKEN`. **No se guarda en el repositorio** |
> | `-Version` | Etiqueta del análisis. **Es lo que hace comparable un mantenimiento con el anterior** — ver [§4.7](#47-cómo-esto-se-usa-en-el-mantenimiento-y-no-solo-en-la-entrega) |
> | `-Configurar` | Solo la primera vez: crea los proyectos y las puertas de calidad |
> | `-SinCompilar` | Salta los ~3 minutos de Gradle cuando el build ya está hecho |

El resto de esta sección explica lo que el script hace por dentro, que es lo que hay que poder
defender en la reunión.

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

> ⚠️ **No pegues `squ_...` literal.** En este README `squ_...` es un marcador de posición. Pasarlo
> tal cual da un **401 del escáner** cinco pasos más adelante, que no se parece en nada a la causa.
> El script ahora lo rechaza al arrancar, y además **valida el token contra el servidor** antes de
> hacer cualquier trabajo. Ojo al comprobarlo a mano: `api/authentication/validate` responde
> **HTTP 200** con `{"valid":false}` cuando el token es malo, así que hay que mirar el cuerpo y no
> el código HTTP.

> **Comprueba antes si el token de la auditoría anterior sigue vivo**, porque no siempre lo está:
>
> ```powershell
> curl.exe -s -u "rnf:SigraRnf2026*" "http://localhost:9000/api/user_tokens/search"
> ```
>
> Si devuelve `"userTokens":[]` —como ocurrió el 16-nov por la tarde— el token con el que se hizo
> el primer escaneo ya no existe y hay que generar otro. **El token no va al repositorio**: va en
> `-Token` o en `$env:SONAR_TOKEN`.

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

> ⚠️ **La puerta no tiene cuatro condiciones: tiene ocho.** Esto se descubrió el 16-nov y
> contradice lo que decía antes este README. **`api/qualitygates/create` no crea la puerta vacía:**
> SonarQube 26.11 le añade por su cuenta las cuatro condiciones de *Clean as You Code* sobre
> **código nuevo**, y la API las marca con `"isCaycCondition": true`:
>
> | Condición añadida por Sonar | Umbral | Qué mide |
> | --- | --- | --- |
> | `new_violations > 0` | 0 | Ningún hallazgo nuevo en el código nuevo |
> | `new_coverage < 80` | 80 % | Cobertura **del código nuevo** |
> | `new_duplicated_lines_density > 3` | 3 % | Duplicación **del código nuevo** |
> | `new_security_hotspots_reviewed < 100` | 100 % | Todo *hotspot* nuevo revisado |
>
> **Se dejan en la puerta del backend, y a propósito:** son exactamente el criterio de **no
> degradación** que [§4.7](#47-cómo-esto-se-usa-en-el-mantenimiento-y-no-solo-en-la-entrega)
> necesita, y «80 % de cobertura en lo que se toque» es una regla sana para un mantenimiento. Pero
> **no son del SRS**, y presentarlas como si lo fueran sería inflar el requisito. El SRS pide 70 %
> global; esto es un 80 % sobre lo nuevo, y es **nuestro**.
>
> **En la puerta del frontend hubo que quitar una.** `new_coverage < 80` sobre un proyecto del que
> **no tenemos cobertura** haría fallar la puerta en cuanto haya código nuevo —por falta de dato y
> no por falta de calidad—, que es justo lo que esa puerta existe para evitar. Se borró con
> `api/qualitygates/delete_condition`, y `escanear-sonar.ps1` ya lo hace solo al configurar.
>
> **Por qué un análisis dice «4 condiciones» y la puerta tiene 8.** Las condiciones de código nuevo
> **solo se evalúan si hay código nuevo**. En el primer análisis de un proyecto no hay con qué
> comparar, así que se omiten y el veredicto sale de las globales. No es un error: es la razón por
> la que `-Version` importa.

### 4.4 Evaluar el backend, paso a paso

Procedimiento completo, verificado el 16 de noviembre. **No modifica nada del repositorio del
producto**, y conviene tener claro qué sí escribe y qué no:

| | |
| --- | --- |
| **No toca** | Ni un archivo versionado del backend. **No** se agrega el plugin de Sonar a `build.gradle` y **no** se crea `sonar-project.properties`: el escáner va en contenedor justamente para eso |
| **Sí escribe** | `software4-SIGRA-backend\SIGRA\build\` (clases compiladas e informe de JaCoCo). Está cubierto por `.gitignore:3`, así que `git status` sigue limpio |
| **Sí cambia** | El servidor de Sonar guarda un análisis nuevo. Es el objetivo, no un efecto secundario |

> **Desde dónde se corre cada paso.** Los pasos 0 y 1, desde esta carpeta
> (`mantenimiento-rnf\herramientas-rnf`). El paso 2 cambia a la carpeta del backend y los pasos 3
> a 5 se quedan ahí. El `..\..` de las rutas relativas resuelve a la raíz del repositorio en los
> dos casos, así que los comandos valen tal cual están escritos. La única excepción es el comando
> del atajo, que —como el resto del README— se escribe desde la raíz del repositorio.

#### Paso 0 · Comprobar el entorno (30 segundos)

```powershell
curl.exe -s "http://localhost:9000/api/system/status"
docker network ls --filter name=sigra-rnf --format "{{.Name}}"
git -C "..\..\software4-SIGRA-backend" status --porcelain
```

Se espera: `"status":"UP"`, la red `sigra-rnf`, y **nada** en el `status` (árbol limpio, para poder
demostrar al final que el escaneo no modificó el producto). Si Sonar no responde, levántalo con
[`levantar.ps1`](levantar.ps1) y dale 1-2 minutos: arranca un Elasticsearch dentro.

#### Paso 1 · El token

`http://localhost:9000` → entrar con las credenciales de [§4.1](#41-credenciales--importante-adminadmin-ya-no-funciona)
→ arriba a la derecha **My Account → Security → Generate Token**, tipo **User Token**.
**Cópialo: Sonar no lo vuelve a mostrar.** Después, en la ventana de PowerShell donde vas a
trabajar:

```powershell
$env:SONAR_TOKEN = 'squ_pega_aqui_el_token'
```

Vive solo en esa ventana y **no queda escrito en ningún archivo**. Si el token de la auditoría
anterior ya no existe —ver el aviso de [§4.2](#42-generar-un-token)— genera otro; no es un error
tuyo.

#### Paso 2 · Regenerar el informe de JaCoCo (~3 min)

```powershell
cd "..\..\software4-SIGRA-backend\SIGRA"
.\gradlew compileJava testClasses jacocoTestReport
```

**Por qué no conviene saltárselo.** Sonar no mide cobertura: **la lee del XML de JaCoCo**. Si el
XML en disco es de una fecha anterior al código que vas a escanear, el tablero mostrará la
cobertura de ayer sobre el código de hoy, y eso es un dato falso en el informe. Corre las pruebas
unitarias; **no necesita base de datos** (`integrationTest` es otra tarea).

Si Gradle falla, **no sigas**: sin el XML, Sonar reporta 0 % de cobertura y la puerta falla **por
falta de dato y no por falta de calidad**.

#### Paso 3 · Escanear (~2 min; la primera vez ~5, que es cuando descarga la imagen)

Desde `software4-SIGRA-backend\SIGRA`, **todo en una línea**:

```powershell
docker run --rm --network sigra-rnf -v "${PWD}:/usr/src" sonarsource/sonar-scanner-cli "-Dsonar.host.url=http://sonarqube:9000" "-Dsonar.token=$env:SONAR_TOKEN" "-Dsonar.projectKey=sigra-backend" "-Dsonar.projectVersion=2026-11-16-bb72c07" "-Dsonar.sources=src/main" "-Dsonar.tests=src/test" "-Dsonar.java.binaries=build/classes/java/main" "-Dsonar.java.test.binaries=build/classes/java/test" "-Dsonar.coverage.jacoco.xmlReportPaths=build/reports/jacoco/test/jacocoTestReport.xml"
```

Al final debe decir `EXECUTION SUCCESS`.

> ⚠️ **Cada `-Dsonar...` va entre comillas dobles.** Sin ellas PowerShell parte el argumento y el
> escáner falla con `Unrecognized option: .host.url=http://sonarqube:9000`. Comprobado.
>
> Y fíjate en `http://sonarqube:9000`, **no** `localhost`: el escáner corre dentro de la red
> `sigra-rnf` y ahí el servidor se llama por el nombre del contenedor.
>
> **`-Dsonar.projectVersion` no es decorativo.** Es lo que permite que el próximo escaneo se compare
> contra este. Sin él el análisis queda como `projectVersion: "not provided"` y el panel *New Code*
> —el que responde «¿este mantenimiento degradó algo?»— se queda vacío. Ver
> [§4.7](#47-cómo-esto-se-usa-en-el-mantenimiento-y-no-solo-en-la-entrega). La etiqueta útil es la
> fecha más el commit, o el identificador del mantenimiento.

#### Paso 4 · Leer el veredicto sin depender del navegador

```powershell
curl.exe -s -u "rnf:SigraRnf2026*" "http://localhost:9000/api/qualitygates/project_status?projectKey=sigra-backend"
curl.exe -s -u "rnf:SigraRnf2026*" "http://localhost:9000/api/measures/component?component=sigra-backend&metricKeys=coverage,sqale_rating,sqale_index,reliability_rating,security_rating,bugs,vulnerabilities,code_smells,security_hotspots,duplicated_lines_density"
```

En los *ratings*, **`1.0` es A** y **`2.0` es B**. El tablero está en
`http://localhost:9000/dashboard?id=sigra-backend`, y qué mirar y en qué orden está en
[§4.6](#46-qué-mirar-en-el-tablero-y-en-qué-orden). La referencia contra la que comparar es el
resultado de [§4.5](#45-resultado-obtenido-el-16-de-noviembre).

#### Paso 5 · Demostrar que no se modificó el producto

```powershell
git -C "..\..\software4-SIGRA-backend" status --porcelain
```

Debe salir **vacío**, igual que en el paso 0. Es la comprobación que hace defendible la frase «el
análisis no tocó el repositorio del producto».

#### El atajo, si no quieres los pasos a mano

Hace lo mismo y además **baja la evidencia** a `evidencias/`:

```powershell
powershell -ExecutionPolicy Bypass -File "mantenimiento-rnf\herramientas-rnf\escanear-sonar.ps1" -Proyecto backend -Version "2026-11-16-bb72c07"
```

Toma el token de `$env:SONAR_TOKEN`. El proyecto y la puerta `SIGRA RNF-20` **ya existen**, así que
**no** uses `-Configurar`.

#### Si quieres cero escrituras, ni en `build/`

Salta el paso 2 y escanea con el XML que ya esté en disco (`-SinCompilar`, si usas el script).
Funciona, pero entonces la cobertura es la del código de la fecha de ese XML, y **eso hay que
escribirlo junto al resultado**. Para una cifra que vaya al informe no sirve.

### 4.5 Resultado obtenido el 16 de noviembre

| Métrica | Valor | Lectura |
| --- | --- | --- |
| **Puerta de calidad** | **OK** | Pasa las **4 condiciones globales** que se evaluaron. La puerta tiene 8: las otras 4 son de *código nuevo* y en este análisis no había con qué compararlas — ver el aviso de [§4.3](#43-proyecto-y-puerta-de-calidad-alineada-al-srs) |
| **Mantenibilidad** | **A** | Es el dato que RNF-20 no tenía |
| **Deuda técnica** | **15 minutos** | Sobre 14 422 líneas |
| Cobertura (según Sonar) | **90,5 %** | Concuerda con el 92,39 % de JaCoCo |
| Fiabilidad · Seguridad | **A** · **A** | |
| Bugs · Vulnerabilidades | **0** · **0** | |
| Code smells | **3** | |
| Security hotspots | **0** | |
| Duplicación | **0,5 %** | |
| Complejidad ciclomática | 1 282 | |

**Da a RNF-20 un respaldo que la cobertura sola no daba.** Pero **no cierra
[H-05](../A4-hallazgos-rnf.md)**, y conviene ser exacto con eso: el criterio de cierre que
escribimos en el hallazgo es *«el CI ejecuta el linter y falla si hay hallazgos»*, y esto corre a
mano en un portátil. Además H-05 abarca **los dos repositorios** y el frontend no está escaneado.
El hallazgo quedó en 🟡 **en corrección**.

**Los 3 *code smells*, por nombre.** Las tres son `java:S2187` («Add some tests to this class»),
severidad **BLOCKER**, y las tres están en **clases de prueba**:
`ConstructorRespuestaErrorTest.java:25`, `HallazgosContratoErrorTest.java:62` y
`PrecedenciaAdvicesTest.java:63`. La regla salta cuando una clase `*Test` no tiene métodos `@Test`
directos, que es lo que pasa con las pruebas en clases `@Nested`: **es un falso positivo de
patrón.** Pero anticipa la lectura incómoda —«0 bugs y 3 BLOCKER»— y cuesta 15 minutos quitarlos.

**La evidencia, en disco y no en una captura.** `evidencias/sonar-backend-2026-11-16-*.json`:

| Archivo | Qué contiene |
| --- | --- |
| `-medidas.json` | Las 20 métricas, incluidas cobertura de líneas (93,5 %) y de ramas (82 %) |
| `-puerta.json` | Las condiciones **evaluadas**, con su valor real y su veredicto |
| `-issues.json` | Los 3 *code smells* con regla, archivo y línea |
| `-hotspots.json` | Vacío: 0 hotspots |
| `-analisis.json` | Fecha del análisis y su `projectVersion` |

Se vuelven a bajar con `escanear-sonar.ps1 -Proyecto evidencias`.

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

### 4.7 Cómo esto se usa en el mantenimiento, y no solo en la entrega

**El escaneo del 16-nov es una foto, y la asignatura no pregunta por una foto.** La pregunta del
proyecto de mantenimiento no es «¿el código está en A?» sino **«¿este mantenimiento dejó el código
igual o peor?»**. SonarQube la contesta con su pestaña **New Code**, pero hace falta una cosa que
el primer escaneo no tuvo:

```powershell
curl.exe -s -u "rnf:SigraRnf2026*" "http://localhost:9000/api/project_analyses/search?project=sigra-backend"
# -> "projectVersion":"not provided"
```

**`not provided` significa que no hay contra qué comparar.** El período de código nuevo del
proyecto es `PREVIOUS_VERSION`, así que sin versión en cada análisis la comparación nunca ocurre.
Se arregla pasando `-Version`, y entonces el flujo por cada mantenimiento es este:

| Momento | Comando | Qué se lee |
| --- | --- | --- |
| **Antes** de tocar el código | `escanear-sonar.ps1 -Version "base-2026-11-17"` | Las métricas globales: la línea base |
| **Al terminar** el mantenimiento | `escanear-sonar.ps1 -Version "M-03-paginacion"` | La pestaña **New Code**: *smells*, duplicación y cobertura **del código nuevo** |
| **En la reunión** | — | Si el código nuevo no degradó nada, está demostrado y no es opinión |

**El criterio que proponemos por cada mantenimiento aprobado:**

> Un mantenimiento **no degrada la mantenibilidad** si la letra global no baja, la deuda técnica no
> crece más de 30 minutos, y el código nuevo no introduce *smells* `blocker` ni `critical`.

Es exactamente lo que [H-05](../A4-hallazgos-rnf.md) echaba de menos: el revisor técnico de F3
rechazaba por «legibilidad» sin respaldo objetivo, y eso se lee como opinión personal.

> ⚠️ **La reserva honesta.** Mientras esto viva en un portátil, la comparación la hace una persona
> a mano y **no muerde**: nada impide integrar un mantenimiento sin escanearlo. **Tenemos el
> indicador, no el control.** Eso solo lo arregla el CI, y el CI está bloqueado por el mismo
> permiso `admin` de [H-01](../A4-hallazgos-rnf.md).

### 4.8 El frontend — escaneado el 16 de noviembre por la noche

```powershell
powershell -ExecutionPolicy Bypass -File "mantenimiento-rnf\herramientas-rnf\escanear-sonar.ps1" -Proyecto frontend -Version "2026-11-17"
```

251 archivos analizados en 2:13 min, `EXECUTION SUCCESS`, revisión de SCM `dd97c25`.

> **Sobre la fecha, para que los registros no se contradigan.** El análisis se corrió a las **19:26
> hora local del 16**, que son las **00:26 UTC del 17**, y **Sonar guarda la hora UTC**: su tablero
> y `api/project_analyses` dicen `2026-11-17`, y la etiqueta de versión quedó `2026-11-17`. La
> evidencia en disco va con la **fecha local** (`sonar-frontend-2026-11-16-*.json`), que es la que
> usan los registros del equipo. Al pasar `-Version`, **usa la fecha local** para que las dos
> series coincidan.

| Métrica | Frontend | Backend, para comparar |
| --- | --- | --- |
| **Mantenibilidad** | **A** | **A** |
| **Deuda técnica** | **65 min** sobre 25 006 líneas | 15 min sobre 14 422 |
| **Fiabilidad** | **A** | **A** |
| **Seguridad** | **B** — por 1 vulnerabilidad `MINOR`, **que es un falso positivo** (abajo) | **A** |
| Bugs · Security hotspots | 0 · 0 | 0 · 0 |
| *Code smells* | **7**, todos `MAJOR` | 3 |
| **Duplicación** | **3,7 %** | 0,5 % |
| Complejidad · cognitiva | 2 730 · 912 | 1 282 · 504 |
| Cobertura | **0 %**, por diseño: sin `lcov` | 90,5 % |

**Con eso, los dos repositorios cumplen el criterio de [A3 §7.2](../A3-criterios-verificacion.md)**
—mantenibilidad A o B, sin *bugs* `blocker` ni `critical`, sin *hotspots* sin revisar—, y la mitad
de [H-05](../A4-hallazgos-rnf.md) que faltaba queda cubierta. **Lo que sigue abierto es el CI.**

**Puerta de calidad: `OK`**, con la puerta `SIGRA RNF-20 sin cobertura` y **4 condiciones
evaluadas** de las 6 que tiene:

| Condición evaluada | Umbral | Valor real | |
| --- | --- | --- | --- |
| `sqale_rating` | peor que B falla | **1 = A** | ✅ |
| `reliability_rating` | peor que B falla | **1 = A** | ✅ |
| `security_rating` | peor que B falla | **2 = B** | ✅ pasa justo en el límite, y por un falso positivo |
| `new_violations` | > 0 falla | **0** | ✅ |

**Va sin cobertura, y el motivo hay que declararlo.** `ng test --code-coverage` no corre en esta
máquina por [H-14](../A4-hallazgos-rnf.md) (Node v24.11.0 contra el v24.15.0 que exige Angular 22),
así que no hay `lcov` que entregarle al escáner. Por eso lleva una puerta propia,
**`SIGRA RNF-20 sin cobertura`**, a la que **se le quitó la condición de cobertura de código nuevo**
que SonarQube añade sola: dejarla haría que la puerta fallara **por falta de dato y no por falta de
calidad**, que es un semáforo mentiroso (detalle en
[§4.3](#43-proyecto-y-puerta-de-calidad-alineada-al-srs)). La cobertura del frontend se sigue
leyendo de los registros del CI.

#### Los 8 hallazgos, uno por uno — porque cuatro tocan RNF-21

Esto es lo que el escaneo aportó de verdad, y no estaba previsto: **la mitad de los hallazgos son
de accesibilidad**, que es el atributo que [H-04](../A4-hallazgos-rnf.md) daba por no automatizable.
No es una auditoría WCAG, pero es la primera señal automática que tenemos de RNF-21.

| Regla | Dónde | Lectura |
| --- | --- | --- |
| `typescript:S5332` *(VULNERABILITY, minor)* | `core/interceptors/auth.interceptor.ts:70` | **Falso positivo, comprobado abriendo el archivo.** Es `new URL(url, 'http://relative.invalid')`: una **base** para poder parsear una URL root-relative. `.invalid` es un TLD reservado por la RFC 2606 y **por ahí no sale tráfico**. **No afecta a RNF-11** |
| `Web:S6845` | `calificaciones/.../planilla-notas-page.html:228` | `<span tabindex="0" aria-label="Registrado fuera de fecha">`: un elemento **no interactivo metido en el orden de tabulación**, y precisamente en la pantalla de notas, que es donde RNF-21 exige teclado. Parece una ayuda deliberada para llegar al marcador; el precio es **una parada de tabulación por fila** |
| `Web:S6825` ×3 | `reportes/.../matriculas-programa-semestre-tab.html:95, 114, 128` | `aria-hidden="true"` en `<th>` y `<td>` decorativos (la columna de la barra). `td`/`th` **no son focusables por defecto**, así que el riesgo práctico es bajo. **Hay que confirmarlo en el recorrido por teclado antes de llamarlo hallazgo** |
| `Web:S9379` | `auth/.../login-page.html:51` | `autofocus` en el campo de correo. Discutible, no es incumplimiento de WCAG AA |
| `typescript:S8786` ×2 | `auth.interceptor.ts:60` y `api-error.interceptor.ts:41` | Expresiones regulares con retroceso super-lineal (`/\/+$/` y `/^Bearer\s+(.+)$/i`). ReDoS **teórico** sobre entradas cortas y acotadas: un prefijo de API y una cabecera `Authorization`. No incumple ningún RNF; 40 min de esfuerzo estimado |

> **La regla que aplicamos aquí.** Ninguno de estos ocho se convierte en hallazgo de RNF por
> aparecer en Sonar. Los cuatro de accesibilidad **van al recorrido por teclado de RNF-21** como
> puntos a comprobar a mano; la «vulnerabilidad» **se descarta con el archivo abierto**, no con una
> opinión. Ver el filtro de [§4.6](#46-qué-mirar-en-el-tablero-y-en-qué-orden).

#### Las trampas que salieron en estas corridas, y cómo quedaron

| Lo que pasó | Por qué | Estado |
| --- | --- | --- |
| El script imprimió **«el escaner salio con codigo» seguido de todo el log**, con el escaneo correcto | `docker run` dejaba su salida en la tubería, así que la función devolvía *el log entero* además del código y la comprobación `-ne 0` se cumplía siempre | ✅ Corregido: la salida va a `Out-Host` y la función devuelve solo el código |
| La puerta salió **`NONE`** | El escáner **sube** el informe; el servidor lo procesa **después**, en su cola (*Compute Engine*). Preguntar en ese hueco devuelve `NONE` | ✅ Corregido: el script espera a que `api/ce/activity_status` quede en `pending:0, inProgress:0` |
| Un `-Token "squ_..."` pegado literal dio **401 del escáner**, y el script siguió: **3 minutos de espera inútil** y **la evidencia buena sobrescrita con seis archivos de 0 bytes** | Tres fallos encadenados: no se validaba el token, no se cortaba tras un escaneo fallido, y `curl -o` **crea el archivo igual** cuando la respuesta es un 401 | ✅ Corregidos los tres: el token se valida contra `api/authentication/validate` antes de empezar, un escaneo fallido **aborta con `exit 1`** sin bajar nada, y cada descarga va a un temporal que **solo se mueve encima si el contenido sirve** |
| El resumen final reventó con `ArgumentNullException` en `[regex]::Matches($puerta, …)` | `Get-Content -Raw` de un archivo vacío devuelve `$null`, no `''` | ✅ Lectura a prueba de nulos |
| La puerta resultó tener **8 condiciones** y no las 4 que creamos | `api/qualitygates/create` **añade solas** las 4 condiciones de *Clean as You Code* sobre código nuevo | ✅ Documentado en [§4.3](#43-proyecto-y-puerta-de-calidad-alineada-al-srs); se conservan en el backend a propósito y se quitó `new_coverage` de la del frontend |
| El proyecto quedó con **la puerta por defecto `Sonar way`** y el nombre en minúsculas | El proyecto no existía y **el escáner lo creó solo**, con la clave como nombre y la puerta por defecto. Sus condiciones son todas sobre *código nuevo*: en un primer análisis devuelve **`OK` con la lista de condiciones vacía** — un verde que no evalúa nada | ✅ Puerta corregida a `SIGRA RNF-20 sin cobertura`, y el script ahora **comprueba que el proyecto exista antes de escanear**. ⚠️ Pendiente: el nombre sigue siendo `sigra-frontend`; **26.11 no expone API para renombrar** (`/api/projects/rename` y `/update_name` devuelven *Unknown url*), hay que hacerlo en *Project Settings* |

> ⚠️ **Y una consecuencia que hay que saber, porque obligó a reescanear:** SonarQube **solo
> recalcula la puerta al analizar**. Como la puerta se corrigió *después* del primer escaneo,
> `api/qualitygates/project_status` siguió devolviendo la evaluación vieja —`OK` con **cero
> condiciones**— hasta el reescaneo. Durante ese rato, el `OK` del frontend **no era citable**; las
> métricas sí, porque salen del análisis y no de la puerta.
>
> **Resuelto:** reescaneado, la puerta evalúa 4 condiciones y da `OK`. La regla que queda escrita:
> **si tocas la puerta, reescanea antes de citar el veredicto**, y mira siempre cuántas condiciones
> se evaluaron — el script lo imprime y avisa en rojo si son cero.

**Evidencia en disco.** `evidencias/sonar-frontend-2026-11-16-*.json`: `medidas`, `issues` (los 8,
con regla, archivo y línea), `hotspots`, `analisis` y **`puerta-asignada`**, que es el que demuestra
que el proyecto quedó con `SIGRA RNF-20 sin cobertura` y no con la puerta por defecto.

### 4.9 Camino permanente: SonarCloud en el CI — es un pedido, no una tarea

| | |
| --- | --- |
| **Por qué SonarCloud** | Gratuito en repositorios públicos, y los dos lo son (`gh repo view` → `"visibility":"PUBLIC"`). Corre en cada PR, así que **sí muerde** |
| **Qué hace falta** | Que un admin cree los dos proyectos y agregue `SONAR_TOKEN` a los secretos de Actions |
| **Quién** | Juan Camilo / Jean Paul. Andrés tiene `push`, **no `admin`** |
| **Cómo pedirlo** | **En el mismo mensaje que las variables de SCA de [H-01](../A4-hallazgos-rnf.md)**: es la misma pantalla de *Settings*, y H-01 lleva nueve días pedido. Dos pedidos separados se atienden peor que uno |

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
