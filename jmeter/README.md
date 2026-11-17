# JMeter · Instrumentos de medición de RNF

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Creado** | 15 de noviembre de 2026 |
| **Para qué** | Cerrar [H-02](../A4-hallazgos-rnf.md) (nueve RNF de rendimiento sin instrumento) y [H-09](../A4-hallazgos-rnf.md) (RNF-18 sin medición de uptime) |
| **Herramienta** | Apache JMeter 5.6.3 (solo necesita Java; el proyecto ya usa Java 21) |

> **Por qué JMeter y no otra cosa.** Es la herramienta más simple que produce las dos cosas que el
> SRS pide con números: **percentiles de tiempo de respuesta** (RNF-03 a RNF-06) y **concurrencia
> real** (RNF-01, 20 usuarios). No hay que tocar el código del producto para usarla, lo que
> importa porque nuestro rol no aprueba PR.

---

## 1. Instalación (una vez)

JMeter es un zip, no un instalador. No requiere permisos de administrador.

```bash
curl -L -o jmeter.tgz https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.tgz
tar xzf jmeter.tgz
./apache-jmeter-5.6.3/bin/jmeter --version      # debe imprimir 5.6.3
```

Se deja **fuera del repositorio** (pesa ~90 MB). Lo que se versiona son los `.jmx` de esta
carpeta y los resultados en `resultados/`.

---

## 2. Los dos planes y qué RNF cubre cada uno

| Archivo | RNF que mide | Entorno | Riesgo de ejecutarlo |
| --- | --- | --- | --- |
| `RNF-18-disponibilidad.jmx` | **RNF-18** (uptime ≥ 95 %) | **Render** (producción) | Ninguno: un solo hilo, solo `GET /actuator/health`, pausa de 2 s. No es carga. |
| `RNF-01-06-rendimiento.jmx` | **RNF-01** (20 concurrentes), **RNF-03** (< 4 s), **RNF-04** (< 3 s), **RNF-06** (< 5 s) | **Local** | Alto si se apunta a Render o a Supabase: ver la advertencia de abajo. |

### ⚠️ Advertencia que hay que respetar

El `.env` del backend apunta a **Supabase**, que es la **misma base de datos que usa el despliegue
de Render**. Por lo tanto:

- Levantar el backend «en local» con ese `.env` **no es local**: la carga le cae a la base
  compartida del equipo.
- Correr los 20 usuarios contra Render o contra Supabase es, en la práctica, una prueba de carga
  **en producción**, con el equipo trabajando encima.

**Lo correcto:** PostgreSQL local en Docker con el esquema del repositorio, y un `.env` aparte
apuntando a ese PostgreSQL. Instrucciones en la sección 4.

---

## 3. RNF-18 · Disponibilidad (se puede correr ya, contra Render)

```bash
cd mantenimiento-rnf/jmeter
../../apache-jmeter-5.6.3/bin/jmeter -n \
  -t RNF-18-disponibilidad.jmx \
  -l resultados/rnf18-render.jtl \
  -e -o resultados/rnf18-render-reporte \
  -Jmuestras=90 -Jpausa=2000
```

| Propiedad | Para qué | Valor por defecto |
| --- | --- | --- |
| `-Jhost` | Dominio a sondear | `software4-sigra-backend.onrender.com` |
| `-Jprotocol` | `http` o `https` | `https` |
| `-Jmuestras` | Cuántos sondeos | `90` (≈ 3 min con pausa de 2 s) |
| `-Jpausa` | Milisegundos entre sondeos | `2000` |

**Criterio.** `% de muestras con código 200 y cuerpo que contiene `UP`` ≥ 95 %.
**Evidencia.** `resultados/rnf18-render.jtl` (datos crudos) y el informe HTML en
`resultados/rnf18-render-reporte/index.html`.

**Reserva obligatoria en el informe.** Un sondeo de minutos **no demuestra uptime de un periodo
de operación**. Lo que demuestra es que el servicio responde y que existe un instrumento repetible
para medirlo. Decirlo con esas palabras; no escribir «uptime del 100 %» a partir de tres minutos.

