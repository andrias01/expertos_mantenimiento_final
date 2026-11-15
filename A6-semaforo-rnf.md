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

> **Vigencia.** Este corte inicial se refiere a backend `d6fa7e1` y frontend `a3135ec`. El
> complemento de auditoría fechado el 15-nov-2026 conserva las cifras históricas, pero corrige el
> estado vigente de H-08 para el backend `c1b1950` y añade los recorridos de navegador. Véase
> [complemento de semáforo](evidencias-rnf/jose-validacion-2026-11/resumen-ejecutivo.md).

---

## 1. El titular, en tres cifras

**Base del conteo: 23 criterios, no 21.** RNF-18 se cuenta como dos (uptime y MTTR se verifican de
forma distinta) y RNF-20 también (cobertura y OpenAPI). Es la misma base para las dos columnas,
así que la comparación es válida.

| | 8 de noviembre | **15 de noviembre** |
| --- | --- | --- |
| 🟢 Verificados con evidencia | 7 | **9** |
| 🟡 Parciales, con la reserva declarada | 3 | **9** |
| 🔴 Sin instrumento o fuera de alcance | 13 | **5** |
| | 23 | 23 |

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
| **RNF-01** | 20 usuarios concurrentes | 🟡 **Instrumento listo, sin ejecutar** | `jmeter/RNF-01-06-rendimiento.jmx`, `-Jusuarios=20`. Falta PostgreSQL local (ver §4) |
| **RNF-02** | 10 en lectura y escritura simultánea | 🔴 **Sin instrumento** | El plan solo lee; el POST de calificación necesita datos sembrados |
| **RNF-03** | 95 % de autenticaciones < 4 s | 🟡 **Instrumento listo, sin ejecutar** | `POST /api/v1/auth/login` con Duration Assertion de 4 000 ms |
| **RNF-04** | 95 % de CRUD de catálogo < 3 s | 🟡 **Instrumento listo, sin ejecutar** | `GET /profesores` y `GET /asignaturas` con Duration Assertion de 3 000 ms |
| **RNF-05** | 95 % de calificaciones < 3 s | 🔴 **Sin instrumento** | Requiere evaluación y matrícula sembradas |
| **RNF-06** | 90 % de estadísticas < 5 s | 🟡 **Instrumento listo, sin ejecutar** | `GET /niveles-logro` con Duration Assertion de 5 000 ms |
| **RNF-07** | 50 evaluaciones por asignatura/semestre | 🔴 **Sin instrumento** | Verificación de volumen; se siembra y se repite la medición |
| **RNF-08** | 95 % de páginas < 3 s con ≥ 5 Mbps | 🟡 **Presupuesto activo; falta la medición de tiempo** | `angular.json:51-62` — presupuesto `initial` 500 kB aviso / 1 MB error, evaluado en cada `ng build` del CI |
| **RNF-09** | Tiempos sostenidos 4 meses | 🔴 **Fuera de alcance** | La ventana del proyecto son 15 días. Requiere decisión escrita de tratamiento |

### 2.2 Seguridad · RNF-10 a RNF-17 · titular José

| RNF | Criterio y umbral del SRS | Veredicto | Evidencia |
| --- | --- | --- | --- |
| **RNF-10** | BCrypt factor ≥ 12, salt única, nunca en claro | 🟢 **Verificado** | `AuthServiceImplTest`, `AuthControllerTest` en verde (suite completa en el CI de `d6fa7e1`) |
| **RNF-11** | HTTPS con **TLS 1.2+** en producción | 🟢 **Verificado hoy** | Ver §3.1 — medición en vivo contra Render |
| **RNF-12** | JWT HS256+, con `iat`/`exp`, sin datos sensibles | 🟢 **Verificado** | `JwtServiceTest` |
| **RNF-13** | Valida firma y vigencia + RBAC del Apéndice 4.1 | 🟢 **Verificado** | `PrivateEndpointAuthorizationArchitectureTest` (recorre el registro real de Spring MVC), `SecurityRf05IntegrationIT`, Bruno `seguridad-rf05/` |
| **RNF-14** | Validar y sanear la entrada; consultas parametrizadas | 🟡 **Parcial, por inspección** | Jakarta Validation + JPA; **sin prueba dedicada de saneamiento**. Reserva que hay que declarar |
| **RNF-15** | Token expira ≤ 60 min; el cliente lo borra al salir | 🟢 **Verificado** | `JwtServiceTest`, `JwtAuthenticationFilterTest`, `session.service.spec.ts`; `application.yaml:38` → `JWT_EXPIRATION_MS` por defecto 3 600 000 ms = 60 min |
| **RNF-16** | Auditoría append-only, 5 años, autenticaciones exitosas **y fallidas** | 🟢 **Verificado** | `AuditoriaIntegracionIT`, `AuditoriaAspectTest` |
| **RNF-17** | Errores sin contraseñas, tokens, SQL, rutas ni trazas | 🟢 **Verificado** | `HallazgosContratoErrorTest`, `ContratoError*Test`, `GlobalExceptionHandlerTest` |

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
| **RNF-20 (a)** | Cobertura ≥ 70 % en RF-04, RF-05, **RF-14** y **RF-16** | 🟢 **Verificado hoy, tras corregir H-08** | Ver §3.3 — global **92,39 %**; los cuatro módulos por encima del umbral y **vigilados** |
| **RNF-20 (b)** | OpenAPI de todo endpoint protegido con 200/400/401/403/404 | 🟢 **Verificado** | 10 clases `*ApiDocumentacionIT` en verde en el CI; contrato en `/v3/api-docs` |

