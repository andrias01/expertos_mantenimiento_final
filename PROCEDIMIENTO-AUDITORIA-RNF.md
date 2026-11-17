# Procedimiento de auditoría de RNF — paso a paso

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Qué es** | El guion operativo para auditar los 23 criterios de RNF. Qué comando correr, **qué mirar exactamente** y cuál es el veredicto |
| **Primera ejecución completa** | 16 de noviembre de 2026 |
| **Entorno** | `herramientas-rnf/` levantado · backend de medición en `127.0.0.1:8081` |
| **Regla que manda** | Si la casilla de evidencia está vacía, el veredicto **no puede ser verde** |

> **Cómo usar este documento.** Cada paso tiene cuatro partes fijas: **comando**, **qué mirar**,
> **umbral del SRS** y **veredicto**. Los «valor obtenido el 16-nov» son referencia: si tu número
> se parece, vas bien; si se aleja mucho, algo cambió y hay que investigar antes de anotar.
>
> **La regla de oro de este rol:** antes de escribir «RNF-XX no cumple», abre el SRS y lee el
> enunciado. Si el enunciado no dice lo que estás a punto de afirmar, lo que encontraste es real
> pero **no es un incumplimiento de RNF**: va al registro de errores del equipo. Ya nos pasó tres
> veces (H-06, H-10, y las que ahora son OBS-01 y OBS-02).

---

## Paso 0 · Preparar y anotar el punto de partida (5 min)

Sin esto, ninguna cifra es verificable por otra persona.

```powershell
powershell -ExecutionPolicy Bypass -File "mantenimiento-rnf\herramientas-rnf\levantar.ps1"
```

Y **anota los SHA**, porque una cifra sin SHA no la puede reproducir nadie:

```powershell
git -C software4-SIGRA-backend rev-parse --short origin/develop
git -C software4-SIGRA-frontend rev-parse --short origin/develop
```

**Qué mirar:**

| Comprobación | Valor esperado |
| --- | --- |
| Tablas en el schema `sigra` | **20** (si dice 19, falta la migración RF19 — ver ERR-022) |
| Usuarios sembrados | **4** |
| `http://localhost:9000/api/system/status` | `{"status":"UP"}` |
| `http://127.0.0.1:8081/actuator/health` | `{"status":"UP"}` |

> ⚠️ **El error que hay que no cometer:** medir contra el backend del puerto **8080**. Ese apunta a
> Supabase, la misma base que usa Render. Cargarlo con 20 usuarios es una prueba de carga en
> producción. **Siempre `8081`.**

---

## Paso 1 · Rendimiento con 20 usuarios — RNF-01, 03, 04, 06 (15 min)

Esta es la parte que no se había podido hacer nunca, y la que dio el hallazgo más importante.

### 1.1 Corrida de carga

Todo en una línea, desde `mantenimiento-rnf`:

```powershell
..\apache-jmeter-5.6.3\bin\jmeter.bat -n -t jmeter\RNF-01-06-rendimiento.jmx -l jmeter\resultados\rnf01-06-local.jtl -e -o jmeter\resultados\rnf01-06-local-reporte -Jhost=127.0.0.1 -Jpuerto=8081 -Jprotocol=http -Jusuarios=20 -Jrampa=20 -Jiteraciones=5 -Jcorreo=admin.bruno@uco.net.co -Jclave=PasswordSeguro123*
```

Tarda ~1 minuto. Genera 400 muestras.

### 1.2 Corrida de control — **no te la saltes**

Es la que distingue «el sistema es lento» de «el sistema es lento cuando los logins se solapan».
Misma orden, con `-Jiteraciones=1` y sin informe:

```powershell
..\apache-jmeter-5.6.3\bin\jmeter.bat -n -t jmeter\RNF-01-06-rendimiento.jmx -l jmeter\resultados\rnf01-control.jtl -Jhost=127.0.0.1 -Jpuerto=8081 -Jprotocol=http -Jusuarios=20 -Jrampa=20 -Jiteraciones=1 -Jcorreo=admin.bruno@uco.net.co -Jclave=PasswordSeguro123*
```

