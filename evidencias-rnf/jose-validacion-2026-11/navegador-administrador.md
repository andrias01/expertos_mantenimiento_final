# Navegador · ADMINISTRADOR

**Fecha:** 15 de noviembre de 2026 · **Ambiente:** despliegue Vercel · **Resultado:** recorrido de solo lectura.
No se registraron nombres, correos, documentos, tokens ni valores de registros. No se enviaron formularios ni se alteraron datos.

## Pantallas recorridas

| Ruta | Pantalla / controles observados | Resultado |
| --- | --- | --- |
| `/admin/catalogo` | Profesores, Facultades, Programas académicos y Materias; búsqueda, filtros de programa/estado/RA y paginación en Materias | Profesores cargó una lista (10 filas de cuerpo en la vista); Facultades mostró una fila; Programas mostró error y opción Reintentar. Materias cargó una tabla en una visita y tuvo “El servicio no está disponible” tras F5; el resultado fue intermitente |
| `/admin/semestres` | Búsqueda por código, filtro de estado, tabla y paginación | Cargó; la interfaz indicó un semestre en curso. No se modificaron fechas |
| `/admin/ra` | Gestión de Resultados de Aprendizaje | “Ocurrió un error inesperado. Intenta de nuevo en unos minutos.” |
| `/admin/asignacion` | Pestañas Asignar y Consultar/desasignar | Asignar mostró “El servicio no está disponible”; Consultar cargó el selector de profesores. No se eligió una persona ni se desasignó |
| `/admin/estudiantes` | Búsqueda y botón Registrar estudiante | “Ocurrió un error inesperado”; no se abrió el formulario ni se consultaron fichas |
| `/admin/matricula` | Filtros de semestre/asignatura e inclusión de inactivas | Las opciones de semestre cargaron; asignatura permaneció deshabilitada hasta elegir semestre. No se seleccionó una matrícula ni se usó Registrar |
| `/admin/auditoria` | Filtros de fechas/tipo y tabla rotulada solo lectura | Cargó. Se observaron eventos de autenticación exitosos y rechazados; no se copiaron IDs, fechas exactas ni detalles individuales |
| `/admin/reportes` | Rendimiento por RA y Riesgo académico | Rendimiento por RA mostró error genérico. Riesgo académico cargó un resultado; no se copió ningún dato del registro |

## Navegación y seguridad de sesión

- Menú de ADMINISTRADOR mostró los ocho módulos anteriores.
- Atrás/Adelante regresó entre las rutas visitadas. Tras regresar a Catálogo, la pestaña activa quedó en Materias, no en Programas.
- F5 en `/admin/catalogo` conservó la sesión y la ruta; la consulta de materias mostró entonces el error genérico de servicio.
- Después de cerrar sesión, una navegación directa a `/admin/catalogo` redirigió a `/login?returnUrl=…`.
- No se inspeccionaron valores de almacenamiento local. El evaluador no expuso `localStorage`/`sessionStorage` en el alcance de lectura.

## Observación

Los errores visibles ocurrieron en el despliegue consultado; no se confirmó el SHA que sirve Vercel ni se capturaron solicitudes API. Una única visita no determina frecuencia ni causa. Véase [hallazgos.md](hallazgos.md).
