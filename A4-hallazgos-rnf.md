# A4 · Registro de hallazgos y riesgos de RNF

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Apertura del registro** | 7 de noviembre de 2026 |
| **Revisión contra el SRS** | 7 de noviembre de 2026 — un hallazgo retirado, uno reformulado, tres nuevos |
| **Sexta revisión** | **16 de noviembre de 2026, noche** — entran los tres instrumentos que faltaban: **OWASP ZAP** autenticado contra el entorno aislado, **Lighthouse CI** y **Trivy** sobre el frontend. Tres hallazgos nuevos (**H-18**, **H-19**, **H-20**), dos observaciones (**OBS-03**, **OBS-04**) y **una corrección**: `dependencyCheckAnalyze` no corre sin clave de NVD, contra lo que decía ACT-122 |
| **Quinta revisión** | **16 de noviembre de 2026, cierre del día** — una tercera corrida de carga, **idéntica en parámetros** a la que abrió H-17, da el resultado contrario. H-17 sigue abierto y en severidad alta, pero su **magnitud pasa a revisión** y deja de bloquear la entrega |
| **Cuarta revisión** | **16 de noviembre de 2026, tarde** — primera medición de carga: entra **H-17**, la tensión medida entre RNF-10 y RNF-03 |
| **Tercera revisión** | **16 de noviembre de 2026** — H-08 confirmado integrado en `develop`; H-10 completado en los dos lados; las dos observaciones de la auditoría de José quedan como **OBS-01 y OBS-02**, fuera del registro de RNF por no tener anclaje en el SRS |
| **Segunda revisión** | **15 de noviembre de 2026** — dos hallazgos cerrados con evidencia, dos en corrección, uno sube de severidad, cuatro nuevos |
| **Alcance de este lote** | Diagnóstico de la capacidad de verificación de los 21 RNF del SRS (Entrega 1) y **verificación inicial** (Entrega 2) |
| **Commit verificado** | backend `d6fa7e1` · frontend `a3135ec` (ambos = `origin/develop`, 14-nov-2026) |
| **Método** | SRS de SIGRA; workflows de CI, `build.gradle`, `package.json`, `e2e/`, suite de pruebas y README de ambos repositorios; **exportación de Mantis del 15-nov (`estado de mantis.csv`), API de GitHub, medición en vivo contra Render y JMeter 5.6.3** |

> **Qué es este documento.** El manual nos pide «definir criterios de verificación, identificar
> riesgos y documentar hallazgos» (§3.5). Cada hallazgo va con su evidencia verificable.
>
> **Naturaleza de este primer lote.** No son defectos introducidos por un mantenimiento: son
> límites en la **capacidad de verificar** el producto que recibimos, más un incumplimiento
> documentable del SRS (H-08). Importan porque si no se cierran, hay RNF que no vamos a poder
> verificar el día 15, y «los requisitos no funcionales fueron verificados» es un criterio de
> finalización (§13).

> **Vigencia.** La tabla original se basa en los SHAs indicados en los metadatos. El seguimiento
> del 15-nov al final de este archivo agrega una comprobación posterior del backend `c1b1950` y
> corrige la hipótesis de causa de H-11. Consulta ese seguimiento antes de reutilizar los estados.

---

## Resumen

### Estado al 15 de noviembre de 2026

