# Navegador · PROFESOR

**Fecha:** 15 de noviembre de 2026 · **Ambiente:** despliegue Vercel · **Resultado:** recorrido de solo lectura.
No se copiaron cuentas, nombres, IDs ni calificaciones. No se registraron evaluaciones, notas o matrículas.

## Pantallas recorridas

| Ruta | Pantalla / controles observados | Resultado |
| --- | --- | --- |
| `/profesor/asignaturas` | “Mis asignaturas”, búsqueda, filtros por programa/estado, tarjetas y botones Ver RA/Ver matrículas | Cargaron dos tarjetas acotadas a la sesión. El detalle Ver RA cargó cuatro RA activos. No se abrió el listado de estudiantes |
| `/profesor/matricula` | Filtros de semestre/asignatura, incluir inactivas, botón Matricular | Las opciones de semestre cargaron; no se eligió asignatura ni se abrió una ficha. No se inició matrícula |
| `/profesor/evaluaciones` | Semestre, materia y RA; texto de regla de suma de ponderaciones | Materia/RA permanecieron en “Cargando…” durante la primera observación; dejaron de mostrar el estado de carga después de unos 2 s. No se eligió ni creó evaluación |
| `/profesor/notas` | Registro de notas y observaciones | La página salió del estado de carga; no se seleccionó evaluación ni se abrió una planilla de notas |
| `/profesor/estadisticas` | Estadísticas y ciclo de mejora | “Ocurrió un error inesperado. Intenta de nuevo en unos minutos.” |
| `/profesor/reportes` | Rendimiento por RA y Riesgo académico | El reporte de rendimiento cargó una tabla (cuatro filas de cuerpo). Riesgo académico no se abrió para evitar exposición innecesaria de datos personales |
| `/profesor/historial` | Mi historial | La pantalla se identifica “Módulo en construcción” |

## Acceso entre roles

Al navegar directamente a `/admin/auditoria`, la aplicación mostró una página 403 “Acceso denegado” y explicó que el rol actual no tiene permiso. Logout devolvió al login. No se intentaron endpoints API ni cambios de datos.

## Observación

La sesión mostró datos limitados a la cuenta del profesor, pero la prueba no comparó la respuesta del servidor con el Apéndice 4.1 (ausente). La falla de Estadísticas se documenta como observación productiva sin atribuir causa. Véase [hallazgos.md](hallazgos.md).
