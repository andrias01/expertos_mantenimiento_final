# Línea base y pruebas pendientes

**Auditoría de RNF de SIGRA · José Alejandro Valencia · corte inicial: 15 de noviembre de 2026**

Este registro separa evidencia previa de trabajo pendiente. No se repiten las mediciones previas que siguen siendo útiles; una prueba solo se marcará como ejecutada con una salida reproducible y con su versión y ambiente identificados.

## Evidencia previa que se reutiliza

| Requisito o tema | Evidencia previa | Alcance real | Tratamiento |
| --- | --- | --- | --- |
| RNF-18 uptime | `jmeter/resultados/rnf18-render.jtl`: 90/90 respuestas exitosas de `/actuator/health`, un hilo, ventana aproximada de 208 s; el plan contiene aserciones HTTP 200 y cuerpo `UP` | Sonda breve de Render. No demuestra disponibilidad histórica ≥95 % | Reutilizar; no repetir la misma sonda |
| RNF-20 (a) | A4/A6 reportan 92,39 % global y cobertura de RF-14/RF-16 sobre `d6fa7e1` | Evidencia histórica. No se atribuye a la rama actual hasta comparar el código y el SHA | Contrastar con HEAD actual antes de aceptar el veredicto verde |
| RNF-20 (b) y seguridad | A3/A6 citan pruebas `*ApiDocumentacionIT`, seguridad y auditoría | La existencia de una clase de prueba no acredita que se haya ejecutado. La corrida backend #199 para `c1b1950` ejecuta `clean test jacocoTestCoverageVerification`; el job llamado “integración” no invoca `integrationTest` | Conservar como evidencia unitaria donde aplique; clasificar por separado las pruebas de integración no ejecutadas |
| RNF-19 frontend | Corrida frontend #72, SHA `9a5fa537708fb711318a9b353c481289299c7240`, con Playwright sin omisiones | E2E de esa combinación versionada, con un solo flujo de autenticación; no equivale a producción ni a cobertura de todos los módulos | Reutilizar y complementar con navegación real cuando la cuenta autorizada esté activa |
| SCA backend | En la CI #199 los trabajos Dependency Review y OWASP Dependency-Check aparecen `SKIPPED` | `SKIPPED` no es PASS ni auditoría | Mantener abierto H-01; solicitar configuración al administrador del repositorio |

## Pendientes de ejecución o comprobación

