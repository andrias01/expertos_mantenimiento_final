# Filas para el libro compartido del equipo

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Para qué** | Pegar en `SIGRA Fase 2 - Guía y registros del equipo.xlsx`, en las tres hojas obligatorias |
| **Fecha** | 15 de noviembre de 2026 |
| **Por qué existe este archivo** | Al 15 de noviembre el libro tenía **97 actividades registradas y ninguna nuestra**. Es un incumplimiento del §12 («las actividades se registran diariamente») y del §9. Esto lo corrige |

> **Correlativos · corregidos el 16 de noviembre de 2026.** En la primera versión de este archivo
> nuestras filas arrancaban en ACT-098, pero al refrescar el libro del equipo apareció que
> **Tomás Marín ya había usado ACT-098 a ACT-102** (paginación extendida y el módulo R7). Los
> correlativos quedaron corridos:
>
> | Registro | Último del libro | Nuestras filas arrancan en |
> | --- | --- | --- |
> | Actividades | **ACT-102** (Tomás Marín, 15-nov) | **ACT-103** |
> | Errores | **ERR-011** | **ERR-012** |
> | Uso de IA | fila **51** | fila **52** |
>
> **Vuelve a confirmarlo antes de pegar.** El libro se mueve varias veces al día: entre el 15 y el
> 16 de noviembre entraron cinco actividades nuevas. Si alguien agregó más, corre los números.

---

## 1. Hoja «Registro de actividades»

Columnas: `Fecha` · `Integrante` · `ID actividad` · `Actividad` · `Tipo` · `Tiempo (h)` ·
`Resultado` · `Evidencia` · `Estado`

