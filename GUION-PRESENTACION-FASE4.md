# Guion de presentación · Fase 4 — Revisión de calidad y requisitos no funcionales

**Proyecto de Mantenimiento de Software · SIGRA**
Andrés Felipe Vélez Alcaraz · José Alejandro Valencia — Especialistas en requisitos no funcionales

| | |
| --- | --- |
| **Duración** | 15 minutos, dos presentadores |
| **Qué nos toca** | Fase 4: explicar si los cambios **afectaron o mejoraron** seguridad, rendimiento, disponibilidad, compatibilidad, usabilidad/accesibilidad y mantenibilidad |
| **La frase del enunciado que nos salva** | *«No todos los cambios afectan todos estos atributos.»* Decir «este atributo no se vio afectado, y por esto» **también es un resultado** |
| **La prueba final** | Si alguien señala un RNF al azar y pregunta «¿cómo saben que se cumple?», respondemos con **un comando, una prueba o un archivo**. Si la respuesta es «lo revisamos», no está verificado |

---

## Mapa de 15 minutos

| Min | Bloque | Quién habla | Qué se muestra |
| --- | --- | --- | --- |
| 0:00 – 1:30 | **1.** Cómo encontramos el software | Andrés | Dos repos + los dos despliegues vivos |
| 1:30 – 4:00 | **2.** Las incidencias y qué RNF tocan | José (seguridad) · Andrés (resto) | Las **3 imágenes** de tableros |
| 4:00 – 6:30 | **3.** Qué encontramos durante los desarrollos | Ambos | A4 · Hallazgos |
| 6:30 – 11:30 | **4.** Ejecución en vivo: desplegado + local | Ambos, alternando | 8 demos cortas |
| 11:30 – 13:30 | **5.** Semáforo y conclusiones | Ambos | A6 · Semáforo |
| 13:30 – 15:00 | **6.** Cierre y preguntas | Ambos | — |

> **Regla de oro del tiempo:** si un bloque se pasa, el que se recorta es el **4**, nunca el **5**.
> Las conclusiones son lo que nos califican.

---

# PARTE 0 · Preparación — empezar **30 minutos antes**

No es opcional. Docker Desktop está apagado y SonarQube tarda en arrancar.

### 0.1 Encender todo (10 min, se hace solo)

```powershell
# 1. Abrir Docker Desktop a mano y ESPERAR a que diga "Engine running"

# 2. Levantar PostgreSQL aislado + SonarQube + Uptime Kuma
powershell -ExecutionPolicy Bypass -File "E:\Card SK hynix 2TB\Documents\Escritorio Documentos\Semestre 9\Software 4\Trabajo\SIGRA\repositorio\mantenimiento-rnf\herramientas-rnf\levantar.ps1"
```

**Qué tiene que decir al final:**

```
Tablas en el schema sigra : 20     <- si dice 19, falta la migración RF19 (ERR-022)
Usuarios sembrados        : 4
```

> ⚠️ El script avisa que `seed-asignaturas-roles.sql` **falla**. Es normal y está documentado
> (ERR-021). No afecta a nada de lo que vamos a mostrar.

### 0.2 Levantar el backend de medición en el puerto 8081

Todo en **una sola línea**:

```powershell
docker run -d --name sigra-backend-rnf --network sigra-rnf -p 8081:8081 -e DB_URL="jdbc:postgresql://sigra-pg-rnf:5432/postgres?currentSchema=sigra" -e DB_USERNAME=postgres -e DB_PASSWORD=rnf_local_solo_pruebas -e JWT_SECRET=rnf_local_jwt_secret_con_al_menos_32_chars_x -e JWT_EXPIRATION_MS=3600000 -e SERVER_PORT=8081 -e JPA_DDL_AUTO=validate -e CORS_ALLOWED_ORIGINS="http://localhost:4200,http://127.0.0.1:4200" sigra-backend:local
```

Si ya existe del día anterior: `docker start sigra-backend-rnf`.
Si quedó roto: `docker rm -f sigra-backend-rnf` y volver a lanzarlo.

Espera ~20 segundos y comprueba:

```powershell
Invoke-WebRequest http://127.0.0.1:8081/actuator/health -UseBasicParsing
```

### 0.3 Despertar los despliegues (Render se duerme en el plan gratuito)

```powershell
curl.exe -s -o NUL -w "Render:  %{http_code} en %{time_total}s`n" https://software4-sigra-backend.onrender.com/actuator/health
curl.exe -s -o NUL -w "Vercel:  %{http_code} en %{time_total}s`n" https://sigra.vercel.app/login
```

Si Render tarda 40-60 s la primera vez, **es el arranque en frío, no una caída**. Vuelve a
lanzarlo y ya responde en medio segundo. Hazlo **antes** de presentar, no en vivo.

### 0.4 Pestañas abiertas antes de empezar

| # | Pestaña | Dirección |
| --- | --- | --- |
| 1 | Tablero SonarQube backend | `http://localhost:9000/dashboard?id=sigra-backend` |
| 2 | Tablero SonarQube frontend | `http://localhost:9000/dashboard?id=sigra-frontend` |
| 3 | Uptime Kuma | `http://localhost:3001` |
| 4 | Informe JMeter (corrida buena, 16:00) | `mantenimiento-rnf\jmeter\resultados\rnf01-06-local-2-reporte\index.html` |
| 5 | Informe JMeter (corrida mala, 09:15) | `mantenimiento-rnf\jmeter\resultados\rnf01-06-local-reporte\index.html` |
| 6 | Informe ZAP autenticado | `mantenimiento-rnf\herramientas-rnf\evidencias\zap\zap-api-admin-2026-11-16.html` |
| 7 | Informe Lighthouse Vercel | `...\evidencias\lhci-vercel-login-2026-11-16\sigra_vercel_app-login-2026_11_17_02_27_05.report.html` |
| 8 | Mantis | el tablero del equipo |
| 9 | A6 · Semáforo | `mantenimiento-rnf\A6-semaforo-rnf.md` |
| 10 | Las 3 imágenes | `rendimiento.jpeg` · `seguridad.jpeg` · `accesibillidad_disponibilidad.jpeg` |

