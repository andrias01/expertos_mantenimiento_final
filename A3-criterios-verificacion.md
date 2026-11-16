# A3 · Criterios de verificación de RNF

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Actividad RACI** | «Verificar requisitos no funcionales» — somos **A/R** |
| **Filtros** | Alimenta **F2** (criterios definidos) y **F4** (pruebas ejecutadas) |
| **Fuente de los enunciados** | SRS de SIGRA, sección «Requisitos no funcionales» |
| **Entrega** | 1 (Día 5), se refina en la 2, se ejecuta para la 3 |

> **La regla.** Un criterio sirve solo si otra persona lo puede ejecutar y obtener el mismo
> veredicto. Cada uno trae **comando**, **umbral** y **evidencia**. Si no se puede ejecutar, no es
> un criterio: es una intención.
>
> **Para F4.** Estos criterios tienen que estar en manos de los analistas de prueba **cuando
> diseñan sus casos**, no cuando ya ejecutaron. Si llegan después, se vuelven trabajo extra y no
> se corren.

---

## 0. Balance, para decirlo de entrada

> **Actualizado el 15 de noviembre de 2026** (Entrega 2, verificación inicial). El semáforo con el
> veredicto y la evidencia de cada criterio está en [A6](A6-semaforo-rnf.md); aquí vive el
> **cómo se ejecuta** cada uno.

Base de 23 criterios: RNF-18 cuenta como dos y RNF-20 también.

| Estado | 8-nov | **15-nov** | Criterios |
| --- | --- | --- | --- |
| 🟢 **Ejecutado, con evidencia** | 7 | **9** | 10, **11**, 12, 13, 15, 16, 17, **20 (a)**, 20 (b) |
| 🟡 **Con reserva declarada** | 3 | **9** | **01**, **03**, **04**, **06**, **08**, 14, **18 uptime**, 19, **21** |
| 🔴 **Sin instrumento o fuera de alcance** | 13 | **5** | 02, 05, 07, 09, 18 MTTR |

**Los tres instrumentos nuevos de esta entrega**, y qué cubre cada uno:

| Instrumento | Estado | Criterios que habilita | Sección |
| --- | --- | --- | --- |
| **`curl` contra el despliegue de Render** | ✅ Ejecutado | RNF-11 (TLS 1.2+) | §1 · RNF-11 |
| **Apache JMeter 5.6.3** | ✅ Un plan ejecutado, uno listo | RNF-18 uptime (ejecutado) · RNF-01, 03, 04, 06 (listos) | §2 y §3 |
| **SonarQube / SonarCloud** | ✅ **Levantado** (local, Docker) | RNF-20 (mantenibilidad, más allá de cobertura) | [§7](#7-seguridad-de-dependencias-y-análisis-estático--transversal) |
| **PostgreSQL aislado** (Docker) | ✅ **Levantado**, con esquema y seeds | Desbloquea RNF-01, 03, 04 y 06 sin cargar la base compartida | [herramientas-rnf](herramientas-rnf/README.md) |
| **Uptime Kuma** (Docker) | ✅ **Levantado** | RNF-18 con ventana de días, no de 208 s | [herramientas-rnf §5](herramientas-rnf/README.md) |
| **OWASP Dependency-Check** | ✅ **Disponible sin permisos** | H-01: el plugin ya está aplicado en `build.gradle:5` | §7.1 |

**De 23 criterios, 9 están verificados con evidencia y 5 no tienen cómo verificarse.** El 8 de
noviembre eran 7 y 13.

---

## 1. Seguridad · RNF-10 a RNF-17 · titular José

### RNF-10 · Contraseñas con BCrypt factor ≥ 12 y salt única · 🟢

| | |
| --- | --- |
| **Criterio** | Ninguna respuesta de la API contiene el campo de contraseña ni el hash. El hash se genera con BCrypt, factor ≥ 12, con salt única por contraseña. En ningún caso se registra en logs. |
| **Comando** | `./gradlew test --tests '*AuthServiceImplTest' --tests '*AuthControllerTest'` |
| **Umbral** | Pruebas en verde. Cero ocurrencias de `$2a$` / `$2b$` en cualquier cuerpo de respuesta. Dos contraseñas iguales producen hashes distintos (salt única). |
| **Evidencia** | Salida del comando en el PR. |
| **Al revisar un PR** | Si agrega un DTO de respuesta que incluya un `Usuario`, confirmar que no arrastre el campo de contraseña por serialización. |

### RNF-11 · HTTPS con TLS 1.2+ en producción · 🟢

> **Cambió el 15 de noviembre de 2026.** Este criterio estaba en 🟠 porque dimos por hecho que no
> había entorno de producción. Sí lo hay, y el criterio pleno se puede ejecutar. Ver
> [H-10](A4-hallazgos-rnf.md), cerrado.

| | |
| --- | --- |
| **Criterio** | El entorno de producción sirve por HTTPS con TLS 1.2 o superior, no acepta versiones anteriores, y no deja tráfico en claro. |
| **Dónde** | `https://software4-sigra-backend.onrender.com` — la URL que el frontend tiene compilada en `src/environments/environment.ts:3` para `production`. Render termina TLS por defecto. |
| **Comando** | las cinco invocaciones de `curl` del bloque de abajo |
| **Umbral** | TLS 1.2 → 200 · TLS 1.3 → 200 · **TLS 1.0 → fallo de handshake** · HTTP → 301 hacia HTTPS |
| **Resultado 15-nov** | 🟢 Los cuatro se cumplen. Detalle en [A6 §3.1](A6-semaforo-rnf.md) |
| **Evidencia** | Salidas de `curl` pegadas en A6 §3.1 y en el hallazgo H-10 |
| **Reserva que queda** | Esto verifica el **backend**. El frontend está en Vercel y hay que medirle lo mismo, pero **su URL de producción no está escrita en ningún archivo de los dos repositorios** (pedido P-08) |
| **Criterio complementario de código** | Ningún archivo del frontend construye una URL `http://` hacia el backend fuera de desarrollo: `grep -rn "http://" software4-SIGRA-frontend/src --include=*.ts \| grep -v environment.development` → cero resultados que apunten al backend |

```bash
H=https://software4-sigra-backend.onrender.com/actuator/health

curl -s -o /dev/null -w "%{http_code} %{http_version}\n" "$H"                   # 200 h2
curl -s -o /dev/null --tlsv1.2 --tls-max 1.2 -w "%{http_code}\n" "$H"           # 200
curl -s -o /dev/null --tlsv1.3               -w "%{http_code}\n" "$H"           # 200
curl -s -o /dev/null --tlsv1.0 --tls-max 1.0 -w "%{http_code}\n" "$H"           # debe FALLAR (exit 35)
curl -s -o /dev/null -w "%{http_code} %{redirect_url}\n" "${H/https/http}"      # 301 -> https
```


### RNF-12 · JWT HS256+ con emisión y expiración, sin datos sensibles · 🟢

| | |
| --- | --- |
| **Criterio** | El token se firma con HS256 o superior, incluye los claims de emisión (`iat`) y expiración (`exp`), y **no contiene** contraseñas ni información académica o personal sensible. |
| **Comando** | `./gradlew test --tests '*JwtServiceTest'` |
| **Umbral** | Prueba en verde. Al decodificar el *payload* de un token emitido, los claims presentes son los necesarios para identificar al usuario y su rol — nada de notas, documentos ni datos personales. |
| **Evidencia** | Salida del comando, y el *payload* decodificado de un token de prueba. |
| **Al revisar un PR** | Si un mantenimiento agrega un claim al token, verificar que no sea información académica. Es la forma más fácil de romper RNF-12 sin darse cuenta. |

### RNF-13 · Validación del token y control de acceso RBAC · 🟢 el criterio más fuerte que tenemos

| | |
| --- | --- |
| **Criterio** | El servidor valida firma y vigencia del JWT antes de atender cada solicitud protegida. Toda ruta privada declara autorización explícita; ninguna queda solo detrás de `authenticated()`. Un rol sin permiso recibe `403`; sin token, `401`. El alcance por recurso se respeta: el profesor solo opera sobre sus asignaturas y el estudiante solo ve lo propio. |
| **Comando** | `./gradlew test --tests '*PrivateEndpointAuthorizationArchitectureTest'`<br>`./gradlew integrationTest --tests '*SecurityRf05IntegrationIT'`<br>Bruno: colección `seguridad-rf05/` (casos 401, 403 y alcance por rol) |
| **Umbral** | Las tres en verde. |
| **Evidencia** | Salida de los comandos; para endpoints nuevos, el caso Bruno correspondiente. |
| **Por qué es el mejor criterio del catálogo** | `PrivateEndpointAuthorizationArchitectureTest` recorre el **registro real de Spring MVC**, así que un endpoint nuevo sin `@PreAuthorize` la pone roja sola. No depende de que alguien se acuerde de escribir una prueba por endpoint: cubre los futuros. |
| **Pendiente** | Contrastar la Matriz RBAC implementada (`docs/security/RBAC_MATRIX.md`) contra el **Apéndice 4.1 del SRS**. Si difieren, es un hallazgo de RNF-13. |

### RNF-14 · Validar y sanear la entrada · 🟡

| | |
| --- | --- |
| **Criterio** | Toda entrada se valida antes de procesarse o almacenarse. Ninguna consulta construye SQL o JPQL por concatenación de entrada del usuario. El contenido almacenado no puede ejecutarse al mostrarse. |
| **Comando** | `grep -rnE '(createQuery\|createNativeQuery).*\+' software4-SIGRA-backend/SIGRA/src/main/java/`<br>`grep -rn '@Query' software4-SIGRA-backend/SIGRA/src/main/java/` → revisar que usen `:parametro`<br>`grep -rn 'innerHTML\|bypassSecurityTrust' software4-SIGRA-frontend/src --include=*.ts` |
| **Umbral** | Cero resultados en el primero y el tercero. En el segundo, cero `@Query` con concatenación. |
| **Evidencia** | Salida de los comandos, pegada en el PR. |
| **Reserva que hay que declarar** | **No hay prueba automatizada de saneamiento.** RNF-14 menciona «ejecución de contenido no autorizado» —es decir, XSS— y eso no está cubierto por ninguna prueba: Angular escapa por defecto, pero un `bypassSecurityTrustHtml` en un mantenibilidad futuro lo rompería sin que nada falle. El criterio es por inspección en F2. |

### RNF-15 · Expiración del token y cierre de sesión · 🟢

| | |
| --- | --- |
| **Criterio** | El JWT expira a los 60 minutos como máximo. Vencido, las solicitudes protegidas se rechazan con `401`. Al cerrar sesión, el cliente elimina el token almacenado. |
| **Comando** | Backend: `./gradlew test --tests '*JwtServiceTest' --tests '*JwtAuthenticationFilterTest'`<br>Frontend: `npx ng test --no-watch` (cubre `session.service.spec.ts`, `sesion.spec.ts`, `interceptors.spec.ts`) |
| **Umbral** | Todas en verde. `JWT_EXPIRATION_MS` ≤ 3600000. |
| **Evidencia** | Salida de los dos comandos. |

### RNF-16 · Historial de auditoría append-only · 🟢

| | |
| --- | --- |
| **Criterio** | Se auditan las autenticaciones **exitosas y fallidas**, y la creación, modificación, activación e inactivación de usuarios, asignaturas, RA, evaluaciones, calificaciones y observaciones. Cada registro incluye **usuario, fecha y hora, acción y resultado**. La tabla no admite `UPDATE` ni `DELETE` por ningún rol. |
| **Comando** | `./gradlew integrationTest --tests '*AuditoriaIntegracionIT'`<br>`./gradlew test --tests '*AuditoriaAspectTest'`<br>Verificación directa: `psql ... -c "UPDATE sigra.<tabla_auditoria> SET ..."` debe **fallar** |
| **Umbral** | Pruebas en verde. El `UPDATE` manual devuelve error de permiso o de regla. Los cuatro campos mínimos están presentes en cada registro. |
| **Evidencia** | Salida de las pruebas y del `psql` mostrando el rechazo. |
| **Ojo al verificar** | Que el `UPDATE` no afecte filas **no** demuestra que esté bloqueado: puede ser que el `WHERE` no casó. El criterio exige que la operación sea **rechazada**. |
| **Lo que más se olvida** | El SRS exige auditar las autenticaciones **fallidas**, no solo las exitosas. Vale confirmarlo explícitamente. |

### RNF-17 · Los errores no exponen detalles técnicos · 🟢

| | |
| --- | --- |
| **Criterio** | Ningún campo de ninguna respuesta de error contiene contraseñas, **tokens completos**, consultas de base de datos, rutas internas, trazas de ejecución ni datos de configuración. En el frontend, el mensaje se decide por el status HTTP y nunca se muestra el cuerpo de la respuesta. |
| **Comando** | Backend: `./gradlew test --tests '*HallazgosContratoErrorTest' --tests '*ContratoError*' --tests '*GlobalExceptionHandlerTest'`<br>Frontend: `npx ng test --no-watch` (cubre `login-error.spec.ts`, `mensaje-de-error.spec.ts`, `estudiante-error.spec.ts`) |
| **Umbral** | Todas en verde. |
| **Evidencia** | Salida de los dos comandos. |
| **Al revisar un PR** | Si agrega un `@ControllerAdvice` de módulo, verificar que **no** declare un método para `Exception.class` — eso lo atiende el manejador global, y declararlo en un módulo crea un empate de precedencia. Ya pasó: es el H-02 de `scripts_andres/hallazgos-manejo-errores.md`. |

---

## 2. Rendimiento · RNF-01 a RNF-09 · titular Andrés · 🟡

> **Cambió el 15 de noviembre de 2026.** El 8 de noviembre esta sección decía «no lista criterios
> ejecutables porque no existen todavía». Ya existen: **Apache JMeter 5.6.3**, con dos planes
> versionados en [`jmeter/`](jmeter/README.md) y los umbrales del SRS puestos como condición de
> fallo. Ver [H-02](A4-hallazgos-rnf.md), en corrección.

### 2.1 Lo que el SRS exige y qué instrumento le corresponde

| RNF | Umbral | Instrumento | Estado |
| --- | --- | --- | --- |
| RNF-01 | 20 usuarios concurrentes | JMeter, `-Jusuarios=20` | 🟡 listo, sin ejecutar |
| RNF-02 | 10 en lectura/escritura simultánea | JMeter + POST de calificación | 🔴 el plan solo lee |
| RNF-03 | 95 % de autenticaciones < 4 s | JMeter, Duration Assertion 4 000 ms | 🟡 listo, sin ejecutar |
| RNF-04 | 95 % de CRUD de catálogo < 3 s | JMeter, Duration Assertion 3 000 ms | 🟡 listo, sin ejecutar |
| RNF-05 | 95 % de calificaciones < 3 s | JMeter + datos sembrados | 🔴 sin sembrar |
| RNF-06 | 90 % de estadísticas < 5 s | JMeter, Duration Assertion 5 000 ms | 🟡 listo, sin ejecutar |
| RNF-07 | 50 evaluaciones por asignatura | Siembra + repetir la medición | 🔴 sin sembrar |
| RNF-08 | 95 % de páginas < 3 s | Presupuesto de `angular.json` + panel de red | 🟡 **bundle medido** |
| RNF-09 | Sostenido 4 meses | — | 🔴 **fuera de alcance** |

### 2.2 Criterio ejecutable · RNF-01, 03, 04 y 06

| | |
| --- | --- |
| **Criterio** | Con 20 usuarios concurrentes, el percentil 95 de cada operación cumple el umbral de su RNF. |
| **Comando** | el de abajo (desde `mantenimiento-rnf/`) |
| **Umbral** | `95th pct` < 4 000 ms en login · < 3 000 ms en catálogo · `90th pct` < 5 000 ms en estadísticas. `Error %` incluye las muestras que incumplieron la Duration Assertion |
| **Evidencia** | `jmeter/resultados/<nombre>-reporte/index.html`, tabla *Statistics*, y el `.jtl` crudo |
| **Dónde se ejecuta** | **Contra PostgreSQL local, nunca contra Render ni Supabase.** Ver la advertencia de abajo |

```bash
jmeter -n -t jmeter/RNF-01-06-rendimiento.jmx \
  -l jmeter/resultados/rnf01-06-local.jtl \
  -e -o jmeter/resultados/rnf01-06-local-reporte \
  -Jhost=127.0.0.1 -Jpuerto=8080 -Jprotocol=http \
  -Jusuarios=20 -Jrampa=20 -Jiteraciones=5 \
  -Jcorreo=administrador.prueba@uco.net.co -Jclave='<clave del usuario sembrado>'
```


> ⚠️ **La advertencia que hay que respetar.** El `.env` del backend apunta a
> `aws-0-us-east-1.pooler.supabase.com`, que es **la misma base de datos que usa el despliegue de
> Render**. Levantar el backend «en local» con ese `.env` no es local: los 20 usuarios le caen a la
> base compartida del equipo. Correr esta prueba así es una prueba de carga en producción. El
> procedimiento correcto —PostgreSQL en Docker con `docs/db/SIGRA_SCHEMA_CURRENT.sql` y un `.env`
> aparte— está en [`jmeter/README.md` §4.1](jmeter/README.md).

### 2.3 Criterio ejecutable · RNF-08 (bundle) · **ya medido**

| | |
| --- | --- |
| **Criterio** | El bundle inicial no supera el presupuesto declarado. |
| **Comando** | `npx ng build` — el presupuesto ya está declarado en `angular.json:51-62` y se evalúa en cada corrida del CI |
| **Valor real 15-nov** | **356,04 kB** sin comprimir · **100,14 kB** transferidos (corrida de CI 43684672703) |
| **Umbral actual** | aviso 500 kB · error 1 MB → **cumple con 29 % de margen** |
| **Propuesta** | **Bajar el aviso a 420 kB.** Deja 18 % de crecimiento y detecta una regresión antes de que el margen se agote. El error se deja en 1 MB |
| **Evidencia** | Registro del paso «Compilar (producción)» del CI del frontend |
| **Reserva** | El presupuesto mide **tamaño**, no **tiempo**. RNF-08 pide 95 % de páginas en menos de 3 s con ≥ 5 Mbps; eso hay que medirlo con el panel de red y declararlo como muestra pequeña |

### 2.4 Lo que se declara fuera de alcance, con justificación

**RNF-09** pide sostener los tiempos durante **cuatro meses de operación continua**. La ventana del
proyecto son 15 días. No es una herramienta que falte: es una imposibilidad temporal. Se declara
fuera de alcance en [A5](A5-informe-calidad.md) con decisión de tratamiento escrita, que es lo que
el §7 exige para lo que no se corrige. **Un «fuera de alcance» justificado cumple; un silencio, no.**

**RNF-02, RNF-05 y RNF-07** sí son alcanzables —necesitan datos sembrados y un POST en el plan de
JMeter— y por eso van a decisión del equipo (D-1 en [A6 §5](A6-semaforo-rnf.md)), no a fuera de
alcance.

---

## 3. Disponibilidad · RNF-18 · titular José · 🟡

> **Cambió el 15 de noviembre de 2026.** El uptime ya tiene instrumento y medición. El MTTR sigue
> sin dato. Ver [H-09](A4-hallazgos-rnf.md), en corrección.

### 3.1 Uptime · criterio ejecutable, **ya ejecutado**

| | |
| --- | --- |
| **Criterio** | El porcentaje de sondeos de `/actuator/health` con código 200 **y** cuerpo `UP` es ≥ 95 %. |
| **Comando** | el de abajo (desde `mantenimiento-rnf/`) |
| **Umbral** | ≥ 95 % de muestras exitosas |
| **Resultado 15-nov** | **90 de 90 → 100,00 %.** Solo códigos 200. p50 289 ms · p90 327 ms · p95 526 ms · p99 1 472 ms |
| **Evidencia** | `jmeter/resultados/rnf18-render.jtl` y el informe HTML |
| **Por qué el veredicto es 🟡 y no 🟢** | La ventana fue de **208 segundos**. El requisito habla de un periodo de operación, no de tres minutos. Lo que la medición demuestra es que el servicio responde y que **existe un instrumento repetible**, que antes no existía. Escribir «uptime del 100 %» a partir de esto sería el dato inflado que el §10 prohíbe |
| **Qué haría falta para 🟢** | Un sondeo de varios días, o un monitor externo. **Excede la ventana del proyecto**: es decisión de tratamiento, no trabajo pendiente |

```bash
jmeter -n -t jmeter/RNF-18-disponibilidad.jmx \
  -l jmeter/resultados/rnf18-render.jtl \
  -e -o jmeter/resultados/rnf18-render-reporte \
  -Jmuestras=90 -Jpausa=2000
```


### 3.2 MTTR · sin instrumento posible, y no es culpa de la herramienta

| | |
| --- | --- |
| **Criterio** | Ante una caída crítica, el tiempo entre el reporte o la detección y el restablecimiento completo no supera las 4 horas. |
| **Por qué JMeter no sirve** | El MTTR se mide sobre el **registro de un incidente real**, no con una herramienta de carga |
| **Estado** | **Sin evento que medir.** No se ha registrado ninguna caída crítica en la fase |
| **Veredicto honesto** | 🔴 «sin dato» — que no es «cumple» ni «no cumple» |
| **Decisión pendiente** | D-3 en [A6 §5](A6-semaforo-rnf.md): o se acepta «sin evento que medir» como veredicto, o se define un procedimiento de respuesta a caída y se verifica en seco. Lo decide el PO |

### 3.3 Criterio sustituto de resiliencia, que se mantiene

| | |
| --- | --- |
| **Criterio** | **(a)** El backend arranca con el esquema validado y `/actuator/health` responde `UP`. **(b)** Con el backend caído, el frontend muestra el mensaje de usuario definido, no una pantalla en blanco ni una traza. |
| **Comando** | (a) `curl --fail https://software4-sigra-backend.onrender.com/actuator/health`<br>(b) `npx ng test --no-watch` cubre el status `0` en `login-error.spec.ts`; el smoke SSR del CI valida la contingencia de API |
| **Umbral** | (a) `{"status":"UP"}` — verificado el 15-nov. (b) Mensaje «No fue posible conectar con el servidor. Verifica tu conexión e intenta nuevamente.» |

---

## 4. Compatibilidad · RNF-19 · titular Andrés · 🟡

| | |
| --- | --- |
| **Criterio** | Los flujos tocados funcionan en las dos últimas versiones de Chrome, Edge y Firefox, en escritorio y móvil. |
| **Comando** | `npm run e2e` (Playwright, Chromium y Firefox, contra backend real) |
| **Umbral** | Suite en verde en ambos navegadores. |
| **Evidencia** | Reporte de Playwright, que el CI publica como artefacto (`sigra-e2e-<run_id>`). |
| **Reservas que hay que declarar** | **(1)** La suite solo recorre el login ([H-03](A4-hallazgos-rnf.md)). **(2)** **Edge no se prueba automáticamente**: Chromium es un sustituto razonable por compartir motor, pero hay que decirlo así, no afirmar que Edge está probado. **(3)** Móvil no se prueba automáticamente; se verifica con el emulador de dispositivo del navegador y captura. |
| **Pendiente** | Obtener el **Apéndice 4.2** del SRS (matriz de compatibilidad de pruebas) para fijar qué versiones y dispositivos hay que cubrir exactamente. Sin él, el alcance de RNF-19 lo estamos suponiendo. |

---

## 5. Mantenibilidad · RNF-20 · titular ambos

RNF-20 tiene dos partes y hay que verificarlas por separado.

### RNF-20 (a) · Cobertura ≥ 70 % de los módulos obligatorios · 🟢 (era 🟡)

| | |
| --- | --- |
| **Criterio** | La cobertura no baja del 70 % ni globalmente ni en **ninguno de los cuatro módulos obligatorios**: autenticación (RF-04), control de acceso por rol (RF-05), cálculo de nivel de logro (RF-14) y generación de conclusiones (RF-16). |
| **Comando** | `./gradlew test jacocoTestCoverageVerification` |
| **Umbral** | 0.7 global y 0.7 por paquete en los cuatro módulos. |
| **Evidencia** | Salida del comando; reporte HTML en `build/reports/jacoco/`. |
| **Estado real 15-nov** | 🟢 **Cumple, tras corregir H-08.** `build.gradle` ya incluye `co.edu.uco.sigra.estadisticas.service*`, así que los cuatro módulos están vigilados. Cobertura global **92,39 %**; `estadisticas.service` 96,48 % y `estadisticas.service.impl` 93,69 %. **Falta el PR.** |
| **Criterio de cierre de H-08** | ✅ Cumplido: se agregó el paquete **y** se comprobó que la regla falla si la cobertura baja —con umbral temporal de 0,99, JaCoCo nombra los dos paquetes nuevos. Detalle en [A6 §3.3](A6-semaforo-rnf.md). |

### RNF-20 (b) · Documentación OpenAPI de los endpoints protegidos · 🟢

| | |
| --- | --- |
| **Criterio** | Todos los endpoints protegidos están documentados en OpenAPI/Swagger, con sus posibles códigos de respuesta: 200, 400, 401, 403 y 404. |
| **Comando** | `./gradlew integrationTest --tests '*ApiDocumentacionIT'` |
| **Umbral** | Las 10 clases `*ApiDocumentacionIT` en verde. Un endpoint nuevo sin documentación de códigos debe hacer fallar la prueba de su módulo. |
| **Evidencia** | Salida del comando; contrato en `http://localhost:8080/v3/api-docs`. |
| **Al revisar un PR** | Si agrega un endpoint protegido, confirmar que trae su documentación con los cinco códigos. Es un requisito del SRS, no una cortesía. |

---

## 6. Accesibilidad · RNF-21 · titular Andrés · 🟡

| | |
| --- | --- |
| **Criterio** | Cero violaciones de impacto `serious` o `critical`. Contraste ≥ 4.5:1 entre texto y fondo. **Navegación completa por teclado en los formularios de registro de notas y observaciones** — el SRS los nombra explícitamente. `label` o `aria-label` en **todos** los campos de formulario. |
| **Comando propuesto** | `@axe-core/playwright` dentro de la suite E2E existente |
| **Umbral** | Cero violaciones `serious` y `critical`. |
| **Evidencia** | Reporte de axe adjunto al PR. |
| **Estado** | **No automatizado** ([H-04](A4-hallazgos-rnf.md)). |
| **Criterio manual aceptable mientras tanto** | axe DevTools en Chrome sobre la vista tocada, con captura; y recorrido por teclado del formulario documentado paso a paso (orden de foco, foco visible, operable sin ratón). Es más lento y no previene regresiones, pero **deja evidencia**, que es lo que exige el §13. |

---

## 7. Seguridad de dependencias y análisis estático · transversal

### 7.1 SCA de dependencias · 🔴 en el backend, 🟢 en el frontend

| | |
| --- | --- |
| **Criterio** | Ninguna dependencia nueva o actualizada introduce una vulnerabilidad conocida de severidad moderada o superior. |
| **Comando** | Frontend: `npm audit --audit-level=high` — **ya corre en CI**<br>Backend: *Dependency Review* y `./gradlew dependencyCheckAnalyze` — **apagados** |
| **Umbral** | Cero hallazgos de severidad `moderate` o superior. |
| **Estado 15-nov** | Asimétrico y **sin cambio desde el 8 de noviembre**. Reconfirmado por API: `gh api repos/.../actions/variables` devuelve `total_count: 0`, así que los dos trabajos se saltan en cada corrida. Es [H-01](A4-hallazgos-rnf.md) |
| **Por qué no lo cerramos nosotros** | Crear una variable de repositorio exige permiso `admin`; el nuestro es `push`. **Es un pedido al equipo, no una tarea nuestra** |

### 7.2 Análisis estático · SonarQube · ⏳ plan listo

> Nuevo el 15 de noviembre de 2026. Ver [H-05](A4-hallazgos-rnf.md), en corrección.

| | |
| --- | --- |
| **Criterio** | Los dos repositorios obtienen calificación de mantenibilidad **A o B**, sin *bugs* de severidad `blocker` ni `critical`, y sin puntos calientes de seguridad sin revisar. |
| **Qué aporta sobre JaCoCo** | JaCoCo responde «cuánto código tocan las pruebas». Mantenibilidad es más: complejidad ciclomática, duplicación, reglas incumplidas, deuda técnica estimada. Y Sonar **consume el XML de JaCoCo**, así que la cobertura corregida en H-08 queda visible en el mismo tablero |
| **Camino 1 · hoy, sin permisos** | SonarQube Community en Docker: `docker run -d --name sonarqube -p 9000:9000 sonarqube:community`, y escanear cada repositorio con el *scanner*. Para el backend basta el plugin de Gradle; para el frontend, `sonar-scanner` con `sonar.sources=src` y `sonar.javascript.lcov.reportPaths` |
| **Camino 2 · permanente, en el CI** | **SonarCloud**, gratuito en repositorios públicos —y los dos lo son: `gh repo view` devuelve `"visibility":"PUBLIC"`. Requiere que un admin cree el proyecto y agregue `SONAR_TOKEN` a los secretos de Actions |
| **Bloqueo actual** | Camino 1: **Docker Desktop no está arrancado**. Camino 2: **el mismo bloqueo de permisos de H-01** — conviene pedir las dos cosas juntas, porque es la misma pantalla de Settings |
| **Evidencia esperada** | Captura del tablero con la calificación de mantenibilidad de cada proyecto, y el enlace |
| **Reserva** | El SRS **no exige** análisis estático. Es un instrumento que nos damos para sostener el veredicto de mantenibilidad con algo más que cobertura; no es un incumplimiento si no se hace |

---

## 8. Suite completa de verificación

Todo lo ejecutable, de una sola vez, al preparar una entrega:

```bash
# Backend — desde software4-SIGRA-backend/SIGRA
./gradlew clean test jacocoTestCoverageVerification
./gradlew integrationTest                      # requiere PostgreSQL y SIGRA/.env
curl --fail http://localhost:8080/actuator/health

# Frontend — desde software4-SIGRA-frontend
npx ng build
npx ng test --no-watch
npm audit --audit-level=high
npm run e2e                                    # requiere backend arriba; ver e2e:preflight

# Verificaciones por inspección
grep -rnE '(createQuery|createNativeQuery).*\+' software4-SIGRA-backend/SIGRA/src/main/java/
grep -rn 'innerHTML\|bypassSecurityTrust' software4-SIGRA-frontend/src --include=*.ts
grep -rn 'http://' software4-SIGRA-frontend/src --include=*.ts | grep -v environment.development

# RNF-11 · TLS en producción (nuevo el 15-nov)
curl -s -o /dev/null -w "%{http_code} %{http_version}\n" https://software4-sigra-backend.onrender.com/actuator/health
curl -s -o /dev/null --tlsv1.2 --tls-max 1.2 -w "%{http_code}\n" https://software4-sigra-backend.onrender.com/actuator/health
curl -s -o /dev/null --tlsv1.0 --tls-max 1.0 -w "%{http_code}\n" https://software4-sigra-backend.onrender.com/actuator/health   # debe fallar
curl -s -o /dev/null -w "%{http_code} %{redirect_url}\n" http://software4-sigra-backend.onrender.com/actuator/health

# RNF-18 · disponibilidad (nuevo el 15-nov)
jmeter -n -t mantenimiento-rnf/jmeter/RNF-18-disponibilidad.jmx \
  -l resultados/rnf18-render.jtl -e -o resultados/rnf18-render-reporte -Jmuestras=90

# RNF-01, 03, 04, 06 · rendimiento (nuevo el 15-nov; requiere PostgreSQL LOCAL, no Supabase)
jmeter -n -t mantenimiento-rnf/jmeter/RNF-01-06-rendimiento.jmx \
  -l resultados/rnf01-06.jtl -e -o resultados/rnf01-06-reporte \
  -Jusuarios=20 -Jrampa=20 -Jiteraciones=5 -Jclave='<clave>'

# H-01 · confirmar si el SCA del backend ya está habilitado
gh api repos/juancabernal/software4-SIGRA-backend/actions/variables
```

Guardar la salida de cada comando: **es la evidencia**, y sin ella el veredicto no puede ser verde.

---

## 9. Pendientes de este artefacto

- [x] ~~Medir el bundle actual y proponer un umbral concreto para RNF-08~~ — hecho el 15-nov:
      356,04 kB; propuesta de bajar el aviso a 420 kB.
- [x] ~~Llevar a la reunión la decisión sobre RNF-18 y el alcance de rendimiento~~ — formuladas
      como D-1, D-2 y D-3 en [A6 §5](A6-semaforo-rnf.md), para decidir en la reunión 3.
- [ ] **Entregar este documento a Santiago Torres y Juan José Narváez** — compromiso C-05,
      **vencido desde el 11 de noviembre**. Es lo que necesitan para F4.
- [ ] Ejecutar `RNF-01-06-rendimiento.jmx` con 20 usuarios contra PostgreSQL local.
- [ ] Escanear los dos repositorios con SonarQube y adjuntar la calificación de mantenibilidad.
- [ ] Obtener el **Apéndice 4.2** para cerrar el criterio de RNF-19 — compromiso C-03, vencido.
- [ ] Obtener el **Apéndice 4.1** y contrastarlo con la matriz RBAC implementada — C-07, bloqueado
      por C-03.
- [ ] Conseguir la **URL de producción del frontend en Vercel** para cerrar RNF-11 en los dos
      lados (pedido P-08).
- [ ] Escribir el **patrón de paginación y de buscador** que el equipo nos asignó y que no hemos
      ejercido ([H-12](A4-hallazgos-rnf.md)).
- [ ] Por cada mantenimiento aprobado, añadir su criterio específico y enlazarlo desde
      [A2](A2-matriz-impacto-calidad.md).

---

[Guía del rol](GUIA-TRABAJO-RNF.md) · [A1 Catálogo](A1-catalogo-rnf.md) · [A2 Matriz de impacto](A2-matriz-impacto-calidad.md) · [A4 Hallazgos](A4-hallazgos-rnf.md) · [A5 Informe](A5-informe-calidad.md) · [A6 Semáforo](A6-semaforo-rnf.md)

---

## 10. Verificación de navegación por rol · 15-nov-2026

| Criterio | Procedimiento ejecutado | Resultado | Alcance |
| --- | --- | --- | --- |
| Sesión y rutas privadas (RNF-13/15) | Login/logout con una cuenta autorizada por rol; abrir después una ruta privada directa | Logout volvió al login; rutas privadas sin sesión redirigieron a login | No se inspeccionaron tokens ni se esperó expiración |
| Separación de roles (RNF-13) | Abrir `/admin/auditoria` como PROFESOR y `/profesor/asignaturas` como ESTUDIANTE | Ambas rutas mostraron 403 | Guarda UI; no valida los endpoints del servidor |
| Error visible (RNF-17) | Recorrido de módulos por rol | Mensajes genéricos sin traza visible en cuatro vistas; consola sin error/warn observado | No se capturaron respuestas JSON ni logs backend |
| Responsive de inicio (RNF-08/21) | Revisar login y pantalla ESTUDIANTE a viewport integrado 608 × 667 | Sin overflow horizontal observado | No es prueba de red 5 Mbps, móvil físico, contraste o teclado completo |

Los recorridos y sus rutas están en [ADMINISTRADOR](evidencias-rnf/jose-validacion-2026-11/navegador-administrador.md), [PROFESOR](evidencias-rnf/jose-validacion-2026-11/navegador-profesor.md) y [ESTUDIANTE](evidencias-rnf/jose-validacion-2026-11/navegador-estudiante.md). La tabla no reemplaza los criterios de integración que requieren un QA aislado.