| ID | Severidad | Atributo | Hallazgo | Titular | Estado |
| --- | --- | --- | --- | --- | --- |
| [H-08](#h-08-alta--rnf-20-vigila-la-cobertura-de-dos-de-los-cuatro-módulos-obligatorios) | **Alta** | Mantenibilidad | RNF-20 vigila la cobertura de dos de los cuatro módulos obligatorios | Ambos | 🟢 **CERRADO** · integrado en `develop` (`bb72c07`, PR #117) |
| [H-10](#h-10-media--rnf-11-tls-12-no-es-verificable-sin-entorno-de-producción) | Media | Seguridad | RNF-11 (TLS 1.2+) no es verificable sin entorno de producción | José | 🟢 **Cerrado** · 15-nov · la premisa cambió: hay producción |
| [H-01](#h-01-alta--el-análisis-de-dependencias-del-backend-está-apagado) | **Alta** | Seguridad | El análisis de dependencias del backend está apagado | José | 🔴 **Abierto · 9 días** · **ya con el dato: 4 CRITICAL y 10 HIGH** |
| [H-11](#h-11-alta--0000053-sin-dueño-y-con-impacto-rnf-por-confirmar) | **Alta** | Rendimiento / fiabilidad | 0000053 sin dueño; impacto RNF y causa por confirmar | Andrés | 🔴 **Abierto** · sin cambio en Mantis al 16-nov |
| [H-17](#h-17-alta--el-login-se-degrada-bajo-presión-de-cpu-por-el-bcrypt-que-exige-rnf-10) | **Alta** | Rendimiento | El login se degrada bajo presión de CPU por el factor de BCrypt que exige RNF-10; **cuánto, todavía no es reproducible** | Andrés | 🟠 **Nuevo · 16-nov** · medido, **magnitud en revisión** (tercera corrida contradice a la primera) |
| [H-03](#h-03-media--alta-el-15-nov--el-e2e-de-navegador-cubre-un-solo-flujo) | **Alta** ⬆ | Mantenibilidad | El E2E de navegador cubre un solo flujo, y el producto creció ocho módulos | Ambos | 🔴 **Abierto · sube de media a alta** |
| [H-02](#h-02-alta--nueve-requisitos-de-rendimiento-sin-un-solo-instrumento-de-medición) | **Alta** | Rendimiento | Nueve requisitos de rendimiento sin un solo instrumento de medición | Andrés | 🟡 **En corrección** · instrumento creado, sin ejecutar |
| [H-09](#h-09-media--rnf-18-no-tiene-medición-de-uptime-ni-de-mttr) | Media | Disponibilidad | RNF-18 no tiene medición de uptime ni de MTTR | José | 🟡 **En corrección** · uptime medido; MTTR sin evento |
| [H-12](#h-12-media--los-dos-rnf-que-el-equipo-nos-asignó-se-resolvieron-sin-nuestra-validación) | Media | Mantenibilidad | Los dos RNF que el equipo nos asignó se resolvieron sin nuestra validación | Ambos | 🔴 **Nuevo** · 15-nov |
| [H-13](#h-13-media--ninguna-incidencia-está-cerrada-en-mantis) | Media | Trazabilidad | Ninguna de las 31 incidencias está en estado `cerrada` en Mantis | Ambos | 🔴 **Nuevo** · 15-nov |
| [H-04](#h-04-media--rnf-21-no-tiene-verificación-automatizada) | Media | Accesibilidad | RNF-21 no tiene verificación automatizada | Andrés | 🟡 **En corrección** · 16-nov noche: Lighthouse CI da **1,00 en `/login`**; las pantallas autenticadas siguen sin medir (bloqueado por H-20) |
| [H-05](#h-05-media--no-hay-análisis-estático-de-código) | Media | Mantenibilidad | No hay análisis estático de código | Ambos | 🟡 **Cerrado en el backend** · Sonar: mantenibilidad **A**, deuda 15 min. **Frontend sin escanear y el criterio de cierre escrito —linter en el CI— no se cumple** |
| [H-14](#h-14-baja--el-entorno-local-no-puede-compilar-el-frontend) | Baja | Mantenibilidad | El entorno local no puede compilar el frontend (Node por debajo del mínimo) | Andrés | 🔴 **Abierto** · 15-nov |
| [H-07](#h-07-baja--el-readme-del-backend-contradice-a-buildgradle-sobre-jacoco) | Baja | Mantenibilidad | El README del backend contradice a `build.gradle` sobre JaCoCo | Ambos | 🔴 **Abierto** · ahora también desactualizado por el fix de H-08 |
| [H-06](#h-06--retirado-por-falso) | — | — | ~~Ningún RNF numerado cubre disponibilidad~~ | — | **Retirado por falso** · 7-nov |

### Movimiento del 8 al 16 de noviembre

| | 8-nov | 15-nov | 16-nov | **16-nov noche** |
| --- | --- | --- | --- | --- |
| Abiertos | 9 | 7 | 8 | **11** |
| En corrección | 0 | 4 | 4 | **4** |
| Cerrados con evidencia | 0 | 2 | 2 | **2** |
| De severidad alta | 3 | 4 | 4 | **6** (H-01, H-03, H-11, H-17, **H-18**, **H-20**) |
| Total del registro | 10 | 14 | 15 | **18** |
| Observaciones sin anclaje en el SRS | — | — | 2 | **4** |

### Nuevos de la noche del 16 de noviembre — los que salieron de los instrumentos

| ID | Severidad | Atributo | Hallazgo | Instrumento que lo encontró |
| --- | --- | --- | --- | --- |
| [H-18](#h-18-alta--nueve-endpoints-de-listado-responden-500-ante-un-nombre-de-parámetro-vacío) | **Alta** | Seguridad · RNF-14 | Nueve endpoints de listado responden 500 ante un nombre de parámetro vacío | OWASP ZAP, escaneo activo autenticado |
| [H-20](#h-20-alta--el-frontend-del-entorno-aislado-está-compilado-contra-la-base-de-producción) | **Alta** | Entorno de verificación | El frontend del entorno «aislado» está compilado contra la base de producción | Preparación de Lighthouse autenticado |
| [H-19](#h-19-media--un-byte-nulo-en-un-filtro-de-texto-llega-hasta-postgresql-y-la-respuesta-dice-409) | Media | Seguridad · RNF-14 | Un byte nulo en un filtro de texto llega hasta PostgreSQL; la respuesta dice 409 | OWASP ZAP |
| [OBS-03](#obs-03-baja--cabecera-de-aislamiento-ausente-y-actuatorhealth-sin-autenticación) | Baja | Configuración | `Cross-Origin-Resource-Policy` ausente y `/actuator/health` sin autenticación | OWASP ZAP |
| [OBS-04](#obs-04-baja--la-auditoría-guarda-hora-local-sin-zona-y-el-reloj-del-motor-va-en-utc) | Baja | Modelo de datos | La auditoría guarda hora local sin zona y el motor va en UTC | Verificación del efecto de ZAP en la base |

**Lo que estos cinco tienen en común, y por qué importa para la reunión del 17.** Los catorce
hallazgos anteriores eran, casi todos, **límites de nuestra capacidad de verificar**. Estos cinco
salen de **ejecutar** los instrumentos contra el producto, y tres apuntan al producto, no a
nosotros. Es el cambio de etapa que el registro venía esperando desde H-17.

Y dejaron también evidencia **a favor** del producto, que vale igual: con 120 reglas activas de
ZAP, **ninguna de las 81 operaciones de la API respondió nada sin token** (RNF-13, *deny by
default*, verificado en ejecución y no solo con pruebas unitarias) y **ningún cuerpo de error
filtró traza, clase, SQL ni ruta interna** (RNF-17). Y Lighthouse dio **1,00 de accesibilidad** en
`/login` en las seis corridas (RNF-21, con el alcance limitado que se explica en H-04).

> **Corrección del propio registro, hecha el 16-nov por la tarde.** Esta tabla llegó a decir
> **3 cerrados** contando H-05. Al revisar su criterio de cierre escrito —*«el CI ejecuta el linter
> y falla si hay hallazgos»*— **no se cumple**, y el hallazgo abarcaba los dos repositorios
> mientras solo se escaneó el backend. Vuelve a **en corrección**. Es nuestra propia regla de método
> aplicada a nosotros: el instrumento montado no es el criterio
> cumplido.

**H-17 es distinto de todos los anteriores y conviene notarlo:** es el primero que sale de una
**medición** y no de inspeccionar configuración. Durante nueve días el registro habló de
«instrumentos que faltan»; este sale de un instrumento ya corriendo.

Y trajo una segunda lección, menos cómoda: **al repetir la misma corrida, el resultado cambió por
completo**. El hallazgo se mantiene porque la causa —la tensión entre el BCrypt factor 12 que
exige RNF-10 y los tiempos que exige RNF-03— está identificada y es estructural; lo que está en
revisión es **cuánto** pesa. Queda escrito tal cual, con las dos corridas a la vista, porque un
registro de hallazgos que solo muestra las mediciones que confirmaron la sospecha no sirve para
nada.

Además, **dos observaciones que no son hallazgos de RNF** (OBS-01 y OBS-02): reales, reportables y
útiles, pero sin anclaje en el SRS. Ver la sección de observaciones al final.

**Lo que hay que decir de entrada.** Dos hallazgos se cierran con evidencia reproducible, y uno de
los dos —H-08— era **el único incumplimiento documentable del SRS** que teníamos: se corrigió con
cuatro líneas y la cobertura de los cuatro módulos obligatorios está hoy en 92,14 %, 100 %,
74,47 %, 96,21 %, 96,48 % y 93,69 %, todas por encima del 70 % y **ahora sí vigiladas**.

Pero hay que decir también lo incómodo: **H-01 lleva ocho días abierto** y su corrección son dos
variables de repositorio que nosotros no tenemos permiso para crear; y **H-03 sube a severidad
alta** porque el producto creció ocho módulos nuevos en una semana y la red de regresión de
navegador sigue recorriendo exactamente un flujo.

### Lo que hay que decir junto con los hallazgos

La red de pruebas de SIGRA es amplia y hay que reconocerlo al presentar: **85 clases de prueba
unitaria y 33 de integración** en el backend, **100 specs** en el frontend, 490 peticiones Bruno,
documentación OpenAPI con 10 clases de prueba que la verifican, y
`PrivateEndpointAuthorizationArchitectureTest`, una guardia arquitectónica que recorre el registro
real de Spring MVC y comprueba que ninguna ruta privada quede solo detrás de `authenticated()`.
Presentar los huecos sin reconocer esto nos haría ver como que no leímos el producto — y varios de
estos hallazgos se cierran apoyándose en lo que ya existe.

---

## H-01 (alta) — El análisis de dependencias del backend está apagado

**Atributo.** Seguridad.
**RNF comprometidos.** Transversal a RNF-10 a RNF-17: una dependencia vulnerable puede romper
cualquiera de ellos.

**Qué se encontró.** El CI del backend define dos trabajos de análisis de composición de software
y los dos están condicionados a variables de repositorio que no están habilitadas:

- `analisis-dependencias` (GitHub *Dependency Review*) corre solo si
  `vars.SIGRA_ENABLE_DEPENDENCY_REVIEW == 'true'`.
- `analisis-dependencias-gradle` (OWASP Dependency-Check) corre solo si
  `vars.SIGRA_ENABLE_OWASP_SCA == 'true'`, y además necesita el secreto `NVD_API_KEY`.

El propio archivo lo advierte: *«Ambos quedan reportados como SKIPPED por defecto, NO como PASS de
seguridad.»*

**Cómo se reproduce.** Abrir cualquier corrida reciente de CI del backend: los dos trabajos
aparecen como *skipped*. O revisar `Settings → Secrets and variables → Actions → Variables`.

**Evidencia.** `software4-SIGRA-backend/.github/workflows/ci.yml`, condiciones `if:` de los dos
trabajos.

**Riesgo.** Una dependencia del backend con vulnerabilidad conocida entra y nadie se entera. Es
asimétrico frente al frontend, que sí ejecuta `npm audit --audit-level=high` en cada corrida: hoy
la mitad del producto tiene sus dependencias auditadas y la otra no — y es la mitad que guarda las
contraseñas, emite los JWT y sostiene el historial de auditoría.

**Severidad.** **Alta**, y es el hallazgo de corrección más barata de todo el registro: dos
variables de repositorio.

**Dueño.** Quien tenga permisos de administración del repositorio (confirmar en la reunión del 8).

**Criterio de cierre.** En el próximo PR hacia `develop`, *Dependency Review* aparece ejecutado
(no *skipped*) y termina sin hallazgos de severidad `moderate` o superior. Evidencia: enlace a la
corrida.

**Estado.** 🔴 **Abierto.**

**Seguimiento · 15 de noviembre de 2026.** Reconfirmado de forma autoritativa, no por inspección
del workflow sino consultando la API de GitHub:

```
$ gh api repos/juancabernal/software4-SIGRA-backend/actions/variables
{"variables":[],"total_count":0}
```

**Cero variables de repositorio.** Las dos condiciones `vars.SIGRA_ENABLE_DEPENDENCY_REVIEW == 'true'`
(`ci.yml:41`) y `vars.SIGRA_ENABLE_OWASP_SCA == 'true'` (`ci.yml:57`) siguen evaluando a falso, así
que los dos trabajos de SCA se saltan en cada corrida. En las ocho corridas de CI del 12 al 15 de
noviembre el resultado fue el mismo: *skipped*, que el propio workflow advierte en su comentario
que **no significa auditado**.

**Por qué no lo hemos corregido nosotros.** Consultando los permisos efectivos:

```
$ gh api repos/juancabernal/software4-SIGRA-backend --jq '.permissions'
{"admin":false,"maintain":false,"pull":true,"push":true,"triage":true}
```

Crear una variable de repositorio exige `admin`. **No es desgana nuestra: es falta de permiso.**
Esto convierte H-01 en un pedido al equipo, no en una tarea nuestra (P-05, reunión 1).

**Seguimiento · 16 de noviembre de 2026 · noveno día.** Reconsultado hoy, sin cambio:

```
$ gh api repos/juancabernal/software4-SIGRA-backend/actions/variables
{"variables":[],"total_count":0}
```

Entre tanto el backend siguió integrando: PR #117, #118 y el R4 de Salomé González pasaron por CI
el 16 de noviembre, **todos con el SCA saltado**. Cada PR que entra sin ese análisis amplía la
superficie no auditada.

**Corrección a lo que dijimos antes.** El 15 de noviembre escribimos «no es desgana nuestra: es
falta de permiso». Eso es cierto **solo para la compuerta de CI**, y conviene separar las dos
cosas, porque mezclarlas nos sirvió de excusa durante nueve días:

| | ¿Podemos nosotros? |
| --- | --- |
| **Auditar** las dependencias del backend hoy | ✅ **Sí.** El plugin `org.owasp.dependencycheck` **ya está aplicado** (`build.gradle:5`) y configurado con `failBuildOnCVSS = 4.0` (línea 53). `./gradlew dependencyCheckAnalyze` corre en local **sin ningún permiso especial** |
| Que el análisis **bloquee** un PR que introduzca una CVE | ❌ No. Eso exige crear las variables de repositorio, y eso exige `admin` |

Es decir: **el hallazgo sigue abierto, pero la mitad que importa para verificar RNF ya no está
bloqueada.** Podemos producir el informe de vulnerabilidades nosotros mismos y llevarlo a la
reunión; lo que seguimos necesitando del admin es que quede como compuerta permanente.

Nota operativa: sin `NVD_API_KEY` la primera descarga de la base de datos de vulnerabilidades es
lenta (puede tardar bastante). Hay dos salidas: pedir una clave gratuita del NVD, o usar **Trivy**
en Docker, que trae su propia base y no necesita clave.

### El dato que faltaba · 16 de noviembre de 2026

Se ejecutó el análisis por la vía que **no** necesita permisos: Trivy sobre la imagen
`sigra-backend:local`, que contiene el jar con las dependencias que realmente se ejecutan.

| Origen | CRITICAL | HIGH | MEDIUM | LOW |
| --- | --- | --- | --- | --- |
| **Librerías Java (`jar`)** | **4** | **10** | 4 | — |
| Sistema operativo base (ubuntu) | — | — | 56 | 4 |

**Las librerías afectadas, todas con versión de arreglo disponible:**

| Librería | Instalada | Arreglo | CVE |
| --- | --- | --- | --- |
| `org.apache.tomcat.embed:tomcat-embed-core` | 11.0.24 | 11.0.25 | CVE-2026-65182, CVE-2026-65905, CVE-2026-68525, CVE-2026-65637 |
| `com.fasterxml.jackson.core:jackson-databind` | 2.21.5 | 2.21.7 | CVE-2026-68497, CVE-2026-91776, CVE-2026-91777 |
| `com.fasterxml.jackson.core:jackson-core` | 2.21.5 | 2.21.7 | CVE-2026-89407, CVE-2026-89425 |
| `tools.jackson.core:jackson-databind` | 3.1.5 | 3.1.7 | CVE-2026-68497, CVE-2026-91776, CVE-2026-91777 |
| `tools.jackson.core:jackson-core` | 3.1.5 | 3.1.7 | CVE-2026-89407, CVE-2026-89425 |

**Evidencia.** `herramientas-rnf/evidencias/trivy-backend-16nov.json`.

**Qué nos interesa y qué no.** Los 56 MEDIUM del sistema operativo base **no son nuestro asunto**:
se corrigen cambiando la imagen base y eso es una decisión de despliegue. Los **14 de severidad alta
o crítica en librerías Java sí**, y son exactamente lo que la compuerta apagada de H-01 habría
detectado en su momento: el `dependencyCheck` del proyecto está configurado con
`failBuildOnCVSS = 4.0`, así que **habría hecho fallar el build**.

**Cómo esto cambia la conversación en la reunión.** Durante nueve días el hallazgo fue «falta
habilitar la compuerta», que es fácil de postergar. Ahora es **«hay 4 vulnerabilidades críticas y
10 altas en dependencias, todas con arreglo publicado, y el proyecto lleva nueve días sin
detectarlas»**. Lo que se pide sigue siendo lo mismo —dos variables de repositorio— pero ya no es
una formalidad de proceso.

**Importante sobre el alcance de la corrección.** Actualizar esas librerías **no es trabajo
nuestro** ni debería hacerse a ciegas el día antes del cierre: `tomcat-embed-core` viene con Spring
Boot y subirlo a mano puede romper la compatibilidad. Lo que corresponde es **reportar el dato** y
que el equipo decida con el revisor técnico.

**Corrección del 16 de noviembre, noche: `dependencyCheckAnalyze` NO corre en local.** En
**ACT-122** quedó escrito que sí, y que «lo bloqueado era la compuerta de CI, no la auditoría».
**La primera mitad es falsa.** Se ejecutó y falla a los 40 segundos:

```
Caused by: io.github.jeremylong.openvulnerability.client.nvd.NvdApiException:
  Invalid API Key, length of 0 too short to provided a masked partial key
> Task :dependencyCheckAnalyze FAILED        (BUILD FAILED in 40s)
```

El plugin 13.0.0 construye su catálogo desde la API de NVD y **exige clave**. `build.gradle:57-62`
solo la pasa si existe `NVD_API_KEY`, y no existe ni en el entorno ni en `~/.gradle`; sin catálogo
en caché, el análisis no arranca. Es el **cuarto** caso del mismo error de método: se afirmó sin
ejecutar.

**Lo que esto cambia, y lo que no.** El dato de las 4 CRITICAL y 10 HIGH **sigue en pie**: lo dio
Trivy, que no pide clave. Lo que cambia es el camino alterno que el registro ofrecía. Y hay una
buena noticia dentro: **la clave de NVD es gratuita y autogestionada**
(`nvd.nist.gov/developers/request-an-api-key`, llega por correo), así que **no depende del permiso
de administrador de H-01** y la puede pedir cualquiera de los dos. Son dos pedidos distintos, y
conviene no volverlos a mezclar:

| Pedido | A quién | Para qué |
| --- | --- | --- |
| Dos variables de repositorio | Admin del repositorio (Juan Camilo / Jean Paul) | La compuerta de SCA en el CI — **el hallazgo H-01** |
| Clave de NVD | A NIST, por formulario | Que `dependencyCheckAnalyze` corra, con su `failBuildOnCVSS = 4.0` |

**Evidencia de esta corrección.** Salida completa de `./gradlew dependencyCheckAnalyze
--no-daemon` del 16-nov · `herramientas-rnf/README.md` §8.1.

---

## H-02 (alta) — Nueve requisitos de rendimiento sin un solo instrumento de medición

> **Reformulado el 7 de noviembre.** Se abrió como «RNF-08 no tiene forma de medirse». Al leer el
> SRS resultó que el rendimiento no es un requisito sino **nueve** (RNF-01 a RNF-09), todos con
> umbrales numéricos. El hallazgo es considerablemente más grande de lo que se afirmó.

**Atributo.** Rendimiento.
**RNF comprometidos.** RNF-01, 02, 03, 04, 05, 06, 07, 08, 09 — los nueve.

**Qué se encontró.** El SRS fija umbrales concretos y medibles para el rendimiento:

| RNF | Umbral que exige el SRS |
| --- | --- |
| RNF-01 | 20 usuarios registrados concurrentes |
| RNF-02 | 10 de ellos en lectura y escritura simultánea |
| RNF-03 | 95 % de autenticaciones en menos de 4 s |
| RNF-04 | 95 % de CRUD de catálogo en menos de 3 s |
| RNF-05 | 95 % de registros de calificación en menos de 3 s |
| RNF-06 | 90 % de consultas de estadísticas en menos de 5 s |
| RNF-07 | 50 evaluaciones por asignatura y semestre sin degradación |
| RNF-08 | 95 % de páginas cargadas en menos de 3 s con ≥ 5 Mbps |
| RNF-09 | Sostener esos tiempos durante 4 meses de operación continua |

**Ninguno tiene instrumento.** No hay prueba de carga, ni medición de tiempos de respuesta, ni
Lighthouse, ni presupuesto de bundle, ni monitoreo. El README del backend asigna «pruebas no
funcionales (carga, tiempos de respuesta, seguridad)» como responsabilidad transversal, pero no
hay nada implementado.

**Cómo se reproduce.** Buscar JMeter, Gatling, k6, Lighthouse o `budgets` en los dos repositorios
y en los dos workflows de CI: no aparecen.

**Evidencia.** Los dos `ci.yml`; `angular.json` sin presupuestos declarados.

> **Ojo con un falso positivo.** Existe una clase `RendimientoSeguridadWebTest`, pero
> «Rendimiento» ahí es el nombre del dominio —el rendimiento *académico* del estudiante en un
> Resultado de Aprendizaje— y no tiene relación con el atributo de calidad. No la citemos como
> evidencia.

**Riesgo.** El día 15 tendremos que dar veredicto sobre nueve RNF y la única respuesta honesta
será «no verificado». Eso incumple el criterio de finalización del §13 para casi la mitad del
catálogo. En el camino, cualquier mantenimiento puede degradar un tiempo de respuesta o inflar el
bundle sin que nada lo detecte.

**Severidad.** **Alta.** No por el estado actual del rendimiento —que podría estar perfectamente
bien— sino porque no hay forma de saberlo ni de defenderlo, y porque son nueve requisitos, no uno.

**Dueño.** Propuesta de Andrés; implementación y alcance a acordar con el equipo.

**Criterio de cierre.** No se puede cerrar completo en 15 días y **hay que decirlo así**. Alcance
mínimo realista, en orden:

1. **Presupuesto de bundle** en `angular.json` que haga fallar `ng build` si se excede → cubre la
   parte preventiva de RNF-08.
2. **Medición manual con el panel de red** del navegador sobre los flujos tocados, con captura →
   deja evidencia para RNF-03 a RNF-06, aunque no previene regresiones.
3. **Declarar RNF-01, 02, 07 y 09 fuera del alcance** de este mantenimiento, con justificación: 20
   usuarios concurrentes y 4 meses de operación continua no se pueden simular en la ventana del
   proyecto sin herramienta de carga y sin entorno de producción.

**Estado.** 🟡 **En corrección.**

**Seguimiento · 15 de noviembre de 2026.** El hallazgo era «no hay un solo instrumento». Ya hay
instrumento, versionado en el repositorio:

| Archivo | Qué mide |
| --- | --- |
| `jmeter/RNF-18-disponibilidad.jmx` | RNF-18 (uptime) — **ejecutado**, ver H-09 |
| `jmeter/RNF-01-06-rendimiento.jmx` | RNF-01 (20 concurrentes), RNF-03 (< 4 s), RNF-04 (< 3 s), RNF-06 (< 5 s) — **sin ejecutar** |
| `jmeter/README.md` | Instalación, ejecución, umbrales del SRS y reservas que hay que declarar |

Los umbrales están puestos como **Duration Assertion** con los valores textuales del SRS, así que
una muestra que se pase del umbral cuenta como error en el informe de JMeter. `-Jusuarios=20` es
RNF-01 literal.

**Por qué sigue sin ejecutarse, y es un hallazgo en sí mismo.** El `.env` del backend apunta a
`aws-0-us-east-1.pooler.supabase.com`: **la misma base de datos que usa el despliegue de Render**.
Levantar el backend «en local» con ese `.env` no es local — la carga de 20 usuarios le caería a la
base compartida del equipo, la misma noche de una entrega. Correr la prueba así sería una prueba
de carga en producción disfrazada de prueba local.

Lo correcto es PostgreSQL local en Docker con `docs/db/SIGRA_SCHEMA_CURRENT.sql`, y eso está
**bloqueado por un detalle operativo**: Docker Desktop no está arrancado en la máquina
(`error during connect: ... dockerDesktopLinuxEngine: The system cannot find the file specified`).

**Reducción de alcance medida.** De nueve requisitos sin instrumento quedan cuatro: RNF-02 y
RNF-05 (necesitan escritura con datos sembrados), RNF-07 (verificación de volumen) y RNF-09
(cuatro meses, fuera de la ventana del proyecto).

**RNF-08 ya tiene su cifra**, y cierra el compromiso C-01. El presupuesto existía y nunca se había
leído: `angular.json:51-62` declara `initial` con aviso a 500 kB y error a 1 MB, y se evalúa en
cada `ng build` del CI. El valor real, de la corrida 43684672703 del 15-nov a las 06:16:

```
Initial chunk files | Names         |  Raw size | Estimated transfer size
                    | Initial total | 356.04 kB |               100.14 kB
```

**356,04 kB sin comprimir y 100,14 kB transferidos, contra un tope de aviso de 500 kB: cumple con
29 % de margen.** Propuesta concreta para RNF-08: **bajar el aviso de 500 kB a 420 kB**, que deja
18 % de crecimiento y detecta una regresión antes de que el margen se agote. El tope de error se
deja en 1 MB.

---

## H-08 (alta) — RNF-20 vigila la cobertura de dos de los cuatro módulos obligatorios

> **Nota de vigencia · 15-nov-2026.** La evidencia de corrección citada en esta sección es
> histórica y se atribuye a `d6fa7e1`. En el backend inspeccionado para esta auditoría (`c1b1950`)
> la regla por paquete de `estadisticas` no está presente; no transferir el cierre a esa rama.
> Véase el [seguimiento](evidencias-rnf/jose-validacion-2026-11/mantenibilidad.md).

**Atributo.** Mantenibilidad.
**RNF comprometido.** **RNF-20 (a)** — incumplimiento directo y demostrable.

**Qué se encontró.** RNF-20 exige pruebas automatizadas que cubran **al menos el 70 % de la lógica
de negocio de cuatro módulos obligatorios**, nombrados uno por uno en el SRS:

| Módulo obligatorio del SRS | ¿Vigilado por el umbral de JaCoCo? |
| --- | --- |
| Autenticación (RF-04) | 🟢 Sí — `co.edu.uco.sigra.auth.service*`, `auth.controller` |
| Control de acceso por rol (RF-05) | 🟢 Sí — `co.edu.uco.sigra.auth.security`, `config` |
| **Cálculo de nivel de logro (RF-14)** | 🔴 **No** |
| **Generación de conclusiones (RF-16)** | 🔴 **No** |

La configuración de `jacocoTestCoverageVerification` incluye una regla por paquete para los dos
primeros y **omite los otros dos**. El propio archivo lo admite en un comentario:

```groovy
// Nivel de logro: agregar 'co.edu.uco.sigra.estadisticas.service*' cuando exista RF-14.
```

Ese comentario quedó obsoleto: **RF-14 y RF-16 ya existen y tienen pruebas** —
`NivelLogroServiceImplTest`, `NivelLogroIntegracionIT`, `ConclusionServiceImplTest`,
`ConclusionIntegracionIT`, `EstadisticasControllerTest` — pero su cobertura **no está vigilada por
ningún umbral**, así que puede bajar del 70 % sin que el build falle.

**Cómo se reproduce.**

```bash
sed -n '99,125p' software4-SIGRA-backend/SIGRA/build.gradle   # la lista de paquetes vigilados
find software4-SIGRA-backend/SIGRA/src/test -name '*NivelLogro*' -o -name '*Conclusion*'
```

**Evidencia.** `software4-SIGRA-backend/SIGRA/build.gradle:99-125`, bloque
`jacocoTestCoverageVerification`, lista `includes` de la regla `element = 'PACKAGE'`.

**Riesgo.** Hoy el proyecto cree cumplir RNF-20 y lo cumple a medias. La regla global del 70 %
puede estar satisfecha mientras el nivel de logro y las conclusiones —que son precisamente la
lógica de negocio más delicada de SIGRA, la que calcula el desempeño de los estudiantes— quedan
por debajo del umbral sin que nadie se entere. Y es justo lo que un mantenimiento puede degradar:
agregar una rama no probada al cálculo del nivel de logro no rompe nada visible.

**Severidad.** **Alta.** Es el único hallazgo del lote que es un **incumplimiento de un requisito
del SRS**, no una ausencia de herramienta. Y su corrección es de dos líneas.

**Dueño.** Por asignar. La corrección es agregar los paquetes de `estadisticas` a la lista
`includes` y actualizar el comentario obsoleto.

**Criterio de cierre.** `./gradlew jacocoTestCoverageVerification` falla si la cobertura de
`co.edu.uco.sigra.estadisticas.service*` baja del 70 %, igual que ya pasa con `auth`. Evidencia:
el diff de `build.gradle` y una corrida del comando.

**Estado.** 🟢 **CERRADO · integrado en `develop` el 16 de noviembre de 2026.**

**Seguimiento · 16 de noviembre.** El fix se integró vía **PR #117** y hoy está en
`origin/develop` (`bb72c07`), con el comentario de RF-14/RF-16 incluido:

```
$ git show origin/develop:SIGRA/build.gradle | sed -n '111,119p'
            includes = [
                    'co.edu.uco.sigra.auth.service*',
                    'co.edu.uco.sigra.auth.controller',
                    'co.edu.uco.sigra.auth.security',
                    'co.edu.uco.sigra.config',
                    // RF-14 (calculo de nivel de logro) y RF-16 (generacion de conclusiones):
                    // el SRS los nombra como modulos obligatorios del RNF-20 (a). Hallazgo H-08.
                    'co.edu.uco.sigra.estadisticas.service*'
            ]

$ git diff SIGRA/build.gradle          # vacío: no queda nada pendiente de subir
```

**RNF-20 (a) cumple en la rama integrada, no solo en una copia de trabajo.** Era el único
incumplimiento documentable del SRS de todo el registro, y queda cerrado.

> ⚠️ **Corrección a una nota que circula en el repositorio.** El
> [registro de la auditoría de José](evidencias-rnf/jose-validacion-2026-11/hallazgos.md) dice
> «En la rama backend inspeccionada (`c1b1950`) falta todavía la regla por paquete de
> `estadisticas`; no cerrar H-08 para esta versión». **Era exacto para `c1b1950`**, donde solo
> estaba el comentario viejo —y por eso el método de José fue el correcto: verificó el SHA que
> tenía delante en vez de creerle a A4. Pero `c1b1950` es anterior al PR #117 y ya es ancestro de
> `develop`, así que la observación quedó superada por los hechos. La nota de vigencia de
> [A6](A6-semaforo-rnf.md) también se corrigió.
>
> **La lección operativa:** citar siempre el SHA junto a la cifra. «92,39 % de cobertura» sin SHA
> no es verificable por nadie más, y fue lo que hizo que dos personas del mismo rol llegaran a
> conclusiones distintas sobre el mismo hallazgo.

**Corrección aplicada.** Cuatro líneas en `SIGRA/build.gradle`:

```diff
  'co.edu.uco.sigra.auth.security',
- 'co.edu.uco.sigra.config'
- // Nivel de logro: agregar 'co.edu.uco.sigra.estadisticas.service*' cuando exista RF-14.
+ 'co.edu.uco.sigra.config',
+ // RF-14 (calculo de nivel de logro) y RF-16 (generacion de conclusiones):
+ // el SRS los nombra como modulos obligatorios del RNF-20 (a). Hallazgo H-08.
+ 'co.edu.uco.sigra.estadisticas.service*'
```

El comentario que el archivo traía —«agregar cuando exista RF-14»— quedó obsoleto hace tiempo:
`estadisticas/service/` tiene hoy `NivelLogroService` (RF-14) y `ConclusionService` (RF-16), con
`NivelLogroServiceImplTest`, `ConclusionServiceImplTest`, `CatalogoNivelesLogroTest`,
`ProveedorNivelesLogroImplTest` y `RecalculoProgramadoNivelLogroTest`.

**Verificación 1 — la cobertura real cumple.** `./gradlew test jacocoTestReport` sobre `d6fa7e1`:

| Módulo obligatorio del SRS | Paquete | Instrucciones | % |
| --- | --- | --- | --- |
| Global | — | 16 012 / 17 330 | **92,39 %** |
| RF-04 | `auth.service` | 211 / 229 | 92,14 % |
| RF-04 | `auth.service.impl` | 196 / 196 | 100,00 % |
| RF-04 | `auth.controller` | 21 / 21 | 100,00 % |
| RF-05 | `auth.security` | 671 / 901 | 74,47 % |
| RF-05 | `config` | 279 / 290 | 96,21 % |
| **RF-14 y RF-16** | `estadisticas.service` | 137 / 142 | **96,48 %** |
| **RF-14 y RF-16** | `estadisticas.service.impl` | 1 202 / 1 283 | **93,69 %** |

```
$ ./gradlew jacocoTestCoverageVerification
BUILD SUCCESSFUL in 17s
```

**Verificación 2 — la regla ahora muerde.** Es el criterio de cierre que nos pusimos en
[A3 §5](A3-criterios-verificacion.md): no basta con que pase, hay que probar que **fallaría** si la
cobertura bajara. Subiendo temporalmente el umbral de esa regla a 0,99:

```
Rule violated for package co.edu.uco.sigra.estadisticas.service.impl: ... is 0.93, but expected minimum is 0.99
Rule violated for package co.edu.uco.sigra.estadisticas.service:      ... is 0.96, but expected minimum is 0.99
```

JaCoCo **nombra** los dos paquetes nuevos. Antes del cambio eran invisibles para la verificación:
podían caer al 10 % y el build seguía verde. El umbral se dejó en 0,7, que es el del SRS.

**Lo que falta.** Abrir el PR en el backend y que **Jean Paul** lo apruebe. Sin eso el cambio vive
solo en la copia de trabajo y RNF-20 (a) sigue incumplido en `develop`.

**Efecto colateral.** Hace que [H-07](#h-07-baja--el-readme-del-backend-contradice-a-buildgradle-sobre-jacoco)
quede más desactualizado todavía: el README del backend hay que corregirlo en el mismo PR.

---

## H-03 (media → **alta** el 15-nov) — El E2E de navegador cubre un solo flujo

> **Corregido el 7 de noviembre.** Se abrió como severidad **alta** con el título «la red de
> regresión E2E cubre un solo módulo». Al medir la suite completa resultó que la red de regresión
> **no** es escasa: 102 clases en el backend, 74 specs en el frontend y 490 peticiones Bruno. El
> hueco es más estrecho de lo que se afirmó y se **baja a media**. Se deja la corrección a la
> vista porque presentar un hallazgo sobredimensionado le cuesta credibilidad al rol.

**Atributo.** Mantenibilidad (detección de regresión de extremo a extremo).
**RNF comprometido.** RNF-19 parcialmente; transversal al resto.

**Qué se encontró.** La carpeta `e2e/` contiene **un único spec de Playwright**: `auth.spec.ts`.
La infraestructura es sólida —levanta el backend real, una base PostgreSQL efímera con seeds, y
corre en Chromium y Firefox— pero lo único que recorre en navegador es el inicio de sesión.

Lo que sí está cubierto por otras vías:

| Nivel | Cobertura real |
| --- | --- |
| Unitarias y de capa web (backend) | 76 clases, con batería de seguridad notable |
| Integración con PostgreSQL (backend) | 26 clases `*IT` |
| Unitarias y de integración (frontend) | 74 specs |
| API de extremo a extremo | 490 peticiones Bruno, con colección `seguridad-rf05` |
| Documentación de API | 10 clases `*ApiDocumentacionIT` |
| **Navegador de extremo a extremo** | **1 spec (solo autenticación)** |

**Cómo se reproduce.**

```bash
find software4-SIGRA-frontend/e2e -name '*.spec.ts'                  # solo auth.spec.ts
find software4-SIGRA-backend/SIGRA/src/test -name '*.java' | wc -l   # 102
find software4-SIGRA-frontend/src -name '*.spec.ts' | wc -l          # 74
```

**Riesgo.** El hueco específico es el **flujo de usuario completo que atraviesa frontend y backend
en un navegador real**: entrar como profesor, abrir una asignatura, registrar una calificación y
ver el nivel de logro recalculado. Las pruebas unitarias no lo cubren por diseño, y Bruno lo cubre
del lado de la API pero no del render, los guards, el interceptor ni el estado de sesión.

**Severidad.** **Media.** Hay red de regresión y es amplia; falta un nivel concreto. Sube a alta
si un mantenimiento toca los guards, el interceptor de token o el `SessionService`, porque ahí el
único cubrimiento de navegador que existe es precisamente `auth.spec.ts`.

**Dueño.** Analistas de prueba, con los flujos priorizados por nosotros.

**Criterio de cierre.** Todo mantenimiento que toque una vista con interacción tiene, **antes** de
implementarse, un spec de Playwright que recorre su camino principal y queda como prueba de
caracterización de la línea base. Evidencia: el spec en verde en Chromium y Firefox.

**Estado.** 🔴 **Abierto · sube de severidad media a ALTA el 15 de noviembre de 2026.**

**Por qué sube.** La severidad media del 7 de noviembre se justificó así: «hay red de regresión y
es amplia; falta un nivel concreto». Esa justificación dejó de ser cierta, porque el denominador
cambió. Entre el 8 y el 15 de noviembre el producto creció, en los dos repositorios:

| Nuevo | Incidencia | Dónde |
| --- | --- | --- |
| Módulo Reportes con R1, R2 y R6 | 0000041 | backend + frontend |
| Módulo Estudiante: Mis materias, Mi progreso, Mi historial | 0000049 | backend `GET /api/v1/estudiantes/me*` + frontend |
| Entidad Facultad y filtro `facultadId` | 0000036 | backend + frontend |
| `GET /api/v1/semestres/mios` | 0000045 | backend |
| `GET /api/v1/auditoria/mis-eventos` (Mi historial del profesor) | — | backend + frontend |
| Reportes por facultad para los tres roles | 0000036 | frontend |
| Estadísticas separada en tres páginas | 0000048 | frontend |
| Nombres separados en primer/segundo nombre y apellidos | 0000035 | backend + frontend, **con migración de datos** |

**Y la suite E2E de navegador sigue siendo exactamente un archivo:** `e2e/auth.spec.ts`. Lo
verificamos: `ls software4-SIGRA-frontend/e2e/` devuelve `auth.spec.ts` y `README.md`, nada más.

**Seguimiento · 16 de noviembre de 2026: el hueco se ensanchó otra vez.** En un día más entraron
dos módulos de reportes nuevos —**R7 «Trazabilidad de uso por rol»** (Tomás Marín, ACT-102, PR
backend y frontend) y **R4 «Acciones de mejora»** (Salomé González, CI del 16-nov)— además de la
paginación extendida a cuatro pantallas del Estudiante y a los reportes del Profesor. La suite E2E
sigue en un archivo. **Diez módulos nuevos, un flujo de navegador probado.**

Ocho módulos nuevos, varios de ellos con reglas de alcance por rol (el estudiante solo ve lo suyo,
el profesor solo sus semestres, R2 solo administrador) y una migración de datos, **sin una sola
prueba de navegador que los recorra**. RNF-19 pide que los flujos tocados funcionen en los
navegadores exigidos; hoy el único flujo que se comprueba en navegador es el login.

**Lo que lo vuelve urgente y no teórico.** La incidencia **0000053** (ver
[H-11](#h-11-alta--0000053-sin-dueño-y-con-impacto-rnf-por-confirmar)) es
precisamente un fallo intermitente en varios módulos y en todos los roles. Es el tipo de defecto
que una suite E2E amplia habría atrapado y que la actual, por construcción, no puede ver.

**Severidad.** **Alta.** Según el §7, alta bloquea la entrega. No proponemos bloquearla: proponemos
que el equipo decida por escrito si se agrega al menos un spec E2E por rol antes del cierre, o si
se acepta como deuda técnica con justificación.

---

## H-04 (media) — RNF-21 no tiene verificación automatizada

**Atributo.** Accesibilidad.
**RNF comprometido.** RNF-21 (WCAG 2.1 AA).

**Qué se encontró.** La documentación menciona que el frontend «trae `@axe-core/playwright` para
RNF-21». En el estado actual del repositorio: no está en `package.json`, no hay referencia a axe
en `e2e/`, y no hay Lighthouse en el CI.

**Cómo se reproduce.** `grep -rn "axe" software4-SIGRA-frontend/package.json
software4-SIGRA-frontend/e2e/` no devuelve resultados.

**Evidencia.** `software4-SIGRA-frontend/package.json`, dependencias completas sin axe.

**Riesgo.** RNF-21 es uno de los RNF más concretos y verificables del SRS: contraste ≥ 4.5:1,
teclado completo en los formularios de notas y observaciones, `label`/ARIA en todos los campos.
Sin herramienta, su verificación depende de revisar a ojo pantalla por pantalla, lo que no escala
y no deja evidencia. Y las vistas que el SRS nombra explícitamente —notas y observaciones— son las
que más se tocan en mantenimiento.

**Severidad.** **Media.** Hay alternativa manual que deja evidencia. Sube a alta si un
mantenimiento aprobado toca formularios de notas u observaciones.

**Dueño.** Propuesta de Andrés; la instalación es de una línea y el E2E ya existe donde engancharla.

**Criterio de cierre.** axe ejecutado sobre `/login` y sobre una vista privada con formulario, sin
violaciones de impacto `serious` ni `critical`. Evidencia: reporte axe en el PR, o captura de axe
DevTools si se hace manual.

**Estado.** 🟡 **Abierto · hay corrección manual, sigue sin automatizar.**

**Seguimiento · 16 de noviembre de 2026, por la noche — hay una primera señal automática, y no la buscábamos.**
El escaneo del frontend con SonarQube devolvió 7 *code smells*, y **cuatro son de accesibilidad**:

| Regla | Dónde | Qué dice |
| --- | --- | --- |
| `Web:S6845` | `calificaciones/.../planilla-notas-page.html:228` | `<span tabindex="0" aria-label="Registrado fuera de fecha">`: elemento **no interactivo en el orden de tabulación**, y es **la pantalla de notas**, justo donde RNF-21 exige recorrido por teclado. Parece una ayuda deliberada; el precio es una parada de tabulación por fila |
| `Web:S6825` ×3 | `reportes/.../matriculas-programa-semestre-tab.html:95, 114, 128` | `aria-hidden="true"` en `<th>` y `<td>` decorativos. `td`/`th` **no son focusables por defecto**, así que el riesgo práctico es bajo |
| `Web:S9379` | `auth/.../login-page.html:51` | `autofocus` en el campo de correo |

**Qué cambia y qué no.** Cambia que *«RNF-21 no tiene ninguna verificación automatizada»* ya no es
exacto: hay reglas de accesibilidad corriendo sobre las plantillas en cada escaneo, sin instalar
nada en el repositorio del producto. **No cambia el hallazgo**, por tres razones que conviene
decir antes de que las pregunten:

1. **Sonar no mide contraste**, que es el primer umbral literal de RNF-21. Eso sigue siendo
   Lighthouse o axe.
2. **Sonar no recorre la aplicación**: lee plantillas. El «teclado completo en notas y
   observaciones» del SRS **solo se demuestra navegando**.
3. **No muerde**: corre a mano en un portátil, no en el CI.

**Lo que sí hace, y es concreto:** los cuatro entran como **puntos a comprobar en el recorrido
manual por teclado**, con archivo y línea. Ninguno se declara incumplimiento por aparecer en
Sonar; el de `aria-hidden` en particular hay que **confirmarlo navegando** antes de llamarlo
hallazgo. Detalle en [herramientas-rnf §4.8](herramientas-rnf/README.md).

**Seguimiento · 15 de noviembre de 2026.** Hay que reconocer trabajo ajeno que nos toca el tema:
Andrea Avendaño (UI/UX) revisó la documentación para extraer los requisitos de accesibilidad
(ACT-095) y corrigió hallazgos de frontend —**contraste 4,5:1**, paginador común en Evaluaciones,
desborde en móvil— en ACT-096, PR frontend **#91**.

**Seguimiento · 16 de noviembre de 2026.** ACT-096 pasó de *Pendiente* a **Cerrada** en el libro del
equipo, así que la corrección de contraste y de desborde en móvil está integrada. Sigue siendo
corrección manual sin red de seguridad.

Eso es bueno y mejora el cumplimiento real de RNF-21. **No cambia el hallazgo**, que no es «el
contraste está mal» sino «no hay forma automática de saber si se rompe». Sigue sin instalarse
`@axe-core/playwright` y sigue sin haber una comprobación que falle cuando una vista nueva entre
sin `label`.

**Lo que corresponde ahora, y es nuestro trabajo de F4.** Pedirle a Andrea la evidencia concreta
del PR #91 —qué vistas midió, con qué herramienta, y la captura— para poder dar un veredicto
amarillo sostenido en evidencia en lugar de amarillo por ausencia. Y llevar al equipo la decisión
sobre la dependencia nueva, que no es nuestra para tomar.

**Severidad.** Se mantiene **media**.

**Seguimiento · 16 de noviembre de 2026, noche. Ya hay instrumento, y da 1,00.** Lighthouse CI
corre con `npx`, sin contenedor y sin dependencia nueva en el repositorio del producto, y **los
umbrales del SRS están escritos como aserciones** en
`herramientas-rnf/lighthouse/lighthouserc.json`: `categories:accessibility ≥ 0,9` más
`color-contrast`, `label` y `tabindex` en 1. Resultado en tres corridas por URL:

| URL | Accesibilidad | Aserciones de RNF-21 |
| --- | --- | --- |
| `https://sigra.vercel.app/login` | **1,00 · 1,00 · 1,00** | contraste, `label`, `tabindex`, `button-name`, `aria-*`, `target-size`: todas en verde |
| `http://localhost:4200/login` | **1,00 · 1,00 · 1,00** | igual |

**Y aun así el hallazgo no se cierra, por dos razones concretas.**

1. **Alcance de una página.** Lighthouse mide **la página que carga**, y `/login` es la única ruta
   pública. Las pantallas que el SRS nombra explícitamente —**notas y observaciones**, donde hay
   que verificar el recorrido por teclado— están detrás del login. Y son justo donde Sonar
   encontró cuatro *code smells* de accesibilidad (`Web:S6845` `tabindex`, `Web:S6825` ×3). Un
   1,00 en el login **no dice nada** de ellas.
2. **Está bloqueado por [H-20](#h-20-alta--el-frontend-del-entorno-aislado-está-compilado-contra-la-base-de-producción).**
   La corrida autenticada se preparó y **se canceló**: el frontend del 4200 habla con la base de
   producción, así que iniciar sesión para medir habría escrito en producción.

**Criterio de cierre, ahora concreto.** Una imagen del frontend contra el 8081 (H-20) y un
`collect.puppeteerScript` que haga el login antes de medir `profesor/notas` y la pantalla de
observaciones. Con eso, RNF-21 queda automatizado donde el SRS lo exige y H-04 se cierra.

**Estado.** 🟡 **Pasa de abierto a en corrección** · instrumento montado y con dato, alcance
incompleto.

---

## H-05 (media) — No hay análisis estático de código

**Atributo.** Mantenibilidad.
**RNF comprometido.** Ninguno directamente. **RNF-20 exige cobertura y documentación de API, no
análisis estático** — así que esto es una buena práctica ausente, no un incumplimiento del SRS, y
hay que presentarlo con esa precisión.

**Qué se encontró.**

- **Frontend:** el README declara que «el análisis estático (`ng lint`) está pendiente de
  configurar». `prettier` está como dependencia pero no se ejecuta como verificación.
- **Backend:** no hay Checkstyle, SpotBugs, PMD ni SonarQube en `build.gradle` ni en el CI.

Ninguno de los dos tiene métrica de duplicación ni de complejidad ciclomática.

**Evidencia.** `software4-SIGRA-frontend/README.md`, sección de pruebas;
`software4-SIGRA-backend/SIGRA/build.gradle`, sin plugins de análisis estático.

**Riesgo.** Dos, distintos. De proceso: el criterio de «legibilidad» que el revisor técnico aplica
en F3 queda sin respaldo objetivo, y el rechazo de un PR se lee como opinión personal en vez de
criterio del proyecto. De producto: el manual contempla uso intensivo de IA durante los 15 días, y
el riesgo característico del código generado es la duplicación y la complejidad, que es justo lo
que el análisis estático detecta mecánicamente.

**Severidad.** **Media.** El proyecto puede cerrar sin esto y el SRS no lo exige. Pero su ausencia
carga de trabajo manual al revisor técnico, que ya es el cuello de botella del equipo.

**Dueño.** Por acordar. La configuración del frontend es más barata (`ng lint` + prettier, ya
instalado).

**Criterio de cierre.** El CI ejecuta el linter y falla si hay hallazgos. Evidencia: paso del
workflow en una corrida.

**Estado.** 🟡 **En corrección · 16 de noviembre de 2026, por la noche.** **Los dos repositorios están
escaneados**, con mantenibilidad **A** en ambos. Lo que impide cerrarlo es el criterio que nosotros
mismos escribimos: **el CI no ejecuta el análisis**, y eso depende de un permiso `admin` que no
tenemos (ver la reserva sobre el cierre, al final de este hallazgo).

**Instrumento montado y ejecutado.** SonarQube Community 26.11 en Docker
([herramientas-rnf §4](herramientas-rnf/README.md)), con una puerta de calidad cuya primera
condición es el umbral textual de RNF-20 (a): `coverage < 70` hace fallar la puerta.

**Resultado del primer escaneo** (backend `bb72c07`, 14 422 líneas):

| Métrica | Valor |
| --- | --- |
| **Puerta de calidad** | **OK** |
| **Mantenibilidad** | **A** |
| **Deuda técnica** | **15 minutos** |
| Cobertura según Sonar | 90,5 % (concuerda con el 92,39 % de JaCoCo) |
| Fiabilidad · Seguridad | A · A |
| Bugs · Vulnerabilidades de código | 0 · 0 |
| Code smells | 3 |
| Security hotspots | 0 |
| Duplicación | 0,5 % |

**Qué aporta esto que la cobertura no aportaba.** Hasta hoy el veredicto de mantenibilidad de
RNF-20 descansaba solo en «cuánto código tocan las pruebas». Ahora hay complejidad, duplicación y
reglas incumplidas medidas: **mantenibilidad A con 15 minutos de deuda sobre 14 422 líneas.** Es un
resultado bueno y conviene decirlo tal cual, sin rebajarlo.

> ⚠️ **La trampa de interpretación, y hay que blindarla en el informe.** Sonar reporta **0
> vulnerabilidades** y en su propio registro dice `Dependency analysis skipped`: **no miró las
> dependencias.** Trivy, sobre la misma imagen, encontró **4 CRITICAL y 10 HIGH**. Son dos
> preguntas distintas:
>
> | Pregunta | Herramienta | Resultado |
> | --- | --- | --- |
> | ¿El código que escribimos tiene fallos? | SonarQube | 0 bugs, 0 vulnerabilidades |
> | ¿Las librerías que usamos tienen CVE? | Trivy | **4 CRITICAL, 10 HIGH** |
>
> Presentar el tablero de Sonar y decir «cero vulnerabilidades» sería un informe falso.

**Los 3 *code smells*, con nombre.** No son opinables y conviene llevarlos resueltos a la reunión:
las tres son `java:S2187` («Add some tests to this class»), de severidad **BLOCKER**, y las tres
están en **clases de prueba**, no en código de producción:

| Archivo | Línea |
| --- | --- |
| `src/test/java/co/edu/uco/sigra/common/exception/ConstructorRespuestaErrorTest.java` | 25 |
| `src/test/java/co/edu/uco/sigra/common/exception/HallazgosContratoErrorTest.java` | 62 |
| `src/test/java/co/edu/uco/sigra/common/exception/PrecedenciaAdvicesTest.java` | 63 |

La regla se dispara cuando una clase cuyo nombre termina en `Test` no tiene métodos `@Test`
directos, que es exactamente lo que pasa cuando las pruebas viven en clases `@Nested`. **Es un
falso positivo de patrón, no deuda real** —y así hay que decirlo—, pero deja una lectura
incómoda que sí hay que anticipar: *«0 bugs, y 3 hallazgos BLOCKER»*. El criterio de A3 §7.2 habla
de **bugs** `blocker` o `critical`, y de esos hay **cero**; estos son *code smells*. Cuesta
15 minutos quitarlos (anotar las clases contenedoras) y limpia el tablero.

**Reserva sobre el cierre, y es nuestra propia regla.** El criterio de cierre que escribimos arriba
dice *«el CI ejecuta el linter y falla si hay hallazgos»*. **Eso no se cumple:** el análisis corre
en un contenedor del portátil de Andrés, a mano, y el CI sigue sin linter. Y el hallazgo se levantó
sobre **los dos repositorios**: a 16 de noviembre `api/projects/search` devuelve **un solo
proyecto**, `sigra-backend`. Por eso el estado baja de 🟢 a 🟡:

| Mitad del hallazgo | Estado real |
| --- | --- |
| Backend, análisis estático existente | 🟢 Hecho y con evidencia en disco |
| Frontend, análisis estático existente | 🟢 **Escaneado el 16-nov por la noche**, y reescaneado para que su puerta se evaluara: **puerta `OK`**, mantenibilidad **A**, deuda 65 min, duplicación 3,7 %, 0 bugs, 7 *code smells*. La única «vulnerabilidad» es un **falso positivo comprobado** |
| El CI lo ejecuta y muerde | 🔴 **No.** Requiere `SONAR_TOKEN` en los secretos → es el mismo permiso `admin` de [H-01](#h-01-alta--el-análisis-de-dependencias-del-backend-está-apagado) |

**Dónde está la evidencia ahora.** Ya no solo en el tablero: `herramientas-rnf/evidencias/`
guarda `sonar-backend-2026-11-16-{medidas,puerta,issues,hotspots,analisis}.json`, bajados de la API.
Importa porque el tablero vive dentro del volumen `sonarqube-data`: si el volumen se borra, la
evidencia se iba con él y el informe citaría una máquina apagada.

**Lo que queda, y no es parte de este hallazgo.** SonarCloud en el CI sigue necesitando que un
admin agregue `SONAR_TOKEN` — eso vive en [H-01](#h-01-alta--el-análisis-de-dependencias-del-backend-está-apagado).
El hallazgo era «no hay análisis estático», y ahora lo hay, con resultado.

**Severidad al cierre.** Era media. Se cierra sin haber subido nunca: era un instrumento que
faltaba, no un incumplimiento.

---

## H-09 (media) — RNF-18 no tiene medición de uptime ni de MTTR

**Atributo.** Disponibilidad.
**RNF comprometido.** RNF-18.

**Qué se encontró.** RNF-18 fija dos umbrales medibles: **uptime ≥ 95 %** de las veces que se
ingresa a la aplicación, y **MTTR ≤ 4 horas** ante una caída crítica, «medido desde el reporte o
detección del incidente hasta el restablecimiento completo del servicio».

No existe forma de medir ninguno de los dos:

- No hay monitoreo de disponibilidad ni registro histórico de caídas.
- No hay un procedimiento de reporte y detección de incidentes que permita cronometrar el MTTR.
- No hay entorno de producción en operación durante el proyecto.

Lo que sí existe y se le parece: `/actuator/health` como endpoint de estado, el smoke SSR del CI,
y el manejo del status `0` en el login del frontend, que muestra «No fue posible conectar con el
servidor».

**Evidencia.** Ausencia de herramienta de monitoreo en ambos repositorios; SRS, sección
«Disponibilidad».

**Riesgo.** Vamos a tener que dar veredicto sobre RNF-18 y, sin entorno en operación y sin
monitoreo, la respuesta honesta es «no verificable en el alcance de este proyecto». Conviene
decidirlo con el Product Owner, no improvisarlo el día 15.

**Severidad.** **Media.** El requisito es de operación, no de código, y el proyecto de
mantenimiento no despliega a producción. Lo que sí es nuestro es **definir cómo se verificaría** y
dejarlo escrito.

**Dueño.** José (titular de disponibilidad), con validación del Product Owner.

**Criterio de cierre.** Dos opciones, a decidir en la reunión del 8:

- **(a)** Declarar RNF-18 fuera del alcance de este mantenimiento, con justificación escrita — es
  lo más probable y es legítimo si queda documentado.
- **(b)** Verificar los **sustitutos verificables** en el alcance: que el backend arranca con el
  esquema validado y `/actuator/health` responde `UP`; y que con el backend caído el frontend
  muestra el mensaje de usuario definido y no una pantalla en blanco ni una traza (lo que además
  es RNF-17). Evidencia: `curl --fail http://localhost:8080/actuator/health` y la prueba de
  status `0` del frontend.

**Estado.** 🟡 **En corrección · la mitad de uptime ya está medida.**

**Seguimiento · 15 de noviembre de 2026.** El hallazgo decía «sin medición de uptime ni de MTTR».
Hoy hay instrumento y hay medición para el uptime.

**Lo que cambió la premisa.** El 7 de noviembre asumimos que no había entorno en operación. Lo
hay: el backend está desplegado en `https://software4-sigra-backend.onrender.com` —la URL que el
frontend tiene compilada en `src/environments/environment.ts:3`— y su actuator está expuesto a
propósito (`application.yaml`, `management.endpoints.web.exposure.include: health`).

**Medición ejecutada** con `jmeter/RNF-18-disponibilidad.jmx`: un solo hilo, `GET /actuator/health`
cada 2 s, con dos aserciones (código 200 **y** cuerpo que contenga `UP`).

```
summary =     90 in 00:03:31 =    0.4/s Avg:   332 Min:   270 Max:  1620 Err:     0 (0.00%)
```

| Métrica | Valor |
| --- | --- |
| Muestras | 90 |
| Exitosas (200 **y** `UP`) | **90 → 100,00 %** |
| Códigos observados | solo `200` |
| Ventana | 15-nov-2026 07:00:37 → 07:04:06 (208 s) |
| p50 / p90 / p95 / p99 | 289 / 327 / 526 / 1 472 ms |

**La reserva, dicha con todas sus letras.** 100 % en una ventana de tres minutos y medio **no es**
«uptime ≥ 95 %». El requisito habla de un periodo de operación. Lo que la medición demuestra es
que el servicio responde, que su health check reporta `UP`, y que ahora existe un instrumento
repetible y versionado para medirlo. Escribir «uptime del 100 %» a partir de esto sería
exactamente el tipo de dato inflado que el §10 del manual prohíbe.

**El MTTR sigue sin dato, y no por falta de herramienta.** MTTR ≤ 4 h se verifica con el registro
de un incidente real: cuánto pasó entre la detección y el restablecimiento. No ha habido ninguna
caída crítica registrada. El veredicto honesto de esa mitad es **«sin evento que medir»**, que no
es lo mismo que «cumple» ni que «no cumple». Es una decisión de tratamiento para el PO (D-3 en
[A6](A6-semaforo-rnf.md)).

**Severidad.** La parte de uptime baja de **media** a **baja**; la parte de MTTR se mantiene
como decisión pendiente, no como hallazgo técnico.

---

## H-10 (media) — RNF-11 (TLS 1.2+) no es verificable sin entorno de producción

**Atributo.** Seguridad.
**RNF comprometido.** RNF-11.

**Qué se encontró.** RNF-11 exige que **en el entorno de producción** el sistema use HTTPS con TLS
1.2 o superior para proteger credenciales, tokens, datos personales, calificaciones y
observaciones. El desarrollo y las pruebas corren sobre HTTP en `localhost`, y no hay un entorno
de producción con certificado en operación durante el proyecto.

El frontend documenta el reverse proxy de `/api` en `docs/security/DEPLOYMENT.md` y usa
`apiUrl: '/api'` en producción, lo que es coherente con terminar TLS en el proxy — pero eso es una
intención de despliegue, no una verificación.

**Evidencia.** `software4-SIGRA-frontend/docs/security/DEPLOYMENT.md`; configuración de entornos
con `apiUrl` relativo en producción.

**Riesgo.** Es un RNF de seguridad que va a quedar sin veredicto. Y hay un riesgo concreto de
mantenimiento: si algún cambio introduce una URL absoluta con `http://` hacia el backend, rompe
RNF-11 en producción y en local no se nota.

**Severidad.** **Media.** No es verificable en el alcance, pero sí es auditable por inspección, y
esa inspección previene el riesgo real.

**Dueño.** José.

**Criterio de cierre.** Verificación por inspección, ejecutable hoy: ningún archivo del frontend
construye una URL `http://` hacia el backend fuera de los entornos de desarrollo, y todos los
servicios leen de `environment.apiUrl`.

```bash
grep -rn "http://" software4-SIGRA-frontend/src --include=*.ts | grep -v environment.development
```

Umbral: cero resultados que apunten al backend. Y dejar declarado en el informe que la
verificación plena de RNF-11 requiere el entorno de producción.

**Estado.** 🟢 **Cerrado · 15 de noviembre de 2026.**

**Por qué se cierra: la premisa del hallazgo era falsa.** H-10 decía que RNF-11 «no es verificable
sin entorno de producción». El entorno de producción **existe y está operando**:
`https://software4-sigra-backend.onrender.com`, que es la URL que el propio frontend tiene
compilada en `src/environments/environment.ts:3` para su configuración `production`. Render
termina TLS por defecto, que es justo lo que el requisito pide.

Es el segundo hallazgo de este registro que se levantó asumiendo algo en vez de comprobarlo —el
primero fue H-06— y conviene decirlo, no taparlo: el método correcto era abrir
`environment.ts` antes de escribir «no hay producción».

**Verificación ejecutada.**

```
$ curl -s -o /dev/null -w "status=%{http_code} http_ver=%{http_version}" \
    https://software4-sigra-backend.onrender.com/actuator/health
status=200 http_ver=2

$ curl --tlsv1.2 --tls-max 1.2 ...  -> status=200              # TLS 1.2 aceptado
$ curl --tlsv1.3               ...  -> status=200              # TLS 1.3 aceptado
$ curl --tlsv1.0 --tls-max 1.0 ...  -> status=000, exit 35     # TLS 1.0 RECHAZADO
$ curl http://software4-sigra-backend.onrender.com/actuator/health
status=301 redirect=https://software4-sigra-backend.onrender.com/actuator/health
```

| Lo que exige RNF-11 | Resultado | Veredicto |
| --- | --- | --- |
| HTTPS en producción | Sirve por HTTPS sobre HTTP/2 | 🟢 |
| TLS **1.2 o superior** | 1.2 y 1.3 aceptados | 🟢 |
| Que no se acepte menos de 1.2 | TLS 1.0 falla en el handshake (exit 35) | 🟢 |
| Que no quede tráfico en claro | HTTP responde 301 hacia HTTPS | 🟢 |

**RNF-11 pasa de 🔴 a 🟢 en el semáforo.**

**Cerrado también por el lado del frontend · 16 de noviembre de 2026.** El 15 de noviembre esto
quedó con una reserva: solo se había medido el **backend**, porque la URL de producción del
frontend no estaba escrita en ningún archivo de los dos repositorios. La auditoría de José la
aportó —`https://sigra.vercel.app`— y se repitió la misma batería contra ella:

```
status=200 http_ver=2          # HTTPS sobre HTTP/2
TLS 1.2 -> 200                 # aceptado
TLS 1.3 -> 200                 # aceptado
TLS 1.0 -> 000, exit 35        # RECHAZADO en el handshake
http://sigra.vercel.app/login  -> 308 redirect=https://sigra.vercel.app/login
```

**RNF-11 cumple de punta a punta** y el pedido **P-08 queda resuelto**. Es el único requisito del
SRS que se verifica en el entorno real que el propio requisito nombra, sin criterio sustituto.

El criterio sustituto que teníamos —que ningún archivo del frontend construya una URL `http://`
hacia el backend— sigue siendo válido como verificación de código y se mantiene en
[A3 §1](A3-criterios-verificacion.md).

---

## H-07 (baja) — El README del backend contradice a `build.gradle` sobre JaCoCo

**Atributo.** Mantenibilidad (exactitud de la documentación).
**RNF comprometido.** Ninguno directamente; afecta la lectura de RNF-20.

**Qué se encontró.** El README del backend afirma en dos lugares que la cobertura todavía no está
instrumentada: en «Pendientes conocidos», punto 7, *«JaCoCo. El plugin de cobertura todavía no
está declarado»*; y en la sección de pruebas, que el reporte estará disponible *«cuando se agregue
el plugin de JaCoCo»*.

Pero `build.gradle` ya lo declara y el CI ya lo ejecuta:

- `build.gradle:6` → `id 'jacoco'`
- `build.gradle:99-104` → `jacocoTestCoverageVerification` con `minimum = 0.7` global
- `build.gradle:105-120` → regla por paquete al 70 % para los módulos de `auth`
- `build.gradle:125` → `check.dependsOn jacocoTestCoverageVerification`

**Evidencia.** README del backend, «Pendientes conocidos» punto 7, contra
`software4-SIGRA-backend/SIGRA/build.gradle:6,99-125`.

**Riesgo.** Documentación que miente en nuestro favor, lo que la hace más peligrosa de lo que
parece: alguien puede proponer «agregar JaCoCo» como mantenimiento y gastar tiempo en algo que ya
está, o asumir que no hay umbral cuando sí hay uno que puede hacer fallar su build. Se agrava por
[H-08](#h-08-alta--rnf-20-vigila-la-cobertura-de-dos-de-los-cuatro-módulos-obligatorios): el
comentario del propio `build.gradle` sobre RF-14 también está obsoleto, así que la documentación
de cobertura está desactualizada en los dos lugares donde existe.

**Severidad.** **Baja.** No afecta funcionamiento ni seguridad, y la corrección es editar dos
párrafos.

**Dueño.** Por asignar; edición de documentación.

**Criterio de cierre.** El README refleja el estado real: JaCoCo declarado, umbral global del 70 %
y reglas por paquete para los módulos obligatorios de RNF-20. Evidencia: diff del README en un PR.

**Estado.** 🔴 **Abierto · y ahora más desactualizado.**

**Seguimiento · 15 de noviembre de 2026.** El fix de [H-08](#h-08-alta--rnf-20-vigila-la-cobertura-de-dos-de-los-cuatro-módulos-obligatorios)
agrega los paquetes de `estadisticas` a la lista vigilada, así que el README del backend queda
desalineado en dos cosas a la vez: en que JaCoCo ya está configurado, y en qué módulos vigila.

**Corrección.** Va en el **mismo PR** del fix de H-08, para no abrir dos. Hay que dejar escrito en
el README que la verificación cubre los cuatro módulos obligatorios del RNF-20 (a), con la cifra
real de cobertura global (92,39 %).

---

## H-11 (alta) — 0000053 sin dueño y con impacto RNF por confirmar

**Atributo de calidad afectado.** Rendimiento / fiabilidad.
**RNF potencial.** RNF-01 podría aplicar si se demuestra afectación al límite de concurrencia o tiempos de respuesta. RNF-02, RNF-04 y RNF-06 requieren impactos medidos; no se atribuyen por el texto del ticket.

**Qué se encontró.** La exportación de Mantis del 15 de noviembre (`estado de mantis.csv`) tiene
una incidencia que no aparece en la hoja «Reparto de incidencias» del libro del equipo y que no
tiene responsable asignado:

| Campo | Valor |
| --- | --- |
| ID | **0000053** |
| Resumen | «Falla intermitente al cargar combos de semestre/asignatura/RA en múltiples módulos, presente en todos los roles» |
| Informador | `jnarvaez` (Juan José Narváez, analista de pruebas) |
| **Asignada a** | **(vacío)** |
| Prioridad / Severidad | **alta / mayor** |
| Reproducibilidad | **a veces** |
| Estado | **nueva** |
| Fecha de envío | 14 de noviembre de 2026 |

**Cómo se reproduce.** Por definición, no se reproduce de forma confiable: la propia incidencia
dice *a veces*. Eso es lo que la hace nuestra.

**Clasificación provisional.** «Intermitente», «a veces» y «en múltiples módulos» describen el
síntoma y su alcance reportado, pero no demuestran que sea un RNF ni que la causa sea concurrencia,
una carrera entre solicitudes o tiempo de respuesta. ERR-002 es un antecedente posible en
Estadísticas, no evidencia de que 0000053 comparta su causa. Hace falta reproducir, registrar
frecuencia y solicitudes/respuestas y contrastar el comportamiento con el SRS.

**Impacto potencial.** Si la falla impide consultar o seleccionar semestre/asignatura/RA, puede
bloquear la tarea del usuario. Esta revisión no confirmó que el control aparezca vacío ni que se
interprete como ausencia de datos; registrar esa conducta durante una reproducción antes de
afirmarla.

**Clasificación de Mantis.** Prioridad alta/severidad mayor, estado nueva y sin responsable en la
exportación. El manual indica que defectos altos confirmados bloquean la entrega; el equipo debe
confirmar la clasificación y el impacto funcional con evidencia.

**Dueño de la corrección.** Por asignar. Primero triage de QA/desarrollo para reproducir y localizar
el componente; asignar responsable después de conocer la causa.

**Criterio de verificación.** Reproducir primero en QA aislado con una línea base de una sesión y
repeticiones controladas; registrar ruta, datos sintéticos, frecuencia, solicitudes y respuestas.
Solo si existe evidencia de concurrencia, ejecutar después el plan JMeter contra QA. Una carga de 20
hilos por sí sola no demuestra la causa ni garantiza reproducibilidad.

**Seguimiento de nuestro rol.** JMeter podría medir impacto de rendimiento si la reproducción
apunta a concurrencia. No sustituye el diagnóstico funcional inicial.

**Estado.** 🔴 **Abierto** · nuevo el 15 de noviembre de 2026.

---

## H-12 (media) — Los dos RNF que el equipo nos asignó se resolvieron sin nuestra validación

**Atributo de calidad afectado.** Mantenibilidad (consistencia de patrones) y cumplimiento del rol.
**RNF comprometido.** RNF-04, RNF-08, RNF-21 (los patrones de paginación y búsqueda son de
interfaz y afectan tiempo de carga y accesibilidad).

**Qué se encontró.** La hoja «Guía y reglas» del libro del equipo define nuestro rol con estas
palabras exactas:

> **Especialistas RNF** — José Alejandro, Andrés Vélez — *Definen y validan los patrones de
> paginación y buscadores.*

Y Mantis clasifica **exactamente esas dos incidencias** en la categoría **«No Funcionalidad»**,
que son las únicas dos del tablero con esa categoría:

| ID | Resumen | Categoría Mantis | Asignada a | Estado | ¿Validamos el patrón? |
| --- | --- | --- | --- | --- | --- |
| **0000040** | Varias tablas no tienen paginación | **No Funcionalidad** | `tmarin` | **resuelta** (resolución *abierta*) | **No** |
| **0000038** | Los listados largos (≈500 docentes) no tienen cuadro de búsqueda | **No Funcionalidad** | `aarbelaez` | **asignada desde el 8-nov** | **No** |

**Cómo se reproduce.** Comparar la hoja «Registro de actividades» del libro (97 filas al 15 de
noviembre) con los nombres de los dos especialistas de RNF: **no hay ninguna fila nuestra**. No
existe registro de que hayamos definido ni validado ningún patrón.

**Evidencia.** `estado de mantis.csv` (categoría y estados) · hoja «Guía y reglas», fila 8 · hoja
«Registro de actividades», filas 4 a 100 · ACT-073, donde Andrea Avendaño deja nota en Mantis
0000038 diciendo que el componente reutilizable de búsqueda «debe hacerlo general» Alejandro
Arbeláez: alguien más tuvo que ocuparse de coordinar el patrón que nos correspondía.

**Riesgo si no se corrige.** Dos riesgos distintos:

- **0000040 ya está resuelta.** Tomás Marín aplicó «paginación igual a la de Materias» en siete
  listados (ACT-006, ACT-023), que es la decisión correcta, pero la tomó él. Si el patrón no se
  valida, nada garantiza que los módulos nuevos —Facultades y Reportes, que siguen sin paginación
  según el compromiso abierto del equipo— lo sigan.
- **0000038 lleva siete días sin movimiento.** El buscador afecta listados de ≈500 docentes, que
  es directamente RNF-04 y RNF-08.

**Severidad y por qué.** **Media.** No es un defecto de funcionamiento, y la solución aplicada en
0000040 parece buena. Es un incumplimiento de **nuestro propio rol**, y lo registramos contra
nosotros porque el §11 evalúa el cumplimiento de responsabilidades individuales «sobre evidencias
verificables», y la evidencia aquí no existe.

**Dueño de la corrección.** Nosotros dos.

**Criterio de verificación de la corrección.** Un documento corto —una página— con el patrón de
paginación y el de búsqueda: tamaño de página, comportamiento al filtrar (que la paginación
respete el filtro activo, que es justo lo que falló en **ERR-001**), vuelta a la página 1,
mínimo de caracteres de búsqueda, y estado vacío. Más una fila por cada incidencia en la matriz
de impacto [A2](A2-matriz-impacto-calidad.md) con veredicto escrito.

**Estado.** 🔴 **Abierto** · nuevo el 15 de noviembre de 2026.

---

## H-13 (media) — Ninguna incidencia está cerrada en Mantis

**Atributo de calidad afectado.** Trazabilidad.
**RNF comprometido.** Ninguno directamente; afecta el criterio de finalización del §13 y el
indicador «% de cambios con trazabilidad completa» del §10.

**Qué se encontró.** De las 31 incidencias del tablero, **ninguna está en estado `cerrada`**:

| Estado en Mantis | Cantidad |
| --- | --- |
| `resuelta` | 22 |
| `nueva` | 6 |
| `asignada` | 3 |
| **`cerrada`** | **0** |

Y en el campo de resolución, varias de las «resueltas» siguen en `abierta` en vez de `corregida`:
0000026, 0000027, 0000029, 0000030, 0000034, 0000038, 0000040, 0000043, 0000045, 0000048, 0000052,
0000053.

**Cómo se reproduce.**

```
$ python -c "import csv,io,collections; \
  rows=list(csv.DictReader(io.open('estado de mantis.csv',encoding='utf-8-sig'))); \
  print(collections.Counter(r['Estado'] for r in rows))"
Counter({'resuelta': 22, 'nueva': 6, 'asignada': 3})
```

**Por qué importa.** Las reglas que el equipo escribió en su propio libro definen `cerrada` así:
«Pasó revisión técnica y pruebas, PR mergeado, documentación al día», y la mueve Jean Paul tras el
visto bueno de pruebas. Mientras ninguna llegue a ese estado, **no hay evidencia en la herramienta
de que la cadena incidencia → PR → revisión → prueba se haya completado para ningún cambio**.

La hoja «Indicadores» del libro reporta «% de incidencias atendidas = 77,78 %» contando
resueltas y cerradas juntas. Eso es correcto para «atendidas». Pero el indicador de **trazabilidad
completa**, que es uno de los tres que el libro deja en blanco para llenar a mano, es hoy
honestamente **0 %**, y conviene escribirlo así antes de que alguien lo llene con un número
optimista. El §10 dice textualmente que no se deben «alterar datos para aparentar cumplimiento».

**Riesgo si no se corrige.** El criterio de finalización del §13 no se puede declarar cumplido
desde la herramienta de gestión, que es la única fuente que un evaluador externo va a mirar.

**Severidad y por qué.** **Media.** No es un defecto del producto y se corrige con disciplina de
tablero, no con código. Pero afecta directamente un criterio de finalización.

**Dueño de la corrección.** Jean Paul (revisor técnico, es quien mueve a `cerrada`) y Juan Camilo
(Scrum Master, seguimiento). Los analistas de prueba dan el visto bueno previo.

**Criterio de verificación de la corrección.** Que al cierre, toda incidencia con PR integrado
esté en `cerrada` con resolución `corregida`. Se comprueba reexportando el CSV y contando.

**Estado.** 🔴 **Abierto** · nuevo el 15 de noviembre de 2026.

---

## H-14 (baja) — El entorno local no puede compilar el frontend

**Atributo de calidad afectado.** Mantenibilidad (reproducibilidad del entorno).
**RNF comprometido.** RNF-08 de forma indirecta: impide medir el bundle en local.

**Qué se encontró.** `npx ng build` no arranca en la máquina del especialista de RNF:

```
$ npx ng build
Node.js version v24.11.0 detected.
The Angular CLI requires a minimum Node.js version of v22.22.3 or v24.15.0 or v26.0.0.
```

**Cómo se reproduce.** Ejecutar `npx ng build` en `software4-SIGRA-frontend` con Node v24.11.0.

**Evidencia.** Salida de arriba. El CI sí compila, porque su paso «Instalar Node 24» trae una
versión que cumple el mínimo; por eso el problema no se ve en GitHub Actions.

**Riesgo si no se corrige.** No afecta al producto ni a los usuarios. Sí afecta nuestro rol: no
podemos medir en local nada del frontend —bundle, presupuestos, tiempos de render— y dependemos
de leer los registros del CI. Es la segunda incidencia de entorno del equipo con el mismo patrón:
Tomás Gómez registró ERR-008 (VS Code 1.146 exigía macOS 14) y ACT-016 (`sass-embedded` exigía
macOS 14), ambas por versiones mínimas de herramientas.

**Severidad y por qué.** **Baja.** Hay vía alterna con evidencia —los registros del CI— y de hecho
la cifra de RNF-08 se obtuvo así. La corrección es actualizar Node.

**Dueño de la corrección.** Andrés.

**Criterio de verificación de la corrección.** `npx ng build` imprime la tabla de tamaños y evalúa
el presupuesto de `angular.json` sin error de versión.

**Lo que conviene proponerle al equipo.** Fijar la versión de Node en `package.json` con el campo
`engines`, para que el requisito sea explícito en el repositorio y no se descubra al compilar.

**Estado.** 🔴 **Abierto** · nuevo el 15 de noviembre de 2026.

---

## H-17 (alta) — El login se degrada bajo presión de CPU por el BCrypt que exige RNF-10

**Atributo de calidad afectado.** Rendimiento.
**RNF comprometidos.** **RNF-01** (20 usuarios concurrentes cumpliendo los tiempos de RNF-03 a
RNF-08) y **RNF-03** (95 % de las autenticaciones en menos de 4 s). La causa está en **RNF-10**
(BCrypt con factor de trabajo mínimo 12).
**Medido por.** Andrés Felipe Vélez, 16 de noviembre de 2026.

> ### ⚠️ Actualización del 16 de noviembre, al cierre del día — leer antes que el resto
>
> Este hallazgo se abrió con el titular **«RNF-03 no se cumple: p95 5 493 ms»**. Horas después, a
> las 16:00, **se repitió la corrida de carga con parámetros idénticos** —`usuarios=20`,
> `rampa=20`, `iteraciones=5`, `correo=admin.bruno@uco.net.co`, `puerto=8081`, todos registrados
> en `mantenimiento-rnf/jmeter.log`— y el resultado fue el contrario:
>
> | | Corrida de carga 09:15 | **Corrida de carga 16:00** |
> | --- | --- | --- |
> | Login p50 | 3 774 ms | **307 ms** |
> | Login p95 | **5 493 ms** 🔴 | **1 035 ms** ✅ |
> | Muestras sobre 4 s | **46 de 100** | **0 de 100** |
> | `/profesores` p95 | 1 394 ms | 29,8 ms |
>
> Evidencia: `jmeter/resultados/rnf01-06-local-2.jtl` y su informe HTML.
>
> **La diferencia no está en el plan de pruebas; está en la máquina.** La reserva nº 1 de abajo
> —«medido en un portátil de 12 CPU con seis contenedores encima, SonarQube incluido»— deja de ser
> una cautela de redacción y pasa a ser **el factor que domina la medición**. El detalle que lo
> prueba: en la corrida de *control* un login **escalonado** costó 546 ms, mientras que en la de
> las 16:00 un login **solapado con otros 19** costó 307 ms de mediana. Un login aislado no puede
> ser más lento que veinte simultáneos salvo que la CPU estuviera ocupada en otra cosa.
>
> **Qué sigue en pie del hallazgo:** la **tensión entre RNF-10 y RNF-03 es real y está
> identificada** —el login es la única operación que se degrada bajo presión de CPU, y la causa es
> `new BCryptPasswordEncoder(12)` en `SecurityConfig.java:39`—. Lo que **no** está establecido es
> su **magnitud**, y por tanto tampoco el incumplimiento de RNF-03.
>
> **Qué cambia en consecuencia:**
>
> - El veredicto de RNF-03 en [A6](A6-semaforo-rnf.md) vuelve de 🔴 a 🟡 («medido, no
>   reproducible»). No es un ascenso: es reconocer que **no tenemos el dato**.
> - **Este hallazgo no debe usarse para bloquear la entrega** mientras la magnitud esté en
>   revisión. La decisión **D-6** de A6 sigue siendo pertinente —la lectura de RNF-01 como
>   «usuarios en sesión» es razonable por sí misma— pero ya no se presenta como forzada por un
>   incumplimiento medido.
> - **Acción pendiente, media hora de trabajo:** repetir la corrida de carga **tres veces seguidas
>   con la máquina en estado conocido**, anotando qué contenedores están arriba, y reportar la
>   mediana. Eso cierra el hallazgo en un sentido o en el otro.
>
> **Y la lección de método, que vale más que el número:** una sola corrida no es una medición. Lo
> que nos salvó de publicar un incumplimiento infundado fue **volver a correr la misma prueba**.

**Qué se encontró.** Primera medición de carga de la historia del proyecto, sobre el entorno
aislado (`sigra-backend-rnf` en 8081 contra `sigra-pg-rnf`), backend `bb72c07`. Dos corridas de
JMeter con **20 hilos** y rampa de 20 s, que solo se diferencian en el número de iteraciones:

| Petición | Umbral del SRS | **Control** (1 iteración: logins escalonados ~1/s) | **Carga** (5 iteraciones: logins solapados) |
| --- | --- | --- | --- |
| `POST /api/v1/auth/login` | 95 % < **4 000 ms** | p50 503 · p95 **546** · max 649 | p50 3 774 · p95 **5 493** · max 6 591 |
| `GET /api/v1/profesores` | 95 % < 3 000 ms | p95 **29** | p95 **1 394** |
| `GET /api/v1/asignaturas` | 95 % < 3 000 ms | p95 **23** | p95 **1 108** |
| `GET /api/v1/niveles-logro` | 90 % < 5 000 ms | p90 **17** | p90 **42** |

**El login se degrada diez veces** y arrastra al resto: `GET /profesores` pasa de 29 ms a 1 394 ms
sin que ese endpoint haya cambiado. De las 100 autenticaciones de la corrida de carga, **46
superaron los 4 s** del umbral. Todas respondieron `200`: no es un fallo funcional, es tiempo.

**Cómo se reproduce.** Procedimiento completo en
[PROCEDIMIENTO-AUDITORIA-RNF.md §1](PROCEDIMIENTO-AUDITORIA-RNF.md). Las dos corridas difieren solo
en `-Jiteraciones=1` contra `-Jiteraciones=5`.

**Evidencia.** `jmeter/resultados/rnf01-control.jtl` (80 muestras) y
`jmeter/resultados/rnf01-06-local.jtl` (400 muestras), con el informe HTML de la segunda. **Y la
tercera corrida, que es la que obliga a la actualización de arriba:**
`jmeter/resultados/rnf01-06-local-2.jtl` (400 muestras, 16:00) con su informe en
`rnf01-06-local-2-reporte/index.html`. Las tres están tabuladas juntas en
[A6 §3.4](A6-semaforo-rnf.md) y en [A3 §2.2.1](A3-criterios-verificacion.md).

**Causa raíz, identificada.** `SecurityConfig.java:39` declara `new BCryptPasswordEncoder(12)`.
Factor 12 son 4 096 rondas de hash, del orden de 300-500 ms de CPU **por autenticación**. Con 20
logins simultáneos la CPU se satura y el resto de las peticiones espera detrás. El patrón encaja
exactamente con lo medido: escalonados no compiten y cumplen de sobra; solapados compiten y
multiplican la latencia por diez.

**Y aquí está lo importante: el factor 12 no es un error, lo exige el SRS.** RNF-10 pide
textualmente «contraseñas con BCrypt, factor de trabajo mínimo 12». Esto no es un defecto de
implementación: es una **tensión entre dos requisitos del propio SRS**, medida y reproducible.

| Requisito | Qué exige | Efecto |
| --- | --- | --- |
| **RNF-10** | BCrypt factor ≥ 12 | Hace que cada login cueste cientos de ms de CPU |
| **RNF-01 + RNF-03** | 20 concurrentes, 95 % de logins < 4 s | Inalcanzable si los 20 autentican a la vez |

**Lo que NO proponemos.** Bajar el factor de BCrypt. Sería incumplir RNF-10 —un requisito de
seguridad— para cumplir uno de rendimiento, y esa no es una decisión que nos corresponda tomar ni
sugerir a la ligera.

**Opciones que sí corresponde poner sobre la mesa**, para que el equipo y el PO decidan:

1. **Declarar el alcance real de RNF-01.** Que los 20 usuarios concurrentes se entiendan como
   usuarios *en sesión*, no autenticando simultáneamente. Un usuario real entra una vez por
   sesión; el perfil de 5 iteraciones reautentica cada pocos segundos. Es la lectura más realista
   y **solo requiere dejarlo escrito** en el SRS o en el informe.
2. **Aceptar la tensión como deuda técnica documentada**, con la medición adjunta.
3. **Medir en hardware representativo** antes de concluir sobre producción.

**Severidad y por qué.** **Alta**, y se mantiene **aunque la magnitud esté en revisión**: lo que
afecta al flujo de entrada de todos los roles no es el número concreto sino la tensión
RNF-10 ↔ RNF-03, que es estructural y sigue ahí. Lo que **sí cambia** es que, por la actualización
del cierre del día, **este hallazgo no bloquea la entrega** mientras no se repita la medición en
condiciones controladas: no se bloquea una entrega con un dato que no es reproducible. La salida
sigue sin ser código —es la **decisión de alcance** del punto 1, que cuesta un párrafo— y ahora
va acompañada de la corrida de confirmación.

**Reservas que acompañan al hallazgo, y van siempre con él:**

1. Medido en un portátil de **12 CPU** con seis contenedores encima (SonarQube incluido, 2,2 GB).
   En un servidor dedicado el número sería mejor. **No afirmamos que producción se comporte así.**
2. El perfil de carga es **más agresivo que el uso real** para el login, por lo dicho arriba.
3. Lo que la medición demuestra, y es suficiente para abrir el hallazgo: **con llegada simultánea
   sostenida el umbral de RNF-03 no se cumple, y la causa está identificada.**
4. **Añadida al cierre del 16-nov, y es la que más pesa:** la reserva nº 1 no era teórica. Una
   tercera corrida con **parámetros idénticos** a la de carga, con la máquina descargada, dio
   p95 **1 035 ms** y **cero** incumplimientos. Por tanto el punto 3 queda acotado así: con
   llegada simultánea sostenida **y la CPU disputada**, RNF-03 no se cumple. Cuánta CPU hace
   falta disputar para que deje de cumplirse es, hoy, una pregunta abierta. Ver la actualización
   al principio de este hallazgo.

**Dueño.** La decisión de alcance: **Product Owner**. La medición en hardware representativo:
nosotros, si hay dónde.

**Criterio de verificación del cierre.** O queda escrita la decisión de alcance de RNF-01, o una
corrida en hardware representativo muestra `95th pct` del login por debajo de 4 000 ms con 20
logins solapados.

**Estado.** 🔴 **Abierto** · nuevo el 16 de noviembre de 2026.

---

## H-18 (alta) — Nueve endpoints de listado responden 500 ante un nombre de parámetro vacío

**Atributo de calidad afectado.** Seguridad (validación de entrada).
**RNF comprometido.** **RNF-14** — «validar y sanear los datos recibidos antes de procesarlos».
Es el primer hallazgo que ataca el 🟡 con el que RNF-14 estaba en el catálogo: *«Jakarta Validation
+ JPA; sin prueba dedicada de saneamiento»* ([A1 §1.2](A1-catalogo-rnf.md)). Ya hay instrumento
dedicado, y encontró esto.
**Titular.** José (seguridad). **Encontrado por.** Andrés, 16-nov, escaneo activo de ZAP.

**Qué se encontró.** Un **nombre de parámetro vacío** en la cadena de consulta (`?=` o `&=&`)
hace que el backend responda **HTTP 500**. No es un caso de laboratorio: ZAP lo disparó 24 veces
sobre **nueve endpoints de listado distintos**, que son los que la interfaz usa para filtrar.

| Endpoint | Instancias |
| --- | --- |
| `/api/v1/auditoria` | 5 |
| `/api/v1/acciones-mejora` | 4 |
| `/api/v1/conclusiones` | 4 |
| `/api/v1/programas` | 4 |
| `/api/v1/facultades` | 2 |
| `/api/v1/semestres` | 2 |
| `/api/v1/estudiantes` · `/api/v1/profesores` · `/api/v1/resultados-aprendizaje` | 1 cada uno |

**Cómo se reproduce.** Con el entorno aislado arriba y un JWT de cualquier rol autorizado:

```bash
curl -s -D - -H "Authorization: Bearer $TOK" \
  "http://localhost:8081/api/v1/programas?=&codigo=ing&estado=ACTIVO"
# HTTP/1.1 500
# {"status":500,"error":"INTERNAL_SERVER_ERROR",
#  "mensaje":"Ocurrió un error inesperado en el servidor"}
```

La misma petición sin el `?=` responde **200**.

**Causa, con la traza en la mano.** El registro del backend dice
`Evento error=UNEXPECTED ... causa=InvalidParameterException`. La excepción **no tiene
`@ExceptionHandler`** en `GlobalExceptionHandler.java`, que sí mapea a 400 los casos de entrada
inválida que conoce (`MethodArgumentNotValidException`, `MethodArgumentTypeMismatchException`,
`HttpMessageNotReadableException`, cuerpo ilegible, tipo de contenido). Al no estar mapeada, cae
en el ramo genérico y sale como 500. **La entrada se detecta como inválida y aun así se contesta
«error inesperado del servidor».**

**Evidencia.** `herramientas-rnf/evidencias/zap/zap-api-admin-2026-11-16.json` (alerta *A Server
Error response code was returned by the server*, 24 instancias) · la salida de `curl` de arriba ·
`docker logs sigra-backend-rnf`.

**Riesgo si no se corrige.** Tres cosas, en orden de importancia:

1. **Un 500 es un diagnóstico falso.** Quien lea el tablero de errores verá «fallo del servidor»
   donde hay una petición mal formada del cliente. Es exactamente el patrón de **0000053**
   («falla intermitente al cargar combos … en todos los roles», [H-11](#h-11-alta--0000053-sin-dueño-y-con-impacto-rnf-por-confirmar)):
   **no afirmamos que sea la misma causa**, pero un endpoint de listado que devuelve 500 ante una
   cadena de consulta imperfecta es una hipótesis que hay que descartar antes de culpar a la
   concurrencia.
2. **Ensucia la medición de disponibilidad.** Los 500 cuentan como error en cualquier sonda de
   RNF-18 y en los percentiles de JMeter.
3. **Es ruido útil para quien pruebe la API**: 24 respuestas 500 reproducibles son un mapa de
   dónde falta validación.

**Lo que NO es.** No es inyección y no es filtración: el cuerpo del 500 no trae traza, ni clase, ni
SQL, ni ruta interna. **Eso confirma RNF-17 en ejecución**, con 120 reglas activas de ZAP y ni una
alerta de divulgación.

**Severidad y por qué.** **Alta.** Afecta a nueve endpoints de producción, se dispara con una
petición trivial que cualquier cliente puede mandar por accidente, y toca un RNF que estaba en
amarillo justo por falta de verificación de saneamiento. La corrección es acotada: mapear la
excepción a 400.

**Dueño de la corrección.** El equipo de desarrollo, con el revisor técnico. **No es nuestro
arreglo** y no se toca el producto desde este rol.

**Criterio de verificación de la corrección.** Las nueve rutas responden **400** a `?=` y el
escaneo autenticado de ZAP vuelve con **0 instancias** de *A Server Error response code*.
Se comprueba con `bash zap/escanear-api-autenticado.sh`.

**Cómo reportarlo, según el procedimiento del equipo.** No se crea incidencia nueva: se comenta
sobre **0000053** —que es la que toca estas pantallas— con la reproducción de arriba, y entra al
registro de errores del libro como **ERR**.

**Estado.** 🔴 **Nuevo** · 16 de noviembre de 2026, noche.

---

## H-19 (media) — Un byte nulo en un filtro de texto llega hasta PostgreSQL, y la respuesta dice 409

**Atributo de calidad afectado.** Seguridad (saneamiento de entrada).
**RNF comprometido.** **RNF-14**, la segunda mitad: *«emplear consultas parametrizadas o
equivalentes»* sí se cumple; *«validar y sanear los datos recibidos»*, no.
**Titular.** José. **Encontrado por.** Andrés, 16-nov, escaneo activo de ZAP.

**Qué se encontró.** Un byte nulo (`%00`) en un filtro de texto atraviesa toda la aplicación y
**lo rechaza el motor de base de datos**, no la validación:

```
org.hibernate.orm.jdbc.error : ERROR: invalid byte sequence for encoding "UTF8": 0x00
  Where: unnamed portal parameter $1
```

Y la respuesta al cliente es **409 CONFLICT** con *«La operación entra en conflicto con información
ya registrada en el sistema»* — un mensaje que describe un conflicto de datos que no existe.

**Cómo se reproduce.**

```bash
curl -s -w "\nHTTP %{http_code}\n" -H "Authorization: Bearer $TOK" \
  "http://localhost:8081/api/v1/estudiantes?filtro=gomez%00"
# HTTP 409 · {"status":409,"error":"CONFLICT","mensaje":"La operación entra en conflicto..."}
```

**Evidencia.** Salida de `curl` de arriba · `docker logs sigra-backend-rnf` (SQLState **22021**,
`HHH000247`) · la alerta de ZAP que lo originó en
`herramientas-rnf/evidencias/zap/zap-api-admin-2026-11-16.json`.

**Riesgo si no se corrige.** El dato tranquilizador primero: **la consulta va parametrizada**, y es
precisamente por eso que el byte llega como parámetro ligado y revienta en el motor en vez de
ejecutarse. **No hay inyección.** Lo que sí hay:

- **Entrada no saneada** que recorre controlador, servicio y repositorio sin que nadie la mire.
- **Un código de estado que miente.** Un 409 le dice al cliente «ya existe algo así»; un
  desarrollador que depure por el código de respuesta buscará duplicados que no existen.
- **Ruido en la auditoría** si el intento queda registrado como conflicto de negocio.

**Severidad y por qué.** **Media.** No es explotable para leer ni alterar datos, y hace falta
construir la petición a mano. Sube a alta si aparece un camino donde el mismo texto sin sanear se
**almacene** en vez de consultarse.

**Dueño de la corrección.** El equipo de desarrollo. Lo acotado es sanear los filtros de texto en
el borde (rechazar caracteres de control) y mapear `DataIntegrityViolationException` por formato a
**400**, no a 409.

**Criterio de verificación de la corrección.** `?filtro=gomez%00` responde **400** y el registro
del backend no muestra `SQLState 22021`.

**Estado.** 🔴 **Nuevo** · 16 de noviembre de 2026, noche.

---

## H-20 (alta) — El frontend del entorno «aislado» está compilado contra la base de producción

**Atributo de calidad afectado.** Mantenibilidad (reproducibilidad y seguridad del entorno de
verificación).
**RNF comprometido.** Ninguno directamente: **es un riesgo de nuestro propio instrumento**, de la
misma familia que [H-14](#h-14-baja--el-entorno-local-no-puede-compilar-el-frontend). Bloquea la
medición automatizada de **RNF-21** y de **RNF-08** sobre pantallas autenticadas.
**Encontrado por.** Andrés, 16-nov, al preparar la corrida autenticada de Lighthouse.

**Qué se encontró.** El `README` de `herramientas-rnf` §0 ya advierte que el contenedor
`sigra-backend` (8080) apunta a Supabase. **Lo que faltaba decir es que el frontend apunta a ese
backend.** El bundle que sirve `sigra-frontend` en el 4200 trae compilado:

```
http://localhost:8080/api
```

y `docker inspect sigra-backend` responde:

```
DB_URL=jdbc:postgresql://aws-0-us-east-1.pooler.supabase.com:5432/postgres?...currentSchema=sigra
```

Es decir: **abrir `localhost:4200` e iniciar sesión es operar la base de producción desde una
pantalla que todo el mundo lee como «local».** El backend aislado del 8081 no tiene frontend.

**Cómo se reproduce.**

```bash
docker exec sigra-frontend sh -c 'grep -rho "http://localhost:80[0-9][0-9][a-z/]*" /app/browser' | sort -u
docker inspect sigra-backend --format '{{json .Config.Env}}' | tr ',' '\n' | grep DB_URL
```

**Evidencia.** Las dos salidas de arriba · `src/environments/environment.ts:3` del frontend, que
en el repositorio apunta a Render (`https://software4-sigra-backend.onrender.com/api`), lo que
confirma que **el `apiUrl` se decide al compilar la imagen** y hay que comprobarlo, no suponerlo.

**Riesgo si no se corrige.** Es el riesgo que de verdad importa de este lote: cualquier integrante
—o cualquiera de nosotros con prisa— puede hacer pruebas destructivas creyendo que está en un
entorno desechable. Nosotros estuvimos a un `click` de medir accesibilidad iniciando sesión contra
producción, y **la corrida se canceló por esto**. El antecedente es el mismo de ERR-022: la
alternativa local estaba rota, así que todo el equipo apuntó a Supabase.

**Severidad y por qué.** **Alta.** No es un defecto del producto, pero es una trampa activa en el
entorno con el que verificamos, y el daño posible es sobre datos reales.

**Dueño de la corrección.** Andrés (es nuestro entorno).

**Criterio de verificación de la corrección.** Una imagen `sigra-frontend-rnf` compilada con
`apiUrl = http://localhost:8081/api`, servida en otro puerto, y la comprobación de §2.4 del README
—un login fallido sube `intentos_fallidos` **en `sigra-pg-rnf`**— hecha **desde el navegador**.
Mientras eso no exista, en el README queda escrito que el 4200 no se usa para nada autenticado.

**Lo que conviene proponerle al equipo.** Que `environment.ts` tome el `apiUrl` de una variable de
entorno en vez de tenerlo fijo en el código: hoy saber contra qué base habla un despliegue exige
desensamblar el bundle.

**Estado.** 🔴 **Nuevo** · 16 de noviembre de 2026, noche.

---

## Observaciones sin anclaje en el SRS

> **Por qué esta sección existe, y por qué estas dos cosas **no** son hallazgos de RNF.**
>
> El 16 de noviembre estas dos observaciones se registraron como «H-15» y «H-16», con un RNF
> comprometido al lado y, en el primer caso, severidad **alta** que «bloquea la entrega por el §7».
> **Estaba mal, y es la tercera vez que cometemos el mismo error de método.** Ningún requisito del
> SRS dice que una vista no deba devolver un mensaje de error genérico, ni exige cabeceras de
> endurecimiento HTTP. Al ponerles un RNF al lado estábamos **deduciendo una exigencia desde lo
> observado**, que es exactamente lo que nos hizo abrir H-06 y H-10 en falso.
>
> Las observaciones **siguen siendo válidas y útiles**: las encontró José verificando, son
> reproducibles y el equipo tiene que atenderlas. Lo que cambia es **de qué son evidencia**: son
> defectos de funcionamiento y de configuración, que pertenecen al registro de errores del equipo
> y al tablero, no al registro de incumplimientos del SRS. Conservan la numeración **OBS** que les
> dio José, que era la correcta desde el principio.

### OBS-01 (media, provisional) — Cuatro vistas del despliegue responden con un error genérico

**Qué es.** Un **defecto funcional** observado en el despliegue, no un incumplimiento de RNF.
**Observado por.** José Alejandro Valencia, 15 de noviembre de 2026, despliegue de Vercel.
**Registro original.** [hallazgos.md](evidencias-rnf/jose-validacion-2026-11/hallazgos.md).

Con el rol autorizado y sin enviar formularios, cuatro vistas mostraron **«Ocurrió un error
inesperado. Intenta de nuevo en unos minutos.»**:

| Rol | Ruta |
| --- | --- |
| ADMINISTRADOR | `/admin/ra` |
| ADMINISTRADOR | `/admin/estudiantes` |
| ADMINISTRADOR | `/admin/reportes` (Rendimiento por RA) |
| PROFESOR | `/profesor/estadisticas` |

En Catálogo apareció además «El servicio no está disponible»: la lista cargó en una visita y
falló tras F5. Detalle por pantalla en
[navegador-administrador.md](evidencias-rnf/jose-validacion-2026-11/navegador-administrador.md) y
[navegador-profesor.md](evidencias-rnf/jose-validacion-2026-11/navegador-profesor.md).

**Severidad: media, provisional** — la que puso José, y se mantiene. Una sola sesión de revisión,
sin tasa de repetición medida y sin SHA del despliegue confirmado. **Sube solo si el equipo
reproduce que bloquea una operación esencial de forma sostenida.**

**Causa: no determinada.** No hubo respuesta de red exportable ni logs del servidor. Puede ser
datos, servicio, red o despliegue. **No atribuirla a concurrencia.**

**Qué nos toca a nosotros.** Dos cosas, ninguna es «corregirlo»:

1. **Bloquea una medición nuestra.** No se puede verificar el umbral de RNF-06 (estadísticas
   < 5 s) sobre una vista que no carga. Eso no convierte a OBS-01 en incumplimiento de RNF-06: lo
   que hace es dejar RNF-06 **sin medir**, que es distinto.
2. **Reportarla donde el equipo la vea**, siguiendo el procedimiento del equipo: no se crean
   incidencias nuevas. Se comenta sobre las existentes que tocan esas pantallas —**0000041**
   (Reportes) y **0000048** (Estadísticas), ambas abiertas— y entra al registro de errores del
   libro como **ERR**.

**Relación con lo que ya existe en Mantis.** 0000041 y 0000048 tocan las mismas pantallas pero
describen otra cosa (alcance del módulo y organización de la información). Ninguna cubre este
síntoma, y por eso hay que dejarlo escrito **en ellas**, no en un ticket nuevo.

**Capturas.** No se publicaron a propósito: las vistas mostraban cuentas, registros académicos y
eventos de auditoría, y no se pudo producir copia redactada con trazabilidad. Decisión correcta.

**Estado.** 🔴 Abierta · fuera del registro de hallazgos de RNF, dentro del registro de errores.

---

### OBS-02 (baja) — Cabeceras de endurecimiento no observadas en login

**Qué es.** Una **revisión de configuración de despliegue**. El SRS no exige estas cabeceras.
**Observado por.** José Alejandro Valencia, 15 de noviembre de 2026.
**Registro original.** [seguridad.md](evidencias-rnf/jose-validacion-2026-11/seguridad.md).

En la respuesta HTTPS muestreada de `https://sigra.vercel.app/login`, **HSTS sí estaba presente**,
pero no aparecieron `Content-Security-Policy`, `X-Frame-Options`, `X-Content-Type-Options`,
`Referrer-Policy` ni `Permissions-Policy`.

**No se declara vulnerabilidad.** No se probó la ausencia en otras capas o rutas ni se demostró
impacto explotable. Es defensa en profundidad, no un requisito incumplido: **RNF-11 pide TLS y el
TLS cumple**; RNF-14 pide validar y sanear la entrada, que es del backend; RNF-17 pide que los
errores no filtren datos, y no los filtran.

**Severidad: baja.** Puede cerrarse con una **decisión escrita** de quien administre Vercel, sin
cambiar nada.

**El subproducto que sí valió oro.** Esta observación nos dio la URL de producción del frontend
—`https://sigra.vercel.app`— que no estaba escrita en ningún archivo de los dos repositorios. Con
ella se completó la verificación de **RNF-11 de punta a punta** (ver [H-10](#h-10-media--rnf-11-tls-12-no-es-verificable-sin-entorno-de-producción))
y quedó resuelto el pedido P-08.

**Estado.** 🔴 Abierta · revisión de configuración, no hallazgo de RNF.

---

### OBS-03 (baja) — Cabecera de aislamiento ausente y `/actuator/health` sin autenticación

**Qué es.** Una **revisión de configuración**, de la misma naturaleza que OBS-02. El SRS no exige
ninguna de las dos cosas, y por eso no es hallazgo de RNF.
**Observado por.** Andrés, 16 de noviembre de 2026, escaneo de ZAP contra el entorno aislado.

Dos observaciones del mismo escaneo:

1. **`Cross-Origin-Resource-Policy` ausente** en las respuestas de la API (ZAP: *Cross-Origin-Resource-Policy
   Header Missing or Invalid*, 5 instancias consolidadas; la regla 90004 es la de aislamiento
   frente a Spectre). Lo que **sí** está presente, y conviene dejarlo escrito porque contrasta con
   OBS-02: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Cache-Control: no-store` y
   `WWW-Authenticate: Bearer`. **Las cabeceras que OBS-02 echaba de menos en Vercel sí las pone el
   backend.**
2. **`/actuator/health` responde 200 sin token**, con `{"groups":["liveness","readiness"],…}`.
   ZAP lo marcó *Spring Actuator Information Leak* (Medium) en la corrida piloto.

**No se declara vulnerabilidad.** No se demostró impacto explotable. El actuator abierto es,
además, **lo que hace posible la sonda de RNF-18**: cerrarlo sin más rompería el monitor de Uptime
Kuma y la medición de disponibilidad. Si se cierra, hay que darle a Kuma un camino autenticado.

**Severidad: baja.** Se cierra con una **decisión escrita** de quien administre el despliegue.

**Evidencia.** `herramientas-rnf/evidencias/zap/zap-api-admin-2026-11-16.json` ·
`zap-api-piloto-autenticado-2026-11-16.json` · `curl -D - http://localhost:8081/actuator/health`.

**Estado.** 🔴 Abierta · revisión de configuración, no hallazgo de RNF.

---

### OBS-04 (baja) — La auditoría guarda hora local sin zona, y el reloj del motor va en UTC

**Qué es.** Una **observación de modelo de datos**. El SRS pide que cada registro de auditoría
lleve «usuario, fecha y hora, acción y resultado» (RNF-16) y **no dice en qué zona**, así que no
hay incumplimiento que declarar. Siguiendo la regla de método de este documento, no se le pone un
RNF al lado.
**Observado por.** Andrés, 16 de noviembre de 2026, al medir el efecto del escaneo de ZAP.

`sigra.historial_auditoria.fecha_hora` es `timestamp without time zone` y guarda **hora local**,
mientras el reloj del motor va en **UTC**:

```
now() = 2026-11-17 02:53:02+00   |   max(fecha_hora) = 2026-11-16 21:51:55
```

Cinco horas de diferencia sobre el mismo evento. El síntoma práctico apareció solo: una consulta
tan natural como `WHERE fecha_hora > now() - interval '40 minutes'` devuelve **cero filas**
mientras la tabla crece.

**Por qué nos importa, aunque no sea un RNF incumplido.** Dos usos reales dependen de cruzar esas
marcas con otras fuentes: el **MTTR de RNF-18** (los eventos de Render y de Uptime Kuma van en
UTC) y cualquier reconstrucción de un incidente. Con cinco horas de desfase y sin zona declarada,
el cruce hay que hacerlo a mano y es fácil equivocarse en la dirección del ajuste.

**Severidad: baja.** No se pierde información —la marca es consistente consigo misma— y la
conservación *append-only* de RNF-16 sigue verificada.

**Lo que conviene proponerle al equipo.** `timestamptz` en columnas de auditoría, o dejar escrito
en el catálogo de datos que la columna va en hora de Colombia. Es decisión del equipo, no nuestra.

**Evidencia.** Consulta de arriba contra `sigra-pg-rnf` ·
`information_schema.columns` para el tipo de la columna.

**Estado.** 🔴 Abierta · observación de modelo de datos.

---

## H-06 — Retirado por falso

**Enunciado original.** «Ningún RNF numerado cubre disponibilidad, aunque el §3.5 del manual nos
pide revisarla.»

**Por qué se retira.** **Es falso.** El SRS tiene **RNF-18**, en la sección «Disponibilidad», y es
explícito: uptime ≥ 95 % y MTTR ≤ 4 horas ante caída crítica, con una clasificación de incidentes
por severidad definida en la sección 3.3.3. El hallazgo se abrió a partir de las menciones de RNF
en el código, donde RNF-18 no aparece citado, y se concluyó de más: **que un requisito no se cite
en el código no significa que no exista en el SRS.**

**Qué lo reemplaza.** [H-09](#h-09-media--rnf-18-no-tiene-medición-de-uptime-ni-de-mttr): el
requisito existe y está bien formulado; lo que falta es medición.

**Por qué queda en el registro.** Porque retirar un hallazgo en silencio es peor que haberlo
abierto. Si lo hubiéramos presentado el 8 sin leer el SRS, el equipo habría concluido —con razón—
que no revisamos la especificación del producto que nos toca verificar. Queda como constancia de
que se verificó contra la fuente y se corrigió.

**Lección para el método.** El catálogo de RNF se construye **desde el SRS**, y el código sirve
para comprobar qué está implementado, nunca al revés.

**Estado.** **Retirado** · 7 de noviembre de 2026.

---

## Nota de método

Este lote se obtuvo leyendo el SRS y los archivos de ambos repositorios, no inspeccionando el
producto en ejecución. Cada evidencia es un archivo y, cuando fue posible, una línea.

**Antes de presentarlos el 8, cada titular debe reproducir su propio hallazgo** y confirmar que
sigue siendo cierto: el estado de un repositorio cambia, y presentar un hallazgo ya corregido le
cuesta credibilidad al rol. H-06 es el recordatorio de por qué esto importa.

**Pendientes de verificación contra el SRS:**

- Obtener el **Apéndice 4.2** (matriz de compatibilidad de pruebas) para fijar el alcance exacto
  de RNF-19: navegadores, versiones y dispositivos.
- Obtener el **Apéndice 4.1** (Matriz RBAC) vigente y contrastarlo con
  `docs/security/RBAC_MATRIX.md`, para confirmar que lo implementado coincide con lo especificado.
  Si hay diferencias, es un hallazgo de RNF-13.
- El SRS menciona cumplimiento de la **ley 1581 de 2012** y la **ley 1377 de 2013** sobre
  protección y tratamiento de datos personales. No está numerado como RNF, pero es una restricción
  de cumplimiento y conviene preguntar al Product Owner si entra en nuestro alcance de revisión.

---

[Guía del rol](GUIA-TRABAJO-RNF.md) · [A1 Catálogo](A1-catalogo-rnf.md) · [A2 Matriz de impacto](A2-matriz-impacto-calidad.md) · [A3 Criterios](A3-criterios-verificacion.md) · [A5 Informe](A5-informe-calidad.md)

---

## Seguimiento de evidencia productiva · José · 15-nov-2026

- El recorrido de Vercel identificó errores genéricos puntuales en `/admin/ra`, `/admin/estudiantes`, `/admin/reportes` y `/profesor/estadisticas`. Quedan como observación nueva **OBS-01**, con frecuencia no determinada, sin causa raíz ni SHA del despliegue. No se duplica 0000041 (alcance de Reportes) ni 0000048 (organización de Estadísticas), cuyos enunciados son distintos.
- **Corrección de la hipótesis de H-11/0000053:** el ticket actual describe carga intermitente de combos de semestre/asignatura/RA. La sesión observó estados iniciales de carga y errores en algunas vistas, pero no correlacionó solicitudes ni ejecutó concurrencia. La hipótesis de carrera o concurrencia y la afirmación de que 20 hilos la vuelven determinista no se han demostrado; no deben presentarse como causa raíz hasta reproducir en QA aislado.
- **H-08/RNF-20(a):** el backend inspeccionado en `c1b1950` sigue sin regla JaCoCo por paquete para `estadisticas`; `d6fa7e1` no forma parte del clon revisado. El cierre consignado para ese commit no se transfiere a esta rama.
- **OBS-02:** en la respuesta de login de Vercel no se observaron varias cabeceras de endurecimiento, aunque HSTS sí. Esta observación no constituye vulnerabilidad confirmada y requiere contrastar configuración de edge.

Detalle reproducible y límites: [hallazgos de esta auditoría](evidencias-rnf/jose-validacion-2026-11/hallazgos.md), [seguridad](evidencias-rnf/jose-validacion-2026-11/seguridad.md), [mantenibilidad](evidencias-rnf/jose-validacion-2026-11/mantenibilidad.md).