**MTTR.** JMeter no lo mide: el MTTR ≤ 4 h se verifica por **registro de incidentes**, no por
herramienta. Mientras no haya una caída real registrada, el veredicto honesto de esa mitad de
RNF-18 es «sin evento que medir», no «cumple».

---

## 4. RNF-01 a RNF-06 · Rendimiento (requiere PostgreSQL local)

### 4.1 Preparar el entorno aislado

```bash
# 1. PostgreSQL local (necesita Docker Desktop abierto)
docker run -d --name sigra-pg-rnf \
  -e POSTGRES_PASSWORD=rnf_local -e POSTGRES_DB=sigra \
  -p 5433:5432 postgres:16

# 2. Cargar el esquema del repositorio
docker exec -i sigra-pg-rnf psql -U postgres -d sigra \
  < software4-SIGRA-backend/docs/db/SIGRA_SCHEMA_CURRENT.sql

# 3. Un .env aparte que NO toca Supabase
cat > software4-SIGRA-backend/SIGRA/.env.rnf <<'FIN'
DB_URL=jdbc:postgresql://127.0.0.1:5433/sigra
DB_USERNAME=postgres
DB_PASSWORD=rnf_local
SERVER_PORT=8080
JWT_SECRET=<el mismo formato que el .env actual, cualquier valor largo>
JWT_EXPIRATION_MS=3600000
FIN

# 4. Levantar el backend contra ese .env
cd software4-SIGRA-backend/SIGRA
DB_URL=jdbc:postgresql://127.0.0.1:5433/sigra DB_USERNAME=postgres DB_PASSWORD=rnf_local \
  JWT_SECRET=<valor> ./gradlew bootRun
```

Se necesita además **un usuario administrador sembrado** en esa base para que el login responda
200. Los seeds de Bruno (`software4-SIGRA-backend/bruno/`) sirven para eso.

### 4.2 Ejecutar (bash)

```bash
cd mantenimiento-rnf/jmeter
../../apache-jmeter-5.6.3/bin/jmeter -n \
  -t RNF-01-06-rendimiento.jmx \
  -l resultados/rnf01-06-local.jtl \
  -e -o resultados/rnf01-06-local-reporte \
  -Jhost=127.0.0.1 -Jpuerto=8080 -Jprotocol=http \
  -Jusuarios=20 -Jrampa=20 -Jiteraciones=5 \
  -Jcorreo=administrador.prueba@uco.net.co \
  -Jclave='<la clave del usuario sembrado>'
```

> **La contraseña nunca va dentro del `.jmx`.** Se pasa con `-Jclave=`. El archivo versionado
> tiene el literal `CAMBIAME` como valor por defecto, justamente para que falle si alguien lo
> corre sin pensar.

### 4.2.1 La misma ejecución desde PowerShell (computadora de Andrés)

El comando de 4.2 está escrito para `bash`. En Windows PowerShell cambia por algo más que las
rutas: **cada propiedad `-J` tiene que ir entre comillas dobles**. Esta es la línea que
efectivamente corre en la máquina de Andrés, con JMeter descomprimido en `C:\apache-jmeter-5.6.3`:

```powershell
cd 'E:\...\SIGRA\repositorio\mantenimiento-rnf'

C:\apache-jmeter-5.6.3\bin\jmeter.bat -n `
  -t jmeter\RNF-01-06-rendimiento.jmx `
  -l jmeter\resultados\rnf01-06-local-2.jtl `
  -e -o jmeter\resultados\rnf01-06-local-2-reporte `
  "-Jhost=127.0.0.1" "-Jpuerto=8081" "-Jprotocol=http" `
  "-Jusuarios=20" "-Jrampa=20" "-Jiteraciones=5" `
  "-Jcorreo=admin.bruno@uco.net.co" `
  "-Jclave=<la clave del usuario sembrado>"
