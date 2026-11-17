# A6 · Semáforo de RNF — Verificación inicial

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Actividad RACI** | «Verificar requisitos no funcionales» — somos **A/R** |
| **Corresponde a** | Entrega 2 · «Registro de defectos y **verificación inicial de RNF**» |
| **Fecha de la medición** | 15 de noviembre de 2026 |
| **Commit verificado** | backend `d6fa7e1` · frontend `a3135ec` (ambos = `origin/develop`) |
| **Filtro** | **F4 · Pruebas** — insumo para los analistas de prueba |

> **Regla que nos aplicamos.** Si la casilla de evidencia está vacía, el veredicto **no puede ser
> verde**. Todo lo verde de esta tabla tiene una salida de comando reproducible detrás.

> **Vigencia · actualizada el 16 de noviembre de 2026.** Las mediciones de este corte se tomaron
> sobre backend `d6fa7e1` y frontend `a3135ec`. Dos cosas cambiaron desde entonces:
>
> 1. **H-08 quedó integrado.** El [complemento de auditoría](evidencias-rnf/jose-validacion-2026-11/resumen-ejecutivo.md)
>    de José anotó que en `c1b1950` faltaba la regla por paquete de `estadisticas` y que no se
>    cerrara H-08 para esa versión. **Era exacto para ese SHA**, pero el fix entró vía **PR #117** y
>    hoy está en `origin/develop` (`bb72c07`). **RNF-20 (a) cumple en la rama integrada.**
> 2. **Se incorporaron los recorridos de navegador** de los tres roles, que aportaron dos
>    observaciones, registradas como **OBS-01 y OBS-02** en la sección de observaciones de
>    [A4](A4-hallazgos-rnf.md). **No mueven el semáforo**: ningún RNF del SRS las cubre.
>
> **Regla que adoptamos a partir de esto:** toda cifra va con su SHA al lado. «92,39 % de
> cobertura» sin SHA no lo puede verificar nadie más, y fue lo que hizo que dos personas del mismo
> rol llegaran a conclusiones distintas sobre el mismo hallazgo.

---

## 1. El titular, en tres cifras

**Base del conteo: 23 criterios, no 21.** RNF-18 se cuenta como dos (uptime y MTTR se verifican de
forma distinta) y RNF-20 también (cobertura y OpenAPI). Es la misma base para las dos columnas,
así que la comparación es válida.

| | 8 de noviembre | 15 de noviembre | 16 de noviembre | **16-nov, noche** |
| --- | --- | --- | --- | --- |
| 🟢 Verificados con evidencia | 7 | 9 | 11 | **11** |
| 🟡 Parciales, con la reserva declarada | 3 | 9 | 7 | **6** |
| 🔴 Sin instrumento, fuera de alcance o **incumplido** | 13 | 5 | 5 | **6** |
| | 23 | 23 | 23 | 23 |

> **El movimiento de la noche del 16 es uno solo, y es hacia atrás: RNF-14 pasa de 🟡 a 🔴.**
> No porque el producto empeorara, sino porque **se le puso el instrumento que le faltaba**. RNF-14
> estaba en amarillo con la reserva escrita *«sin prueba dedicada de saneamiento»*; el escaneo
> activo de ZAP es esa prueba, y encontró dos defectos ([H-18](A4-hallazgos-rnf.md) y
> [H-19](A4-hallazgos-rnf.md)). Los otros tres criterios que la noche tocó —RNF-08, RNF-13 y
> RNF-17— **mejoraron su respaldo sin cambiar de color**.

> **Corregido al cierre del 16 de noviembre.** Durante unas horas esta tabla dijo 11 / 6 / 6, con
> **RNF-03 en rojo**. Una tercera corrida de carga, con **parámetros idénticos** a la que motivó el
> rojo, dio el resultado contrario (§3.4). RNF-03 vuelve a **amarillo**: no porque cumpla, sino
> porque **la medición no es reproducible todavía** y afirmar el incumplimiento sería tan
> infundado como afirmar el cumplimiento.

**La tarde del 16 de noviembre cambió el panorama de verdad**, porque por primera vez hubo
**medición de carga** y no solo inspección:

| Criterio | De | A |
| --- | --- | --- |
| **RNF-04** | 🟡 instrumento sin ejecutar | 🟢 **p95 1 394 / 1 108 ms** contra 3 000 |
| **RNF-06** | 🟡 bloqueado | 🟢 **p90 42 ms** contra 5 000 (en la API) |
| **RNF-01** | 🟡 sin ejecutar | 🟡 **20 hilos concurrentes alcanzados y medidos**, sin errores |
| **RNF-03** | 🟡 sin ejecutar | 🟡 **medido 3 veces, con resultados que se contradicen** |