Con 1 iteración y rampa de 20 s, los 20 logins se reparten a ~1 por segundo: **no se solapan**.
Con 5 iteraciones, los usuarios vuelven a entrar en bucle y **sí se solapan**.

### 1.3 Qué mirar, exactamente

Abre `jmeter\resultados\rnf01-06-local-reporte\index.html`, tabla **Statistics**. Mira **tres
columnas y nada más**:

| Columna | Para qué |
| --- | --- |
| **`95th pct`** | Es la cifra que el SRS pide para RNF-03, 04 y 05. **No uses `Average`** |
| **`90th pct`** | Solo para RNF-06: el SRS pide 90 %, no 95 % |
| **`Error %`** | Incluye las muestras que se pasaron del umbral, porque el plan lleva *Duration Assertion* |

### 1.4 Umbrales del SRS y veredicto

| Petición | RNF | Umbral | Escalonado 09:17 | Solapado 09:15 (máquina cargada) | **Solapado 16:00 (máquina libre)** | Veredicto |
| --- | --- | --- | --- | --- | --- | --- |
| `POST /auth/login` | RNF-03 | 95 % < **4 000 ms** | p95 **546 ms** ✅ | p95 **5 493 ms** ❌ | p95 **1 035 ms** ✅ | 🟡 **no reproducible** |
| `GET /profesores` | RNF-04 | 95 % < **3 000 ms** | p95 29 ms | p95 **1 394 ms** | p95 29,8 ms | 🟢 cumple siempre |
| `GET /asignaturas` | RNF-04 | 95 % < **3 000 ms** | p95 23 ms | p95 **1 108 ms** | p95 24,9 ms | 🟢 cumple siempre |
| `GET /niveles-logro` | RNF-06 | 90 % < **5 000 ms** | p90 17 ms | p90 **42 ms** | p90 13 ms | 🟢 cumple siempre |

> ⚠️ **Las dos columnas de «solapado» son la misma prueba**, con los mismos parámetros
> (`usuarios=20 rampa=20 iteraciones=5`, mismo usuario, mismo puerto), separadas por seis horas y
> por el estado de la máquina. Dan veredictos opuestos sobre RNF-03. **Por eso el veredicto de esa
> fila es amarillo y no rojo:** no tenemos el dato. Ver [A6 §3.4](A6-semaforo-rnf.md).

**RNF-01** (20 usuarios concurrentes) se verifica por el hecho de que la corrida completó 400
muestras con los 20 hilos activos y **ningún error de conexión**: todos los códigos fueron `200`.
En la corrida de las 16:00, **84 de las 400 muestras** se tomaron con los 20 hilos vivos a la vez
(columna `allThreads` del `.jtl`). El sistema aguanta 20 usuarios; si aguanta además los tiempos
de RNF-03 mientras lo hace es justamente lo que está en revisión.

### 1.5 El hallazgo, y cómo explicarlo sin exagerar

Con la máquina cargada, el login pasa de **546 ms a 5 493 ms** —factor diez— cuando los logins se
solapan, y arrastra al resto: `GET /profesores` pasa de 29 ms a 1 394 ms sin que ese endpoint haya
cambiado. **Con la máquina libre, la misma prueba da p95 de 1 035 ms y cero incumplimientos.** Las
dos cosas son ciertas, y la segunda obliga a enunciar el hallazgo con cuidado: lo que está medido
es que **el login es la única operación que se degrada cuando falta CPU**, no cuánto se degrada en
un entorno representativo.

**La causa está identificada y no es un misterio:** `SecurityConfig.java:39` declara
`new BCryptPasswordEncoder(12)`. Factor 12 son 4 096 rondas de hash, ~300-500 ms de CPU **por
login**. Con 20 logins simultáneos, la CPU se satura y todo lo demás espera detrás.

**Y aquí está lo importante para nuestro rol: el factor 12 no es un error, lo exige el SRS.**
RNF-10 pide «BCrypt con factor de trabajo mínimo 12». Así que esto es una **tensión entre dos
requisitos del propio SRS**, medida y reproducible:

