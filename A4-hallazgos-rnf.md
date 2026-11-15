# A4 · Registro de hallazgos y riesgos de RNF

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Apertura del registro** | 7 de noviembre de 2026 |
| **Revisión contra el SRS** | 7 de noviembre de 2026 — un hallazgo retirado, uno reformulado, tres nuevos |
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

---

## Resumen

### Estado al 15 de noviembre de 2026

| ID | Severidad | Atributo | Hallazgo | Titular | Estado |
| --- | --- | --- | --- | --- | --- |
| [H-08](#h-08-alta--rnf-20-vigila-la-cobertura-de-dos-de-los-cuatro-módulos-obligatorios) | **Alta** | Mantenibilidad | RNF-20 vigila la cobertura de dos de los cuatro módulos obligatorios | Ambos | 🟢 **Corregido y verificado** · 15-nov · falta PR |
| [H-10](#h-10-media--rnf-11-tls-12-no-es-verificable-sin-entorno-de-producción) | Media | Seguridad | RNF-11 (TLS 1.2+) no es verificable sin entorno de producción | José | 🟢 **Cerrado** · 15-nov · la premisa cambió: hay producción |
| [H-01](#h-01-alta--el-análisis-de-dependencias-del-backend-está-apagado) | **Alta** | Seguridad | El análisis de dependencias del backend está apagado | José | 🔴 **Abierto · 8 días** · reconfirmado por API |
| [H-11](#h-11-alta--la-incidencia-0000053-no-tiene-dueño-y-es-de-perfil-no-funcional) | **Alta** | Rendimiento / fiabilidad | La incidencia 0000053 no tiene dueño y es de perfil no funcional | Andrés | 🔴 **Nuevo** · 15-nov |
| [H-03](#h-03-media--alta-el-15-nov--el-e2e-de-navegador-cubre-un-solo-flujo) | **Alta** ⬆ | Mantenibilidad | El E2E de navegador cubre un solo flujo, y el producto creció ocho módulos | Ambos | 🔴 **Abierto · sube de media a alta** |
| [H-02](#h-02-alta--nueve-requisitos-de-rendimiento-sin-un-solo-instrumento-de-medición) | **Alta** | Rendimiento | Nueve requisitos de rendimiento sin un solo instrumento de medición | Andrés | 🟡 **En corrección** · instrumento creado, sin ejecutar |
| [H-09](#h-09-media--rnf-18-no-tiene-medición-de-uptime-ni-de-mttr) | Media | Disponibilidad | RNF-18 no tiene medición de uptime ni de MTTR | José | 🟡 **En corrección** · uptime medido; MTTR sin evento |
| [H-12](#h-12-media--los-dos-rnf-que-el-equipo-nos-asignó-se-resolvieron-sin-nuestra-validación) | Media | Mantenibilidad | Los dos RNF que el equipo nos asignó se resolvieron sin nuestra validación | Ambos | 🔴 **Nuevo** · 15-nov |
| [H-13](#h-13-media--ninguna-incidencia-está-cerrada-en-mantis) | Media | Trazabilidad | Ninguna de las 31 incidencias está en estado `cerrada` en Mantis | Ambos | 🔴 **Nuevo** · 15-nov |
| [H-04](#h-04-media--rnf-21-no-tiene-verificación-automatizada) | Media | Accesibilidad | RNF-21 no tiene verificación automatizada | Andrés | 🟡 **Abierto** · corregido a mano por UI/UX, sin automatizar |
| [H-05](#h-05-media--no-hay-análisis-estático-de-código) | Media | Mantenibilidad | No hay análisis estático de código | Ambos | 🟡 **En corrección** · plan de SonarQube listo |
| [H-14](#h-14-baja--el-entorno-local-no-puede-compilar-el-frontend) | Baja | Mantenibilidad | El entorno local no puede compilar el frontend (Node por debajo del mínimo) | Andrés | 🔴 **Nuevo** · 15-nov |
| [H-07](#h-07-baja--el-readme-del-backend-contradice-a-buildgradle-sobre-jacoco) | Baja | Mantenibilidad | El README del backend contradice a `build.gradle` sobre JaCoCo | Ambos | 🔴 **Abierto** · ahora también desactualizado por el fix de H-08 |
| [H-06](#h-06--retirado-por-falso) | — | — | ~~Ningún RNF numerado cubre disponibilidad~~ | — | **Retirado por falso** · 7-nov |

### Movimiento entre el 8 y el 15 de noviembre

| | 8-nov | 15-nov |
| --- | --- | --- |
| Abiertos | 9 | **7** |
| En corrección | 0 | **4** |
| Cerrados con evidencia | 0 | **2** |
| De severidad alta | 3 | **4** (H-08 se cierra, H-03 sube, H-11 entra) |

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
Esto convierte H-01 en un pedido al equipo, no en una tarea nuestra, y lleva **ocho días** pedido
(P-05, reunión 1). Hay que escalarlo con nombre y fecha esta noche.

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

**Estado.** 🟢 **Corregido y verificado · 15 de noviembre de 2026.** Falta abrirlo como Pull
Request: nuestro rol no integra código.

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

Ocho módulos nuevos, varios de ellos con reglas de alcance por rol (el estudiante solo ve lo suyo,
el profesor solo sus semestres, R2 solo administrador) y una migración de datos, **sin una sola
prueba de navegador que los recorra**. RNF-19 pide que los flujos tocados funcionen en los
navegadores exigidos; hoy el único flujo que se comprueba en navegador es el login.

**Lo que lo vuelve urgente y no teórico.** La incidencia **0000053** (ver
[H-11](#h-11-alta--la-incidencia-0000053-no-tiene-dueño-y-es-de-perfil-no-funcional)) es
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

**Seguimiento · 15 de noviembre de 2026.** Hay que reconocer trabajo ajeno que nos toca el tema:
Andrea Avendaño (UI/UX) revisó la documentación para extraer los requisitos de accesibilidad
(ACT-095) y corrigió hallazgos de frontend —**contraste 4,5:1**, paginador común en Evaluaciones,
desborde en móvil— en ACT-096, PR frontend **#91**, que al momento de esta revisión figura en
estado *Pendiente* en el registro del equipo.

Eso es bueno y mejora el cumplimiento real de RNF-21. **No cambia el hallazgo**, que no es «el
contraste está mal» sino «no hay forma automática de saber si se rompe». Sigue sin instalarse
`@axe-core/playwright` y sigue sin haber una comprobación que falle cuando una vista nueva entre
sin `label`.

**Lo que corresponde ahora, y es nuestro trabajo de F4.** Pedirle a Andrea la evidencia concreta
del PR #91 —qué vistas midió, con qué herramienta, y la captura— para poder dar un veredicto
amarillo sostenido en evidencia en lugar de amarillo por ausencia. Y llevar al equipo la decisión
sobre la dependencia nueva, que no es nuestra para tomar.

**Severidad.** Se mantiene **media**.

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

**Estado.** 🟡 **En corrección.**

**Seguimiento · 15 de noviembre de 2026.** Se decidió el instrumento: **SonarQube**, por dos
caminos en paralelo.

**Camino 1 — medición hoy, sin depender de nadie.** SonarQube Community en Docker, escaneando los
dos repositorios desde la copia local. Da la nota de mantenibilidad, la deuda técnica, los *code
smells* y los puntos calientes de seguridad, con evidencia esta misma noche. **Bloqueado por el
mismo detalle operativo que H-02: Docker Desktop no está arrancado.**

**Camino 2 — permanente, en el CI.** SonarCloud, que es **gratuito en repositorios públicos** y
los dos lo son (verificado: `gh repo view` devuelve `"visibility":"PUBLIC"` en ambos). Requiere que
el dueño del repositorio cree el proyecto y agregue `SONAR_TOKEN` a los secretos de Actions.
**Es el mismo bloqueo de permisos de H-01**, y conviene pedir las dos cosas juntas en la misma
petición al admin, porque es el mismo clic en la misma pantalla de Settings.

**Lo que aporta a RNF-20 que JaCoCo no aporta.** JaCoCo responde «cuánto código tocan las
pruebas». Mantenibilidad es más que eso: complejidad, duplicación, reglas incumplidas. Sonar
también **consume el XML de JaCoCo**, así que la cobertura corregida en H-08 queda visible en el
mismo tablero y deja de vivir en un reporte local que nadie abre.

**Severidad.** Se mantiene **media**: el SRS no lo exige, y el proyecto puede cerrar sin esto.

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

**La reserva que queda, y que abre un pedido nuevo.** Esto verifica el **backend**. El frontend
está en Vercel y hay que medirle lo mismo, pero **su URL de producción no está escrita en ningún
archivo de los dos repositorios** (lo buscamos: no hay ninguna referencia a `vercel.app` fuera de
`vercel.json`, que solo configura el despliegue). Queda como pedido **P-08**: que quien hizo el
despliegue comparta la URL, para cerrar RNF-11 en los dos lados.

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

## H-11 (alta) — La incidencia 0000053 no tiene dueño y es de perfil no funcional

**Atributo de calidad afectado.** Rendimiento / fiabilidad.
**RNF comprometido.** RNF-01, RNF-02 (concurrencia), RNF-04, RNF-06.

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

**Por qué es un asunto de RNF y no solo funcional.** Tres señales juntas:

1. **«Intermitente» y «a veces»** es el perfil de un problema de concurrencia, de carrera entre
   peticiones o de tiempo de respuesta, no de lógica de negocio. Una regla de negocio mal escrita
   falla siempre; esto falla a veces.
2. **«En múltiples módulos y en todos los roles»** apunta a algo compartido —la carga en cascada
   de los combos— y no a un módulo concreto.
3. Hay un antecedente directo en el propio registro del equipo: **ERR-002**, donde Tomás Gómez
   documentó que en Estadísticas «una respuesta vieja podía sobrescribir la más reciente» porque
   las peticiones no cancelaban las anteriores. Ese es exactamente el mecanismo que produce un
   combo que a veces carga y a veces no. Si el patrón se repitió en los módulos que tocaron
   0000044, 0000045 y 0000046 —que son los de filtros en cascada— 0000053 es la misma causa raíz
   replicada.

**Riesgo si no se corrige.** Un profesor abre Evaluaciones o Estadísticas, el combo de semestre
aparece vacío, y concluye que no tiene asignaturas. No es un error visible con mensaje: es un
listado vacío, que el usuario lee como «no hay datos». Es el peor modo de falla posible para un
sistema de registro académico, porque no se nota.

**Severidad y por qué.** **Alta.** Prioridad alta y severidad mayor en Mantis, y según el §7 del
manual los defectos altos **bloquean la entrega**. Agravante: lleva un día sin dueño, y la entrega
es hoy.

**Dueño de la corrección.** Por asignar. Nuestra propuesta: quien haya trabajado el patrón de
filtros en cascada (Tomás Marín por 0000045, Salomé González por 0000044, Tomás Gómez por 0000047),
porque la causa raíz probablemente sea común a los tres.

**Criterio de verificación de la corrección.** `jmeter/RNF-01-06-rendimiento.jmx` con
`-Jusuarios=20` sobre los endpoints de catálogo, contra PostgreSQL local. Si el defecto es de
concurrencia o de cancelación de peticiones, 20 hilos lo vuelven **determinista**, y entonces se
puede corregir y comprobar. Mientras solo se pruebe a mano, va a seguir siendo «a veces».

**Lo que esto significa para nuestro rol.** Es el mejor argumento que tenemos para que el equipo
adopte JMeter: no es burocracia de calidad, es la única forma práctica de cazar un defecto abierto
de severidad alta que hoy nadie tiene asignado.

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