| ID | Prueba o verificación pendiente | RNF | Ambiente seguro | Estado inicial / condición |
| --- | --- | --- | --- | --- |
| P-01 | Carga inicial sin autenticación: URL, redirecciones, HTTPS/certificado, errores visibles, solicitudes normales, consola, cabeceras y viewport responsive | 11, 17, 19, 21 | Vercel, navegador integrado | Ejecutada el 15-nov-2026; hallazgos de alcance limitado en “Observación sin autenticación” |
| P-02 | Recorrido de módulos, permisos visibles, deep links, atrás/F5, estados y logout por rol | 13, 15, 17, 19, 21 | Vercel; cuentas autorizadas | Ejecutado para ADMINISTRADOR, PROFESOR y ESTUDIANTE; limitaciones y rutas en los informes de navegador |
| P-03 | Validación real de login/logout, persistencia y eliminación de sesión en el cliente | 12, 15 | Vercel, navegador integrado | Login y logout observados para los tres roles; rutas privadas volvieron al login tras cerrar sesión. La inspección directa del almacén de navegador no está disponible en el evaluador, por lo que no se leyó ni se verificó la eliminación del token en almacenamiento |
| P-04 | TLS y cabeceras HTTP de la aplicación frontend de Vercel | 11 | Vercel | Parcial: TLS 1.2 y 1.3 negociaron con respuesta 200; la sonda TLS 1.0 falló en Schannel del cliente, así que no permite inferir soporte del servidor. HSTS presente. El muestreo no halló CSP ni varias cabeceras de endurecimiento; revisar configuración antes de puntuar |
| P-05 | Contrastar matriz RBAC con Apéndice 4.1 y compatibilidad con Apéndice 4.2 | 13, 19 | Documentación SRS | Bloqueado: los apéndices no aparecen en el repositorio de mantenimiento ni en los documentos de Entrega 1 disponibles |
| P-06 | Inspección de validación/saneamiento de entradas, parametrización, HTML confiable y mensajes de error | 14, 17 | Código local de solo lectura y navegador | Inspección estática parcial: hay `@Valid`/restricciones Jakarta y uso de JPA; no se ejecutaron pruebas de inyección/XSS ni pruebas de saneamiento. No realizar ataques contra producción |
| P-07 | Verificar autorización negativa por recurso y respuestas 401/403 desde el backend | 13 | QA local aislado | Las rutas del frontend cruzadas entre roles devolvieron 403 y una ruta privada sin sesión redirigió al login; respuestas de endpoints backend no comprobadas. No manipular IDs en producción |
| P-08 | Verificar token vencido, logout y acceso posterior a rutas privadas | 12, 15 | QA local; navegador para logout | Logout y bloqueo posterior de rutas observados; persistencia tras F5 observada en ADMINISTRADOR. Expiración máxima de 60 minutos no se esperó ni verificó en vivo |
| P-09 | Confirmar eventos de auditoría, campos requeridos, cobertura de eventos fallidos y rechazo real de UPDATE/DELETE | 16 | QA local aislado | Pantalla de auditoría de ADMINISTRADOR carga y se declara de solo lectura; no se alteraron eventos ni se probó la base. CI #199 no invoca `integrationTest` |
| P-10 | Verificar cobertura y umbral de los cuatro módulos obligatorios sobre el SHA actual | 20 (a) | Backend local, salidas en `build/` ignorado | Inspección confirmó que `build.gradle` en HEAD `c1b1950` no incluye `estadisticas` en reglas por paquete; el commit `d6fa7e1` no está en el clon. No se atribuye el 92,39 % histórico a HEAD actual |
| P-11 | Contrato OpenAPI de todos los endpoints protegidos y códigos requeridos | 20 (b) | QA/local | Existen clases `*ApiDocumentacionIT`, pero CI #199 no invoca `integrationTest`; GET único a `/v3/api-docs` agotó 20 s sin bytes. Publicación y respuestas del contrato siguen sin verificar |
| P-12 | Medición de JMeter para 20 usuarios, login, catálogo y estadísticas | 01, 03, 04, 06 | Backend local + PostgreSQL local aislado | Pendiente y bloqueada hasta demostrar aislamiento. El plan advierte que la configuración habitual apunta a la base compartida; no cargar Render ni Supabase |
| P-13 | Carga de lectura/escritura, registros de calificación y 50 evaluaciones por asignatura | 02, 05, 07 | QA local aislado con datos sintéticos | Pendiente; requiere sembrar datos y probar escrituras exclusivamente en QA |
| P-14 | Medición de renderizado de páginas bajo 5 Mbps, escritorio/móvil; comprobación manual de teclado, labels y contraste | 08, 21 | Navegador integrado / emulación local | Inspección a 608 × 667 px sin desbordamiento horizontal en login y pantalla ESTUDIANTE. No se midieron 5 Mbps, tiempos de renderizado, teclado completo ni contraste |
| P-15 | Compatibilidad con las dos últimas versiones de Chrome, Edge y Firefox en escritorio/móvil | 19 | Navegadores de prueba / QA | Navegación de roles en un solo navegador integrado. E2E previo cubre Chromium y Firefox, un flujo y un SHA; Apéndice 4.2 ausente |
| P-16 | Disponibilidad sostenida y MTTR | 18 | Monitoreo operativo / registros de incidentes | No repetir sonda breve. Uptime requiere ventana representativa; MTTR queda “sin evento que medir”. Los errores de pantalla observados no prueban caída total ni tiempos de recuperación |
| P-17 | Mantenibilidad adicional (SonarQube/SonarCloud) | 20, transversal | Local o CI | No ejecutar hasta resolver Docker local o permisos de token; RNF-20 exige cobertura y OpenAPI, no Sonar |
| P-18 | Reproducibilidad del build frontend en local | 08, 20 | Frontend local | Evidencia previa reporta Node `v24.11.0`, por debajo del mínimo de Angular CLI. No repetir build sin verificar versión/runtime primero |

## Inconsistencias de línea base que deben resolverse con evidencia

