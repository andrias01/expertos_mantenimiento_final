# Navegador · ESTUDIANTE

**Fecha:** 15 de noviembre de 2026 · **Ambiente:** despliegue Vercel · **Resultado:** recorrido de solo lectura.
Las pantallas incluían datos personales/académicos; se omiten nombres, correos, documentos, cursos y resultados individuales.

## Pantallas recorridas

| Ruta | Pantalla / controles observados | Resultado |
| --- | --- | --- |
| `/estudiante/materias` | Mis materias, búsqueda por código/nombre, filtro de programa, alcance “Datos autorizados por tu sesión”, rótulo “Solo lectura” | Cargó una tarjeta de materia vinculada a la sesión. No se abrió información adicional de estudiantes |
| `/estudiante/progreso` | Mi progreso | La navegación llegó a la ruta, pero la pantalla indica “Módulo en construcción” |

## Acceso entre roles y sesión

La ruta directa `/profesor/asignaturas` mostró 403 y “No tienes permisos para consultar esta pantalla con tu rol actual”. Logout devolvió al login; después, la ruta directa `/estudiante/materias` volvió a `/login?returnUrl=…`.

En el viewport del navegador integrado de 608 × 667 px, `scrollWidth` y `clientWidth` fueron 608 px; no se observó desbordamiento horizontal. Esto no equivale a probar un teléfono ni otros breakpoints.