| Fecha | Integrante | ID | Actividad | Tipo | h | Resultado | Evidencia | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 15/11/2026 | Andrés Felipe Vélez | ACT-103 | Revisión del estado real del proyecto para la verificación inicial de RNF: documento de Entrega 1, libro del equipo, exportación de Mantis y los dos repositorios en `develop` | Revisión | 1.5 | Se identificó que el producto ya está desplegado (Render + Vercel), lo que vuelve verificables RNF-11 y la mitad de uptime de RNF-18 | A6-semaforo-rnf.md; commits `d6fa7e1` (backend) y `a3135ec` (frontend) | Cerrada |
| 15/11/2026 | José Alejandro Valencia | ACT-104 | Medición de la cobertura real de los cuatro módulos obligatorios del RNF-20 (a) con JaCoCo | Prueba | 0.5 | Global 92,39 %; `estadisticas.service` 96,48 % y `estadisticas.service.impl` 93,69 %, los dos módulos que no estaban vigilados | Salida de `./gradlew test jacocoTestReport`; A4 hallazgo H-08 | Cerrada |
| 15/11/2026 | José Alejandro Valencia | ACT-105 | Corrección del hallazgo H-08: agregar `co.edu.uco.sigra.estadisticas.service*` a la verificación de cobertura de `build.gradle` | Desarrollo | 0.5 | La verificación ya cubre los cuatro módulos que el SRS nombra (RF-04, RF-05, RF-14, RF-16). `jacocoTestCoverageVerification` pasa | Diff de 4 líneas en `SIGRA/build.gradle`; pendiente de PR | Cerrada |
| 15/11/2026 | José Alejandro Valencia | ACT-106 | Prueba de que la regla de cobertura **falla** si la cobertura baja (criterio de cierre de H-08) | Prueba | 0.3 | Con umbral temporal de 0,99 JaCoCo nombra `estadisticas.service` y `estadisticas.service.impl`; antes del cambio eran invisibles | Salida de `jacocoTestCoverageVerification` con las dos violaciones | Cerrada |
| 15/11/2026 | José Alejandro Valencia | ACT-107 | Verificación de RNF-11 (HTTPS con TLS 1.2+) contra el despliegue de producción en Render | Prueba | 0.5 | Cumple completo: HTTPS sobre HTTP/2, TLS 1.2 y 1.3 aceptados, TLS 1.0 rechazado, HTTP responde 301 a HTTPS. **Cierra el hallazgo H-10** | Salidas de `curl` en A6 §3.1 | Cerrada |
| 15/11/2026 | Andrés Felipe Vélez | ACT-108 | Instalación de Apache JMeter 5.6.3 y creación de los dos planes de prueba de RNF | Desarrollo | 1.5 | `RNF-18-disponibilidad.jmx` y `RNF-01-06-rendimiento.jmx` versionados, con los umbrales del SRS como Duration Assertion y la contraseña fuera del archivo | `mantenimiento-rnf/jmeter/` y su README | Cerrada |
| 15/11/2026 | Andrés Felipe Vélez | ACT-109 | Medición de disponibilidad (RNF-18) contra el backend en Render con JMeter | Prueba | 0.5 | 90 muestras, 90 exitosas (100 %), solo códigos 200 con cuerpo `UP`; p95 de 526 ms. Ventana de 208 s, que es la reserva que hay que declarar | `jmeter/resultados/rnf18-render.jtl` e informe HTML | Cerrada |
| 15/11/2026 | Andrés Felipe Vélez | ACT-110 | Medición del bundle del frontend para fijar el umbral de RNF-08 | Prueba | 0.5 | 356,04 kB sin comprimir y 100,14 kB transferidos, contra un presupuesto de aviso de 500 kB: cumple con 29 % de margen. Propuesta: bajar el aviso a 420 kB | Corrida de CI 43684672703 del frontend; `angular.json:51-62` | Cerrada |
| 15/11/2026 | Andrés Felipe Vélez | ACT-111 | Confirmación del hallazgo H-01 por la API de GitHub y de por qué no lo podemos corregir nosotros | Revisión | 0.3 | `actions/variables` devuelve `total_count: 0`: los dos trabajos de SCA se saltan en cada corrida. Nuestro permiso es `push`, no `admin`: hace falta un administrador | Salidas de `gh api` en A4 hallazgo H-01 | Cerrada |
| 15/11/2026 | José Alejandro Valencia | ACT-112 | Verificación de que la auditoría registra autenticaciones **fallidas**, no solo exitosas (RNF-16, compromiso C-06) | Prueba | 0.3 | Cubierto por `AuditoriaIntegracionIT` y `AuditoriaAspectTest`. RNF-16 queda en verde | A6 §2.2 | Cerrada |
| 15/11/2026 | José Alejandro Valencia | ACT-113 | Revisión de la incidencia 0000029 (bloqueo tras 5 intentos fallidos, RF-04) | Revisión | 0.3 | Está implementada y probada: `Usuario.intentosFallidos`, `fechaBloqueo`, `estaBloqueado`, respuesta 423 documentada en OpenAPI. Falta cerrar la resolución en Mantis | `auth/entity/Usuario.java`; `AuthControllerTest`, `UsuarioTest` | Cerrada |
| 15/11/2026 | Andrés Felipe Vélez | ACT-114 | Análisis de la exportación de Mantis del 15-nov y cruce contra la hoja de reparto del libro | Revisión | 1.0 | Tres hallazgos nuevos: 0000053 sin dueño (alta/mayor), las dos incidencias de categoría «No Funcionalidad» resueltas sin nuestra validación, y ninguna de las 31 en estado `cerrada` | `estado de mantis.csv`; A4 hallazgos H-11, H-12 y H-13 | Cerrada |
| 15/11/2026 | Ambos | ACT-115 | Elaboración del semáforo de RNF y actualización del registro de hallazgos para la verificación inicial de la Entrega 2 | Documentación | 2.0 | Sobre 23 criterios (RNF-18 y RNF-20 cuentan doble): 9 en verde, 9 en amarillo con la reserva declarada y 5 en rojo. Dos hallazgos cerrados, cuatro en corrección, cuatro nuevos, uno sube de severidad | `A6-semaforo-rnf.md`, `A4-hallazgos-rnf.md` | Cerrada |
| 15/11/2026 | Ambos | ACT-116 | Preparación del acta de la reunión 3 y del seguimiento de los compromisos de la reunión 1 | Documentación | 0.5 | Tres de siete compromisos cumplidos, uno bloqueado por otro y tres no cumplidos, con la causa escrita | `evidencias-reuniones/reunion-3-2026-11-15/acta.md` | Cerrada |

