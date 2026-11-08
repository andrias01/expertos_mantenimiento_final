# A4 · Registro de hallazgos y riesgos de RNF

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Apertura del registro** | 7 de noviembre de 2026 |
| **Revisión contra el SRS** | 7 de noviembre de 2026 — un hallazgo retirado, uno reformulado, tres nuevos |
| **Alcance de este lote** | Diagnóstico de la capacidad de verificación de los 21 RNF del SRS (Entrega 1) |
| **Método** | SRS de SIGRA; workflows de CI, `build.gradle`, `package.json`, `e2e/`, suite de pruebas y README de ambos repositorios |

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

| ID | Severidad | Atributo | Hallazgo | Titular | Estado |
| --- | --- | --- | --- | --- | --- |
| [H-01](#h-01-alta--el-análisis-de-dependencias-del-backend-está-apagado) | **Alta** | Seguridad | El análisis de dependencias del backend está apagado | José | Abierto |
| [H-02](#h-02-alta--nueve-requisitos-de-rendimiento-sin-un-solo-instrumento-de-medición) | **Alta** | Rendimiento | Nueve requisitos de rendimiento sin un solo instrumento de medición | Andrés | Abierto |
| [H-08](#h-08-alta--rnf-20-vigila-la-cobertura-de-dos-de-los-cuatro-módulos-obligatorios) | **Alta** | Mantenibilidad | RNF-20 vigila la cobertura de dos de los cuatro módulos obligatorios | Ambos | Abierto |
| [H-03](#h-03-media--el-e2e-de-navegador-cubre-un-solo-flujo) | Media | Mantenibilidad | El E2E de navegador cubre un solo flujo | Ambos | Abierto |
| [H-04](#h-04-media--rnf-21-no-tiene-verificación-automatizada) | Media | Accesibilidad | RNF-21 no tiene verificación automatizada | Andrés | Abierto |
| [H-05](#h-05-media--no-hay-análisis-estático-de-código) | Media | Mantenibilidad | No hay análisis estático de código | Ambos | Abierto |
| [H-09](#h-09-media--rnf-18-no-tiene-medición-de-uptime-ni-de-mttr) | Media | Disponibilidad | RNF-18 no tiene medición de uptime ni de MTTR | José | Abierto |
| [H-10](#h-10-media--rnf-11-tls-12-no-es-verificable-sin-entorno-de-producción) | Media | Seguridad | RNF-11 (TLS 1.2+) no es verificable sin entorno de producción | José | Abierto |
| [H-07](#h-07-baja--el-readme-del-backend-contradice-a-buildgradle-sobre-jacoco) | Baja | Mantenibilidad | El README del backend contradice a `build.gradle` sobre JaCoCo | Ambos | Abierto |
| [H-06](#h-06--retirado-por-falso) | — | — | ~~Ningún RNF numerado cubre disponibilidad~~ | — | **Retirado** |

**Tres hallazgos de severidad alta.** Según el §7, «los defectos críticos y altos bloquean la
entrega». Ninguno bloquea la Entrega 1 —son de capacidad de verificación, no defectos de
funcionalidad— pero **H-08 es un incumplimiento directo del SRS** y los tres condicionan la
Entrega 3.

### Lo que hay que decir junto con los hallazgos

La red de pruebas de SIGRA es amplia y hay que reconocerlo al presentar: 102 clases de prueba en
el backend (26 de integración), 74 specs en el frontend, 490 peticiones Bruno, documentación
OpenAPI con 10 clases de prueba que la verifican, y
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

**Estado.** Abierto.

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

**Estado.** Abierto.

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

**Estado.** Abierto.

---

## H-03 (media) — El E2E de navegador cubre un solo flujo

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

**Estado.** Abierto.

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

**Estado.** Abierto.

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

**Estado.** Abierto.

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

**Estado.** Abierto.

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

**Estado.** Abierto.

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

**Estado.** Abierto.

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