- **RNF-10** exige el coste que hace lento el login.
- **RNF-01 + RNF-03** exigen que 20 usuarios concurrentes entren en menos de 4 s.

Está registrado como **[H-17](A4-hallazgos-rnf.md)**. No se propone bajar el factor de BCrypt: eso
sería incumplir RNF-10 para cumplir RNF-03.

**Las reservas que hay que declarar, siempre:**

1. Medido en un portátil con **12 CPU** y seis contenedores encima. En un servidor dedicado el
   número sería mejor. **No afirmar que producción se comporta así.**
2. El perfil de 5 iteraciones hace que cada usuario **vuelva a autenticarse** cada pocos segundos.
   Un usuario real entra una vez por sesión. El perfil es más agresivo que la realidad, **y hay que
   decirlo**.
3. Lo que la medición sí demuestra: **con llegada simultánea sostenida y la CPU disputada, el
   umbral de RNF-03 no se cumple**, y la causa es conocida.
4. **La reserva nº 1 resultó ser la dominante.** Repetida la misma corrida con la máquina libre,
   RNF-03 cumple. **Antes de reportar cualquier número de carga: tres corridas con la máquina en
   el mismo estado, anotando `docker ps`, y se reporta la mediana.** Una sola corrida no es una
   medición.

---

## Paso 2 · Disponibilidad — RNF-18 (5 min para montar, 24 h para el dato)

### 2.1 Uptime real

`http://localhost:3001` → *Add New Monitor* → tipo **HTTP(s)** → URL
`https://software4-sigra-backend.onrender.com/actuator/health` → intervalo **60** s.

**Qué mirar, al día siguiente:** el porcentaje de **Uptime 24h** que muestra la tarjeta del
monitor, y el número de incidentes.

| Umbral del SRS | Veredicto |
| --- | --- |
| Uptime ≥ **95 %** | 🟢 si el porcentaje de 24 h o más lo supera |

**La reserva obligatoria:** Kuma mide **desde tu portátil**. Si se suspende, el hueco cuenta como
caída y el dato sale sesgado **a la baja**. Anota siempre la ventana real junto al porcentaje.

### 2.2 Sonda puntual, si necesitas un dato hoy

```powershell
..\apache-jmeter-5.6.3\bin\jmeter.bat -n -t jmeter\RNF-18-disponibilidad.jmx -l jmeter\resultados\rnf18-render.jtl -e -o jmeter\resultados\rnf18-render-reporte -Jmuestras=90 -Jpausa=2000
```

**Qué mirar:** `Error %` = 0 y todos los códigos `200`.
**Valor del 15-nov:** 90/90 muestras, p95 526 ms, ventana de 208 s.
**Veredicto:** 🟡 **y punto.** Tres minutos y medio **no demuestran** «uptime ≥ 95 %» de un periodo
de operación. Escribir «uptime del 100 %» con esta evidencia es inflar el dato, y el §10 del manual
lo prohíbe explícitamente.

### 2.3 MTTR

**No hay comando.** El MTTR ≤ 4 h se mide sobre el registro de un incidente real: cuánto pasó entre
la detección y el restablecimiento. No ha habido ninguna caída crítica.

**Veredicto honesto: 🔴 «sin evento que medir»**, que no es «cumple» ni «no cumple». Es la decisión
D-3 para el Product Owner.

---

## Paso 3 · Seguridad en TLS — RNF-11 (5 min)

```powershell
$h = "https://software4-sigra-backend.onrender.com/actuator/health"
curl.exe -s -o NUL -w "base: %{http_code} %{http_version}`n" $h
curl.exe -s -o NUL --tlsv1.2 --tls-max 1.2 -w "TLS1.2: %{http_code}`n" $h
curl.exe -s -o NUL --tlsv1.3 -w "TLS1.3: %{http_code}`n" $h
curl.exe -s -o NUL --tlsv1.0 --tls-max 1.0 -w "TLS1.0: %{http_code}`n" $h
curl.exe -s -o NUL -w "HTTP: %{http_code} -> %{redirect_url}`n" "http://software4-sigra-backend.onrender.com/actuator/health"
```

Repite lo mismo cambiando `$h` por `https://sigra.vercel.app/login`.