| 16/11/2026 | Andrés Felipe Vélez | ACT-117 | Verificación de que el fix de H-08 quedó integrado en `develop` | Prueba | 0.3 | Confirmado: la regla por paquete de `estadisticas` está en `origin/develop` (`bb72c07`) vía PR #117. **RNF-20 (a) cumple en la rama integrada**, no solo en la copia de trabajo | `git show origin/develop:SIGRA/build.gradle`; `git diff` vacío | Cerrada |
| 16/11/2026 | Andrés Felipe Vélez | ACT-118 | Incorporación de las dos observaciones de la auditoría de José al registro, y **clasificación corregida** | Documentación | 0.8 | Primero se registraron como hallazgos de RNF («H-15» alta y «H-16» baja) y **se corrigió el mismo día**: ningún RNF del SRS prohíbe un error genérico ni exige cabeceras HTTP. Quedan como **OBS-01** (media provisional, la severidad de José) y **OBS-02** (baja), fuera del registro de incumplimientos del SRS | A4, sección «Observaciones sin anclaje en el SRS» | Cerrada |
| 16/11/2026 | Andrés Felipe Vélez | ACT-122 | Comprobación de que el análisis de dependencias del backend **sí** se puede correr sin permiso de administrador | Revisión | 0.3 | El plugin `org.owasp.dependencycheck` está aplicado en `build.gradle:5` con `failBuildOnCVSS = 4.0`. `./gradlew dependencyCheckAnalyze` corre en local: **lo bloqueado era la compuerta de CI, no la auditoría** | A4 hallazgo H-01, seguimiento del 16-nov | Cerrada |
| 16/11/2026 | Andrés Felipe Vélez | ACT-119 | Refresco de las tres fuentes del equipo (Mantis, Word de la Entrega 1, libro de Fase 2) y cruce contra los artefactos de RNF | Revisión | 0.5 | Mantis **sin un solo cambio** desde el 15-nov (0000053 sigue sin dueño, 0 de 31 cerradas). El Word no cambió de contenido. El libro sí: cinco actividades nuevas, ACT-096 cerrada y el compromiso de paginación en curso | `estado de mantis.csv`; libro de Fase 2 | Cerrada |
| 16/11/2026 | Andrés Felipe Vélez | ACT-120 | Corrección de los correlativos de nuestras filas en el libro del equipo | Otro | 0.2 | Tomás Marín había ocupado ACT-098 a ACT-102; nuestras filas se corrieron a ACT-103 en adelante para no colisionar | `registros-equipo-rnf.md` | Cerrada |

| 16/11/2026 | Andrés Felipe Vélez | ACT-121 | Verificación de RNF-11 contra el frontend en Vercel, con la URL que aportó la auditoría de José | Prueba | 0.2 | `https://sigra.vercel.app`: TLS 1.2 y 1.3 aceptados, **TLS 1.0 rechazado** (exit 35), HTTP → 308 a HTTPS. **RNF-11 cumple de punta a punta** y cierra el pedido P-08 | Salidas de `curl` en A6 §3.1.1 | Cerrada |

| 16/11/2026 | Andrés Felipe Vélez | ACT-123 | Montaje del entorno de verificación: PostgreSQL aislado, SonarQube y Uptime Kuma en Docker, con script reproducible | Desarrollo | 2.0 | `herramientas-rnf/` con `docker-compose.yml`, `levantar.ps1` y README. Probado de punta a punta: 19 tablas, 4 usuarios sembrados, SonarQube 26.11 `UP`, Uptime Kuma HTTP 200. **Desbloquea JMeter sin tocar Supabase** | `mantenimiento-rnf/herramientas-rnf/` | Cerrada |
| 16/11/2026 | Andrés Felipe Vélez | ACT-124 | Hallazgo de un seed desactualizado al cargar la base limpia | Prueba | 0.3 | `seed-asignaturas-roles.sql` falla contra el esquema actual: omite `fecha_matricula`, obligatoria desde la migración RF-08. Registrado como **ERR-021**; corrección de una línea | Salida de `levantar.ps1` | Cerrada |

