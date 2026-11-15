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

### 4.2 Ejecutar

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
