# Filas para el libro compartido del equipo

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Para qué** | Pegar en `SIGRA Fase 2 - Guía y registros del equipo.xlsx`, en las tres hojas obligatorias |
| **Fecha** | 15 de noviembre de 2026 |
| **Por qué existe este archivo** | Al 15 de noviembre el libro tenía **97 actividades registradas y ninguna nuestra**. Es un incumplimiento del §12 («las actividades se registran diariamente») y del §9. Esto lo corrige |

> **Correlativos.** La última actividad del libro es **ACT-097** (Andrea Avendaño, 14-nov), el
> último error es **ERR-011** y el registro de uso de IA llega a la fila **51**. Nuestras filas
> arrancan en **ACT-098** y **ERR-012**. **Antes de pegar, confirmar que nadie agregó filas
> entremedio** y correr los correlativos si hace falta.

---

## 1. Hoja «Registro de actividades»

Columnas: `Fecha` · `Integrante` · `ID actividad` · `Actividad` · `Tipo` · `Tiempo (h)` ·
`Resultado` · `Evidencia` · `Estado`

| Fecha | Integrante | ID | Actividad | Tipo | h | Resultado | Evidencia | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 15/11/2026 | Andrés Felipe Vélez | ACT-098 | Revisión del estado real del proyecto para la verificación inicial de RNF: documento de Entrega 1, libro del equipo, exportación de Mantis y los dos repositorios en `develop` | Revisión | 1.5 | Se identificó que el producto ya está desplegado (Render + Vercel), lo que vuelve verificables RNF-11 y la mitad de uptime de RNF-18 | A6-semaforo-rnf.md; commits `d6fa7e1` (backend) y `a3135ec` (frontend) | Cerrada |
| 15/11/2026 | José Alejandro Valencia | ACT-099 | Medición de la cobertura real de los cuatro módulos obligatorios del RNF-20 (a) con JaCoCo | Prueba | 0.5 | Global 92,39 %; `estadisticas.service` 96,48 % y `estadisticas.service.impl` 93,69 %, los dos módulos que no estaban vigilados | Salida de `./gradlew test jacocoTestReport`; A4 hallazgo H-08 | Cerrada |
| 15/11/2026 | José Alejandro Valencia | ACT-100 | Corrección del hallazgo H-08: agregar `co.edu.uco.sigra.estadisticas.service*` a la verificación de cobertura de `build.gradle` | Desarrollo | 0.5 | La verificación ya cubre los cuatro módulos que el SRS nombra (RF-04, RF-05, RF-14, RF-16). `jacocoTestCoverageVerification` pasa | Diff de 4 líneas en `SIGRA/build.gradle`; pendiente de PR | Cerrada |
| 15/11/2026 | José Alejandro Valencia | ACT-101 | Prueba de que la regla de cobertura **falla** si la cobertura baja (criterio de cierre de H-08) | Prueba | 0.3 | Con umbral temporal de 0,99 JaCoCo nombra `estadisticas.service` y `estadisticas.service.impl`; antes del cambio eran invisibles | Salida de `jacocoTestCoverageVerification` con las dos violaciones | Cerrada |
| 15/11/2026 | José Alejandro Valencia | ACT-102 | Verificación de RNF-11 (HTTPS con TLS 1.2+) contra el despliegue de producción en Render | Prueba | 0.5 | Cumple completo: HTTPS sobre HTTP/2, TLS 1.2 y 1.3 aceptados, TLS 1.0 rechazado, HTTP responde 301 a HTTPS. **Cierra el hallazgo H-10** | Salidas de `curl` en A6 §3.1 | Cerrada |
| 15/11/2026 | Andrés Felipe Vélez | ACT-103 | Instalación de Apache JMeter 5.6.3 y creación de los dos planes de prueba de RNF | Desarrollo | 1.5 | `RNF-18-disponibilidad.jmx` y `RNF-01-06-rendimiento.jmx` versionados, con los umbrales del SRS como Duration Assertion y la contraseña fuera del archivo | `mantenimiento-rnf/jmeter/` y su README | Cerrada |
| 15/11/2026 | Andrés Felipe Vélez | ACT-104 | Medición de disponibilidad (RNF-18) contra el backend en Render con JMeter | Prueba | 0.5 | 90 muestras, 90 exitosas (100 %), solo códigos 200 con cuerpo `UP`; p95 de 526 ms. Ventana de 208 s, que es la reserva que hay que declarar | `jmeter/resultados/rnf18-render.jtl` e informe HTML | Cerrada |
| 15/11/2026 | Andrés Felipe Vélez | ACT-105 | Medición del bundle del frontend para fijar el umbral de RNF-08 | Prueba | 0.5 | 356,04 kB sin comprimir y 100,14 kB transferidos, contra un presupuesto de aviso de 500 kB: cumple con 29 % de margen. Propuesta: bajar el aviso a 420 kB | Corrida de CI 43684672703 del frontend; `angular.json:51-62` | Cerrada |
| 15/11/2026 | Andrés Felipe Vélez | ACT-106 | Confirmación del hallazgo H-01 por la API de GitHub y de por qué no lo podemos corregir nosotros | Revisión | 0.3 | `actions/variables` devuelve `total_count: 0`: los dos trabajos de SCA se saltan en cada corrida. Nuestro permiso es `push`, no `admin`: hace falta un administrador | Salidas de `gh api` en A4 hallazgo H-01 | Cerrada |
| 15/11/2026 | José Alejandro Valencia | ACT-107 | Verificación de que la auditoría registra autenticaciones **fallidas**, no solo exitosas (RNF-16, compromiso C-06) | Prueba | 0.3 | Cubierto por `AuditoriaIntegracionIT` y `AuditoriaAspectTest`. RNF-16 queda en verde | A6 §2.2 | Cerrada |
| 15/11/2026 | José Alejandro Valencia | ACT-108 | Revisión de la incidencia 0000029 (bloqueo tras 5 intentos fallidos, RF-04) | Revisión | 0.3 | Está implementada y probada: `Usuario.intentosFallidos`, `fechaBloqueo`, `estaBloqueado`, respuesta 423 documentada en OpenAPI. Falta cerrar la resolución en Mantis | `auth/entity/Usuario.java`; `AuthControllerTest`, `UsuarioTest` | Cerrada |
| 15/11/2026 | Andrés Felipe Vélez | ACT-109 | Análisis de la exportación de Mantis del 15-nov y cruce contra la hoja de reparto del libro | Revisión | 1.0 | Tres hallazgos nuevos: 0000053 sin dueño (alta/mayor), las dos incidencias de categoría «No Funcionalidad» resueltas sin nuestra validación, y ninguna de las 31 en estado `cerrada` | `estado de mantis.csv`; A4 hallazgos H-11, H-12 y H-13 | Cerrada |
| 15/11/2026 | Ambos | ACT-110 | Elaboración del semáforo de RNF y actualización del registro de hallazgos para la verificación inicial de la Entrega 2 | Documentación | 2.0 | Sobre 23 criterios (RNF-18 y RNF-20 cuentan doble): 9 en verde, 9 en amarillo con la reserva declarada y 5 en rojo. Dos hallazgos cerrados, cuatro en corrección, cuatro nuevos, uno sube de severidad | `A6-semaforo-rnf.md`, `A4-hallazgos-rnf.md` | Cerrada |
| 15/11/2026 | Ambos | ACT-111 | Preparación del acta de la reunión 3 y del seguimiento de los compromisos de la reunión 1 | Documentación | 0.5 | Tres de siete compromisos cumplidos, uno bloqueado por otro y tres no cumplidos, con la causa escrita | `evidencias-reuniones/reunion-3-2026-11-15/acta.md` | Cerrada |

**Total: 10,2 horas.**

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