| 16/11/2026 | Andrés Felipe Vélez | ACT-125 | Levantar un segundo backend contra la base aislada y comprobar que no habla con Supabase | Prueba | 1.0 | Contenedor `sigra-backend-rnf` en el puerto 8081 contra `sigra-pg-rnf`. **Prueba decisiva:** un login fallido subió `intentos_fallidos` de 0 a 1 **en la base local**, y un login correcto lo devolvió a 0. El entorno de medición de rendimiento queda listo | `herramientas-rnf/README.md` §2.1 y §2.4 | Cerrada |
| 16/11/2026 | Andrés Felipe Vélez | ACT-126 | Hallazgo: el esquema documentado no permite arrancar el backend | Prueba | 0.5 | Falta `historial_auditoria` en `SIGRA_SCHEMA_CURRENT.sql`; la crea la migración RF19, nunca integrada. Registrado como **ERR-022**. Explica por qué todo el equipo apunta a Supabase: la alternativa estaba rota | Traza de arranque; `README.md` §2.3 | Cerrada |
| 16/11/2026 | Andrés Felipe Vélez | ACT-127 | Verificación **en ejecución** de RNF-16, RNF-15 y RNF-10 sobre el entorno aislado | Prueba | 0.5 | Primera evidencia de ejecución y no solo de pruebas unitarias: `historial_auditoria` registró `LOGIN_FALLIDO` y `LOGIN_EXITOSO` con fecha, rol, acción y detalle (RNF-16); la respuesta del login trae `expiraEn: 3600` = 60 min exactos (RNF-15) y ningún campo de contraseña ni hash (RNF-10) | Consultas a `sigra.historial_auditoria`; `README.md` §2.4 | Cerrada |

| 16/11/2026 | Andrés Felipe Vélez | ACT-128 | Primera medición de carga con 20 usuarios concurrentes y corrida de control | Prueba | 1.5 | **RNF-03 NO CUMPLE**: p95 de 5 493 ms contra 4 000, con 46 de 100 logins por encima. Escalonados cumplen (p95 546 ms). RNF-04 y RNF-06 cumplen con margen. Causa: BCrypt factor 12 que exige RNF-10. Hallazgo **H-17** | `jmeter/resultados/rnf01-06-local.jtl` y `rnf01-control.jtl` | Cerrada |
| 16/11/2026 | Andrés Felipe Vélez | ACT-129 | Configuración de SonarQube y primer escaneo del backend | Desarrollo | 1.5 | Usuario propio, proyecto y **puerta de calidad con el umbral textual de RNF-20 (a)**. Resultado: puerta **OK**, mantenibilidad **A**, deuda **15 min**, 0 bugs, 3 code smells, duplicación 0,5 %. **Cierra H-05** | `herramientas-rnf/README.md` §4 · `localhost:9000/dashboard?id=sigra-backend` | Cerrada |
| 16/11/2026 | Andrés Felipe Vélez | ACT-130 | Análisis de dependencias del backend con Trivy, por la vía que no exige permisos de admin | Prueba | 0.8 | **4 CRITICAL y 10 HIGH** en librerías Java (`tomcat-embed-core` 11.0.24 y la familia `jackson` 2.21.5/3.1.5), todas con arreglo publicado. Los 56 MEDIUM restantes son del sistema operativo base y no son de nuestro alcance | `herramientas-rnf/evidencias/trivy-backend-16nov.json` | Cerrada |
| 16/11/2026 | Andrés Felipe Vélez | ACT-131 | Documentar la configuración de cada servicio de Docker | Documentación | 0.7 | `herramientas-rnf/README.md` con credenciales, puerta de calidad, monitor de Kuma campo por campo, y los tres errores de invocación que ya tropezamos (comillas en PowerShell, rutas en Git Bash, `admin/admin` invalidado) | `herramientas-rnf/README.md` §4 y §5 | Cerrada |

**Total: 10,2 h del 15 de noviembre + 11,1 h del 16 de noviembre = 21,3 horas.**

---

## 2. Hoja «Registro de uso de IA»

Columnas: `Integrante y fecha` · `Herramienta` · `Propósito` · `Prompt (resumen)` · `Resultado` ·
`Aplicación` · `Verificación` · `Errores encontrados` · `Decisión` · `¿Verificado?`

> **El criterio de verificación que nos exigimos** (guía §8.2): «lo revisé» **no es** evidencia.
> Para un criterio de verificación, la evidencia mínima es **haberlo ejecutado y pegado la salida
> real**. Las cuatro filas de abajo cumplen eso: cada una tiene un comando corrido, no una
> afirmación.