> SonarQube: usuario **`rnf`**, contraseña **`SigraRnf2026*`**. `admin/admin` **ya no funciona**
> y no es un olvido: SonarQube invalida la contraseña por defecto tras el primer uso.

### 0.5 Dos terminales de PowerShell abiertas

- **Terminal A** parada en `...\repositorio\mantenimiento-rnf` → para JMeter y consultas a la base.
- **Terminal B** parada donde sea → para los `curl` de TLS.

---

# PARTE 1 · Cómo encontramos el software (0:00 – 1:30) — **Andrés**

### Qué decir, en este orden

**1. Son dos repositorios y ya están en producción.**

> «SIGRA son dos proyectos: un backend en Spring Boot con PostgreSQL, 14 422 líneas, y un
> frontend en Angular, 25 006 líneas. Y lo primero que cambió nuestro trabajo fue descubrir que
> **el producto ya está desplegado**: el backend en Render y el frontend en Vercel. Eso convirtió
> en medibles dos requisitos que el 8 de noviembre habíamos declarado imposibles de comprobar.»

**2. La red de pruebas que ya existía — hay que reconocerla.**

> «El producto no llegó desnudo: tiene **85 clases de prueba unitaria y 33 de integración** en el
> backend, **100 specs** en el frontend, 490 peticiones de Bruno, y una guardia arquitectónica que
> recorre el registro real de Spring y comprueba que ninguna ruta privada quede desprotegida.»

**3. Lo que no había: ni un solo instrumento de medición.**

> «Lo que no encontramos fue **nada con qué medir**. Nueve requisitos de rendimiento sin una
> herramienta de carga. Ningún análisis estático. Ningún monitoreo de disponibilidad. Y el
> análisis de vulnerabilidades de dependencias, apagado.»

**4. El hallazgo incómodo del arranque.**

> «Al intentar levantar el entorno desde el repositorio, el backend **no arranca**: el esquema
> base crea 19 tablas y la aplicación espera 20. Falta una migración que nadie integró. Y eso
> explica algo importante: el equipo entero apunta a la base de Supabase **no por comodidad, sino
> porque la alternativa estaba rota**. Esa base de Supabase es la misma del despliegue. Es decir:
> cualquier prueba de carga local habría sido una prueba de carga **en producción**.»

**5. La base del conteo.**

> «El SRS tiene **21 requisitos no funcionales**, pero nosotros contamos **23 criterios**, porque
> el RNF-18 y el RNF-20 se verifican en dos mitades cada uno.»

**Qué mostrar:** las dos URLs desplegadas abiertas en el navegador. Nada más.

---

# PARTE 2 · Las incidencias y qué RNF tocan (1:30 – 4:00)

Aquí van **las tres imágenes**. Es el corazón de nuestra trazabilidad: conecta el tablero de
Mantis con los requisitos del SRS.

### Entrada (Andrés, 20 segundos)

> «El tablero tiene **31 incidencias**, 18 de esta fase. Nosotros no las arreglamos: nuestro
> trabajo fue preguntarle a cada una **qué atributo de calidad pone en juego**. Y aplicamos un
> filtro estricto: *¿el SRS exige esto?* Si no lo exige, lo que encontramos es real y se reporta,
> **pero no es un incumplimiento de RNF**. Ese filtro nos hizo retirar tres cosas que ya habíamos
> escrito como hallazgos.»

---

## 2.1 · Imagen `rendimiento.jpeg` — RNF-01 a 09 (Andrés, 50 s)

**La idea:** doce incidencias distintas, **un solo patrón**.

> «Mirando las doce juntas, casi todas dicen lo mismo con palabras diferentes: *tablas sin
> paginación*, *500 docentes sin buscador*, *el filtro «todas» no mostraba nada*. Todas son
> **traer la lista completa en cada carga**. Por eso tocan RNF-04 y RNF-08, que son los tiempos
> de respuesta del catálogo y de las páginas.»

Los tres puntos a señalar con el cursor:

| Incidencia | Por qué la señalamos |
| --- | --- |
| **0000053** — los combos fallan «a veces», en todos los roles | Es el perfil exacto de un **defecto de concurrencia**. Severidad mayor y **sin dueño asignado**. Es nuestro hallazgo H-11 |
| **0000052 / 0000025 / 0000028** — faltan datos de prueba, no existe calificaciones | **Sin datos no hay nada que medir.** Es la razón por la que RNF-02, 05 y 07 siguen en rojo: no es que no quisiéramos medirlos |
| **0000041 / 0000048** — el módulo de Reportes y las Estadísticas | Módulo por construir: **el criterio se fija antes**, no después |