### 2.6 Accesibilidad · RNF-21 · titular Andrés

| RNF | Criterio y umbral del SRS | Veredicto | Evidencia |
| --- | --- | --- | --- |
| **RNF-21** | WCAG 2.1 AA: contraste ≥ 4.5:1, teclado en notas y observaciones, labels en todo campo | 🟡 **Corregido a mano, sin automatizar** | Andrea Avendaño trabajó el contraste 4,5:1 y el desborde en móvil (ACT-096, PR frontend #91, en estado *Pendiente*). **No hay verificación automática**: `@axe-core/playwright` no está instalado ([H-04](A4-hallazgos-rnf.md)) |

---

## 3. Las tres mediciones nuevas, con su salida real

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

**Consecuencia:** [H-10](A4-hallazgos-rnf.md) se cierra. La única reserva es que esto verifica el
**backend**; el frontend en Vercel hay que medirlo igual, y la URL de producción del frontend no
está escrita en ningún archivo del repositorio (pendiente P-08).

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

## 4. Lo que falta para pasar amarillos a verdes, con nombre y bloqueo

| # | Qué falta | Quién puede | Bloqueo real |
| --- | --- | --- | --- |
| 1 | Abrir el PR del fix de H-08 y que el revisor técnico lo apruebe | Andrés abre · **Jean Paul aprueba** | Ninguno. Está listo y probado |
| 2 | **PostgreSQL local** para correr los 20 usuarios sin tocar Supabase | Andrés | **Docker Desktop no está arrancado.** Es un clic |
| 3 | Activar `SIGRA_ENABLE_DEPENDENCY_REVIEW` y `SIGRA_ENABLE_OWASP_SCA` | **Solo un admin del repo** (Juan Camilo / Jean Paul) | Andrés tiene `push`, **no `admin`**: no puede. Lleva 8 días pedido |
| 4 | SonarQube para la nota de mantenibilidad | Andrés, en local con Docker | Mismo bloqueo que el 2 |
| 5 | `@axe-core/playwright` para automatizar RNF-21 | Equipo de frontend | Decisión del equipo: es una dependencia nueva |
| 6 | URL de producción del frontend en Vercel, para medirle TLS | Quien hizo el despliegue | No está escrita en ningún archivo del repositorio |

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

---

## 6. Trazabilidad con Mantis

| Incidencia | Por qué nos toca | Estado en Mantis | Nuestra lectura |
| --- | --- | --- | --- |
| **0000053** (alta/mayor, 14-nov) | «Falla intermitente al cargar combos … en múltiples módulos, presente en todos los roles», reproducibilidad *a veces* | **nueva · sin asignar** | Síntoma e impacto RNF por confirmar; la causa no está demostrada. Reproducir primero en QA aislado y luego decidir si corresponde JMeter. El manual aplica bloqueo a defectos altos confirmados; validar clasificación e impacto con evidencia |
| **0000038** (alta/mayor) | Mantis la clasifica como **«No Funcionalidad»**; la guía del equipo nos asigna «definir y validar los patrones de paginación y buscadores» | **asignada desde el 8-nov** | 7 días sin movimiento. Es nuestra responsabilidad de validación y no hemos podido ejercerla porque no hay implementación que validar |
| **0000040** (alta/mayor) | Igual: **«No Funcionalidad»**, patrón de paginación | **resuelta** (resolución *abierta*) | Se resolvió **sin que validáramos el patrón**. Hay que revisarla y dejar el veredicto escrito |
| **0000029** (alta/fallo, seguridad) | Bloqueo tras 5 intentos fallidos (RF-04, uno de los 4 módulos del RNF-20) | **resuelta** (resolución *abierta*) | Verificado: está implementado (`Usuario.intentosFallidos`, `fechaBloqueo`, `estaBloqueado`, 423 documentado) y probado. Solo falta cerrar la resolución en Mantis |

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