| Integrante y fecha | Herramienta | Propósito | Prompt (resumen) | Resultado | Aplicación | Verificación | Errores encontrados | Decisión | ¿Verificado? |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Andrés Felipe Vélez — 15/11/2026 | Claude (Claude Code) | Revisar el estado real del proyecto y preparar la verificación inicial de RNF para la Entrega 2 | Revisar los dos documentos del equipo y los repositorios actualizados; preparar el paso a paso de la parte de RNF usando HTTPS de Render, JMeter y SonarQube | Semáforo de los 21 RNF, dos planes de JMeter, el fix de H-08 y cuatro hallazgos nuevos | Se aplicó: el fix está en `build.gradle` y los `.jmx` en el repositorio | **Cada afirmación se ejecutó**: `curl` contra Render para TLS, `gradlew jacocoTestCoverageVerification` para la cobertura, JMeter para las 90 muestras, `gh api` para las variables de repositorio. Las salidas están pegadas en A4 y A6 | Propuso inicialmente medir los 20 usuarios contra Render; se descartó al verificar que el `.env` apunta a la misma Supabase del despliegue, lo que lo convertiría en una prueba de carga en producción | Aceptada con ajustes | **Sí** |
| José Alejandro Valencia — 15/11/2026 | Claude (Claude Code) | Corregir el hallazgo H-08 en la configuración de cobertura | Agregar los paquetes de `estadisticas` a la lista vigilada de JaCoCo y comprobar que no rompe el build | Diff de 4 líneas en `SIGRA/build.gradle` | Aplicado en la copia de trabajo; pendiente de PR | Se corrió `jacocoTestCoverageVerification` (BUILD SUCCESSFUL) **y además** se subió el umbral a 0,99 de forma temporal para comprobar que la regla ahora nombra los dos paquetes nuevos. Las dos salidas están en A4 | Ninguno | Aceptada | **Sí** |
| Andrés Felipe Vélez — 15/11/2026 | Claude (Claude Code) | Construir los planes de JMeter con los umbrales del SRS | Planes para RNF-18 (disponibilidad) y RNF-01 a RNF-06 (rendimiento), parametrizados y sin credenciales dentro del archivo | Dos `.jmx` y un README | El de disponibilidad se ejecutó y dio resultado; el de rendimiento queda listo y sin ejecutar | El plan de disponibilidad se **corrió de verdad**: 90 muestras, salida de JMeter y `.jtl` adjuntos. El de rendimiento no se ha ejecutado y **así queda declarado** en el semáforo, en amarillo y no en verde | Ninguno | Aceptada | **Sí** |
| Andrés Felipe Vélez — 15/11/2026 | Claude (Claude Code) | Cruzar la exportación de Mantis contra el libro del equipo | Buscar incidencias sin dueño, sin cerrar, o de categoría no funcional que nos correspondan | Tres hallazgos nuevos (H-11, H-12, H-13) | Documentados en A4 y llevados a la reunión 3 | Se contaron los estados sobre el CSV y se confirmó la categoría «No Funcionalidad» de 0000038 y 0000040 fila por fila; la asignación de rol se verificó en la hoja «Guía y reglas», fila 8 | Al revisar 0000029 propuso tratarla como defecto abierto de seguridad; **se descartó**: el bloqueo está implementado y probado en el código. Lo que falta es solo cerrar la resolución en Mantis | Aceptada con ajustes | **Sí** |

---

## 3. Hoja «Registro de errores»

Columnas: `ID y fecha` · `Reportado por` · `Funcionalidad` · `Descripción` · `Severidad` ·
`Responsable` · `Causa raíz` · `Solución` · `Evidencia` · `Estado`

> **Por qué nuestros hallazgos de RNF van aquí también** (guía §8.3): si solo viven en
> `A4-hallazgos-rnf.md`, para el equipo no existen y no se van a corregir. La escala de severidad
> es la del manual (§9.3): crítica · alta · media · baja.

