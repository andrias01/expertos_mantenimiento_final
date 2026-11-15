# Revisión de seguridad

**Fecha:** 15 de noviembre de 2026 · **Tipo:** inspección estática y navegación real no destructiva.
**Versiones de código:** backend `c1b1950bc88f51de3eff4471e29d598482d0774e`; frontend `9a5fa537708fb711318a9b353c481289299c7240`.

## Hallazgos de control observados

- Sin sesión, `/admin/catalogo` redirigió a login con `returnUrl`.
- PROFESOR recibió 403 al abrir `/admin/auditoria`; ESTUDIANTE recibió 403 al abrir `/profesor/asignaturas`.
- Logout de cada rol volvió al login; el acceso posterior a una ruta privada volvió a pedir autenticación.
- La consola del navegador integrado terminó sin entradas `error` o `warn`.
- La UI de auditoría se declara de solo lectura. No se intentó modificar o borrar eventos.

Estas pruebas acreditan guardas de rutas en el cliente para los pares de roles probados; no demuestran por sí solas que cada endpoint valide roles en el servidor. Las respuestas 401/403 por endpoint requieren QA aislado.

## Inspección estática

| Control | Evidencia observada | Límite |
| --- | --- | --- |
| Contraseñas (RNF-10) | `SecurityConfig.java` usa `BCryptPasswordEncoder(12)`; pruebas de autenticación previas existen | No se registraron credenciales ni se inspeccionó la base de usuarios |
| JWT (RNF-12/15) | Servicio genera/verifica JWT y filtro valida firma, expiración y usuario/rol; frontend usa `sessionStorage` y su servicio borra sesión al salir | No se capturó ni inspeccionó ningún token; no se esperó una expiración real de 60 min |
| RBAC (RNF-13) | `@PreAuthorize` en controladores, guardas Angular y 403 visual en rutas cruzadas | Apéndice 4.1 ausente; no se probaron endpoints con solicitudes manipuladas en producción |
| Validación (RNF-14) | DTOs con `@Valid`, `@NotBlank`, `@Size`, `@Pattern`; acceso a datos con JPA | No se hizo prueba de inyección, XSS o saneamiento; falta cubrir entradas y renderizado con datos de QA |
| Auditoría (RNF-16) | Aspecto para login y operaciones seleccionadas; entidad de historial inmutable en ORM | No se verificó rechazo de UPDATE/DELETE en PostgreSQL ni persistencia ante fallo del repositorio. `AuditoriaAspect` captura y registra excepciones de auditoría, lo que evita que fallen operaciones de negocio pero puede dejar un evento sin persistir |
| Errores (RNF-17) | Pantallas muestran mensajes genéricos; manejadores de seguridad/errores y filtros de correlación existen | No se capturaron contratos JSON en vivo; errores de páginas no se rastrearon a API sin registro HTTP exportable |

## Configuración HTTP observada

La página de login respondió HTTP 200 por HTTPS con certificado validado por el cliente y HSTS `max-age=63072000; includeSubDomains; preload`. Sondas forzadas a TLS 1.2 y TLS 1.3 respondieron 200. La sonda forzada a TLS 1.0 falló localmente en Windows Schannel, por lo que no prueba si el servidor lo acepta.

En la respuesta revisada no aparecieron `Content-Security-Policy`, `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy` ni `Permissions-Policy`. La ausencia en una respuesta no es una vulnerabilidad confirmada: revisar si Vercel u otra capa agrega controles para otras rutas y decidir política de cabeceras.

El código `SecurityConfig.java` permite GET público a `/swagger-ui.html`, `/swagger-ui/**`, `/v3/api-docs` y `/v3/api-docs/**`. El GET único al OpenAPI productivo agotó 20 s sin bytes; por tanto, la publicación efectiva no se confirmó. Esto contradice la nota existente en `docs/security/RISKS_AND_DECISIONS.md` que describe Swagger como no público por defecto. Verificar y alinear documentación/configuración; no se declara exposición confirmada ni vulnerabilidad por el solo `permitAll`.

## Conclusión

No se confirmó una vulnerabilidad explotable en esta revisión. Se observaron controles funcionales de rutas, configuraciones favorables y brechas de evidencia. Los puntos de seguimiento están en [hallazgos.md](hallazgos.md) y [pruebas-pendientes.md](pruebas-pendientes.md).