```

> **Las comillas dobles no son estética.** Sin ellas, PowerShell 5.1 parte `-Jhost=127.0.0.1` en
> **dos** argumentos (`-Jhost=127` y `.0.0.1`), porque corta el token después del número, y JMeter
> aborta con `An error occurred: Unknown arg: .0.0.1`. Solo afecta a los valores con puntos como
> la IP; `-Jpuerto=8081` sobrevive por casualidad, no por estar bien escrito. Las comillas
> **simples** tampoco resuelven la clave: son de PowerShell y no llegan al proceso.

Dos cosas de esa máquina que son del entorno, no del plan de pruebas:

| | |
| --- | --- |
| **Puerto 8081** | El backend se levanta en `8081`, no en el `8080` de 4.1; de ahí `-Jpuerto=8081`. Si se usa el `.env.rnf` tal como está en 4.1, el valor correcto es `8080`. |
| **Nombres de salida nuevos en cada corrida** | JMeter **aborta si el `.jtl` ya existe o si el directorio de `-o` no está vacío**. Por eso el sufijo `-2`: hay que cambiar el nombre o borrar la corrida anterior de `resultados/`. |

### 4.3 Umbrales que el plan ya tiene puestos

Son los del SRS, no inventados. Cada petición trae su **Duration Assertion**, así que una muestra
que pase del umbral cuenta como error en el informe:

| Petición | RNF | Umbral del SRS |
| --- | --- | --- |
| `POST /api/v1/auth/login` | RNF-03 | 95 % < **4 s** |
| `GET /api/v1/profesores` | RNF-04 | 95 % < **3 s** |
| `GET /api/v1/asignaturas` | RNF-04 | 95 % < **3 s** |
| `GET /api/v1/niveles-logro` | RNF-06 | 90 % < **5 s** |

`-Jusuarios=20` es **RNF-01** textual: «hasta 20 usuarios registrados de forma concurrente,
cumpliendo los tiempos de RNF-03 a RNF-08».

### 4.4 Cómo se lee el veredicto

En `resultados/<nombre>-reporte/index.html`, tabla *Statistics*:

- Columna **`95th pct`** de cada petición → se compara contra el umbral del RNF. Esa es la cifra
  que el SRS pide, no el promedio.
- Columna **`Error %`** → incluye las muestras que incumplieron la Duration Assertion.
- **`90th pct`** para RNF-06, porque el SRS pide 90 % y no 95 % en estadísticas.
- `#Samples` tiene que dar `usuarios × iteraciones` por petición (100 con el perfil estándar) y
  `4 ×` eso en el `Total`. Si no cuadra, la corrida se cortó y el resto de la tabla no sirve.

> ⚠️ **La tabla APDEX no sirve para el veredicto, y es la trampa más fácil de este informe.**
> Usa los umbrales **por defecto de JMeter** —500 ms tolerable, 1,5 s frustrante—, **no los del
> SRS**. Un login con Apdex 0,790 **no está incumpliendo RNF-03**: se le está midiendo contra
> 500 ms cuando el umbral del SRS es 4 000 ms. Lo mismo con la columna **`Average`**: el SRS
> habla de percentiles, no de promedios. **Solo *Statistics*, y solo las columnas de arriba.**

Las secciones *Errors* y *Top 5 Errors by sampler* vacías, y *Requests Summary* en PASS 100 %,
dicen lo mismo que `Error % = 0`. Son redundantes; no aportan un dato propio.

**La concurrencia de RNF-01 no sale en el informe HTML.** Hay que leerla del `.jtl` crudo,
columna `allThreads`:

```bash
# Máximo de hilos simultáneos alcanzado
awk -F, 'NR>1 && $13>m{m=$13} END{print m}' resultados/<nombre>.jtl
# Cuántas muestras se tomaron con la concurrencia completa
awk -F, 'NR>1 && $13==20{n++} END{print n}' resultados/<nombre>.jtl
```

> Con rampa de 20 s, los primeros hilos terminan antes de que arranquen los últimos, así que la
> concurrencia plena dura una ventana estrecha. Citar **cuántas muestras** se tomaron con los 20
> hilos vivos, no solo que el máximo fue 20.