---

## 2.2 · Imagen `seguridad.jpeg` — RNF-10 a 17 (**José**, 50 s)

**La idea:** aquí el patrón es **el rastro**.

> «En seguridad las incidencias no piden funciones nuevas: piden que las cosas **dejen huella**.
> La cuenta que no se bloqueaba tras 5 fallos, la asignatura que se quedaba en borrador, la
> modificación que no se podía probar: todas apuntan al RNF-16, que exige auditar **tanto los
> accesos exitosos como los fallidos**.»

Los tres puntos a señalar:

| Incidencia | Por qué la señalamos |
| --- | --- |
| **0000039** — el error mostraba un ID interno de la base | Es **RNF-17** textual: los mensajes de error no pueden filtrar datos internos |
| **0000044 / 0000045 / 0000043** — el profesor veía todos los semestres | Es la **Matriz RBAC** del RNF-13. Alcance de datos por rol |
| **0000026 / 0000035** — se creaba matrícula sin estudiante | Es **RNF-14**: validar y sanear **en el servidor**, no en el formulario. Guarden este, porque es el requisito del que vamos a hablar al final |

---

## 2.3 · Imagen `accesibillidad_disponibilidad.jpeg` — RNF-21 y RNF-18 (Andrés, 40 s)

> «Ocho incidencias de accesibilidad, y casi todas son el mismo problema: **el sistema dice
> algo que la persona no puede interpretar**. Una columna que muestra «0» en vez de una etiqueta,
> resultados listados solo por código, botones que cambian de texto después de la acción. El
> RNF-21 exige WCAG 2.1 AA: contraste 4,5 a 1, etiquetas en todo campo y navegación completa por
> teclado.»

Y el punto que conecta con el resto:

> «La de disponibilidad es **una sola**, la 0000036: programas académicos sin facultad asociada.
> Parece menor, pero **cambia el esquema de la base**, y con la validación estricta que usamos
> el backend puede **no arrancar**. Por eso toca RNF-18.»

---

## 2.4 · El cierre del bloque — hay que decirlo (José, 20 s)

> «Y una cosa que nos corresponde reconocer a nosotros: de las 31 incidencias, Mantis clasifica
> solo **dos** como «No Funcionalidad» —la paginación y el buscador— y son justamente **las dos
> que el equipo nos asignó**. Ninguna de las dos pasó por nuestra validación antes de resolverse.
> Está registrado como hallazgo H-12, contra nosotros mismos.»

---

# PARTE 3 · Qué encontramos durante los desarrollos (4:00 – 6:30)

**La idea que une el bloque:** los primeros hallazgos eran límites **nuestros** para verificar.
Los últimos ya apuntan **al producto**. Ese cambio de etapa es la historia.

### 3.1 Lo que corregimos (Andrés, 30 s)

> «**H-08 era el único incumplimiento del SRS que teníamos documentado.** El RNF-20 exige
> cobertura de pruebas del 70 % en cuatro módulos que el SRS nombra uno por uno, y la verificación
> automática vigilaba **dos de los cuatro**. Se corrigió con cuatro líneas, está integrado en la
> rama de trabajo en el PR #117, y hoy los cuatro módulos están entre 74 % y 100 %, con un global
> de **92,39 %**.»

### 3.2 Lo que no está en nuestras manos (José, 30 s)

> «**H-01: el análisis de vulnerabilidades de dependencias del backend lleva nueve días
> apagado.** Encenderlo son dos variables de configuración del repositorio, y requieren permiso de
> administrador que nosotros no tenemos. Mientras tanto, lo medimos por fuera con Trivy: **4
> vulnerabilidades críticas y 10 altas** en librerías de Java. El dato existe; lo que falta es
> que sea una compuerta automática.»

### 3.3 El hallazgo que nos enseñó el método (Andrés, 45 s)

**Este es el mejor momento de toda la presentación. No lo corras.**

> «El 16 de noviembre hicimos la primera medición de carga de la historia del proyecto, y nos dio
> que el login tardaba **5 493 milisegundos** en el percentil 95, contra un umbral de 4 000. 46 de
> 100 autenticaciones por encima del límite. Lo íbamos a reportar como incumplimiento.
>
> **Repetimos la misma prueba seis horas después, con los parámetros idénticos, y dio 1 035
> milisegundos. Cero incumplimientos.** La diferencia no estaba en el sistema: estaba en que la
> máquina tenía seis contenedores encima.
>
> Así que el veredicto no es verde ni rojo: es **amarillo, "medido, no reproducible"**. Porque
> afirmar que incumple sería tan infundado como afirmar que cumple. **Una sola corrida no es una
> medición.**»

Y entonces el remate, que es lo que de verdad aporta:

> «Pero lo que sí quedó demostrado es la causa, y es interesante: el login es la única operación
> que se degrada cuando falta CPU, y es **porque el SRS lo exige así**. El RNF-10 pide BCrypt con
> factor 12 — eso son 4 096 rondas de cifrado por cada autenticación. **Es una tensión entre dos
> requisitos del propio SRS:** el de seguridad encarece lo que el de rendimiento quiere rápido.
> Y nosotros **no proponemos bajar el factor**: eso sería incumplir un requisito de seguridad
> para cumplir uno de rendimiento. Lo que proponemos es que el Product Owner **declare por
> escrito** que los 20 usuarios concurrentes son usuarios *en sesión*, no autenticando a la vez.»

### 3.4 Lo que encontraron los instrumentos (José, 45 s)

> «Cuando por fin pudimos escanear la API con OWASP ZAP contra el entorno aislado, salieron dos
> cosas que no sabíamos:
>
> **Primera:** nueve endpoints de listado responden **error 500** ante algo tan simple como un
> nombre de parámetro vacío en la URL. 24 casos. El sistema **detecta** que la entrada es
> inválida y aun así responde «error interno» en vez de «petición incorrecta». Eso es el RNF-14:
> validar y sanear la entrada. Es **H-18**.
>
> **Segunda:** un byte nulo en un filtro de texto atraviesa el controlador, el servicio y el
> repositorio, y lo rechaza **PostgreSQL**. Es **H-19**.
>
> Y aquí está el matiz honesto: eso demuestra que **la mitad del requisito sí se cumple** —las
> consultas van parametrizadas, por eso el byte llega como dato y no se ejecuta— pero la otra
> mitad, validar y sanear, **no**.»

### 3.5 Y la evidencia a favor, que vale igual (José, 20 s)

> «El mismo escaneo dejó evidencia **a favor** del producto, y hay que decirla: con 120 reglas
> activas, ZAP recorrió **las 81 operaciones de la API sin token y ninguna devolvió datos** —265
> peticiones, todas rechazadas—. Eso es el RNF-13 verificado **en ejecución**, no solo con pruebas
> unitarias. Y de los 24 errores 500 que provocamos, **ningún cuerpo de respuesta filtró una
> traza, una clase, una consulta SQL ni una ruta interna**. Eso es el RNF-17, confirmado.»

---

# PARTE 4 · Ejecución en vivo (6:30 – 11:30)

> **Dos advertencias que decimos en voz alta antes de empezar**, porque son parte del rigor:
>
> 1. **Nunca lanzamos ZAP contra Render ni contra Vercel.** Es un escaneo activo: inyecta, borra
>    y escribe. Solo va contra nuestro backend local del 8081, cuya base es desechable.
> 2. **Nunca medimos carga contra el puerto 8080.** Ese backend es local, pero su base de datos es
>    **la de producción**. Siempre el **8081**.

---

## DEMO A · RNF-11 · TLS en el **servicio desplegado** (1 min) — **José**

Terminal B. Es la demo más rápida y la más sólida que tenemos.

```powershell
$h = "https://software4-sigra-backend.onrender.com/actuator/health"
curl.exe -s -o NUL -w "base:   %{http_code} HTTP/%{http_version}`n" $h
curl.exe -s -o NUL --tlsv1.2 --tls-max 1.2 -w "TLS1.2: %{http_code}`n" $h
curl.exe -s -o NUL --tlsv1.3 -w "TLS1.3: %{http_code}`n" $h
curl.exe -s -o NUL --tlsv1.0 --tls-max 1.0 -w "TLS1.0: %{http_code}`n" $h
```

**Qué decir mientras corre:**

> «El requisito pide HTTPS con TLS 1.2 o superior. Y aquí está la trampa que hay que evitar: que
> la página responda 200 por HTTPS **no demuestra nada**. Un servidor que acepta TLS 1.0 responde
> 200 igual. Lo que hay que comprobar es que **el 1.0 falle**.»

**Qué tiene que salir:** `TLS1.2: 200`, `TLS1.3: 200`, y **`TLS1.0: 000`** (falla, es lo correcto).

> «**Verde.** Y es el único requisito del SRS que verificamos de punta a punta en el entorno real
> que el propio requisito nombra, sin criterio sustituto. Lo mismo da el frontend en Vercel.»

---

## DEMO B · RNF-18 · Disponibilidad del **servicio desplegado** (40 s) — **José**

Abre **Uptime Kuma** (`http://localhost:3001`) y muestra el monitor del backend de Render.

**Qué decir:**

> «Esto consulta el estado de salud del backend desplegado cada 60 segundos. El umbral del SRS es
> 95 % de disponibilidad.»

**Y ahora la parte que nos distingue — la reserva:**

> «Pero el número va **siempre acompañado de la ventana**. Esto mide **desde este portátil**: si
> el portátil se suspende o pierde red, el hueco se cuenta como caída del servicio y el dato sale
> sesgado **a la baja**. Y la primera medición que tuvimos fue una sonda de **208 segundos** que
> daba 100 %. Escribir «uptime del 100 %» con tres minutos y medio de evidencia **sería inflar el
> dato**, y el manual lo prohíbe explícitamente. Por eso el veredicto es **amarillo**.»

Y el MTTR:

> «La segunda mitad del requisito es el tiempo de recuperación ante una caída crítica, máximo 4
> horas. **No ha habido ninguna caída.** Así que el veredicto honesto es rojo: *«sin evento que
> medir»*, que no es «cumple» ni «no cumple». Es una decisión pendiente del Product Owner.»

---