**Qué mirar, las cuatro condiciones:**

| Condición | Esperado | Backend (16-nov) | Frontend (16-nov) |
| --- | --- | --- | --- |
| Sirve por HTTPS | `200` | ✅ 200, HTTP/2 | ✅ 200, HTTP/2 |
| TLS 1.2 aceptado | `200` | ✅ | ✅ |
| TLS 1.3 aceptado | `200` | ✅ | ✅ |
| **TLS 1.0 rechazado** | `000`, exit **35** | ✅ | ✅ |
| HTTP redirige | `301` o `308` | ✅ 301 | ✅ 308 |

**Veredicto: 🟢 cumple de punta a punta.** Es el único RNF verificado en el entorno real que el
propio requisito nombra, sin criterio sustituto.

> **Ojo con el falso verde.** Que `https://` responda 200 **no** es suficiente: hay que comprobar
> que **1.0 falla**. Un servidor que acepta TLS 1.0 responde 200 igual y estarías firmando un
> cumplimiento falso.

---

## Paso 4 · Mantenibilidad — RNF-20 (a) y H-05 (30 min)

### 4.1 Cobertura de los cuatro módulos obligatorios

Desde `software4-SIGRA-backend\SIGRA`:

```powershell
.\gradlew test jacocoTestReport jacocoTestCoverageVerification
```

**Qué mirar:** que termine en **`BUILD SUCCESSFUL`**. La regla por paquete está en
`build.gradle:111-119` y vigila los cuatro módulos que el SRS nombra.

**Y la comprobación que de verdad importa**, porque «pasa» no demuestra que vigile: sube el umbral
de esa regla a `0.99` temporalmente y confirma que **falla nombrando** los paquetes:

```
Rule violated for package co.edu.uco.sigra.estadisticas.service.impl: ... is 0.93
Rule violated for package co.edu.uco.sigra.estadisticas.service:      ... is 0.96
```

Devuelve el umbral a `0.7` después. Si al subirlo **no** nombra `estadisticas`, la regla no lo está
vigilando y RNF-20 (a) vuelve a estar incumplido.

| Módulo del SRS | Paquete | Umbral | Valor 16-nov |
| --- | --- | --- | --- |
| Global | — | ≥ 70 % | **92,39 %** |
| RF-04 | `auth.service` / `.impl` / `auth.controller` | ≥ 70 % | 92,14 / 100 / 100 % |
| RF-05 | `auth.security` / `config` | ≥ 70 % | 74,47 / 96,21 % |
| RF-14 y RF-16 | `estadisticas.service` / `.impl` | ≥ 70 % | **96,48 / 93,69 %** |