- A5/A6 registran 9 criterios verdes, 9 amarillos y 5 rojos (23 criterios). El acta preparada de la reunión 3 afirma “pasamos de 7 a 10” y de “11 sin instrumento a 4” y cuenta 21 RNF. El acta está marcada como preparada antes de la reunión; se conserva la cifra de A5/A6 como antecedente hasta validar cada criterio, sin reemplazar cifras silenciosamente.
- A4/A6 y la bitácora declaran H-08 corregido en `d6fa7e1`, pero el backend local se encuentra en `c1b1950` y la rama comprobada debe compararse antes de aceptar ese cierre. La CI #199 corresponde a `c1b1950`; no se le atribuirá el resultado de otro SHA.
- El conjunto disponible no contiene el SRS completo `SIGRA.docx` ni los Apéndices 4.1/4.2; solo contiene documentos de Entrega 1 y el libro de seguimiento. Por tanto, no se podrá cerrar la trazabilidad exacta con esos apéndices hasta obtenerlos.
- La incidencia Mantis 0000053 se describe como intermitente, pero su causa no está confirmada. La relación con concurrencia es una hipótesis; no se afirmará que 20 hilos la hagan determinista sin reproducirla en QA y registrar frecuencia y solicitudes.

## Observación sin autenticación · 15 de noviembre de 2026

- URL observada: `https://sigra.vercel.app/login`; carga visible y permanece en el mismo origen/ruta, sin redirección observada. Respuesta HTTP 200; certificado validado por el cliente Windows. HSTS presente (`max-age=63072000; includeSubDomains; preload`). Sondas forzadas a TLS 1.2 y TLS 1.3 devolvieron HTTP 200. La sonda forzada a TLS 1.0 terminó con error local de Schannel (`SEC_E_UNSUPPORTED_FUNCTION`); resultado inconcluso sobre la configuración del servidor.
- En la respuesta revisada no se observaron `Content-Security-Policy`, `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy` ni `Permissions-Policy`. Es una observación de cabeceras, no una vulnerabilidad confirmada. Revisar si hay controles equivalentes en otra capa antes de concluir.
- Consola integrada: sin entradas `error` o `warn` en la revisión. Recursos observados: un CSS y el bundle JS principales del sitio. No se registraron valores de cookies, tokens, datos personales ni cuerpos de solicitud.
- En el viewport disponible de 608 × 667 px el formulario y panel visual se observan sin desbordamiento horizontal; la página tiene desplazamiento vertical. No se inspeccionaron breakpoints adicionales ni dispositivos reales.
- La pantalla muestra campos de correo institucional y contraseña, casilla para mostrar contraseña, botón de inicio de sesión y la indicación de máximo de 72 bytes UTF-8. Se solicita al usuario iniciar sesión con una cuenta autorizada de ADMINISTRADOR para continuar; no se recogieron credenciales.

## Recorrido autenticado · 15 de noviembre de 2026

- ADMINISTRADOR: `/admin/catalogo`, `/admin/semestres`, `/admin/ra`, `/admin/asignacion`, `/admin/estudiantes`, `/admin/matricula`, `/admin/auditoria`, `/admin/reportes`; navegación Atrás/Adelante preservó la ruta y F5 mantuvo la sesión. Una ruta `/admin/catalogo` sin sesión redirigió al login. Véase [navegador-administrador.md](navegador-administrador.md).
- PROFESOR: `/profesor/asignaturas`, `/profesor/matricula`, `/profesor/evaluaciones`, `/profesor/notas`, `/profesor/estadisticas`, `/profesor/reportes`, `/profesor/historial`; `/admin/auditoria` mostró 403. Logout volvió al login. Véase [navegador-profesor.md](navegador-profesor.md).
- ESTUDIANTE: `/estudiante/materias` y `/estudiante/progreso`; la ruta `/profesor/asignaturas` mostró 403. Logout volvió al login y una ruta privada redirigió al login. Véase [navegador-estudiante.md](navegador-estudiante.md).
- No se seleccionaron estudiantes, calificaciones ni IDs de registros; no se enviaron formularios ni se modificaron datos. Las capturas no se incorporan porque las pantallas con información académica contienen datos identificables y no se dispone de una ruta de captura local con redacción comprobable. El navegador integrado no expuso un registro de solicitudes HTTP exportable; no se guardaron tokens ni cookies.
- En recorridos de los tres roles, el registro consultado de consola no tenía entradas `error` ni `warn`.

## Orden inmediato

1. Conservar la revisión anónima del login como evidencia acotada; completar la validación de cabeceras/TLS con la configuración del servidor cuando exista acceso de solo lectura.
2. Solicitar al usuario iniciar sesión con una cuenta autorizada de rol ADMINISTRADOR; completar el recorrido de ese rol antes de cambiar de cuenta.
3. Pedir después las cuentas PROFESOR y ESTUDIANTE, una a la vez, y repetir los recorridos pertinentes.
4. Reanudar las pruebas locales solo cuando esté demostrada la separación de la base QA respecto de Supabase/Render.