### 4.5 Una corrida no es una medición

Lo aprendimos el 16 de noviembre por la vía cara: dos corridas con **parámetros idénticos**, a
seis horas de distancia, dieron p95 de login de **5 493 ms** y **1 035 ms**. La diferencia era
cuántos contenedores había encima de la máquina, no el plan de pruebas. El detalle completo está
en [A6 §3.4](../A6-semaforo-rnf.md) y en [H-17](../A4-hallazgos-rnf.md).

**La regla que queda:** antes de reportar un número de carga, **correr la prueba tres veces con la
máquina en el mismo estado** y anotar qué había levantado (`docker ps`). Reportar la mediana de
las tres, no la peor ni la mejor.

### 4.6 Corridas ya ejecutadas

| `.jtl` | Fecha y hora | Perfil | Para qué sirve |
| --- | --- | --- | --- |
| `rnf01-06-local.jtl` | 16-nov 09:15 | 20 hilos · 5 iter. | Corrida de carga **con la máquina cargada** (SonarQube y 5 contenedores más) |
| `rnf01-control.jtl` | 16-nov 09:17 | 20 hilos · **1 iter.** | Control: logins escalonados, para aislar el efecto del solapamiento |
| `rnf01-06-local-2.jtl` | 16-nov 16:00 | 20 hilos · 5 iter. | **Misma prueba que la primera**, con la máquina descargada. La que destapó que el dato no era reproducible |

> **Higiene pendiente.** `mantenimiento-rnf/jmeter.log` guarda la línea
> `Setting JMeter property: clave=…` **en claro**. Es la clave del usuario sembrado de pruebas, la
> misma que está en `seed-roles.sql`, así que no es un secreto real — pero el log viaja con la
> entrega y contradice la regla que este mismo README declara en §4.2. **No versionar `jmeter.log`.**

---

## 5. Lo que estos planes **no** miden, y hay que declararlo

| RNF | Por qué no | Qué se declara |
| --- | --- | --- |
| **RNF-02** (10 en lectura/escritura simultánea) | El plan actual solo lee. Añadir un POST de calificación exige datos sembrados coherentes. | Pendiente, o fuera de alcance justificado |
| **RNF-05** (calificaciones < 3 s) | Igual: necesita evaluación y matrícula sembradas | Pendiente |
| **RNF-07** (50 evaluaciones por asignatura) | Es verificación de volumen, no de carga: se siembra y se repite la medición | Pendiente |
| **RNF-08** (páginas < 3 s) | Es del frontend; JMeter no renderiza. Se mide con el panel de red + el presupuesto de `angular.json` (500 kB) | Instrumento distinto |
| **RNF-09** (sostenido 4 meses) | Fuera de la ventana del proyecto | **Fuera de alcance**, con justificación |
| **RNF-18 MTTR** | No hay caída registrada que medir | «Sin evento que medir» |

---

## 6. Relación con la incidencia 0000053

Mantis tiene abierta la incidencia **0000053** (alta/mayor, 14-nov, **sin asignar**): «falla
intermitente al cargar combos de semestre/asignatura/RA en múltiples módulos, presente en todos
los roles», reproducibilidad *a veces*.

«Intermitente» y «a veces» es exactamente el perfil de un problema que una prueba manual no
reproduce y una prueba de carga sí. `RNF-01-06-rendimiento.jmx` con 20 hilos sobre los endpoints
de catálogo es el instrumento adecuado para intentar reproducirla de forma determinista. Es el
argumento más fuerte que tenemos para que el equipo adopte esta herramienta: no es burocracia de
calidad, es la forma de cazar un defecto abierto que nadie tiene asignado.

---

[Guía del rol](../GUIA-TRABAJO-RNF.md) · [A3 Criterios](../A3-criterios-verificacion.md) · [A4 Hallazgos](../A4-hallazgos-rnf.md) · [A5 Informe](../A5-informe-calidad.md)