| ID y fecha | Reportado por | Funcionalidad | Descripción | Severidad | Responsable | Causa raíz | Solución | Evidencia | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ERR-012 — 15/11/2026 | José Alejandro Valencia | Verificación de cobertura (RNF-20 a) | La verificación de JaCoCo vigilaba 2 de los 4 módulos que el SRS nombra como obligatorios: el cálculo de nivel de logro (RF-14) y la generación de conclusiones (RF-16) quedaban fuera del umbral del 70 % | **alta** | José Alejandro Valencia | Un comentario obsoleto en `build.gradle` («agregar cuando exista RF-14») que quedó sin actualizar cuando RF-14 y RF-16 se implementaron | Agregar `co.edu.uco.sigra.estadisticas.service*` a la lista `includes`. La cobertura real ya era 96,48 % y 93,69 %, así que el cambio no rompe nada | Hallazgo H-08 en A4; `jacocoTestCoverageVerification` BUILD SUCCESSFUL; prueba con umbral 0,99 | **Resuelto · pendiente de PR** |
| ERR-013 — 15/11/2026 | Andrés Felipe Vélez | CI del backend — análisis de dependencias | Los dos trabajos de SCA (Dependency Review y OWASP Dependency-Check) se saltan en cada corrida desde el inicio de la fase; el frontend sí audita con `npm audit` | **alta** | Admin del repositorio (Juan Camilo / Jean Paul) | Las variables `SIGRA_ENABLE_DEPENDENCY_REVIEW` y `SIGRA_ENABLE_OWASP_SCA` nunca se crearon: `gh api actions/variables` devuelve `total_count: 0`. Crearlas exige permiso `admin`, que los especialistas de RNF no tienen | Crear las dos variables de repositorio con valor `true`. **Pendiente desde el 8 de noviembre** | Hallazgo H-01 en A4; salidas de `gh api` | **Abierto · 8 días** |
| ERR-014 — 15/11/2026 | Andrés Felipe Vélez | Suite E2E de navegador (RNF-19) | El producto creció ocho módulos entre el 8 y el 15 de noviembre (Reportes R1/R2/R6, Estudiante `me`, Facultad, `semestres/mios`, `auditoria/mis-eventos`, Reportes por facultad, Estadísticas en tres páginas, nombres separados con migración) y la suite E2E sigue recorriendo un solo flujo: `e2e/auth.spec.ts` | **alta** (sube de media) | Por asignar | La suite no creció con el producto. Varios módulos nuevos tienen reglas de alcance por rol que ninguna prueba de navegador recorre | Agregar al menos un spec E2E por rol antes del cierre, **o** declararlo deuda técnica con justificación escrita | Hallazgo H-03 en A4; `ls software4-SIGRA-frontend/e2e/` | **Abierto** |
| ERR-015 — 15/11/2026 | Andrés Felipe Vélez | Combos de semestre/asignatura/RA (incidencia 0000053) | La incidencia 0000053, de prioridad alta y severidad mayor, reportada el 14-nov, **no tiene responsable asignado** y no aparece en la hoja de reparto del libro. Según el §7 los defectos altos bloquean la entrega | **alta** | **Sin asignar** | Sin confirmar. Hipótesis: el mismo patrón de ERR-002 (peticiones que no cancelan las anteriores) replicado en los módulos de filtros en cascada de 0000044, 0000045 y 0000047 | Asignar dueño y reproducir con `jmeter/RNF-01-06-rendimiento.jmx` a 20 hilos, que vuelve determinista un fallo intermitente | Hallazgo H-11 en A4; `estado de mantis.csv` | **Abierto** |
| ERR-016 — 15/11/2026 | Andrés Felipe Vélez | Gestión de incidencias en Mantis | Ninguna de las 31 incidencias del tablero está en estado `cerrada` (22 resueltas, 6 nuevas, 3 asignadas), y 12 de las resueltas siguen con resolución `abierta` en vez de `corregida` | media | Jean Paul (revisor técnico) y Juan Camilo (SM) | El estado `cerrada` lo mueve el revisor técnico tras el visto bueno de pruebas, y ese paso no se ha ejecutado para ninguna incidencia | Pasar a `cerrada` toda incidencia con PR integrado, revisión y prueba. Hasta entonces, el indicador «% de cambios con trazabilidad completa» se reporta como **0 %** | Hallazgo H-13 en A4; conteo sobre `estado de mantis.csv` | **Abierto** |
| ERR-017 — 15/11/2026 | Andrés Felipe Vélez | Patrones de paginación y buscador (0000040 y 0000038) | Las dos únicas incidencias que Mantis clasifica como «No Funcionalidad» son las que el libro asigna a los especialistas de RNF («definen y validan los patrones de paginación y buscadores»), y ninguna de las dos pasó por nuestra validación. 0000038 lleva 7 días en «asignada» | media | **Andrés Vélez y José Valencia** | No registramos actividad entre el 8 y el 15 de noviembre, así que el rol no se ejerció sobre las dos incidencias que nos correspondían | Documento de una página con el patrón de paginación y de buscador (tamaño de página, que la paginación respete el filtro activo —lo que falló en ERR-001—, vuelta a la página 1, mínimo de caracteres de búsqueda y estado vacío) + fila en A2 con veredicto | Hallazgo H-12 en A4; hoja «Guía y reglas» fila 8; hoja «Registro de actividades» sin filas nuestras | **Abierto** |
| ERR-023 — 16/11/2026 | Andrés Felipe Vélez | Dependencias del backend | **4 vulnerabilidades CRITICAL y 10 HIGH** en librerías Java de la imagen `sigra-backend:local`: `tomcat-embed-core` 11.0.24 (4 CVE) y la familia `jackson` 2.21.5 y 3.1.5 (10 CVE). Todas con versión de arreglo publicada | **alta** | Revisor técnico / equipo | Las dependencias no se auditan desde el inicio de la fase: la compuerta de SCA del CI está apagada (ERR-013). El `dependencyCheck` del proyecto tiene `failBuildOnCVSS = 4.0`, así que **habría hecho fallar el build** | Decidir con el revisor técnico. **No actualizar a ciegas**: `tomcat-embed-core` llega con Spring Boot y subirlo a mano puede romper compatibilidad | `herramientas-rnf/evidencias/trivy-backend-16nov.json`; A4 hallazgo H-01 | **Abierto** |
| ERR-022 — 16/11/2026 | Andrés Felipe Vélez | Esquema base de datos (`docs/db/SIGRA_SCHEMA_CURRENT.sql`) | **El backend no arranca con el esquema que documenta el repositorio.** El baseline crea 19 tablas y las entidades JPA esperan 20: falta `historial_auditoria`. Con `JPA_DDL_AUTO=validate` el arranque aborta con *Schema validation: missing table [historial_auditoria]* | **alta** | Por asignar | La tabla la crea `docs/db/RF19_historial_auditoria_migration.sql`, que **nunca se integró al baseline**. El baseline se documenta como «el DDL del schema sigra tal como existe en la base que usa el backend hoy», y no lo es | Integrar el DDL de `historial_auditoria` en `SIGRA_SCHEMA_CURRENT.sql`, o documentar explícitamente que el baseline requiere aplicar RF19 después | Traza de arranque del contenedor; `herramientas-rnf/README.md` §2.3 | **Abierto** |
| ERR-021 — 16/11/2026 | Andrés Felipe Vélez | Datos de prueba del backend (`bruno/SIGRA/seed`) | `seed-asignaturas-roles.sql:61` inserta en `sigra.matricula` **sin la columna `fecha_matricula`**, que el esquema actual declara `NOT NULL` (`SIGRA_SCHEMA_CURRENT.sql:246`). Cargar los seeds en orden sobre una base limpia falla con *null value in column "fecha_matricula" violates not-null constraint* | media | Por asignar | El seed es del **6 de octubre** y la migración RF-08 que hizo esa columna obligatoria es del **11 de octubre**: el seed quedó cinco días atrás y nadie lo actualizó. `seed-estudiantes.sql:184` sí la incluye, así que el patrón correcto ya existe en el repositorio | Agregar `fecha_matricula` al INSERT, copiando el patrón de `seed-estudiantes.sql`. Es **una línea** | Salida de `levantar.ps1`; `herramientas-rnf/README.md` §1 | **Abierto** |
| ERR-019 — 16/11/2026 | José Alejandro Valencia | Vistas de administrador y estadísticas del profesor | Cuatro vistas del despliegue muestran «Ocurrió un error inesperado. Intenta de nuevo en unos minutos.» con el rol autorizado y sin enviar formularios: `/admin/ra`, `/admin/estudiantes`, `/admin/reportes` (Rendimiento por RA) y `/profesor/estadisticas`. En Catálogo apareció además «El servicio no está disponible» y la lista falló tras F5 | media *(provisional)* | Por asignar | **No determinada.** Sin respuesta de red exportable ni logs; el SHA del despliegue no está confirmado. Puede ser datos, servicio, red o despliegue. **No atribuir a concurrencia** | Reproducir en QA correlacionando `X-Request-Id`, y volver a comprobar por SHA. Se deja nota en las incidencias abiertas que tocan esas pantallas (0000041 y 0000048); **no se crea ticket nuevo** | OBS-01 en A4; `navegador-administrador.md` y `navegador-profesor.md` de la auditoría de José | **Abierto** |
| ERR-020 — 16/11/2026 | José Alejandro Valencia | Configuración del despliegue (Vercel) | En la respuesta de `https://sigra.vercel.app/login` está HSTS, pero no se observaron CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy ni Permissions-Policy | baja | Quien administre Vercel | Configuración del edge, no del código | Revisar y **registrar la decisión de política**. Puede cerrarse sin cambiar nada si el equipo decide que no aplican. **No se declara vulnerabilidad** | OBS-02 en A4; `seguridad.md` de la auditoría de José | **Abierto** |
| ERR-018 — 15/11/2026 | Andrés Felipe Vélez | Entorno local del frontend | `npx ng build` no arranca: Node v24.11.0 instalado contra el mínimo v24.15.0 que exige Angular CLI. Impide medir el bundle en local | baja | Andrés Felipe Vélez | Deriva de versión del entorno local. El CI no lo ve porque su paso «Instalar Node 24» trae una versión que cumple | Actualizar Node. Mientras tanto la cifra de RNF-08 se obtuvo del registro de CI. Propuesta al equipo: declarar `engines` en `package.json` | Hallazgo H-14 en A4; salida de `npx ng build` | **Abierto** |