Lo que el día entrega de verdad no es un veredicto sobre RNF-03, sino algo más incómodo y más
útil: **la primera medición de carga del proyecto, y la prueba de que todavía no es repetible**.
La tensión de fondo —el factor 12 de BCrypt que exige RNF-10 encarece cada login— está
identificada y es real; lo que no está es su magnitud. Ver [§3.4](#34-rnf-01-03-04-y-06--las-tres-corridas-de-carga-y-por-qué-no-coinciden)
y [H-17](A4-hallazgos-rnf.md).

**El conteo no se movió el 16 de noviembre, y conviene explicar por qué no.** Ese día pasó lo
siguiente: se confirmó que **RNF-20 (a) quedó integrado** en `develop`, se completó **RNF-11 en
los dos lados** (backend y frontend), y la auditoría de navegador de José aportó dos
observaciones. Ninguna de las dos mueve el semáforo, porque **ninguna tiene anclaje en el SRS**:
OBS-01 es un defecto funcional del despliegue y OBS-02 una revisión de configuración. Lo que sí
hacen es **bloquear una medición nuestra** (RNF-06 sigue amarillo, pero ahora por un motivo
distinto: la vista no carga).

> En una versión anterior de este documento esas dos observaciones figuraron como hallazgos de RNF
> con severidad alta y RNF-06 se bajó a rojo. **Se corrigió**: era deducir una exigencia desde lo
> observado, el mismo error de H-06 y H-10. Detalle en la sección de observaciones de
> [A4](A4-hallazgos-rnf.md).

| Qué se movió | De | A |
| --- | --- | --- |
| **RNF-11** TLS 1.2+ | 🔴 sin entorno de producción | 🟢 **verificado contra Render** |
| **RNF-20 (a)** cobertura de los 4 módulos | 🟡 vigilaba 2 de 4 | 🟢 **los 4, tras corregir H-08** |
| **RNF-18** uptime | 🔴 sin medición | 🟡 **medido**, con reserva de ventana |
| **RNF-01, 03, 04, 06** | 🔴 sin instrumento | 🟡 **instrumento creado**, sin ejecutar |
| **RNF-08** páginas < 3 s | 🔴 sin instrumento | 🟡 **bundle medido**: 356,04 kB |
| **RNF-21** accesibilidad | 🔴 sin verificación | 🟡 corregido a mano por UI/UX, sin automatizar |

**Lo que cambió el panorama:** el producto **ya está desplegado** (backend en Render, frontend en
Vercel). Eso convirtió dos requisitos que el 8 de noviembre declaramos «no verificables sin
entorno de producción» en requisitos **medibles hoy**: RNF-11 (TLS) y la mitad de uptime de
RNF-18. Y la cobertura de RNF-20 (a) pasó a cumplir completo con un cambio de cuatro líneas.

**Lo que no cambió y hay que decirlo:** siguen en rojo RNF-02, RNF-05, RNF-07 (necesitan datos
sembrados), RNF-09 (cuatro meses de operación, fuera de la ventana del proyecto) y el MTTR de
RNF-18 (sin ninguna caída registrada que medir). Cinco de 23.

---

## 2. Semáforo completo · 21 RNF

### 2.1 Rendimiento · RNF-01 a RNF-09 · titular Andrés

| RNF | Criterio y umbral del SRS | Veredicto | Evidencia |
| --- | --- | --- | --- |
| **RNF-01** | 20 usuarios concurrentes | 🟡 **Ejecutado · la concurrencia se alcanza; el veredicto cuelga de RNF-03** | Tres corridas de 20 hilos (§3.4). La concurrencia es real y está medida: `allThreads` llega a **20** y **84 de las 400 muestras** de la corrida de las 16:00 se ejecutaron con los 20 hilos activos a la vez, **cero errores**, todos `200`. Pero el SRS pide 20 concurrentes *cumpliendo los tiempos de RNF-03 a RNF-08*, y el número de RNF-03 todavía no es reproducible: ver [H-17](A4-hallazgos-rnf.md) |
| **RNF-02** | 10 en lectura y escritura simultánea | 🔴 **Sin instrumento** | El plan solo lee; el POST de calificación necesita datos sembrados |
| **RNF-03** | 95 % de autenticaciones < 4 s | 🟡 **Medido tres veces · el resultado no es reproducible** | Dos corridas **con parámetros idénticos** dan veredictos opuestos: 09:15 → p95 **5 493 ms** (46 de 100 por encima de 4 s); 16:00 → p95 **1 035 ms**, cero incumplimientos. La diferencia es la carga de la máquina, no el plan. Ver §3.4 y [H-17](A4-hallazgos-rnf.md). **No se puede afirmar que cumple ni que no cumple** hasta repetir con la máquina en estado controlado |
| **RNF-04** | 95 % de CRUD de catálogo < 3 s | 🟢 **Verificado · medido 3 veces** | Cumple en las tres corridas, y es el criterio más sólido de la sección: peor caso p95 **1 394 ms** (`/profesores`) y **1 108 ms** (`/asignaturas`) con la máquina saturada; mejor caso **29,8** y **24,9 ms**. Contra 3 000 ms, cumple incluso en el peor de los escenarios medidos |
| **RNF-05** | 95 % de calificaciones < 3 s | 🔴 **Sin instrumento** | Requiere evaluación y matrícula sembradas |
| **RNF-06** | 90 % de estadísticas < 5 s | 🟢 **Verificado en la API · medido 3 veces** | p90 entre **13 ms** y **42 ms** en `GET /niveles-logro` con 20 concurrentes, contra 5 000 ms. Dos órdenes de magnitud de margen en el peor caso. **Reserva:** mide el endpoint, no la pantalla; `/profesor/estadisticas` sigue devolviendo error genérico en el despliegue (OBS-01), así que el tiempo *de la vista* no está medido |
| **RNF-07** | 50 evaluaciones por asignatura/semestre | 🔴 **Sin instrumento** | Verificación de volumen; se siembra y se repite la medición |
| **RNF-08** | 95 % de páginas < 3 s con ≥ 5 Mbps | 🟡 **Ahora medido · cumple en la mediana, se pasa en el peor caso** | Lighthouse CI, 3 corridas por URL (§3.5): `/login` de Vercel **mediana TTI 1 267 ms**, peor caso **3 439 ms**; en local, mediana 1 459 ms y peor 1 690 ms. El presupuesto de `angular.json:51-62` sigue activo en cada `ng build` del CI. **Reserva:** una de tres corridas de producción pasó de 3 s por bloqueo de CPU (TBT 2 786 ms), y solo se midió la ruta pública |
| **RNF-09** | Tiempos sostenidos 4 meses | 🔴 **Fuera de alcance** | La ventana del proyecto son 15 días. Requiere decisión escrita de tratamiento |

### 2.2 Seguridad · RNF-10 a RNF-17 · titular José

| RNF | Criterio y umbral del SRS | Veredicto | Evidencia |
| --- | --- | --- | --- |
| **RNF-10** | BCrypt factor ≥ 12, salt única, nunca en claro | 🟢 **Verificado · ahora también en ejecución** | `AuthServiceImplTest`, `AuthControllerTest` en verde. **16-nov:** la respuesta real del login solo trae `token`, `tipo`, `expiraEn` y `usuario`; ningún campo de contraseña ni hash |
| **RNF-11** | HTTPS con **TLS 1.2+** en producción | 🟢 **Verificado en los dos lados** | Ver §3.1 — backend (Render) y frontend (Vercel): TLS 1.2 y 1.3 aceptados, **TLS 1.0 rechazado**, HTTP redirige a HTTPS en ambos. Cierra el pedido P-08 |
| **RNF-12** | JWT HS256+, con `iat`/`exp`, sin datos sensibles | 🟢 **Verificado** | `JwtServiceTest` |
| **RNF-13** | Valida firma y vigencia + RBAC del Apéndice 4.1 | 🟢 **Verificado · ahora también en ejecución** | `PrivateEndpointAuthorizationArchitectureTest` (recorre el registro real de Spring MVC), `SecurityRf05IntegrationIT`, Bruno `seguridad-rf05/`. **16-nov noche:** ZAP recorrió las **81 operaciones** del OpenAPI sin token y **ninguna devolvió datos** —265 peticiones, todas 401—, con 120 reglas activas. *Deny by default* verificado en ejecución. **Reserva:** falta el contraste **entre roles**, que es la Matriz RBAC propiamente dicha; el guion ya acepta el rol como argumento |
| **RNF-14** | Validar y sanear la entrada; consultas parametrizadas | 🔴 **Incumplido · con prueba dedicada, 16-nov noche** | La mitad de *«consultas parametrizadas»* **cumple y quedó demostrada**: el byte nulo llega al motor como parámetro ligado en vez de ejecutarse. La mitad de *«validar y sanear»* **no**: `?filtro=gomez%00` atraviesa controlador, servicio y repositorio y lo rechaza PostgreSQL ([H-19](A4-hallazgos-rnf.md)), y un nombre de parámetro vacío produce **500 en nueve endpoints** ([H-18](A4-hallazgos-rnf.md)). Evidencia: `herramientas-rnf/evidencias/zap/zap-api-admin-2026-11-16.json` |
| **RNF-15** | Token expira ≤ 60 min; el cliente lo borra al salir | 🟢 **Verificado · ahora también en ejecución** | `JwtServiceTest`, `JwtAuthenticationFilterTest`, `session.service.spec.ts`; `application.yaml:38`. **16-nov:** la respuesta real del login devuelve `expiraEn: 3600` segundos = 60 min exactos |
| **RNF-16** | Auditoría append-only, 5 años, autenticaciones exitosas **y fallidas** | 🟢 **Verificado · ahora también en ejecución** | `AuditoriaIntegracionIT`, `AuditoriaAspectTest`, **y evidencia de ejecución del 16-nov**: sobre el entorno aislado, `sigra.historial_auditoria` registró `LOGIN_FALLIDO` y `LOGIN_EXITOSO` con fecha y hora, rol, acción y detalle. Ver [herramientas-rnf §2.4](herramientas-rnf/README.md) |
| **RNF-17** | Errores sin contraseñas, tokens, SQL, rutas ni trazas | 🟢 **Verificado · ahora también bajo escaneo activo** | `HallazgosContratoErrorTest`, `ContratoError*Test`, `GlobalExceptionHandlerTest`. Los mensajes genéricos que OBS-01 observa en el despliegue **cumplen** este requisito: no filtran nada. **16-nov noche:** con 120 reglas de ZAP activas y **24 respuestas 500 provocadas**, ni un cuerpo trajo traza, clase, SQL ni ruta interna, y no se levantó ninguna alerta de divulgación. La única observación de exposición es `/actuator/health` abierto, sin anclaje en el SRS (**OBS-03**) |

### 2.3 Disponibilidad · RNF-18 · titular José

| RNF | Criterio y umbral del SRS | Veredicto | Evidencia |
| --- | --- | --- | --- |
| **RNF-18 (uptime)** | Disponible ≥ 95 % de las veces que se ingresa | 🟡 **Medido, con reserva de ventana** | Ver §3.2 — **90/90 muestras en 200, 100 %**, ventana de 3 min 31 s |
| **RNF-18 (MTTR)** | ≤ 4 h ante caída crítica | 🔴 **Sin evento que medir** | No se ha registrado ninguna caída crítica. No es «cumple»: es «no hay dato» |

### 2.4 Compatibilidad · RNF-19 · titular Andrés

| RNF | Criterio y umbral del SRS | Veredicto | Evidencia |
| --- | --- | --- | --- |
| **RNF-19** | 2 últimas versiones de Chrome, Edge y Firefox; escritorio y móvil | 🟡 **Parcial, 3 reservas** | `npm run e2e` (Playwright, Chromium + Firefox, contra backend real en el CI). **(1)** la suite recorre **un solo flujo** (`e2e/auth.spec.ts`) · **(2)** Edge no se prueba, Chromium es sustituto por motor · **(3)** móvil no se prueba automáticamente |

### 2.5 Mantenibilidad · RNF-20 · titular ambos

| RNF | Criterio y umbral del SRS | Veredicto | Evidencia |
| --- | --- | --- | --- |
| **RNF-20 (a)** | Cobertura ≥ 70 % en RF-04, RF-05, **RF-14** y **RF-16** | 🟢 **Verificado · integrado en `bb72c07`** | Ver §3.3 — global **92,39 %** sobre `d6fa7e1`; la regla de los cuatro módulos está en `develop` desde el PR #117 |
| **RNF-20 (b)** | OpenAPI de todo endpoint protegido con 200/400/401/403/404 | 🟢 **Verificado** | 10 clases `*ApiDocumentacionIT` en verde en el CI; contrato en `/v3/api-docs` |

**Respaldo nuevo del 16-nov, y hay que presentarlo en su sitio.** SonarQube Community 26.11 escaneó
el backend: puerta de calidad **OK**, **mantenibilidad A**, deuda técnica **15 minutos** sobre
14 422 líneas, duplicación 0,5 %, complejidad ciclomática 1 282, 0 bugs, 0 *security hotspots* y
3 *code smells* (los tres `java:S2187` en clases de prueba, falso positivo de patrón — detalle en
[H-05](A4-hallazgos-rnf.md)). Cobertura según Sonar 90,5 %, que concuerda con el 92,39 % de JaCoCo.

| | |
| --- | --- |
| **Qué cambia del veredicto** | **Nada del semáforo.** RNF-20 ya estaba 🟢 por cobertura y OpenAPI, que es lo único que el SRS exige |
| **Qué sí aporta** | La palabra «mantenibilidad» del §13 pasa a tener un número y una letra detrás, no solo un porcentaje de líneas cubiertas |
| **Reserva obligatoria** | El SRS **no exige** una calificación de Sonar. La letra **respalda**, no define. Y los umbrales de fiabilidad y seguridad (peor que B hace fallar) **son nuestros**, no del SRS |
| **Evidencia** | `herramientas-rnf/evidencias/sonar-backend-2026-11-16-*.json`, bajada de la API — no una captura |

**Y esa misma noche del 16 se escaneó el frontend** —puerta de calidad **OK**—, con lo que el respaldo cubre los dos repositorios:
mantenibilidad **A**, deuda **65 min** sobre 25 006 líneas, fiabilidad **A**, 0 bugs, 0 *hotspots*,
7 *code smells* y **duplicación 3,7 %**. Va **sin cobertura** por [H-14](A4-hallazgos-rnf.md), así
que lleva una puerta sin esa condición; la cobertura del frontend se sigue leyendo del CI. La letra
de seguridad sale **B** por una única vulnerabilidad `MINOR` que **es un falso positivo
comprobado** (`new URL(url, 'http://relative.invalid')`, un TLD reservado por RFC 2606: por ahí no
sale tráfico, y **no afecta a RNF-11**).

| Dato a vigilar | Por qué |
| --- | --- |
| **Duplicación 3,7 % en el frontend** contra 0,5 % en el backend | Es el indicador que el manual asocia al riesgo del código generado con IA. No incumple nada —el SRS no fija umbral— pero es **la cifra a mirar en el próximo mantenimiento** |

### 2.6 Accesibilidad · RNF-21 · titular Andrés

| RNF | Criterio y umbral del SRS | Veredicto | Evidencia |
| --- | --- | --- | --- |
| **RNF-21** | WCAG 2.1 AA: contraste ≥ 4.5:1, teclado en notas y observaciones, labels en todo campo | 🟡 **Automatizado en la ruta pública · 1,00 · el resto sin medir** | Andrea Avendaño trabajó el contraste 4,5:1 y el desborde en móvil (ACT-096, PR frontend #91). **16-nov noche:** Lighthouse CI da **accesibilidad 1,00 en las seis corridas** de `/login` (Vercel y local), con contraste, `label`, `tabindex`, `button-name`, `aria-*` y `target-size` en verde, y los umbrales escritos como aserciones en `lighthouse/lighthouserc.json` (§3.6). **Reserva:** `/login` es la única ruta pública; **notas y observaciones —las que el SRS nombra— siguen sin medir**, bloqueadas por [H-20](A4-hallazgos-rnf.md) |

**Novedad de la noche del 16: hay una primera señal automática, y salió de buscar otra cosa.** El escaneo de
SonarQube al frontend devolvió **cuatro hallazgos de accesibilidad** sobre las plantillas, con
archivo y línea: `Web:S6845` (`tabindex` en un elemento no interactivo **en la pantalla de notas**,
que es justo donde el SRS exige teclado), `Web:S6825` ×3 (`aria-hidden` en celdas decorativas) y
`Web:S9379` (`autofocus` en el login).

| | |
| --- | --- |
| **Qué cambia** | Ya no es exacto decir que RNF-21 no tiene **ninguna** verificación automatizada |
| **Qué no cambia** | El veredicto sigue 🟡 y H-04 sigue abierto: **Sonar no mide contraste** —el primer umbral literal del RNF— **ni recorre la aplicación**, lee plantillas. El «teclado completo en notas y observaciones» solo se demuestra navegando |
| **Qué hacemos con ellos** | Entran como **puntos del recorrido manual por teclado**, no como incumplimientos. El de `aria-hidden` hay que **confirmarlo navegando**: `td`/`th` no son focusables por defecto |

---

## 3. Las mediciones nuevas, con su salida real

### 3.1 RNF-11 · TLS 1.2+ en producción — 🟢 **cumple**

El 8 de noviembre declaramos este requisito «no verificable sin entorno de producción». El
entorno **existe**: `https://software4-sigra-backend.onrender.com`, que es la URL compilada en
`src/environments/environment.ts:3` del frontend. Render termina TLS por defecto, que es
precisamente lo que el requisito pide.

```
$ curl -s -o /dev/null -w "status=%{http_code} http_ver=%{http_version}\n" \
    https://software4-sigra-backend.onrender.com/actuator/health
status=200 http_ver=2

$ curl --tlsv1.2 --tls-max 1.2 ... → status=200      # TLS 1.2 aceptado
$ curl --tlsv1.3            ... → status=200      # TLS 1.3 aceptado
$ curl --tlsv1.0 --tls-max 1.0 ... → status=000, exit 35   # TLS 1.0 RECHAZADO (handshake failure)
$ curl http://software4-sigra-backend.onrender.com/actuator/health
status=301 redirect=https://software4-sigra-backend.onrender.com/actuator/health
```

| Lo que exige el SRS | Resultado |
| --- | --- |
| HTTPS en producción | ✅ Sirve por HTTPS, HTTP/2 |
| TLS 1.2 **o superior** | ✅ 1.2 y 1.3 aceptados |
| Que no se admita menos | ✅ TLS 1.0 rechazado en el handshake |
| Que no haya tráfico en claro | ✅ HTTP responde 301 a HTTPS |

### 3.1.1 Y el frontend, medido el 16 de noviembre

La auditoría de José aportó la URL que faltaba: `https://sigra.vercel.app`. Con ella se repitió la
misma batería:

| Lo que exige el SRS | Backend (Render) | **Frontend (Vercel)** |
| --- | --- | --- |
| HTTPS en producción | ✅ 200, HTTP/2 | ✅ **200, HTTP/2** |
| TLS 1.2 | ✅ 200 | ✅ **200** |
| TLS 1.3 | ✅ 200 | ✅ **200** |
| TLS 1.0 rechazado | ✅ exit 35 | ✅ **exit 35** |
| Sin tráfico en claro | ✅ 301 → HTTPS | ✅ **308 → HTTPS** |

**Consecuencia: [H-10](A4-hallazgos-rnf.md) se cierra sin reservas y el pedido P-08 queda
resuelto.** RNF-11 es el único requisito del SRS que hoy se verifica **de punta a punta en el
entorno real que el requisito nombra**, y no por sustitución.

La única nota que queda es de otra naturaleza y vive en **OBS-02** ([A4](A4-hallazgos-rnf.md)): en la
respuesta de login se observó HSTS pero no CSP ni las otras cabeceras de endurecimiento. Eso no es
parte de RNF-11 —el requisito pide TLS, no cabeceras— pero conviene que el equipo decida la
política.

### 3.2 RNF-18 · Uptime — 🟡 **medido, con reserva de ventana**

```
$ jmeter -n -t RNF-18-disponibilidad.jmx -l resultados/rnf18-render.jtl \
         -e -o resultados/rnf18-render-reporte -Jmuestras=90 -Jpausa=2000

summary =     90 in 00:03:31 =    0.4/s Avg:   332 Min:   270 Max:  1620 Err:     0 (0.00%)
```

| Métrica | Valor |
| --- | --- |
| Muestras | **90** |
| Exitosas (código 200 **y** cuerpo con `UP`) | **90 → 100,00 %** |
| Códigos observados | solo `200` |
| Ventana | 15-nov-2026 07:00:37 → 07:04:06 (**208 s**) |
| p50 / p90 / p95 / p99 | 289 / 327 / **526** / 1 472 ms |
| Mínimo / máximo | 270 / 1 620 ms |

**Por qué queda amarillo y no verde.** El umbral del SRS es un porcentaje de disponibilidad de un
periodo de operación. Tres minutos y medio de sondeo **no son ese periodo**. Lo que esta medición
sí demuestra, y es lo que vamos a decir con estas palabras:

1. El servicio **responde** y su health check reporta `UP`.
2. Existe un **instrumento repetible y versionado** para medirlo, que antes no existía.
3. Las latencias observadas no se acercan a ningún umbral problemático.

Para subirlo a verde hace falta un sondeo largo (o un monitor externo tipo cron/uptime) corriendo
varios días, y eso **excede la ventana del proyecto**. Es una decisión de tratamiento, no un
trabajo pendiente.

### 3.3 RNF-20 (a) · Cobertura de los cuatro módulos obligatorios — 🟢 **cumple, tras corregir H-08**

El `build.gradle` vigilaba **dos** de los cuatro módulos que el SRS nombra. El cambio son cuatro
líneas:

```diff
  'co.edu.uco.sigra.auth.security',
- 'co.edu.uco.sigra.config'
- // Nivel de logro: agregar 'co.edu.uco.sigra.estadisticas.service*' cuando exista RF-14.
+ 'co.edu.uco.sigra.config',
+ // RF-14 (calculo de nivel de logro) y RF-16 (generacion de conclusiones):
+ // el SRS los nombra como modulos obligatorios del RNF-20 (a). Hallazgo H-08.
+ 'co.edu.uco.sigra.estadisticas.service*'
```

Cobertura real medida con `./gradlew test jacocoTestReport` sobre `d6fa7e1`:

| Módulo del SRS | Paquete | Instrucciones cubiertas | ≥ 70 % |
| --- | --- | --- | --- |
| **Global** | — | 16 012 / 17 330 = **92,39 %** | ✅ |
| RF-04 autenticación | `auth.service` | 211 / 229 = **92,14 %** | ✅ |
| RF-04 autenticación | `auth.service.impl` | 196 / 196 = **100,00 %** | ✅ |
| RF-04 autenticación | `auth.controller` | 21 / 21 = **100,00 %** | ✅ |
| RF-05 control de acceso | `auth.security` | 671 / 901 = **74,47 %** | ✅ |
| RF-05 control de acceso | `config` | 279 / 290 = **96,21 %** | ✅ |
| **RF-14 nivel de logro + RF-16 conclusiones** | `estadisticas.service` | 137 / 142 = **96,48 %** | ✅ **nuevo** |
| **RF-14 nivel de logro + RF-16 conclusiones** | `estadisticas.service.impl` | 1 202 / 1 283 = **93,69 %** | ✅ **nuevo** |

```
$ ./gradlew jacocoTestCoverageVerification
BUILD SUCCESSFUL in 17s
```

**Prueba de que la regla ahora sí muerde** (el criterio de cierre que nos pusimos en
[A3 §5](A3-criterios-verificacion.md)). Subiendo el umbral de esa regla a 0,99 de forma temporal,
JaCoCo nombra los paquetes nuevos — antes eran invisibles para la verificación:

```
Rule violated for package co.edu.uco.sigra.estadisticas.service.impl: ... is 0.93, but expected minimum is 0.99
Rule violated for package co.edu.uco.sigra.estadisticas.service:      ... is 0.96, but expected minimum is 0.99
```

El umbral se dejó en 0,7, que es el del SRS. **El cambio no rompe nada y cierra el único
incumplimiento documentable del SRS que teníamos.** Falta abrirlo como PR: nuestro rol no aprueba
integraciones.

---

### 3.4 RNF-01, 03, 04 y 06 · Las tres corridas de carga, y por qué no coinciden

Las tres se ejecutaron el **16 de noviembre** contra el entorno aislado (`127.0.0.1:8081` sobre
`sigra-pg-rnf`), con el mismo usuario `admin.bruno@uco.net.co` —hash `$2a$12$…`, factor 12
confirmado en `seed-roles.sql`— y el mismo plan `RNF-01-06-rendimiento.jmx`:

| # | `.jtl` | Hora | Iteraciones | Login p95 | `/profesores` p95 | `/asignaturas` p95 | `/niveles-logro` p90 | Incumplimientos |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `rnf01-06-local.jtl` | 09:15 | **5** (solapados) | **5 493 ms** 🔴 | 1 394 ms | 1 108 ms | 42 ms | **46 de 100** |
| 2 | `rnf01-control.jtl` | 09:17 | **1** (escalonados) | 546 ms ✅ | 29 ms | 23 ms | 17 ms | 0 |
| 3 | `rnf01-06-local-2.jtl` | **16:00** | **5** (solapados) | **1 035 ms** ✅ | 29,8 ms | 24,9 ms | 13 ms | **0 de 400** |

**Las corridas 1 y 3 son la misma prueba.** No es una interpretación: `mantenimiento-rnf/jmeter.log`
registra para la de las 16:00 `usuarios=20`, `rampa=20`, `iteraciones=5`, `correo=admin.bruno@uco.net.co`,
`puerto=8081` — exactamente los parámetros de la corrida 1. Y aun así el login pasa de **5 493 ms
con 46 incumplimientos** a **1 035 ms con cero**.

**Qué lo explica.** La corrida 1 se tomó con seis contenedores encima, SonarQube incluido; la 3,
con la máquina descargada. El dato que lo delata es la corrida 2: un login **escalonado** costó
allí 546 ms, mientras que en la corrida 3 un login **solapado con otros 19** costó 307 ms de
mediana. Un login aislado no puede ser más lento que veinte simultáneos si la CPU está libre: lo
que varió entre la mañana y la tarde fue cuánta CPU quedaba para el backend.

**Qué sobrevive y qué no:**

| Afirmación | Estado |
| --- | --- |
| La concurrencia de 20 se alcanza y se sostiene | ✅ **Firme.** `allThreads` llega a 20; 84 de las 400 muestras de la corrida 3 se tomaron con los 20 hilos vivos |
| RNF-04 y RNF-06 cumplen | ✅ **Firme.** Cumplen en las tres corridas, incluso con la máquina saturada |
| El login es la operación que se degrada bajo presión de CPU, y la causa es BCrypt factor 12 | ✅ **Firme.** Es la única que se mueve, y la causa está en `SecurityConfig.java:39` |
| **RNF-03 no cumple con 20 concurrentes** | ⚠️ **No sostenible hoy.** Dos corridas idénticas, veredictos opuestos |
| La magnitud de la degradación | ⚠️ **Desconocida.** Entre 1,2× y 10×, según el estado de la máquina |

**Lo que falta, y es barato:** repetir la corrida de carga **tres veces seguidas con la máquina en
estado conocido** —anotando qué contenedores están arriba— y reportar la mediana de las tres. Es
media hora de trabajo y convierte el dato más discutible de la entrega en el más sólido.

---

### 3.5 RNF-14 · Escaneo activo de la API — 🔴 **el único incumplimiento demostrado por ejecución**

OWASP ZAP 2.17.0 (`zap-api-scan.py` sobre el OpenAPI del backend: **61 rutas, 81 operaciones**),
contra el entorno aislado del 8081 y **nunca contra Render ni Vercel**. Procedimiento completo y
trampas en [herramientas-rnf §6](herramientas-rnf/README.md).

| Corrida | Veredicto de ZAP | Qué demuestra |
| --- | --- | --- |
| **Sin token** | `PASS: 120 · WARN: 0` | **Nada se obtiene sin JWT**: 265 peticiones, todas 401. Es el *deny by default* de RNF-13 verificado en ejecución |
| **Autenticada como ADMINISTRADOR** | `PASS: 119 · WARN-NEW: 2` | **24 respuestas 500** en nueve endpoints de listado y la cabecera `Cross-Origin-Resource-Policy` ausente |

```bash
# El defecto, en una línea
curl -s -D - -H "Authorization: Bearer $TOK"   "http://localhost:8081/api/v1/programas?=&codigo=ing&estado=ACTIVO"
# HTTP/1.1 500 · {"status":500,"error":"INTERNAL_SERVER_ERROR",
#                 "mensaje":"Ocurrió un error inesperado en el servidor"}

# Y el que prueba la mitad de "sanear"
curl -s -H "Authorization: Bearer $TOK"   "http://localhost:8081/api/v1/estudiantes?filtro=gomez%00"
# HTTP 409 · y en el registro: ERROR: invalid byte sequence for encoding "UTF8": 0x00
```

**Cómo se sostiene el 🔴, y dónde un revisor podría discutirlo.** Hay que decirlo con precisión,
porque son dos cosas de peso distinto:

- **[H-19](A4-hallazgos-rnf.md) es el que incumple RNF-14 sin discusión.** El texto del SRS dice
  «validar y sanear los datos recibidos **antes de procesarlos o almacenarlos**». Un byte de
  control recorrió controlador, servicio y repositorio, y lo detuvo el motor de base de datos. No
  hubo saneamiento en ningún borde.
- **[H-18](A4-hallazgos-rnf.md) admite otra lectura**, y queda registrada: se puede clasificar como
  defecto de **manejo de errores** —la entrada sí se detecta como inválida, lo que falla es el
  código de respuesta— y no de validación. **No cambia el color**, porque H-19 ya lo fija, pero sí
  cambia a quién se le pide el arreglo. Lo dejamos escrito para no repetir el error de método de
  H-06 y H-10 en sentido contrario: afirmar más de lo que la evidencia aguanta.

**Lo que este escaneo NO cubre, y hay que declararlo.** Se corrió con **un solo rol**: contrasta
el perímetro, no la Matriz RBAC entre roles. Y el escaneo autenticado **escribe** —dejó 112
facultades basura y 435 filas de auditoría—, así que exige respaldo y restauración de la base, que
es parte del procedimiento.

### 3.6 RNF-08 y RNF-21 · Lighthouse CI — 🟡 los dos, por la misma razón: **alcance**

Lighthouse 12.6.1 vía `@lhci/cli` 0.15.x, preset *desktop*, **tres corridas por URL**, con los
umbrales del SRS escritos como aserciones (`interactive ≤ 3000 ms`, `accessibility ≥ 0,9`,
`color-contrast`/`label`/`tabindex` en 1).

| | Vercel `/login` | Local `/login` |
| --- | --- | --- |
| **TTI — el umbral de RNF-08** | mediana **1 267 ms** · peor **3 439 ms** | mediana **1 459 ms** · peor 1 690 ms |
| Bloqueo total (TBT) | 100 / **2 786** / 274 ms | **0 ms** las tres |
| **Accesibilidad — RNF-21** | **1,00 · 1,00 · 1,00** | **1,00 · 1,00 · 1,00** |
| Bytes transferidos | 1 087 715 | 1 416 020 |

**Las dos reservas, que son las que impiden el verde.**

1. **RNF-08: `lhci` asserta contra la mediana.** La corrida de **3 439 ms** —por encima de los 3 s
   del SRS— **no hizo fallar la puerta**. Con el mismo bundle, el TBT fue de 100 a 2 786 ms, así
   que la variación es de CPU del cliente, no del servidor: en local, el TBT fue 0 en las tres. Es
   el **mismo patrón de H-17**: una medida que cambia de veredicto según la carga de la máquina.
   Se declara, no se promedia para que salga bonito.
2. **RNF-21: `/login` es la única ruta pública.** Las pantallas que el SRS nombra —**notas y
   observaciones**— están detrás del login, y la corrida autenticada **se canceló** al descubrir
   que el frontend local habla con la base de producción ([H-20](A4-hallazgos-rnf.md)). El 1,00 es
   real y es la primera cifra automática de RNF-21, pero es de una pantalla de cuatro campos.

**El aviso que sale en las dos URL, y por qué no es contradicción.** `total-byte-weight` marca
1,08 MB contra el presupuesto de 500 kB de `angular.json:51-62`. No se contradice con los
356,04 kB raw del presupuesto: el presupuesto mide **el bundle inicial** y Lighthouse mide **todo
lo que la página descarga**. No mezclar las dos cifras en el informe.

**Evidencia.** `herramientas-rnf/evidencias/lhci-vercel-login-2026-11-16/` y
`lhci-local-login-2026-11-16/` — informe JSON y HTML de cada corrida.

---

## 4. Lo que falta para pasar amarillos a verdes, con nombre y bloqueo

| # | Qué falta | Quién puede | Bloqueo real |
| --- | --- | --- | --- |
| 1 | ~~Abrir el PR del fix de H-08~~ | — | ✅ **Hecho.** Integrado en `develop` (`bb72c07`) vía PR #117 el 16-nov |
| 2 | ~~PostgreSQL local para correr los 20 usuarios~~ | — | ✅ **Resuelto el 16-nov.** [`herramientas-rnf/`](herramientas-rnf/README.md) levanta PostgreSQL aislado + backend en 8081, verificado: un login fallido mueve el contador **en la base local**, no en Supabase |
| 3 | Activar `SIGRA_ENABLE_DEPENDENCY_REVIEW` y `SIGRA_ENABLE_OWASP_SCA` | **Solo un admin del repo** (Juan Camilo / Jean Paul) | Andrés tiene `push`, **no `admin`**: no puede. **Lleva 9 días pedido** y entre tanto entraron los PR #117, #118 y el R4, todos con el SCA saltado |
| 4 | SonarQube para la nota de mantenibilidad | Andrés | 🟢 **Backend escaneado** (16-nov): puerta **OK**, mantenibilidad **A**, deuda **15 min**, cobertura 90,5 %. Evidencia en `herramientas-rnf/evidencias/sonar-backend-2026-11-16-*.json` |
| 4a | ~~Escanear el frontend~~ y meter el análisis estático en el CI | **admin** (CI) | ✅ **Frontend escaneado el 16-nov por la noche**: **A**, deuda 65 min, duplicación 3,7 %, y **4 hallazgos de accesibilidad que alimentan RNF-21**. 🟡 Queda el CI: exige `SONAR_TOKEN` en los secretos, **el mismo permiso `admin` de la fila 3** — pedirlo junto. Por eso [H-05](A4-hallazgos-rnf.md) sigue amarillo |
| 4b | **Repetir la corrida de carga 3 veces con la máquina en estado conocido**, para cerrar RNF-03 | Andrés | 🔴 **Nada lo bloquea.** El entorno ya está levantado y el comando está escrito ([`jmeter/README.md` §4.2.1](jmeter/README.md)). Es media hora, y sin eso el dato de RNF-03 no se sostiene — ver §3.4 |
| 5 | `@axe-core/playwright` para automatizar RNF-21 | Equipo de frontend | Decisión del equipo: es una dependencia nueva |
| 6 | ~~URL de producción del frontend~~ | — | ✅ **Resuelto:** `https://sigra.vercel.app`, de la auditoría de José. Falta comprobarle el rechazo de TLS 1.0 |
| 7 | **Dejar OBS-01 escrita en 0000041 y 0000048**, que son las incidencias abiertas que tocan esas pantallas | Andrés / José | Ninguno. **No se crea ticket nuevo**: el procedimiento del equipo es revisar las existentes |
| 8 | Reproducir OBS-01 en QA correlacionando `X-Request-Id` | Backend + frontend + operaciones | Requiere observabilidad del despliegue |
| 9 | Correr `./gradlew dependencyCheckAnalyze` y llevar el informe de CVE | Andrés / José | 🔴 **Corregido el 16-nov noche: se ejecutó y FALLA.** `NvdApiException: Invalid API Key, length of 0` a los 40 s — el plugin 13.0.0 exige clave de NVD. No es `admin`: la clave es **gratuita y autogestionada** en `nvd.nist.gov/developers/request-an-api-key`. El dato de CVE que ya tenemos lo dio **Trivy**, que no pide clave |
| 10 | **Correr ZAP con los tres roles** y comparar los informes, para cerrar la Matriz RBAC de RNF-13 | Andrés / José | **Ninguno.** El guion acepta el rol como argumento: `bash zap/escanear-api-autenticado.sh profesor.bruno@uco.net.co`. Exige respaldar y restaurar la base, porque el escaneo escribe |
| 11 | **Imagen del frontend contra el 8081** + `collect.puppeteerScript` con login, para medir RNF-21 en notas y observaciones | Andrés | 🔴 **[H-20](A4-hallazgos-rnf.md)**: hoy el frontend local apunta a la base de producción, así que no se puede iniciar sesión para medir |
| 12 | Clave de NVD para que `dependencyCheckAnalyze` tenga catálogo | Andrés / José | Ninguno — formulario público, llega por correo. **No confundir con la fila 3** |

---

## 5. Las tres decisiones que el equipo tiene que tomar esta noche

El manual exige que **todo amarillo o rojo tenga decisión escrita** antes del cierre: se corrige,
se acepta como deuda técnica con justificación, o se declara fuera de alcance. Un rojo sin
decisión es un criterio de finalización incumplido (§13), y nos lo cobran a nosotros.

| # | Decisión | Opciones | Quién decide |
| --- | --- | --- | --- |
| **D-1** | **RNF-02, RNF-05, RNF-07** (los tres rojos de rendimiento que sí serían alcanzables) | (a) se siembran los datos y se miden antes del día 15 · (b) deuda técnica documentada | Equipo |
| **D-2** | **RNF-09** (4 meses de operación continua) | Fuera de alcance con justificación — **es la única opción honesta** | PO |
| **D-3** | **RNF-18 MTTR** | (a) se acepta «sin evento que medir» como veredicto · (b) se define un procedimiento de respuesta a caída y se verifica en seco | PO |
| **D-4** | **OBS-01**: cuatro vistas con error genérico en el despliegue | (a) se reproduce y corrige antes del cierre · (b) se declara defecto conocido. **No es un RNF**, así que no condiciona el §13; sí condiciona la calidad del producto que se entrega | Equipo + PO |
| **D-6** | **[H-17](A4-hallazgos-rnf.md)**: el login se degrada bajo presión de CPU por el BCrypt que exige RNF-10. **Ojo:** la magnitud está en revisión — dos corridas idénticas se contradicen (§3.4), así que esta decisión **ya no es urgente ni bloquea la entrega** | (a) **declarar por escrito que los 20 usuarios de RNF-01 son usuarios en sesión, no autenticando a la vez** — la lectura más realista, cuesta un párrafo y **se sostiene por sí sola**, con independencia de cómo cierre la medición · (b) deuda técnica documentada con las tres corridas adjuntas · (c) **repetir la medición en estado controlado antes de decidir nada** — la opción recomendada ahora. **No se propone bajar el factor de BCrypt**: sería incumplir RNF-10 para cumplir RNF-03 | **PO**, sin prisa |
| **D-5** | **[H-03](A4-hallazgos-rnf.md)**: diez módulos nuevos, un flujo E2E | (a) un spec por rol antes del cierre · (b) deuda técnica con justificación escrita | Equipo |

---

## 6. Trazabilidad con Mantis

| Incidencia | Por qué nos toca | Estado en Mantis | Nuestra lectura |
| --- | --- | --- | --- |
| **0000053** (alta/mayor, 14-nov) | «Falla intermitente al cargar combos … en múltiples módulos, presente en todos los roles», reproducibilidad *a veces* | **nueva · sin asignar** | Síntoma e impacto RNF por confirmar; la causa no está demostrada. Reproducir primero en QA aislado y luego decidir si corresponde JMeter. El manual aplica bloqueo a defectos altos confirmados; validar clasificación e impacto con evidencia |
| **0000038** (alta/mayor) | Mantis la clasifica como **«No Funcionalidad»**; la guía del equipo nos asigna «definir y validar los patrones de paginación y buscadores» | **asignada desde el 8-nov** | 7 días sin movimiento. Es nuestra responsabilidad de validación y no hemos podido ejercerla porque no hay implementación que validar |
| **0000040** (alta/mayor) | Igual: **«No Funcionalidad»**, patrón de paginación | **resuelta** (resolución *abierta*) | Se resolvió **sin que validáramos el patrón**. Hay que revisarla y dejar el veredicto escrito |
| **0000029** (alta/fallo, seguridad) | Bloqueo tras 5 intentos fallidos (RF-04, uno de los 4 módulos del RNF-20) | **resuelta** (resolución *abierta*) | Verificado: está implementado (`Usuario.intentosFallidos`, `fechaBloqueo`, `estaBloqueado`, 423 documentado) y probado. Solo falta cerrar la resolución en Mantis |

> **Cómo trabaja este equipo el tablero, y por qué importa para nuestro rol.** El equipo **no
> crea incidencias nuevas** en esta fase: revisa las que ya están, y si una figura como
> `cerrada` pero no cumple su criterio de aceptación, **la reabre dejando escrito por qué**.
> Eso define nuestra tarea de F4 con precisión: no abrir tickets, sino **verificar las 22 que
> están en `resuelta`** contra su criterio y dejar el veredicto en cada una. Y tiene un efecto
> incómodo: como **ninguna está en `cerrada`**, la compuerta de reapertura todavía no se ha
> podido ejercer ni una vez.

> **Al 16 de noviembre, Mantis no registra un solo cambio respecto al 15.** Se reexportó el
> tablero y se comparó fila por fila: mismas 31 incidencias, mismos estados, mismas
> resoluciones, y la fecha de actualización más reciente sigue siendo 2026-11-15. **0000053
> sigue sin dueño** y ninguna incidencia pasó a `cerrada`. Lo que sí se movió fue el código:
> entraron R7, R4 y más paginación. El tablero va por detrás del repositorio.

> **Dato de higiene de Mantis:** de las 31 incidencias del tablero, **ninguna está en estado
> `cerrada`** (22 resueltas, 6 nuevas, 3 asignadas). Según las reglas del propio equipo, `cerrada`
> exige revisión técnica + pruebas + PR integrado + documentación al día. Mientras eso no pase, el
> indicador «% de cambios con trazabilidad completa» es honestamente **0 %**.

---

[Guía del rol](GUIA-TRABAJO-RNF.md) · [A1 Catálogo](A1-catalogo-rnf.md) · [A2 Matriz de impacto](A2-matriz-impacto-calidad.md) · [A3 Criterios](A3-criterios-verificacion.md) · [A4 Hallazgos](A4-hallazgos-rnf.md) · [A5 Informe](A5-informe-calidad.md) · [JMeter](jmeter/README.md)

---

## Complemento de semáforo · verificación del 15-nov-2026

El conteo previo **9 verdes / 9 amarillos / 5 rojos** y su base de **23 criterios** se conservan como línea histórica; no se ajustan con la cifra distinta del acta preparada de reunión 3.

La evidencia nueva no permite marcar como verde ningún requisito de forma global. En particular:

- RNF-11: el frontend respondió con HTTPS/TLS 1.2 y 1.3 y HSTS, pero la sonda TLS 1.0 fue inconclusa y no cubrió cada ruta/dato del backend.
- RNF-13: las dos rutas cruzadas por rol mostraron 403 y las rutas privadas sin sesión redirigieron; Apéndice 4.1 y endpoints backend siguen pendientes.
- RNF-15: logout y bloqueo posterior de rutas se observaron; expiración y eliminación directa del token no se inspeccionaron en vivo.
- RNF-20(a): la rama backend actual aún no aplica regla por paquete a RF-14/RF-16; H-08 queda abierto para `c1b1950`.
- RNF-20(b): las clases OpenAPI no están ejecutadas en la CI #199 y el GET productivo de documentación no respondió en 20 s.
- RNF-18: la sonda corta sigue siendo insuficiente para uptime/MTTR; además, algunas vistas productivas mostraron error genérico sin que ello mida una caída total.

La tabla completa por criterio y su evidencia está en [resumen ejecutivo](evidencias-rnf/jose-validacion-2026-11/resumen-ejecutivo.md); limitaciones y trabajos restantes están en [pruebas pendientes](evidencias-rnf/jose-validacion-2026-11/pruebas-pendientes.md).