## DEMO C · RNF-10, 15 y 16 en el **entorno local** (1 min 30) — **José**

Terminal A. Primero la prueba de que de verdad estamos midiendo la base local:

```powershell
# 1. contador de intentos fallidos ANTES
docker exec -e PGPASSWORD=rnf_local_solo_pruebas sigra-pg-rnf psql -U postgres -d postgres -t -A -c "SELECT intentos_fallidos FROM sigra.usuario WHERE correo_institucional='admin.bruno@uco.net.co'"
```

```powershell
# 2. un login con clave INCORRECTA contra 8081 -> debe dar 401
curl.exe -s -o NUL -w "%{http_code}`n" -X POST "http://127.0.0.1:8081/api/v1/auth/login" -H "Content-Type: application/json" -d "{\"correoInstitucional\":\"admin.bruno@uco.net.co\",\"contrasena\":\"clave-mala\"}"
```

```powershell
# 3. contador DESPUÉS: si subió, estamos midiendo la base local y no Supabase
docker exec -e PGPASSWORD=rnf_local_solo_pruebas sigra-pg-rnf psql -U postgres -d postgres -t -A -c "SELECT intentos_fallidos FROM sigra.usuario WHERE correo_institucional='admin.bruno@uco.net.co'"
```

> «El contador sube de 0 a 1. Eso demuestra que este backend habla con **nuestra base aislada** y
> no con la de producción. Sin esta comprobación, cualquier cifra que midiéramos sería sospechosa.»

Ahora el login correcto, que muestra tres requisitos de una vez:

```powershell
curl.exe -s -X POST "http://127.0.0.1:8081/api/v1/auth/login" -H "Content-Type: application/json" -d "{\"correoInstitucional\":\"admin.bruno@uco.net.co\",\"contrasena\":\"PasswordSeguro123*\"}"
```

> «Tres requisitos en una sola respuesta:
> **RNF-10** — la respuesta trae token, tipo, expiración y usuario. **Ningún campo de contraseña
> ni de hash.**
> **RNF-15** — `expiraEn: 3600` segundos. Son 60 minutos exactos, que es el máximo que permite el
> SRS.
> Y el contador de intentos fallidos **vuelve a cero**, que es el RF-04.»

Y el rastro, que es el RNF-16:

```powershell
docker exec -e PGPASSWORD=rnf_local_solo_pruebas sigra-pg-rnf psql -U postgres -d postgres -c "SELECT fecha_hora, rol_usuario, accion FROM sigra.historial_auditoria ORDER BY fecha_hora DESC LIMIT 5"
```

> «Ahí están el `LOGIN_FALLIDO` y el `LOGIN_EXITOSO` que acabamos de generar, con fecha, hora,
> rol y acción. **El RNF-16 exige auditar tanto los exitosos como los fallidos**, y hasta ahora
> solo lo teníamos comprobado con pruebas unitarias. Esto es en ejecución.»

---

## DEMO D · RNF-01, 03, 04, 06 · Carga con 20 usuarios en **local** (1 min) — **Andrés**

> ⚠️ **NO corras JMeter en vivo.** Tarda un minuto, y si la máquina está cargada por el proyector
> y las diez pestañas abiertas, te va a dar el resultado malo y vas a tener que explicarlo a la
> carrera. **Muestra los informes ya generados.** Si alguien pide verlo correr, el comando está
> abajo.

Abre la pestaña 4 (`rnf01-06-local-2-reporte\index.html`) → tabla **Statistics**.

> «Esto son 20 usuarios simultáneos, 400 peticiones. Y hay que mirar **una sola columna**: la del
> **percentil 95**, que es la que pide el SRS. **No el promedio** — el promedio esconde justamente
> lo que el requisito quiere controlar.»

| Petición | Requisito | Umbral | Resultado |
| --- | --- | --- | --- |
| `POST /auth/login` | RNF-03 | 95 % < 4 000 ms | **1 035 ms** ✅ … *y 5 493 ms en la otra corrida* |
| `GET /profesores` | RNF-04 | 95 % < 3 000 ms | **29,8 ms** ✅ |
| `GET /asignaturas` | RNF-04 | 95 % < 3 000 ms | **24,9 ms** ✅ |
| `GET /niveles-logro` | RNF-06 | **90 %** < 5 000 ms | **13 ms** ✅ |

> «Fíjense en que el de estadísticas se mide con el percentil **90**, no el 95, porque el SRS pide
> 90 ahí. Son detalles que, si se pasan por alto, invalidan el veredicto.»

Y ahora abre la pestaña 5 (la corrida de las 09:15) **al lado**:

> «Y esta es la misma prueba, con los mismos parámetros, seis horas antes. El login da **5 493**.
> Las dos son ciertas. Por eso ese requisito está en amarillo y no en verde ni en rojo.»

**El comando, por si lo piden** (desde `mantenimiento-rnf`, todo en una línea; ojo con las
comillas dobles en cada `-J`, sin ellas PowerShell parte la IP en dos argumentos):

```powershell
C:\apache-jmeter-5.6.3\bin\jmeter.bat -n -t jmeter\RNF-01-06-rendimiento.jmx -l jmeter\resultados\demo.jtl -e -o jmeter\resultados\demo-reporte "-Jhost=127.0.0.1" "-Jpuerto=8081" "-Jprotocol=http" "-Jusuarios=20" "-Jrampa=20" "-Jiteraciones=5" "-Jcorreo=admin.bruno@uco.net.co" "-Jclave=PasswordSeguro123*"
```

---

## DEMO E · RNF-20 y mantenibilidad · Tableros de SonarQube (1 min) — **Andrés**

Pestaña 1 (backend) y pestaña 2 (frontend). Se miran **cinco cosas y en este orden**:

| # | Qué mirar | Backend | Frontend |
| --- | --- | --- | --- |
| 1 | **Quality Gate** | `Passed` | `Passed` |
| 2 | **Mantenibilidad** | **A** · deuda 15 min sobre 14 422 líneas | **A** · deuda 65 min sobre 25 006 |
| 3 | Fiabilidad · Seguridad | A · A | A · **B** (un falso positivo comprobado) |
| 4 | Bugs · Hotspots | 0 · 0 | 0 · 0 |
| 5 | Cobertura · Duplicación | 90,5 % · 0,5 % | sin dato · **3,7 %** |

**Qué decir:**

> «Esto es lo que le da a la palabra «mantenibilidad» **un número detrás**. La puerta de calidad
> no es la que viene por defecto: le pusimos **las condiciones del SRS** — cobertura mínima del
> 70 %, que es textual del RNF-20.»

**Y las dos reservas honestas, que son las que nos van a preguntar:**

> «Primera: las letras de fiabilidad y seguridad **no las exige el SRS**. Ese umbral nos lo
> pusimos nosotros, y hay que presentarlo así.
>
> Segunda, y es la importante: **no se puede decir "cero vulnerabilidades" citando este tablero.**
> En el registro del escaneo dice literalmente *«análisis de dependencias omitido»*. Sonar
> contesta *¿el código que escribimos tiene fallos?* — y responde cero. La otra pregunta,
> *¿las librerías que usamos tienen vulnerabilidades conocidas?*, la contesta Trivy, y respondió
> **4 críticas y 10 altas**. Las dos cifras van juntas o no va ninguna.»

Y el dato que dejamos para el próximo mantenimiento:

> «La duplicación del frontend está en **3,7 %** contra 0,5 % del backend. No incumple nada, el
> SRS no fija umbral. Pero es el indicador que el manual asocia al riesgo del código generado con
> IA, y es **la cifra que hay que vigilar** en el próximo mantenimiento.»

---

## DEMO F · RNF-08 y RNF-21 · Lighthouse contra el **servicio desplegado** (40 s) — **Andrés**

Abre la pestaña 7 (informe de Vercel).

> «Lighthouse solo **carga** la página, no la ataca, así que sí se puede correr contra producción.
> Tres corridas por dirección.»

| | Resultado |
| --- | --- |
| **Accesibilidad (RNF-21)** | **1,00 en las seis corridas**: contraste, etiquetas, tabulación, nombres de botón, todo en verde |
| **Tiempo hasta interactivo (RNF-08)** | mediana **1 267 ms** contra un umbral de 3 000 … **pero el peor caso dio 3 439 ms** |

**Las dos reservas:**

> «Sobre el rendimiento: una de las tres corridas se pasó del umbral, por bloqueo de CPU del
> navegador, no del servidor. Por eso es amarillo: **hay que mirar las tres, no la mediana sola**.
>
> Y sobre la accesibilidad, que es más importante: ese 1,00 es de la pantalla de **login**, que es
> la única ruta pública. El RNF-21 exige navegación completa por teclado **en las pantallas de
> notas y observaciones**, y esas están detrás del inicio de sesión y **siguen sin medir**. Un 100
> en Lighthouse **no cierra el requisito**. Por eso el hallazgo H-04 pasa a amarillo, no a
> cerrado.»

---

## DEMO G · RNF-14 · Escaneo activo de la API en **local** (1 min) — **José**

Abre la pestaña 6 (informe ZAP). Y si da tiempo, reprodúcelo en vivo, que es más contundente:

```powershell
# 1. obtener el token
$r = curl.exe -s -X POST "http://127.0.0.1:8081/api/v1/auth/login" -H "Content-Type: application/json" -d "{\"correoInstitucional\":\"admin.bruno@uco.net.co\",\"contrasena\":\"PasswordSeguro123*\"}" | ConvertFrom-Json

