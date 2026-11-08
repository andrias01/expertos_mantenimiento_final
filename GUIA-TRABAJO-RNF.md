# Guía de trabajo · Especialistas en Requisitos No Funcionales

**Proyecto de Mantenimiento de Software · SIGRA**
Ingeniería de Software 4 · Universidad Católica de Oriente · 2026

| | |
| --- | --- |
| **Responsables del rol** | Andrés Felipe Vélez Alcaraz · José Alejandro Valencia |
| **Rol en el manual operativo** | §3.5 Especialista en requisitos no funcionales |
| **Documento base** | `BITACORAS DE CLASE/Clase#11/Proyecto Mantenimiento.pdf` |
| **Producto a mantener** | SIGRA (backend Spring Boot 4 + frontend Angular 22) |
| **Última actualización** | 7 de noviembre de 2026 |

> **Cómo usar este documento.** Las secciones 1 a 5 son la base que se lee una vez y se consulta.
> La sección 6 es la operativa: tiene un bloque por reunión con lo que hay que llevar listo y el
> guion de qué decir. La sección 9 es la bitácora que se va llenando.

---

## Índice

- [1. Qué nos toca y hasta dónde llega nuestra autoridad](#1-qué-nos-toca-y-hasta-dónde-llega-nuestra-autoridad)
- [2. Reparto del trabajo entre Andrés y José](#2-reparto-del-trabajo-entre-andrés-y-josé)
- [3. Catálogo de RNF de SIGRA](#3-catálogo-de-rnf-de-sigra)
- [4. Línea base de verificación: con qué podemos medir hoy](#4-línea-base-de-verificación-con-qué-podemos-medir-hoy)
- [5. Los cinco artefactos que entregamos](#5-los-cinco-artefactos-que-entregamos)
- [6. Las cuatro reuniones: qué llevar y qué decir](#6-las-cuatro-reuniones-qué-llevar-y-qué-decir)
- [7. Cómo participamos en los filtros F2 y F4](#7-cómo-participamos-en-los-filtros-f2-y-f4)
- [8. Registros obligatorios que nos exigen](#8-registros-obligatorios-que-nos-exigen)
- [9. Bitácora de hallazgos](#9-bitácora-de-hallazgos)
- [10. Riesgos propios del rol](#10-riesgos-propios-del-rol)
- [11. Checklist de cierre](#11-checklist-de-cierre)

---

## 1. Qué nos toca y hasta dónde llega nuestra autoridad

### 1.1 Las tres labores del manual (§3.5)

1. Identificar atributos de calidad afectados por cada mantenimiento.
2. Revisar seguridad, rendimiento, disponibilidad, compatibilidad y mantenibilidad, según aplique.
3. Definir criterios de verificación, identificar riesgos y documentar hallazgos.

Y la frase que define el rol: **«Debe participar desde el diagnóstico y análisis de impacto, no
solamente al finalizar.»** Si nos aparecemos en el día 14 a verificar, incumplimos el rol aunque
el informe quede bonito.

### 1.2 Dónde somos la A de la matriz RACI (Anexo A)

Esto es lo más importante de toda la guía. En la matriz RACI tenemos **exactamente dos
actividades donde somos A/R** —responsables últimos— y en el resto somos consultados:

| Actividad | Nuestro papel | Qué significa en la práctica |
| --- | --- | --- |
| **Identificar requisitos no funcionales** | **A/R** | Nadie más responde por esto. Si no existe el catálogo de RNF por mantenimiento, es nuestra falla. |
| **Verificar requisitos no funcionales** | **A/R** | El criterio de finalización «los requisitos no funcionales fueron verificados» lo firmamos nosotros. |
| Análisis de impacto | R/C | Participamos ejecutando o como consultados; la responsabilidad general es de desarrollo. |
| Diseñar solución técnica | C | Opinamos sobre atributos de calidad, no sobre el diseño. |
| Revisar y aprobar Pull Request | C | **No aprobamos PR.** Esa autoridad es exclusiva del revisor técnico. |
| Diseñar casos de prueba | C | Aportamos los casos de RNF; el dueño es el equipo de pruebas. |
| Ejecutar pruebas funcionales y regresión | C | No las ejecutamos nosotros. |
| Registrar y corregir defectos | C | Reportamos los nuestros; corrige el desarrollador responsable. |

Además somos **co-responsables de dos filtros de calidad** (§7):

- **F2 · Diseño** — junto al revisor técnico. Criterio de salida: *diseño coherente, impacto
  identificado y **criterios definidos***. Esos criterios definidos son los nuestros.
- **F4 · Pruebas** — junto a los analistas de pruebas. Criterio de salida: *pruebas ejecutadas y
  resultados satisfactorios; defectos bloqueantes resueltos*.

### 1.3 Nuestros límites (decirlo en voz alta evita conflictos)

- No aprobamos técnicamente código ni integramos a la rama principal.
- No bajamos ni subimos la severidad de un defecto por nuestra cuenta: se decide en conjunto.
- No reemplazamos al equipo de pruebas: nosotros definimos **qué hay que verificar y con qué
  criterio**; ellos ejecutan las pruebas funcionales y de regresión.
- Sí podemos **bloquear una entrega** por la vía legítima: un RNF no verificado incumple el
  criterio de finalización del §13, y un hallazgo de severidad crítica o alta bloquea la entrega
  según el §7.

### 1.4 Lo que aparece en cada entrega y es nuestro

| Entrega | Línea del cronograma que nos nombra |
| --- | --- |
| **Entrega 1 · Día 5** | «Análisis de impacto, riesgos y **requisitos no funcionales**» |
| **Entrega 2 · Día 10** | «Registro de defectos y **verificación inicial de RNF**» |
| **Entrega 3 · Día 15** | «Pruebas funcionales, de regresión y **verificación de RNF**» + «**informe de calidad**» |
| **Criterios de finalización §13** | «Los **requisitos no funcionales fueron verificados**» |

---

## 2. Reparto del trabajo entre Andrés y José

El manual contempla **un** especialista RNF y nosotros somos **dos**. Eso es una ventaja si la
usamos bien: nos repartimos por **atributo de calidad**, no por repositorio, porque los atributos
transversales (la seguridad de punta a punta, por ejemplo) se caen justo en la frontera entre
frontend y backend si cada uno mira solo su lado.

### 2.1 Titular y suplente por atributo

| Atributo de calidad | Titular | Suplente | Por qué |
| --- | --- | --- | --- |
| **Seguridad** (autenticación, RBAC, inyección, secretos, dependencias) | José | Andrés | José implementó `auth`, `security` y `auditoria` en el backend |
| **Disponibilidad** (arranque, `/actuator/health`, degradación) | José | Andrés | Mismo terreno |
| **Auditoría / integridad del historial** | José | Andrés | RF-19 y RNF-16 son suyos |
| **Rendimiento** (tiempos de respuesta, tamaño de bundle, carga < 3 s) | Andrés | José | Andrés trabajó el frontend y el build |
| **Compatibilidad** (navegadores, responsive) | Andrés | José | Terreno frontend |
| **Usabilidad y accesibilidad** (WCAG AA, teclado, color) | Andrés | José | Terreno frontend |
| **Mantenibilidad** (duplicación, complejidad, cobertura, documentación) | **Ambos** | — | Es el atributo que más se degrada en mantenimiento; se revisa a cuatro ojos |

**Por qué hay suplente en cada fila.** En el taller de análisis del manual señalamos que el punto
único de falla del equipo es el revisor técnico. No repitamos ese error en nuestro propio rol: si
uno de los dos no puede en una fecha, el otro tiene que poder responder por el atributo. Cada
suplente debe poder decir, en cualquier reunión, en qué va el atributo del otro.

### 2.2 Lo que hacemos siempre juntos

- El **catálogo de RNF por mantenimiento** (artefacto A1): lo firmamos los dos.
- La **matriz de impacto en atributos de calidad** (A2): uno redacta, el otro revisa.
- El **informe de calidad de cierre** (A5): una sola voz, dos revisiones.
- La **clasificación de severidad** de nuestros hallazgos: nunca uno solo.

### 2.3 Regla de trabajo entre nosotros dos

> Ningún hallazgo entra al registro sin que el otro lo haya leído. No es desconfianza: es que un
> hallazgo mal clasificado le cuesta tiempo a un desarrollador y credibilidad a nuestro rol.

---

## 3. Catálogo de RNF de SIGRA

El SRS define **21 requisitos no funcionales**, agrupados por atributo. El catálogo completo, con
el enunciado textual de cada uno y su instrumento de verificación, está en
[A1-catalogo-rnf.md](A1-catalogo-rnf.md). Aquí va el mapa para orientarse.

| Grupo | RNF | Qué cubre | Titular |
| --- | --- | --- | --- |
| **Rendimiento** | RNF-01 a RNF-09 | 20 usuarios concurrentes · autenticación < 4 s · CRUD y calificaciones < 3 s · estadísticas < 5 s · 50 evaluaciones por asignatura · páginas < 3 s · sostenido 4 meses | Andrés |
| **Seguridad** | RNF-10 a RNF-17 | BCrypt ≥ 12 con salt · TLS 1.2+ · JWT HS256 con iat/exp · RBAC en el backend · validar y sanear · expiración 60 min · auditoría append-only · errores sin detalles técnicos | José |
| **Disponibilidad** | RNF-18 | Uptime ≥ 95 % · MTTR ≤ 4 h ante caída crítica | José |
| **Compatibilidad** | RNF-19 | Dos últimas versiones de Chrome, Edge y Firefox, escritorio y móvil | Andrés |
| **Mantenibilidad** | RNF-20 | Cobertura ≥ 70 % en cuatro módulos obligatorios · OpenAPI de endpoints protegidos con sus códigos | Ambos |
| **Accesibilidad** | RNF-21 | WCAG 2.1 AA: contraste 4.5:1 · teclado en notas y observaciones · labels en todos los campos | Andrés |

### 3.1 Cobertura real, la cifra que hay que llevar a la reunión

| Estado | Cantidad | RNF |
| --- | --- | --- |
| 🟢 **Verificable hoy sin trabajo adicional** | 7 | 10, 12, 13, 15, 16, 17, 20 (b) |
| 🟡 **Verificable con reservas que hay que declarar** | 3 | 14, 19, 20 (a) |
| 🟠 **Necesita una decisión del equipo primero** | 2 | 11, 21 |
| 🔴 **Sin instrumento en el alcance de 15 días** | 9 | 01 a 09 — todo el rendimiento |

**De 21 requisitos no funcionales, siete se verifican hoy y nueve no tienen cómo verificarse.** El
rendimiento es el tema central del diagnóstico, y hay que nombrarlo el día 5.

### 3.2 Cómo se construye un catálogo, y el error que no hay que repetir

La primera versión de este catálogo se armó a partir de las menciones de `RNF-` en el código y los
README, y listaba 12 requisitos. El SRS tiene 21. Peor: concluimos que **ningún RNF cubría
disponibilidad** cuando RNF-18 existe y es explícito — ese fue el hallazgo H-06, retirado por
falso.

> **La regla que queda.** El catálogo de RNF se construye **desde el SRS**. El código sirve para
> comprobar qué está implementado y qué se puede verificar, nunca para deducir qué se exige. Que
> un requisito no se cite en el código no significa que no exista.

## 4. Línea base de verificación: con qué podemos medir hoy

Antes de prometer criterios de verificación hay que saber qué herramientas ya existen en SIGRA.
Esto se revisó directamente en los dos repositorios el 7 de noviembre.

### 4.1 Lo que ya corre automáticamente

**El volumen de la red de pruebas, para no subestimarla.** Antes de señalar huecos hay que saber
qué hay, porque es bastante más de lo que parece a primera vista:

| Nivel | Cantidad |
| --- | --- |
| Clases de prueba del backend | **102** (76 unitarias y de capa web + 26 de integración) |
| Specs del frontend | **74** |
| Peticiones de la colección Bruno | **490** |
| Specs E2E de Playwright | **1** (solo autenticación) |

Dentro de esa red hay una pieza que nos sirve especialmente:
**`PrivateEndpointAuthorizationArchitectureTest`** es una guardia arquitectónica que recorre el
registro real de Spring MVC y comprueba que ninguna ruta privada quede solo detrás de
`authenticated()`. Es decir: **un endpoint nuevo sin `@PreAuthorize` pone la prueba roja sola**.
Es el mejor criterio de verificación de RNF-13 que podríamos pedir, y ya existe.

**Frontend** (`software4-SIGRA-frontend/.github/workflows/ci.yml`)

| Verificación | Comando | Qué RNF toca |
| --- | --- | --- |
| Build producción y desarrollo | `ng build` | RNF-08 (indirecto) |
| Chequeo de tipos (app, spec, e2e) | `tsc --noEmit` | Mantenibilidad |
| Pruebas unitarias | `ng test --no-watch` (Vitest) | Mantenibilidad |
| **Auditoría de dependencias** | `npm audit --audit-level=high` | **Seguridad** |
| Smoke SSR y rutas profundas | `smoke:ssr`, `smoke:vercel` | Disponibilidad |
| **E2E en Chromium y Firefox** | `npm run e2e` (Playwright, backend real + PostgreSQL efímero) | **RNF-19** |

**Backend** (`software4-SIGRA-backend/.github/workflows/ci.yml`)

| Verificación | Comando | Qué RNF toca |
| --- | --- | --- |
| Pruebas unitarias | `./gradlew test` | Mantenibilidad |
| Pruebas de integración con PostgreSQL | `./gradlew integrationTest` | Disponibilidad |
| **Cobertura mínima 70 %** | `./gradlew jacocoTestCoverageVerification` | **Mantenibilidad** |
| Validación de esquema | `ddl-auto=validate` | Integridad |

### 4.2 Lo que está apagado o no existe

Esto es material de hallazgo inmediato, no suposición: se verificó en los archivos del repositorio.

| ID | Hueco | Evidencia | Atributo | Severidad |
| --- | --- | --- | --- | --- |
| H-01 | **El SCA de dependencias del backend está apagado** | `ci.yml` condiciona *Dependency Review* a `vars.SIGRA_ENABLE_DEPENDENCY_REVIEW` y *OWASP Dependency-Check* a `vars.SIGRA_ENABLE_OWASP_SCA`; ninguna está habilitada. El propio comentario advierte que «SKIPPED no significa auditado» | Seguridad | **Alta** |
| H-02 | **Nueve requisitos de rendimiento sin un solo instrumento** | No existe prueba de carga, medición de tiempos, Lighthouse ni presupuesto de bundle. RNF-01 a RNF-09 fijan umbrales numéricos y ninguno se puede medir | Rendimiento | **Alta** |
| H-08 | **RNF-20 vigila la cobertura de 2 de los 4 módulos obligatorios** | `build.gradle:105-120` incluye los paquetes de `auth` y `config`, pero no los de `estadisticas`, donde viven RF-14 y RF-16. El comentario del propio archivo lo admite y quedó obsoleto | Mantenibilidad | **Alta** |
| H-03 | **El E2E de navegador cubre un solo flujo** | `e2e/` contiene un único spec: `auth.spec.ts`. La red general es amplia (ver 4.1), pero el nivel de navegador solo cubre el login | Mantenibilidad | Media |
| H-04 | **RNF-21 sin verificación automatizada** | No hay `@axe-core/playwright` en `package.json` ni uso de axe en `e2e/`, pese a que la documentación lo menciona | Accesibilidad | Media |
| H-05 | **Sin análisis estático de código** | No hay linter en el frontend (`ng lint` pendiente según el README) ni Checkstyle/Sonar en el backend. *RNF-20 no lo exige: es buena práctica ausente, no incumplimiento* | Mantenibilidad | Media |
| H-09 | **RNF-18 sin medición de uptime ni MTTR** | El requisito existe y fija umbrales (≥ 95 %, ≤ 4 h), pero no hay monitoreo ni entorno en operación durante el proyecto | Disponibilidad | Media |
| H-10 | **RNF-11 (TLS 1.2+) no verificable** | Exige HTTPS en producción; no hay entorno de producción. Verificable solo por inspección de URLs absolutas en el código | Seguridad | Media |
| H-07 | **Documentación desactualizada sobre JaCoCo** | El README dice que el plugin «todavía no está declarado», pero `build.gradle:6,99-125` ya lo declara con umbral global y por paquete | Mantenibilidad | Baja |
| ~~H-06~~ | ~~Sin RNF de disponibilidad~~ | **Retirado por falso:** RNF-18 existe en el SRS y es explícito. Ver [A4](A4-hallazgos-rnf.md#h-06--retirado-por-falso) | — | — |

### 4.3 Qué proponemos activar el día 1 (barato y de alto retorno)

Ordenado por costo/beneficio. Nosotros no lo implementamos —no es nuestro rol— pero lo
**proponemos con criterio y lo exigimos como criterio de verificación**:

1. **Completar el umbral de cobertura de RNF-20 (H-08).** Agregar
   `co.edu.uco.sigra.estadisticas.service*` a la lista `includes` de
   `jacocoTestCoverageVerification`. Son **dos líneas** y cierra el único incumplimiento
   documentable del SRS en el registro: hoy el nivel de logro y las conclusiones no tienen umbral
   de cobertura aunque el SRS los nombre como módulos obligatorios.
2. **Encender el SCA del backend (H-01).** Dos variables de repositorio. Cierra el hueco de
   seguridad más grande y es la propuesta más fácil de defender.
3. **Presupuesto de bundle en `angular.json` (H-02).** Da un criterio numérico y verificable para
   RNF-08 sin montar pruebas de carga, y es lo único de la lista que **previene** regresiones de
   rendimiento en lugar de solo medir el estado actual.
4. **`@axe-core/playwright` en el E2E existente (H-04).** Convierte RNF-21 de «se revisó a ojo» a
   «el build falla si baja la accesibilidad».
5. **Linter y formateador en el frontend (H-05).** Vuelve objetivo el criterio de legibilidad que
   hoy es opinión del revisor técnico, y lo descarga.
6. **Pruebas de caracterización sobre la línea base (H-03).** El manual exige conservar la línea
   base (§8); usarla para capturar el comportamiento actual antes de tocar código es lo único que
   avisa si un mantenimiento rompió algo.

> **Cómo presentar esta lista.** Las dos primeras cuestan minutos y cierran hallazgos de severidad
> alta. Si el equipo solo acepta una cosa de todo lo que proponemos, que sea la primera: es la que
> convierte un incumplimiento del SRS en cumplimiento, con dos líneas de configuración.

---

## 5. Los cinco artefactos que entregamos

Estos son los documentos con los que se mide nuestro rol. Viven en esta misma carpeta
`mantenimiento-rnf/`.

| ID | Artefacto | Archivo | Para cuándo | Dueño |
| --- | --- | --- | --- | --- |
| **A1** | Catálogo de RNF aplicables por mantenimiento | `A1-catalogo-rnf.md` | Entrega 1 | Ambos |
| **A2** | Matriz de impacto en atributos de calidad | `A2-matriz-impacto-calidad.md` | Entrega 1 | Ambos |
| **A3** | Criterios de verificación de RNF | `A3-criterios-verificacion.md` | Entrega 1, se refina en 2 | Por titular |
| **A4** | Registro de hallazgos y riesgos de RNF | `A4-hallazgos-rnf.md` | Vivo, todo el proyecto | Por titular |
| **A5** | Informe de calidad (verificación final de RNF) | `A5-informe-calidad.md` | Entrega 3 | Ambos |

### 5.1 A2 · Matriz de impacto — plantilla

Una fila por cada requerimiento de mantenimiento. Esta es la tabla que nos piden en F2.

| Campo | Contenido |
| --- | --- |
| ID del mantenimiento | `MNT-03` |
| Tipo | Correctivo / adaptativo / perfectivo / preventivo |
| Módulos tocados | `auth`, `estudiantes` |
| **Atributos de calidad afectados** | Seguridad, mantenibilidad |
| **RNF comprometidos** | RNF-13, RNF-17 |
| Riesgo si no se verifica | Un endpoint nuevo sin `@PreAuthorize` queda accesible a cualquier rol autenticado |
| Severidad del riesgo | Crítica / alta / media / baja |
| **Criterio de verificación** | Prueba que un ESTUDIANTE recibe 403 en el endpoint nuevo |
| Cómo se verifica | `./gradlew test --tests '*Rbac*'` + caso Bruno |
| Evidencia esperada | Salida de la prueba en el PR |
| Veredicto | Pendiente / verificado / no cumple |
| Verificado por | José · fecha |

### 5.2 A3 · Criterio de verificación — cómo se escribe uno bueno

Un criterio sirve solo si otra persona puede ejecutarlo y obtener el mismo veredicto. La regla:
**verbo medible + umbral + cómo se comprueba + qué evidencia queda.**

| ❌ No sirve | ✅ Sirve |
| --- | --- |
| «Se revisó la seguridad» | «Un usuario con rol ESTUDIANTE recibe 403 en `GET /api/v1/profesores`. Evidencia: prueba `RbacProfesoresTest` en verde en el PR» |
| «La página carga rápido» | «El bundle inicial no supera los 500 KB comprimidos. Evidencia: salida de `ng build` con presupuesto declarado en `angular.json`» |
| «Los errores no muestran detalles técnicos» | «Ningún campo de la respuesta 500 contiene la cadena `co.edu.uco.sigra`, `SQL`, `Exception` ni una ruta de archivo. Evidencia: `HallazgosContratoErrorTest` en verde» |
| «Es accesible» | «axe no reporta violaciones *serious* ni *critical* en `/login` y en la planilla de notas. Evidencia: reporte axe adjunto al PR» |

### 5.3 A4 · Hallazgo — plantilla

Reutilizamos el formato que ya se usó en `scripts_andres/hallazgos-manejo-errores.md`, que
funcionó bien y el equipo ya conoce:

```markdown
## H-0X (severidad) — título corto del hallazgo · Estado

**Atributo de calidad afectado.** Seguridad / rendimiento / ...
**RNF comprometido.** RNF-XX
**Qué se encontró.** Hecho verificable, sin adjetivos.
**Cómo se reproduce.** Pasos exactos o comando.
**Evidencia.** Archivo:línea, salida de comando, captura.
**Riesgo si no se corrige.** Consecuencia concreta para el usuario o el producto.
**Severidad y por qué.** Crítica/alta bloquean la entrega (§7); media/baja requieren decisión de tratamiento.
**Dueño de la corrección.** Nombre del desarrollador responsable.
**Criterio de verificación de la corrección.** Qué prueba tiene que pasar para cerrarlo.
**Estado.** Abierto / en corrección / verificado / aceptado como deuda técnica.
```

**Regla de severidad** (del §7 del manual): crítica y alta **bloquean la entrega**; media y baja
se documentan y necesitan una **decisión de tratamiento antes del cierre**. No inflemos
severidades para que nos escuchen: se nos gasta la credibilidad y después nadie nos cree la que
sí importa.

---

## 6. Las cuatro reuniones: qué llevar y qué decir

### 6.0 Cómo leer el calendario

El manual habla de un cronograma de **15 días calendario** con entregas en los días 5, 10 y 15.
Tomando como hipótesis que el **día 1 fue el 4 de noviembre** (la clase donde se entregó el
manual), el calendario queda así:

| Fecha | Día del proyecto | Hito del manual |
| --- | --- | --- |
| mié 4 nov | Día 1 | Kick-off |
| **dom 8 nov · 8:00 pm** | **Día 5** | **Entrega 1 · Diagnóstico y planeación** |
| **mié 11 nov · 6:00 pm** | **Día 8** | Implementación en curso |
| vie 13 nov | Día 10 | Entrega 2 · Implementación y revisión técnica |
| **dom 15 nov · 8:00 pm** | **Día 12** | Validación en curso |
| **mar 17 nov · 11:00 pm** | **Día 14** | Última sincronización antes del cierre |
| mié 18 nov | Día 15 | Entrega 3 · Validación y cierre |

> 🔴 **Primera acción del domingo 8: confirmar este calendario con el Product Owner / Scrum
> Master.** Si las entregas 2 y 3 caen en otras fechas, todo el plan de abajo se corre. No
> asumamos: preguntémoslo y dejémoslo escrito.

En las cuatro reuniones cada integrante responde las tres preguntas de la Daily (§6):
**¿qué realicé?, ¿qué realizaré? y ¿qué impedimentos tengo?** Los problemas técnicos largos se
sacan a un espacio aparte — eso también lo dice el manual, y nos conviene usarlo: nuestros temas
suelen ser largos.

---

### 6.1 🟥 Hoy, sábado 7 de noviembre — antes de la reunión de mañana

La reunión 1 coincide con la Entrega 1, donde nos nombran explícitamente. Hay que llegar con algo
escrito, no con buenas intenciones.

**Andrés y José, juntos (1 hora de llamada):**

- [ ] Leer esta guía completa y ponerse de acuerdo en el reparto de la sección 2.
- [ ] Decidir quién habla primero mañana y qué dice cada uno (no repetirse).

- [x] ~~Confirmar los RNF contra el SRS~~ — hecho. Son **21**, no 12, y están en
      [A1](A1-catalogo-rnf.md) con su enunciado textual.
- [x] ~~Formalizar los hallazgos en A4~~ — hecho: nueve abiertos y uno retirado.

**Andrés:**

- [ ] Medir el bundle actual (`npx ng build`) para poder proponer un umbral concreto de RNF-08.
- [ ] Cronometrar con el panel de red una autenticación y un CRUD de catálogo, para llevar al
      menos una cifra real de RNF-03 y RNF-04 a la reunión.
- [ ] Buscar el **Apéndice 4.2** del SRS (matriz de compatibilidad) — falta para cerrar RNF-19.

**José:**

- [ ] Verificar en GitHub si `SIGRA_ENABLE_DEPENDENCY_REVIEW` y `SIGRA_ENABLE_OWASP_SCA` siguen
      deshabilitadas (confirma H-01).
- [ ] Reproducir H-08: `sed -n '99,125p' SIGRA/build.gradle` y confirmar que los paquetes de
      `estadisticas` no están en la lista `includes`. **Es el hallazgo más fuerte que llevamos.**
- [ ] Confirmar que la auditoría registra autenticaciones **fallidas**, no solo exitosas (el SRS
      lo exige explícitamente en RNF-16).
- [ ] Buscar el **Apéndice 4.1** (Matriz RBAC) y compararlo con `docs/security/RBAC_MATRIX.md`.

**Ambos:**

- [ ] Leer la sección 3.2 de esta guía. H-06 se retiró por falso y conviene que los dos sepamos
      por qué antes de presentar: si alguien pregunta, la respuesta es que verificamos contra el
      SRS y corregimos, no que se nos pasó.
- [ ] Acordar quién habla primero y qué dice cada uno.

---

### 6.2 Reunión 1 · Domingo 8 de noviembre, 8:00 pm — Entrega 1

**Qué hay que tener listo antes:**

| Entregable | Estado mínimo aceptable |
| --- | --- |
| A1 · Catálogo de RNF | Los **21 RNF del SRS** con enunciado, atributo, titular e instrumento |
| A2 · Matriz de impacto | Estructura creada; filas por llenar cuando se conozcan los mantenimientos |
| A3 · Criterios de verificación | Un criterio por RNF, con comando y umbral donde exista |
| A4 · Hallazgos | Nueve hallazgos abiertos y uno retirado, con evidencia |
| Propuestas | Las cinco de la sección 4.3, ordenadas por costo |

**Guion de intervención (apuntar a 3 minutos):**

> **¿Qué realicé?**
> Partimos del SRS y levantamos el catálogo completo: SIGRA tiene **21 requisitos no
> funcionales**. Sobre eso revisamos los dos repositorios para ver con qué se puede verificar cada
> uno. La red de pruebas es amplia —102 clases en el backend, 74 specs en el frontend, 490
> peticiones Bruno, documentación OpenAPI verificada por pruebas, y una guardia arquitectónica que
> impide que una ruta privada quede sin autorización— así que **siete RNF se verifican hoy sin
> trabajo adicional**. Pero **nueve no tienen ningún instrumento**: todo el grupo de rendimiento.
> Dejamos el catálogo con titular por atributo, los criterios de verificación con su comando, y el
> registro de hallazgos: nueve abiertos, tres de severidad alta.
>
> **¿Qué realizaré?**
> En cuanto el Product Owner priorice los mantenimientos, llenamos la matriz de impacto: por cada
> requerimiento, qué atributos de calidad toca, qué RNF compromete y con qué criterio se va a
> verificar. Eso es lo que necesita el filtro F2 para cerrar, así que lo tenemos antes de que
> empiece el desarrollo.
>
> **¿Qué impedimentos tengo?**
> Tres, y los dos primeros necesitan decisión del equipo:
> 1. **Nueve requisitos de rendimiento sin forma de medirse.** El SRS fija umbrales concretos
>    —autenticación en menos de 4 s, CRUD en menos de 3, estadísticas en menos de 5, 20 usuarios
>    concurrentes— y no hay prueba de carga ni medición de tiempos. Traemos una propuesta de
>    alcance mínimo, pero hay que decidir qué se verifica y qué se declara fuera de alcance, y eso
>    se decide ahora, no el día 15.
> 2. **El análisis de dependencias del backend está apagado.** Son dos variables de repositorio.
>    Mientras siga así, la seguridad de las dependencias del backend no está auditada: está
>    omitida, y el frontend sí la audita en cada corrida.
> 3. **Nos faltan los Apéndices 4.1 y 4.2 del SRS.** El 4.2 define qué navegadores y dispositivos
>    exige RNF-19; sin él estamos suponiendo el alcance. El 4.1 es la Matriz RBAC, y la necesitamos
>    para contrastarla con lo implementado.

**Si queda tiempo, el hallazgo que conviene mostrar con detalle** es H-08: RNF-20 exige cobertura
mínima del 70 % en cuatro módulos obligatorios, y la configuración de JaCoCo solo vigila dos. El
cálculo de nivel de logro y la generación de conclusiones —la lógica más delicada del producto—
pueden bajar de cobertura sin que el build falle. Es el único hallazgo del lote que es un
**incumplimiento documentable del SRS**, y se corrige con dos líneas.

**Qué hay que pedir explícitamente en esta reunión:**

- [ ] Confirmación de las fechas de Entrega 2 y Entrega 3.
- [ ] Que el PO comparta la lista priorizada de mantenimientos **antes del día 8** (si no, no
      podemos cumplir F2 a tiempo y hay que decirlo ahora, no después).
- [ ] Decisión sobre las cinco propuestas de la sección 4.3, con responsable y fecha.
- [ ] Acordar que **ningún requerimiento pasa F2 sin su fila en la matriz de impacto**. Esta es la
      pieza que convierte nuestro rol en filtro y no en documento.
- [ ] Quién habilita las variables de SCA y para cuándo.

---

### 6.3 Reunión 2 · Miércoles 11 de noviembre, 6:00 pm — Implementación en curso

Estamos a dos días de la Entrega 2, que pide «verificación inicial de RNF». Esta reunión es la
última oportunidad de corregir el rumbo antes de esa entrega.

**Qué hay que tener listo antes:**

| Entregable | Estado |
| --- | --- |
| A2 · Matriz de impacto | **Completa**, una fila por mantenimiento priorizado |
| A3 · Criterios de verificación | Cerrados para todo mantenimiento que ya esté en desarrollo |
| Participación en F2 | Registro de qué diseños revisamos y con qué veredicto |
| A4 · Hallazgos | Actualizado, con estado de los siete iniciales |
| Verificación inicial | Al menos un criterio ya ejecutado con evidencia, por titular |

**Guion de intervención:**

> **¿Qué realicé?**
> Cerré la matriz de impacto de los mantenimientos priorizados: por cada uno está dicho qué
> atributos toca, qué RNF compromete y con qué criterio se verifica. Participé en el filtro F2 de
> [N] diseños junto al revisor técnico y dejé los criterios definidos en cada uno. De los siete
> hallazgos iniciales, [N] están corregidos y [N] siguen abiertos.
>
> **¿Qué realizaré?**
> Ejecutar la verificación inicial de RNF que pide la Entrega 2 y entregar los criterios de RNF a
> los analistas de pruebas para que los incorporen a sus casos — eso es F4 y lo necesitan antes de
> empezar a ejecutar, no después.
>
> **¿Qué impedimentos tengo?**
> [Nombrar solo lo que bloquea de verdad, con la decisión que se necesita y de quién.]

**Alertas que debemos levantar si aplican:**

- Un mantenimiento que entró a desarrollo **sin pasar por nuestra revisión de impacto**: eso es un
  F2 incumplido y hay que decirlo con el ID del requerimiento, no en general.
- Un PR que toca un módulo con RNF comprometido y no trae evidencia del criterio.
- Las propuestas de la sección 4.3 que se aprobaron y nadie ejecutó.

---

### 6.4 Reunión 3 · Domingo 15 de noviembre, 8:00 pm — Validación

Ya pasó la Entrega 2. Estamos en la fase donde el manual pide «pruebas funcionales, de regresión y
verificación de RNF». Aquí nuestro trabajo pasa de definir a **verificar**, que es la segunda
actividad donde somos A/R.

**Qué hay que tener listo antes:**

| Entregable | Estado |
| --- | --- |
| Verificación de RNF | Ejecutada para **todos** los RNF comprometidos, con veredicto por cada uno |
| A4 · Hallazgos | Cada hallazgo con estado y, si está corregido, con la evidencia de la nueva verificación |
| A5 · Informe de calidad | Borrador avanzado |
| Semáforo de RNF | Tabla de una página: cada RNF en verde, amarillo o rojo |

**El semáforo** es la herramienta más útil para esta reunión. Una tabla que cualquiera entiende
en diez segundos:

| RNF | Atributo | Criterio | Veredicto | Evidencia |
| --- | --- | --- | --- | --- |
| RNF-13 | Seguridad | 403 para rol sin permiso en los endpoints nuevos | 🟢 Verificado | `RbacTest` en verde, PR #42 |
| RNF-08 | Rendimiento | Bundle inicial ≤ 500 KB | 🟡 Parcial | Medido a mano; sin presupuesto en CI |
| RNF-21 | Accesibilidad | Sin violaciones serious/critical en axe | 🔴 No verificado | Sin herramienta disponible |

**Guion de intervención:**

> **¿Qué realicé?**
> Verifiqué los RNF comprometidos por los mantenimientos. El resultado es: [N] en verde,
> [N] en amarillo y [N] en rojo. Los rojos son [listar], y los traigo porque el criterio de
> finalización del manual pide que los RNF estén verificados: si quedan en rojo, el proyecto no
> cumple ese criterio aunque las funcionalidades pasen.
>
> **¿Qué realizaré?**
> Cerrar el informe de calidad y verificar las correcciones de los hallazgos que siguen abiertos.
> Para los amarillos y rojos que no alcancen, dejar la decisión de tratamiento escrita, que es lo
> que el manual exige para severidad media y baja.
>
> **¿Qué impedimentos tengo?**
> [Lo que falte para pasar un rojo a verde, con nombre y fecha de quién puede resolverlo.]

**Decisión que hay que forzar aquí:** para cada RNF en rojo o amarillo, el equipo decide una de
tres cosas y queda **escrito**: se corrige antes del cierre, se acepta como deuda técnica con
justificación, o se declara fuera del alcance de este mantenimiento. Un rojo sin decisión es un
criterio de finalización incumplido y nos lo van a cobrar a nosotros.

---

### 6.5 Reunión 4 · Martes 17 de noviembre, 11:00 pm — Última antes del cierre

Esta es la víspera. Aquí no se abre trabajo nuevo: se confirma que lo que firmamos es cierto.

**Qué hay que tener listo antes:**

| Entregable | Estado |
| --- | --- |
| A5 · Informe de calidad | **Terminado**, no borrador |
| Semáforo de RNF | Final, sin casillas vacías |
| Decisiones de tratamiento | Escritas para todo amarillo y rojo |
| Indicadores | Los nuestros, calculados (sección 8.4) |
| Checklist de cierre | Sección 11 de esta guía, marcado |

**Guion de intervención:**

> **¿Qué realicé?**
> El informe de calidad está terminado. Los requisitos no funcionales quedaron verificados así:
> [N] cumplen, [N] con deuda técnica documentada y decisión de tratamiento, [N] fuera de alcance
> declarado. Todos los hallazgos de severidad alta y crítica están cerrados con evidencia de la
> nueva verificación. [O: queda abierto X, y por eso no podemos declarar cumplido el criterio.]
>
> **¿Qué realizaré?**
> Presentar el informe de calidad en la revisión final y aportar a la retrospectiva lo que
> aprendimos del rol: el control de calidad tiene que estar dentro del flujo de trabajo, no en un
> documento que se llena al final.
>
> **¿Qué impedimentos tengo?**
> [Idealmente ninguno. Si hay uno a esta altura, es un riesgo de incumplimiento del §13 y hay que
> decirlo con esas palabras.]

**Para la retrospectiva**, llevar dos o tres conclusiones concretas y accionables. Las que ya
tenemos sustentadas del análisis del manual:

1. Un registro sin criterio de salida y sin revisión independiente no es un control, es un
   archivo. Los criterios de RNF funcionan solo cuando son condición de salida de un filtro.
2. Participar desde el diagnóstico sí cambió el resultado: los atributos de calidad no se pueden
   agregar al final.
3. Lo que no es medible no se verifica. Los RNF sin herramienta de medición llegaron al día 15
   sin veredicto, y eso se sabía desde el día 5.

---

## 7. Cómo participamos en los filtros F2 y F4

### 7.1 F2 · Diseño — con el revisor técnico

Somos co-responsables del criterio de salida: *diseño coherente, impacto identificado y
**criterios definidos***.

**Checklist para no aprobar F2 a la ligera:**

- [ ] ¿Está identificado el impacto sobre **funcionalidades que ya existían**? (No solo lo nuevo.)
- [ ] ¿Qué atributos de calidad toca este cambio? ¿Está en la matriz A2?
- [ ] ¿Qué RNF quedan comprometidos?
- [ ] ¿Hay un criterio de verificación **medible** por cada RNF comprometido?
- [ ] ¿El criterio dice con qué comando o prueba se comprueba y qué evidencia queda?
- [ ] ¿El cambio introduce dependencias nuevas? (Seguridad y rendimiento.)
- [ ] ¿Toca `auth`, `security` o `auditoria`? → revisión obligatoria de José.
- [ ] ¿Agrega rutas, formularios o vistas? → revisión obligatoria de Andrés (RNF-08, 19, 21).
- [ ] ¿Toca mensajes de error? → RNF-17 en los dos lados.
- [ ] ¿Qué funcionalidades existentes hay que **volver a probar** por culpa de este cambio?

> La última casilla es la más importante y la que más se omite. «Impacto identificado» se cumple
> escribiendo un párrafo genérico; lo que sirve es la **lista de funcionalidades existentes que
> hay que reprobar**. Sin ese enlace, la regresión aparece en F4, que es el escenario más caro.

### 7.2 F4 · Pruebas — con los analistas de pruebas

**Nuestra entrada al filtro es anticipada:** los criterios de verificación de RNF tienen que
estar en manos de los analistas de pruebas **cuando diseñan los casos**, no cuando ya ejecutaron.
Si llegamos después, nuestros criterios se vuelven trabajo extra para ellos y no se ejecutan.

- [ ] Los criterios de A3 se entregaron a los analistas de pruebas y están en sus casos.
- [ ] Cada RNF comprometido tiene al menos un caso que lo cubre.
- [ ] La verificación de RNF está ejecutada, con evidencia, no declarada.
- [ ] Los hallazgos de RNF están en el registro de errores (§9.3) con ID, no solo en nuestro A4.
- [ ] Ningún hallazgo crítico o alto de RNF queda abierto.

### 7.3 Cuándo decimos «no»

Nuestra autoridad para frenar algo viene de dos reglas del manual, y conviene citarlas tal cual:

- **§7:** «Los defectos críticos y altos bloquean la entrega.»
- **§13:** «Los requisitos no funcionales fueron verificados.»

Si un RNF comprometido no tiene criterio, o tiene criterio y no se verificó, el criterio de
finalización no se cumple. Eso se dice **en reunión y por escrito**, con el ID del requerimiento y
el RNF, nunca como una queja general sobre la calidad.

---

## 8. Registros obligatorios que nos exigen

El manual exige tres registros (§9) y los indicadores del §10. Dos cosas nos cuestan la nota si
las descuidamos: el registro diario de actividades y el registro de uso de IA con verificación.

### 8.1 Registro de actividades (§9.1) — diario

Campos: fecha · integrante · ID de actividad · actividad · tipo · tiempo · resultado · evidencia ·
estado.

> «Las actividades se registran **diariamente**» (§12). No el día antes de la entrega. El 20 % de
> la nota es cumplimiento de responsabilidades individuales y se sustenta «en evidencias
> verificables, no únicamente en la percepción de los compañeros» (§11). Nuestro registro **es**
> esa evidencia.

### 8.2 Registro de uso de IA (§9.2) — con verificación, no solo con declaración

El manual pide: integrante y fecha · herramienta · propósito · prompt · resultado · aplicación ·
**verificación** · errores · decisión. Y se diligencia **también cuando la respuesta se descarta**.

Qué cuenta como verificación en nuestro caso particular:

| Si usamos IA para... | La evidencia mínima es... |
| --- | --- |
| Redactar un criterio de verificación | Haberlo **ejecutado** y pegado la salida real |
| Analizar el impacto de un cambio | Haber abierto los archivos citados y confirmado que existen |
| Redactar un hallazgo | Archivo:línea verificado a mano, y comando reproducido |
| Documentación o informe | Que el otro de los dos lo contraste contra el código y lo firme |

> «Lo revisé» **no es** evidencia de verificación. Es justo el vacío que señalamos en el análisis
> del manual; sería incoherente que nosotros cayéramos en él.

### 8.3 Registro de errores (§9.3)

Nuestros hallazgos de RNF van **también** al registro de errores del equipo, con su ID. Si solo
viven en nuestro `A4-hallazgos-rnf.md`, para el equipo no existen y no se van a corregir.

### 8.4 Indicadores que nos tocan (§10)

De los siete indicadores del manual, estos dependen de nosotros y conviene llevarlos calculados
a las reuniones 3 y 4:

| Indicador | Cómo lo calculamos |
| --- | --- |
| % de cambios con trazabilidad | Mantenimientos con fila en A2 ÷ total de mantenimientos |
| % de pruebas ejecutadas (parte RNF) | RNF con veredicto ÷ RNF comprometidos |
| Defectos identificados y corregidos (parte RNF) | Hallazgos de A4 por estado |
| % de usos de IA con evidencia de verificación | Nuestras entradas con verificación real ÷ total |

> «Los indicadores deben reflejar resultados reales. No se deben fijar metas arbitrarias ni
> alterar datos para aparentar cumplimiento» (§10). Un 60 % honesto vale más que un 100 % que no
> resiste una pregunta.

---

## 9. Bitácora de hallazgos

Resumen vivo. El detalle de cada uno va en `A4-hallazgos-rnf.md` con la plantilla de la
sección 5.3.

| ID | Severidad | Atributo | Hallazgo | Titular | Estado |
| --- | --- | --- | --- | --- | --- |
| H-01 | **Alta** | Seguridad | SCA de dependencias del backend apagado (`SIGRA_ENABLE_*` sin habilitar) | José | Abierto |
| H-02 | **Alta** | Rendimiento | Nueve requisitos de rendimiento (RNF-01 a 09) sin un solo instrumento de medición | Andrés | Abierto |
| H-08 | **Alta** | Mantenibilidad | RNF-20 vigila la cobertura de 2 de los 4 módulos obligatorios: RF-14 y RF-16 quedan fuera del umbral | Ambos | Abierto |
| H-03 | Media | Mantenibilidad | El E2E de navegador cubre un solo flujo (`auth.spec.ts`) | Ambos | Abierto |
| H-04 | Media | Accesibilidad | RNF-21 sin verificación automatizada; axe no está instalado ni usado | Andrés | Abierto |
| H-05 | Media | Mantenibilidad | Sin análisis estático en ninguno de los dos repositorios | Ambos | Abierto |
| H-09 | Media | Disponibilidad | RNF-18 sin medición de uptime ni de MTTR | José | Abierto |
| H-10 | Media | Seguridad | RNF-11 (TLS 1.2+) no verificable sin entorno de producción | José | Abierto |
| H-07 | Baja | Mantenibilidad | README del backend dice que JaCoCo está pendiente; `build.gradle` ya lo declara | Ambos | Abierto |
| ~~H-06~~ | — | — | ~~Ningún RNF cubre disponibilidad~~ · **retirado por falso: RNF-18 existe** | — | Retirado |

> **Por qué H-06 queda en la tabla.** Retirar un hallazgo en silencio es peor que haberlo abierto.
> Se levantó leyendo las menciones de RNF en el código, donde RNF-18 no aparece citado, y se
> concluyó de más. Queda como constancia de que verificamos contra el SRS y corregimos. El detalle
> está en [A4](A4-hallazgos-rnf.md#h-06--retirado-por-falso).

---

## 10. Riesgos propios del rol

| Riesgo | Por qué nos pasaría | Cómo lo evitamos |
| --- | --- | --- |
| **Llegar tarde al diagnóstico** | El manual nos exige participar desde el inicio; si el equipo arranca a desarrollar sin la matriz A2, nuestro filtro F2 queda de adorno | Exigir en la reunión del 8 que ningún requerimiento pase F2 sin su fila en A2 |
| **Criterios no medibles** | Es cómodo escribir «se revisó la seguridad»; nadie lo puede ejecutar y el día 15 no hay veredicto | Toda fila de A3 pasa la prueba de la sección 5.2 |
| **Firmar «verificado» sin evidencia** | Presión de tiempo el día 15 | Sin salida de comando o archivo:línea, el veredicto es amarillo, no verde |
| **Convertirnos en el cuello de botella** | Dos personas revisando el impacto de nueve desarrolladores | Titular + suplente por atributo, y criterios reutilizables escritos una vez |
| **Que nos lean como «los que frenan»** | Es el conflicto clásico entre desarrollo y calidad | Todo rechazo cita criterio incumplido + evidencia + corrección requerida (§7). Nunca opinión |
| **RNF sin herramienta de medición** | Rendimiento y disponibilidad hoy no se pueden medir | Nombrarlo el **día 5**, no el 15. Un riesgo avisado temprano es trabajo; avisado tarde es excusa |
| **Duplicar trabajo entre nosotros dos** | El manual contempla un solo especialista | Reparto por atributo de la sección 2, no por repositorio |
| **Registro de IA sin verificación** | Vale 5 % y no bloquea nada, así que es racional dejarlo | Llenarlo el mismo día; la tabla de la sección 8.2 define qué cuenta |

---

## 11. Checklist de cierre

Esto es lo que tiene que estar cierto el 18 de noviembre para que nuestro rol quede cumplido.

**Del manual (§13) — la línea que firmamos nosotros:**

- [ ] **Los requisitos no funcionales fueron verificados.**

**Lo que lo sustenta:**

- [ ] A1 · Catálogo de RNF completo, con los RNF confirmados contra el SRS
- [ ] A2 · Matriz de impacto con una fila por cada mantenimiento ejecutado
- [ ] A3 · Un criterio medible por cada RNF comprometido
- [ ] A4 · Todos los hallazgos con estado final; ninguno crítico o alto abierto
- [ ] A5 · Informe de calidad terminado y presentado
- [ ] Semáforo de RNF sin casillas vacías
- [ ] Decisión de tratamiento escrita para cada amarillo y rojo
- [ ] Los cinco atributos del §3.5 revisados: seguridad, rendimiento, disponibilidad,
      compatibilidad y mantenibilidad
- [ ] Participación registrada en F2 y F4, con veredictos
- [ ] Registro de actividades al día, sin huecos
- [ ] Registro de uso de IA con verificación real en el 100 % de las entradas
- [ ] Hallazgos de RNF también en el registro de errores del equipo, con ID
- [ ] Indicadores de la sección 8.4 calculados con datos reales
- [ ] Aporte a la retrospectiva preparado

**Prueba final, para los dos:** si en la revisión final alguien señala cualquier RNF al azar y
pregunta «¿cómo saben que esto se cumple?», debemos poder responder con un comando, una prueba o
un archivo. Si la respuesta es «lo revisamos», no está verificado.

---

## Anexo · Referencias rápidas

| Qué | Dónde |
| --- | --- |
| Manual operativo | `BITACORAS DE CLASE/Clase#11/Proyecto Mantenimiento.pdf` |
| Análisis del manual (Andrés) | `BITACORAS DE CLASE/Clase#11/Taller_Analisis_Manual_Operativo_Mantenimiento.docx` |
| Arquitectura y RNF del backend | `software4-SIGRA-backend/README.md` §5 |
| Arquitectura y RNF del frontend | `software4-SIGRA-frontend/README.md` §5 |
| Matriz RBAC implementada | `software4-SIGRA-frontend/docs/security/RBAC_MATRIX.md` |
| Documentos de seguridad del frontend | `software4-SIGRA-frontend/docs/security/` |
| CI del frontend | `software4-SIGRA-frontend/.github/workflows/ci.yml` |
| CI del backend | `software4-SIGRA-backend/.github/workflows/ci.yml` |
| Cobertura y SCA del backend | `software4-SIGRA-backend/SIGRA/build.gradle` |
| Formato de hallazgos ya usado | `software4-SIGRA-frontend/scripts_andres/hallazgos-manejo-errores.md` |
| Matriz RBAC oficial | Apéndice 4.1 del SRS |