---

## 4. Hoja «Indicadores» — los tres que se llenan a mano

El libro deja tres indicadores en blanco porque no tienen hoja propia. Estos son los valores
honestos al 15 de noviembre, con el cálculo a la vista para que cualquiera los pueda rehacer:

| Indicador | Numerador | Denominador | % | Cómo se calculó |
| --- | --- | --- | --- | --- |
| % de PR aprobados en primera revisión | *(no auditable por nosotros)* | — | — | Requiere el historial de revisiones de cada PR. No tenemos permiso de lectura de revisiones en bloque; lo puede calcular Jean Paul |
| **% de pruebas ejecutadas (parte RNF)** | **14** | **23** | **61 %** | Criterios con veredicto respaldado por una **medición ya ejecutada**: los 9 verdes más los 5 amarillos que descansan en evidencia corrida (RNF-08 bundle, RNF-18 uptime, RNF-19 E2E del CI, RNF-14 inspección, RNF-21 corrección de UI/UX). **No** se cuentan RNF-01, 03, 04 ni 06: tienen instrumento pero no se han ejecutado. Base de 23 criterios (RNF-18 y RNF-20 cuentan doble) |
| **% de cambios con trazabilidad completa** | **0** | **31** | **0 %** | Incidencias en estado `cerrada` en Mantis sobre el total del tablero. Ver ERR-016 |