# 2. el defecto, en una línea: un nombre de parámetro VACÍO
curl.exe -s -D - -H "Authorization: Bearer $($r.token)" "http://127.0.0.1:8081/api/v1/programas?=&codigo=ing&estado=ACTIVO"
```

> «Esto responde **500 · error interno**. Y no es un caso rebuscado: es un nombre de parámetro
> vacío en la URL. Pasa en **nueve endpoints de listado**, 24 casos distintos. El sistema
> **detecta** que la entrada es inválida —en el registro aparece la excepción— y aun así responde
> «error inesperado del servidor» en vez de «petición incorrecta». El RNF-14 pide validar y
> sanear la entrada: **es el único incumplimiento que demostramos ejecutando**, no inspeccionando.
>
> Y fíjense en el cuerpo de la respuesta: trae la hora, el código y un mensaje genérico. **Ni
> traza, ni clase, ni SQL.** Eso **confirma el RNF-17** en el mismo movimiento.»

> **Si alguien pregunta por qué el informe de ZAP es de ayer y no de hoy:** porque el escaneo
> autenticado **escribe en la base** —dejó 112 facultades basura— y hay que respaldar y restaurar
> antes y después. No es algo que se haga en vivo en una presentación.

---

## DEMO H · H-01 · Dependencias (30 s) — **José**

```powershell
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --scanners vuln --severity HIGH,CRITICAL --quiet sigra-backend:local
```

Si no hay tiempo, muestra el JSON ya guardado en `herramientas-rnf\evidencias\trivy-backend-16nov.json`.

> «**4 críticas y 10 altas**, todas en librerías de Java: Tomcat embebido y la familia Jackson.
> Se arreglan subiendo de versión. Y el dato honesto del frontend es distinto: sus dependencias
> declaradas dan **cero**. Las 19 que aparecen en su imagen son del propio `npm` que trae la
> imagen base de Node, **no son de SIGRA** — presentarlas como vulnerabilidades del proyecto sería
> un error de lectura.»

---

# PARTE 5 · Semáforo y conclusiones (11:30 – 13:30)

Abre la pestaña 9 (A6) o la tabla resumen.

## 5.1 El titular en tres cifras (Andrés, 40 s)

| | 8 de noviembre | **Hoy** |
| --- | --- | --- |
| 🟢 Verificados con evidencia ejecutable | 7 | **11** |
| 🟡 Cumplen con la reserva declarada | 3 | **6** |
| 🔴 Sin veredicto, sin instrumento o incumplido | 13 | **6** |
| | 23 criterios | 23 criterios |

> «Pasamos de 7 verdes a 11 sobre 23 criterios. Pero el movimiento que más nos enorgullece es
> **uno hacia atrás**: el RNF-14 pasó de amarillo a **rojo**. Y no porque el producto empeorara,
> sino porque **le pusimos el instrumento que le faltaba**. Estaba en amarillo con la reserva
> escrita *«sin prueba dedicada de saneamiento»*; hicimos la prueba, y encontró dos defectos.
>
> **Esa es la diferencia entre un semáforo honesto y uno decorativo.**»

Y la regla que lo sostiene:

> «La regla que nos aplicamos desde el día uno: **si la casilla de evidencia está vacía, el
> veredicto no puede ser verde.** Los once verdes tienen detrás una salida de comando
> reproducible, guardada en disco. No una captura de pantalla.»

## 5.2 Por atributo — respondiendo literal a la Fase 4 (José, 40 s)

| Atributo | ¿Los cambios lo afectaron o lo mejoraron? |
| --- | --- |
| **Seguridad** | **Mejoró** en respaldo: 7 de 8 requisitos verdes, y tres de ellos ahora verificados **en ejecución** y no solo con pruebas. **Empeoró el veredicto de RNF-14**, al medirlo por primera vez |
| **Rendimiento** | **Mejoró lo medible**: de cero instrumentos a tres corridas de carga. RNF-04 y RNF-06 pasan a verde con dos órdenes de magnitud de margen. RNF-03 queda en amarillo por **no reproducible** |
| **Disponibilidad** | **Se pudo medir por primera vez**, pero con reserva de ventana. El tiempo de recuperación no tiene ningún evento que medir |
| **Compatibilidad** | **No se vio afectada**. Sigue igual: Chromium y Firefox automatizados, **un solo flujo**. Edge y móvil no se prueban, y hay que decirlo así |
| **Mantenibilidad** | **Mejoró y es demostrable**: se corrigió el único incumplimiento del SRS que teníamos (H-08), y los dos repositorios tienen hoy calificación **A** |
| **Usabilidad y accesibilidad** | **Mejoró en la ruta pública** (1,00 automatizado) y **sigue sin medir** donde el requisito lo exige: notas y observaciones |

## 5.3 Las tres conclusiones (Andrés y José, una cada uno, 40 s)

Son las de la retrospectiva. Decirlas tal cual, son concretas y accionables:

> **1.** «Un registro sin criterio de salida y sin alguien independiente que lo revise **no es un
> control, es un archivo**. Los criterios de RNF funcionan solo cuando son **condición de salida
> de un filtro**.»
>
> **2.** «Participar desde el diagnóstico **sí cambió el resultado**. Los atributos de calidad
> no se pueden agregar al final: los dos requisitos que el equipo nos asignó se resolvieron sin
> nuestra validación, y por eso no pudimos ejercer el filtro.»
>
> **3.** «**Lo que no se puede medir no se verifica.** Los requisitos sin instrumento llegaron al
> cierre sin veredicto, y eso se sabía desde el día cinco. La diferencia entre el 8 y el 17 de
> noviembre no fue trabajo de documentación: fue **montar los instrumentos que faltaban**.»

## 5.4 Lo que queda abierto y hay que declarar (José, 20 s)

> «Y por honestidad, lo que queda vivo para el siguiente equipo:
> — El análisis de dependencias **sigue apagado**, y necesita un permiso de administrador.
> — Tenemos **el indicador, no el control**: SonarQube corre en un portátil, así que nada impide
> integrar un cambio sin escanearlo. Eso solo lo arregla el CI.
> — De las 31 incidencias de Mantis, **ninguna está en estado «cerrada»**. El indicador de
> trazabilidad completa es honestamente **0 %**, y preferimos decirlo así antes que maquillarlo.»

---

# PARTE 6 · Cierre (13:30 – 15:00)

> «Como especialistas en requisitos no funcionales: los requisitos comprometidos por los
> mantenimientos **fueron verificados** con los criterios documentados, y **los que no pudieron
> verificarse están declarados como tales**, con su justificación y su decisión pendiente.
>
> Un informe honesto con rojos declarados vale más que uno en verde que no resiste una pregunta.»

---

# ANEXO 1 · Preguntas que nos van a hacer, y la respuesta

| Pregunta | Respuesta corta |
| --- | --- |
| **«¿Cómo saben que el RNF-XX se cumple?»** | Abre A6, busca la fila, lee el comando y la salida. **Siempre** hay uno. Si el veredicto es amarillo o rojo, di cuál es la reserva, **no la escondas** |
| **«¿Por qué RNF-03 está en amarillo si midieron 1 035 ms?»** | Porque otra corrida idéntica dio 5 493. **No tenemos el dato**, y afirmar el cumplimiento sería tan infundado como afirmar el incumplimiento |
| **«¿Por qué no bajan el factor de BCrypt?»** | Porque el SRS lo exige en el RNF-10. Sería incumplir un requisito de seguridad para cumplir uno de rendimiento. Esa decisión no nos corresponde |
| **«¿Entonces no hay vulnerabilidades?»** | **Cuidado, trampa.** En el código: cero. En las dependencias: **4 críticas y 10 altas**. Son dos preguntas distintas y dos herramientas distintas |
| **«¿El error genérico de las cuatro pantallas no es un incumplimiento?»** | **No.** Ningún requisito del SRS prohíbe un mensaje de error genérico. Es una observación real (OBS-01) y bloquea una medición nuestra, pero **no es un hallazgo de RNF**. Ese filtro lo aplicamos siempre |
| **«¿Por qué montaron una base aparte?»** | Porque el backend local apunta a Supabase, que es **la base del despliegue**. Cargarla con 20 usuarios habría sido una prueba de carga en producción |
| **«¿Por qué ninguna incidencia está cerrada?»** | Es un hallazgo nuestro (H-13). Cerrar exige revisión técnica, pruebas, PR integrado y documentación al día. Mientras no pase, la trazabilidad completa es 0 % |

---

# ANEXO 2 · Si algo falla en vivo

| Síntoma | Qué hacer |
| --- | --- |
| Docker no responde | Abre Docker Desktop y espera a «Engine running». **No lo intentes arreglar en vivo**: pasa a las demos de los servicios desplegados (A y B), que no dependen de Docker |
| SonarQube da 404 o no carga | Tarda 1-2 min en arrancar porque levanta un Elasticsearch dentro. Mientras tanto, muestra los JSON de `herramientas-rnf\evidencias\` |
| Render tarda 50 segundos | Es el arranque en frío del plan gratuito. **Dilo en voz alta**, es una observación válida sobre disponibilidad. Y vuelve a lanzar el comando |
| El backend 8081 no responde | `docker start sigra-backend-rnf`, espera 20 s. Si no, pasa a los informes ya generados |
| JMeter dice `Unknown arg: .0.0.1` | Faltan las **comillas dobles** en los `-J`. PowerShell parte la IP en dos argumentos |
| JMeter no se encuentra | La ruta buena es `C:\apache-jmeter-5.6.3\bin\jmeter.bat`, **no** `..\apache-jmeter-5.6.3\...` |

---

# ANEXO 3 · Las frases que NO se pueden decir

| ❌ No decir | ✅ Decir |
| --- | --- |
| «Cero vulnerabilidades» | «Cero en el código. **4 críticas y 10 altas en las dependencias**» |
| «Uptime del 100 %» | «100 % **en una ventana de X**, medido desde un portátil» |
| «El sistema no cumple el RNF-03» | «Medido tres veces con resultados que se contradicen. **No tenemos el dato**» |
| «Accesibilidad verificada» | «**1,00 en la ruta pública.** Notas y observaciones siguen sin medir» |
| «Probado en Chrome, Edge y Firefox» | «Chromium y Firefox. **Edge no se prueba**; Chromium es un sustituto por compartir motor» |
| «Hay que comunicarse mejor» | Una conclusión concreta y verificable. Ver 5.3 |

---

# ANEXO 4 · Apagar cuando termine

```powershell
docker compose -f "E:\Card SK hynix 2TB\Documents\Escritorio Documentos\Semestre 9\Software 4\Trabajo\SIGRA\repositorio\mantenimiento-rnf\herramientas-rnf\docker-compose.yml" stop
```

Usa `stop`, **no `down -v`**: borrar el volumen se lleva el historial de Uptime Kuma, que es la
evidencia de RNF-18 que se acumula con el tiempo.

---

[A3 Criterios](A3-criterios-verificacion.md) · [A4 Hallazgos](A4-hallazgos-rnf.md) · [A5 Informe](A5-informe-calidad.md) · [A6 Semáforo](A6-semaforo-rnf.md) · [Procedimiento de auditoría](PROCEDIMIENTO-AUDITORIA-RNF.md) · [Herramientas](herramientas-rnf/README.md)