**Veredicto: 🟢 cumple**, integrado en `develop` (`bb72c07`, PR #117).

### 4.2 OpenAPI — RNF-20 (b)

```powershell
.\gradlew integrationTest --tests '*ApiDocumentacionIT'
```

**Qué mirar:** las **10** clases `*ApiDocumentacionIT` en verde. Un endpoint protegido nuevo sin sus
códigos 200/400/401/403/404 documentados debe hacer fallar la prueba de su módulo.

### 4.3 SonarQube

> Reescrito el 16 de noviembre, después de montarlo de verdad. **La versión anterior de este paso
> decía `admin` / `admin` y eso ya no funciona** — ver el aviso de más abajo.

**Un solo comando**, desde cualquier carpeta:

```powershell
powershell -ExecutionPolicy Bypass -File "mantenimiento-rnf\herramientas-rnf\escanear-sonar.ps1" -Proyecto ambos -Token "squ_..." -Version "<id del mantenimiento o la fecha>"
```

Escanea, imprime el veredicto y **deja la evidencia en `herramientas-rnf/evidencias/`**. La primera
vez, agrega `-Configurar`: crea los proyectos y las puertas de calidad. Detalle de cada paso en
[`herramientas-rnf/README.md` §4](herramientas-rnf/README.md).

> ⚠️ **`admin / admin` no sirve, y no es un olvido.** Al montar la instancia funcionó unos minutos
> y después empezó a responder **401**; cambiarle la contraseña devuelve `old_password_incorrect`.
> SonarQube invalida la contraseña por defecto tras el primer uso y **la cuenta `admin` quedó
> inaccesible**. Se usa el usuario `rnf`, miembro de `sonar-administrators` — credenciales en
> [`herramientas-rnf/README.md` §4.1](herramientas-rnf/README.md). Son de una instancia local y
> desechable.

**El token** se genera en *My Account → Security → Generate Token*, tipo **User Token**. SonarQube
**no lo vuelve a mostrar**, así que anótalo donde lo vayas a usar. **No va al repositorio**: el
script lo toma de `-Token` o de `$env:SONAR_TOKEN`. Si `api/user_tokens/search` te devuelve la lista
vacía, el token de la auditoría anterior ya no existe y hay que generar otro.

**Siempre con `-Version`.** Es lo que convierte el escaneo en instrumento de mantenimiento y no en
una foto: sin él, todos los análisis quedan como `projectVersion: "not provided"` y la pestaña
*New Code* —la que responde «¿este mantenimiento degradó algo?»— queda vacía. Ver
[A3 §7.3](A3-criterios-verificacion.md).

**Qué mirar en el tablero**, cinco cosas y en este orden:

| Métrica | Qué significa | Qué anotar |
| --- | --- | --- |
| **Quality Gate** | El veredicto de una ojeada | `Passed` o `Failed` |
| **Maintainability rating** | A–E. Es el dato de RNF-20 que JaCoCo no da | La letra |
| **Technical debt** | Tiempo estimado de arreglo | Minutos, horas o días |
| **Bugs** de severidad `blocker` y `critical` | Defectos probables | Cuántos de cada severidad |
| **Security hotspots** | Puntos a revisar a mano, **no** vulnerabilidades confirmadas | Cuántos, y **no los llames vulnerabilidades** |

> **No conviertas un *code smell* en hallazgo de RNF.** El SRS no exige una calificación de Sonar.
> Sonar **sostiene** el veredicto de mantenibilidad; no lo define. Si Sonar da C, eso es insumo
> para la retrospectiva, no un incumplimiento del §13.

> ⚠️ **Y la frase que no se puede escribir.** «Cero vulnerabilidades» a secas, citando Sonar, es
> falso: el escáner registra `Dependency analysis skipped`. Esa pregunta la contesta el **paso 5**,
> y el 16-nov contestó **4 CRITICAL y 10 HIGH**. Las dos cifras van juntas o ninguna.

---

## Paso 5 · Dependencias — H-01 (30 min la primera vez)

Dos caminos. **No necesitas permiso de administrador para ninguno**: el plugin ya está aplicado en
`build.gradle:5`.

```powershell
# Camino A: el que el proyecto ya tiene configurado (failBuildOnCVSS = 4.0)
cd software4-SIGRA-backend\SIGRA
.\gradlew dependencyCheckAnalyze
```

La primera vez descarga la base del NVD y es lento. Si se eterniza, el camino B trae su propia base.

**Camino B: Trivy sobre la imagen.** Es el que conviene, y no por comodidad: la imagen contiene el
jar con **las dependencias que realmente se ejecutan**, mientras que escanear el árbol de archivos
analiza también lo que haya quedado en la caché de Gradle.

```powershell
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --scanners vuln --severity HIGH,CRITICAL --quiet sigra-backend:local
```

> **Dos formas de invocar Trivy que NO funcionan, comprobadas el 16-nov:**
>
> 1. **Desde Git Bash.** MSYS traduce `/src` a `C:/Program Files/Git/src` y falla con
>    `lstat C:/Program Files/Git/src: no such file or directory`. **Usa PowerShell**, o prefija
>    `MSYS_NO_PATHCONV=1`.
> 2. **`trivy fs` sobre la carpeta del backend sin excluir nada.** Se mete en
>    `SIGRA/build/tmp/.cache/expanded/`, intenta analizar los zips que Gradle dejó expandidos y
>    muere con `semaphore acquire: context deadline exceeded`. Si insistes en `fs`, añade
>    `--skip-dirs SIGRA/build --skip-dirs SIGRA/.gradle --skip-dirs SIGRA/bin`.

**Qué mirar:** el número de vulnerabilidades **HIGH** y **CRITICAL**, y de qué dependencia vienen.
Trivy separa los hallazgos del **sistema operativo base** de los de las **librerías Java**: a
nosotros nos interesan los segundos, porque los primeros se arreglan cambiando la imagen base y eso
es decisión de despliegue, no de RNF.

**Umbral del criterio:** cero hallazgos de severidad `moderate` o superior.

**Qué anotar, y es la parte que cambia la conversación:** lleva el informe a la reunión. Eso convierte
H-01 de «llevo nueve días pidiendo las variables» a **«aquí está el resultado del análisis; lo que
falta es que sea una compuerta permanente, y eso sí necesita un admin»**. Son dos cosas distintas y
nos conviene separarlas.

```powershell
# El frontend ya lo audita en cada corrida de CI; para verlo en local:
cd software4-SIGRA-frontend
npm audit --audit-level=high
```

---

## Paso 6 · Rendimiento y accesibilidad del frontend — RNF-08 y RNF-21 (20 min)

Una sola herramienta cubre los dos.

```powershell
npx -y @lhci/cli collect --url=https://sigra.vercel.app/login --numberOfRuns=3
npx -y @lhci/cli assert --preset=lighthouse:recommended
```

**Qué mirar:**

| Métrica de Lighthouse | Requisito | Umbral |
| --- | --- | --- |
| **Largest Contentful Paint** | RNF-08 (páginas < 3 s) | < **3 000 ms** |
| **Performance score** | RNF-08, indicador global | referencia, no umbral del SRS |
| **Accessibility score** y sus auditorías | RNF-21 | las de `color-contrast`, `label` y `aria-*` **en cero violaciones** |

Para fijarlo como compuerta, un `lighthouserc.json` con:

```jsonc
{
  "ci": {
    "assert": {
      "assertions": {
        "categories:accessibility": ["error", {"minScore": 0.9}],
        "largest-contentful-paint": ["error", {"maxNumericValue": 3000}]
      }
    }
  }
}
```

**El tamaño del bundle ya está medido y no hace falta repetirlo:** 356,04 kB sin comprimir y
100,14 kB transferidos, contra un presupuesto de aviso de 500 kB en `angular.json:51-62`. Cumple
con 29 % de margen. **Propuesta: bajar el aviso a 420 kB** para que detecte el crecimiento antes de
que se agote el margen.

> **Cuidado con el *score* de accesibilidad.** Lighthouse puntúa lo **automatizable**. RNF-21 exige
> además **navegación completa por teclado en los formularios de notas y observaciones**, y eso
> ninguna herramienta lo comprueba: hay que recorrerlo a mano con `Tab` y documentar el orden de
> foco. Un 100 en Lighthouse **no** cierra RNF-21.

---

## Paso 7 · Seguridad de aplicación — RNF-14 y RNF-17 (30 min)

> ⚠️ **ZAP es un escaneo activo: envía entradas maliciosas.** **Nunca** lo lances contra
> `sigra.vercel.app` ni contra Render sin autorización escrita del equipo. Contra tu backend de
> **8081** no hay problema: la base es desechable.

```powershell
docker run --rm --network sigra-rnf -v "${PWD}:/zap/wrk" zaproxy/zap-stable zap-baseline.py -t http://sigra-backend-rnf:8081 -r zap-informe.html
```

**Qué mirar:** las alertas de nivel **High** y **Medium**, y cuáles corresponden a qué requisito:

| Alerta de ZAP | Requisito | Lectura |
| --- | --- | --- |
| SQL Injection, XSS | **RNF-14** (validar y sanear) | Si aparece, es hallazgo de RNF con anclaje claro |
| Fugas en mensajes de error | **RNF-17** | Confirma o refuta lo que hoy verificamos por pruebas |
| Cabeceras ausentes (CSP, X-Frame-Options…) | **ninguno** | Es **OBS-02**. El SRS no las exige: va al registro de errores, no al de RNF |

Esa última fila es la trampa de este paso. ZAP grita mucho sobre cabeceras y es tentador anotarlo
como incumplimiento. No lo es.

---

## Paso 8 · Compatibilidad — RNF-19 (15 min)

```powershell
cd software4-SIGRA-frontend
npm run e2e
```

**Qué mirar:** la suite en verde en Chromium **y** Firefox.

**Las tres reservas que hay que declarar siempre, porque el veredicto es 🟡 y no 🟢:**

1. La suite recorre **un solo flujo**: `e2e/auth.spec.ts`. Es el único archivo de `e2e/`.
2. **Edge no se prueba.** Chromium es un sustituto razonable por compartir motor, pero hay que
   decirlo así, no afirmar que Edge está probado.
3. **Móvil no se prueba** automáticamente.

**Y una cuarta que descubrimos el 16-nov y agrava H-03:** el job de E2E del CI **no compila el
backend del PR**: descarga un *release* fijo (`SIGRA_E2E_BACKEND_SHA`, un SHA que no existe
siquiera en el clon). El único flujo de navegador que hay corre contra una versión congelada, **no
contra `develop`**.

Para cubrir Edge, Playwright lo soporta con `channel: 'msedge'`. Es una línea de configuración, y
cerraría una de las tres reservas.

---

## Paso 9 · Verificación funcional en Mantis — nuestro trabajo de F4 (60 min)

**El procedimiento del equipo: no se crean incidencias.** Se revisan las que ya están, y si una
figura como `cerrada` pero no cumple su criterio de aceptación, **se reabre dejando escrito por
qué**.

Nuestra tarea concreta: **verificar las 22 incidencias en `resuelta`** contra su criterio y dejar el
veredicto en cada una. Orden recomendado:

| Orden | Incidencia | Por qué primero |
| --- | --- | --- |
| 1 | **0000040** paginación | Mantis la clasifica **«No Funcionalidad»** y el libro nos asigna «definir y validar los patrones de paginación». Se resolvió sin nuestra validación ([H-12](A4-hallazgos-rnf.md)) |
| 2 | **0000038** buscador | La otra «No Funcionalidad». Lleva 8 días en `asignada` |
| 3 | 0000041 y 0000048 | Son las pantallas de **OBS-01**: hay que dejar la nota ahí, no en un ticket nuevo |
| 4 | 0000029 y 0000030 | Son de José, están implementadas y probadas; solo falta pasar la resolución a `corregida` |
| 5 | El resto de las `resueltas` | Una por una contra su criterio |

**Qué mirar en cada una:** ¿el criterio de aceptación se cumple **en el despliegue**, no solo en el
PR? Y para las nuestras, ¿el patrón quedó documentado para que los módulos nuevos lo sigan?

**Dato de higiene que hay que reportar:** de las 31 incidencias, **ninguna está en `cerrada`** (22
resueltas, 6 nuevas, 3 asignadas). El indicador «% de cambios con trazabilidad completa» es
honestamente **0 %** ([H-13](A4-hallazgos-rnf.md)).

---

## Paso 10 · Cerrar la auditoría (30 min)

En este orden:

1. **Guardar la evidencia.** Cada `.jtl`, cada informe HTML, cada captura. **Sin la salida del
   comando, el veredicto no puede ser verde.**
2. **Actualizar [A6](A6-semaforo-rnf.md)** con el veredicto de cada criterio y su SHA.
3. **Actualizar [A4](A4-hallazgos-rnf.md)** con los hallazgos nuevos. Antes de escribir cada uno,
   aplicar el filtro: *¿el SRS exige esto?* Si no, va al registro de errores del equipo.
4. **Pegar las filas en el libro compartido** desde
   [`registros-equipo-rnf.md`](registros-equipo-rnf.md), confirmando antes los correlativos.
5. **Llevar las decisiones pendientes a la reunión.** Un rojo sin decisión escrita es un criterio de
   finalización del §13 incumplido, y nos lo cobran a nosotros.

### Lista de comprobación de la auditoría

- [ ] SHA del backend y del frontend anotados junto a cada cifra
- [ ] Carga **y control** de JMeter corridas (sin la de control no se puede explicar el hallazgo)
- [ ] Uptime Kuma lleva **más de 24 h** encendido
- [ ] TLS comprobado en los **dos** despliegues, incluido que **1.0 falle**
- [ ] Cobertura verificada **y** probado que la regla muerde al subir el umbral
- [ ] Sonar escaneado **con `-Version`**, la calificación anotada y **la evidencia bajada a
      `herramientas-rnf/evidencias/`** (el tablero vive en un volumen de Docker; no es evidencia citable)
- [ ] Informe de dependencias generado
- [ ] Lighthouse corrido, y el recorrido por **teclado** hecho a mano
- [ ] ZAP **solo** contra 8081
- [ ] Las 22 incidencias `resueltas` revisadas una por una
- [ ] Cada hallazgo nuevo pasó el filtro «¿lo exige el SRS?»
- [ ] Toda reserva escrita con sus palabras, no omitida

---

## Resumen: qué mirar en una página

| # | Criterio | Comando | Qué mirar | Umbral |
| --- | --- | --- | --- | --- |
| 1 | RNF-01 | JMeter, `-Jusuarios=20` | 400 muestras sin errores de conexión | 20 concurrentes |
| 2 | **RNF-03** | JMeter | `95th pct` del login | **< 4 000 ms** → 🟡 **5 493 ms o 1 035 ms según la carga de la máquina; sin repetir, no hay dato** |
| 3 | RNF-04 | JMeter | `95th pct` de profesores y asignaturas | < 3 000 ms → 🟢 |
| 4 | RNF-06 | JMeter | **`90th pct`** de niveles-logro | < 5 000 ms → 🟢 |
| 5 | RNF-08 | Lighthouse + `ng build` | LCP y bundle inicial | < 3 000 ms · < 500 kB → 🟢 356 kB |
| 6 | RNF-10 | login real | que la respuesta **no** traiga contraseña ni hash | cero → 🟢 |
| 7 | RNF-11 | `curl` con `--tlsv1.X` | que **1.0 falle** y HTTP redirija | 🟢 los dos lados |
| 8 | RNF-14 | ZAP contra 8081 | alertas de SQLi y XSS | cero |
| 9 | RNF-15 | login real | `expiraEn` | = 3 600 s → 🟢 |
| 10 | RNF-16 | consulta a `historial_auditoria` | que haya `LOGIN_FALLIDO` **y** `LOGIN_EXITOSO` | ambos → 🟢 |
| 11 | RNF-17 | ZAP + pruebas de contrato | que los errores no filtren nada | 🟢 |
| 12 | RNF-18 | Uptime Kuma | % de uptime **y la ventana** | ≥ 95 % → 🟡 |
| 13 | RNF-19 | `npm run e2e` | verde en Chromium y Firefox, con 4 reservas | 🟡 |
| 14 | RNF-20a | `jacocoTestCoverageVerification` | `BUILD SUCCESSFUL` + que la regla muerda | ≥ 70 % → 🟢 |
| 15 | RNF-20b | `*ApiDocumentacionIT` | las 10 clases en verde | 🟢 |
| 16 | RNF-21 | Lighthouse + **teclado a mano** | contraste, labels, orden de foco | 🟡 |
| 17 | H-01 | `dependencyCheckAnalyze` o Trivy | HIGH y CRITICAL | cero |
| 18 | H-05 | SonarQube (`escanear-sonar.ps1`) | calificación de mantenibilidad, **los dos repositorios** | A o B |

---

[Guía del rol](GUIA-TRABAJO-RNF.md) · [A3 Criterios](A3-criterios-verificacion.md) · [A4 Hallazgos](A4-hallazgos-rnf.md) · [A6 Semáforo](A6-semaforo-rnf.md) · [Herramientas](herramientas-rnf/README.md) · [JMeter](jmeter/README.md)
