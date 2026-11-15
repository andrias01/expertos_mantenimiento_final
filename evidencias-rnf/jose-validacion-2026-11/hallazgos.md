# Hallazgos y seguimiento

Este registro separa el síntoma observado, la causa no confirmada y las incidencias que ya existen. No se crearon IDs de Mantis ni se duplicaron tickets.

## OBS-01 · Errores genéricos en vistas administrativas y estadísticas

| Campo | Valor |
| --- | --- |
| RNF relacionado | RNF-06, RNF-17 y disponibilidad operativa |
| Atributo | Disponibilidad funcional / manejo de errores |
| Ambiente y fecha | Despliegue Vercel, 15-nov-2026 |
| SHA | No confirmado para el despliegue |
| Rol y rutas | ADMINISTRADOR: `/admin/ra`, `/admin/estudiantes`, `/admin/reportes` (Rendimiento por RA); PROFESOR: `/profesor/estadisticas` |
| Severidad sugerida | Media provisional; elevar si el equipo reproduce que bloquea una operación esencial de manera sostenida |
| Frecuencia | Una sesión de revisión; no se estimó tasa ni se hizo repetición controlada |
| Estado | Observado; causa y alcance pendientes |

**Descripción / esperado.** Las vistas deben cargar o comunicar de forma recuperable el estado de la consulta.
**Observado.** Las cuatro vistas mostraron “Ocurrió un error inesperado. Intenta de nuevo en unos minutos.” En Catálogo hubo además un mensaje transitorio “El servicio no está disponible”; la lista cargó en una visita y falló después de F5.
**Reproducción segura.** Iniciar sesión con rol autorizado y abrir la ruta indicada; no enviar formularios. Los resultados fueron visibles en esta sesión y el archivo [navegador-administrador.md](navegador-administrador.md)/[navegador-profesor.md](navegador-profesor.md) registra cada estado.
**Impacto.** Impide o retrasa la consulta de esas funciones en el despliegue observado; se desconoce si la causa es datos, servicio, red o despliegue.
**Causa probable.** No sustentada; no hubo respuesta de red exportable ni logs del servidor.
**Recomendación/equipo.** Desarrollo backend y frontend, con operaciones/infraestructura: correlacionar `X-Request-Id` y errores de servicio en QA/observabilidad, reproducir y volver a comprobar por SHA. No atribuirlo a concurrencia sin medición.
**Relación con Mantis.** No se encontró un ticket con este mismo síntoma transversal. 0000041 (alcance del módulo Reportes) y 0000048 (organización de Estadísticas) son temas relacionados, pero no prueban esta causa ni describen exactamente el error genérico.

## OBS-02 · Cabeceras de endurecimiento no observadas en login

| Campo | Valor |
| --- | --- |
| RNF relacionado | RNF-11, RNF-14, RNF-17 |
| Ambiente y fecha | Respuesta HTTPS de `https://sigra.vercel.app/login`, 15-nov-2026 |
| Severidad sugerida | Baja / revisión de configuración |
| Frecuencia | Un muestreo de la respuesta |
| Estado | Pendiente confirmar en Vercel/edge |

HSTS estaba presente. En la respuesta muestreada no aparecieron CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy ni Permissions-Policy. No se ha probado ausencia en otras capas/rutas ni impacto explotable; no se declara vulnerabilidad. Operaciones/infraestructura debe revisar y registrar decisión de política.

## Hallazgos previos que se conservan

- **H-08 / RNF-20(a):** A4 lo da por corregido en `d6fa7e1`. En la rama backend inspeccionada (`c1b1950`) falta todavía la regla por paquete de `estadisticas`; el commit citado no está en el clon. No cerrar H-08 para esta versión.
- **H-11 / Mantis 0000053:** 0000053 sigue `nueva/abierta` y describe combos intermitentes de semestre/asignatura/RA en varios roles. En esta revisión algunas listas cargaron, otras tuvieron error/carga inicial; frecuencia, endpoint y causa no se midieron. La hipótesis de carrera/concurrencia y la propuesta de hacerla determinista con 20 hilos no quedan demostradas; retirarlas como causa confirmada hasta reproducir en QA.
- **Mantis 0000038:** búsqueda en listados largos, `asignada/abierta`; no se probaron 500 registros.
- **Mantis 0000040:** varias tablas sin paginación, `resuelta/abierta`; se observó paginación en Materias, pero no se verificaron todas las tablas afectadas.
- **Mantis 0000041:** módulo de Reportes con siete reportes, `nueva/abierta`; la UI observada muestra Rendimiento por RA y Riesgo académico. El SRS ausente impide concluir cobertura completa.
- **Mantis 0000048:** agrupación excesiva de Estadísticas, `asignada/abierta`; la pantalla profesor actual devolvió error, sin volver a evaluar su diseño completo.
- **Mantis 0000049:** menú estudiante con poca información, `resuelta/corregida`; esta visita mostró dos opciones y “Mi progreso” en construcción. Contrastar con el criterio de aceptación antes de declarar regresión.

## Imágenes y datos sensibles

Las capturas de la herramienta integrada se revisaron durante la sesión, pero no se publican como archivos: varias vistas mostraban cuentas, registros académicos o eventos de auditoría, y no se pudo producir una copia local redacted con trazabilidad. No se incluyen IDs, credenciales, cookies, tokens, nombres, correos, documentos ni calificaciones.