> El §10 del manual dice textualmente que los indicadores «deben reflejar resultados reales» y que
> «no se deben fijar metas arbitrarias ni alterar datos para aparentar cumplimiento». El 0 % de
> trazabilidad es incómodo y es el número correcto: se corrige moviendo incidencias a `cerrada`,
> no cambiando la fórmula.

---

## 5. Hoja «Compromisos y fechas» — dos cosas que hay que corregir

1. **Las fechas no coinciden entre los dos documentos del equipo.** El libro dice Entrega 2 =
   sábado 14 de nov 6:00 pm y Entrega 3 = martes 17 de nov 8:00 pm. El documento Word de la
   Entrega 1 dice Entrega 2 = domingo 15 de nov 8:00 pm y Entrega 3 = martes 17 de nov 11:00 pm.
   **Hay que decidir cuál manda**, porque determina qué se está entregando esta noche.

2. **Agregar los compromisos de RNF** que salen de la reunión 3 (C-08 a C-15 en el
   [acta](evidencias-reuniones/reunion-3-2026-11-15/acta.md)), y los dos pedidos al equipo que
   siguen abiertos: crear las variables de SCA (8 días) y entregar los Apéndices 4.1 y 4.2 del SRS.

---

[Guía del rol](GUIA-TRABAJO-RNF.md) · [A4 Hallazgos](A4-hallazgos-rnf.md) · [A6 Semáforo](A6-semaforo-rnf.md) · [Acta reunión 3](evidencias-reuniones/reunion-3-2026-11-15/acta.md)
