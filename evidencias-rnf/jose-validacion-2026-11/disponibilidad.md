# Disponibilidad, rendimiento y compatibilidad

## Evidencia anterior reutilizada

`jmeter/resultados/rnf18-render.jtl` tiene 90 respuestas exitosas de `/actuator/health`, en un hilo y durante aproximadamente 208 s. El plan verifica estado 200 y cuerpo `UP`. No estima uptime ≥95 % ni MTTR y no se repitió.

El plan `jmeter/RNF-01-06-rendimiento.jmx` espera 20 usuarios para login/catálogo/estadísticas, pero no se ejecutó: no se acreditó una base PostgreSQL de QA separada de Render/Supabase. Los casos de escritura y 50 evaluaciones necesitan datos sintéticos. No se ejecutaron cargas ni solicitudes de escritura en producción.

## Comprobación nueva, sin carga

- Frontend Vercel: HTTP 200 por HTTPS; certificado validado; TLS 1.2 y 1.3 con 200; HSTS presente. TLS 1.0 inconcluso por error local del cliente Windows Schannel.
- Se intentó un GET único de solo lectura a `/v3/api-docs` del backend y no llegaron bytes en 20 s (`HTTP 000`). No se repitió. Esto no identifica si la causa es arranque en frío, red o servicio y no se cuenta como medición de disponibilidad.
- En la aplicación hubo mensajes genéricos de error en vistas de RA, estudiantes, Estadísticas y reportes del administrador; otras vistas cargaron. Son observaciones puntuales del despliegue, no una serie temporal, y no acreditan una caída total ni un MTTR.
- La página de login y la de materias del estudiante se revisaron en un viewport integrado de 608 × 667 px; ambas sin desbordamiento horizontal observado. No se simuló red de 5 Mbps ni se midió el umbral de 3 s.
- No se usaron Chrome/Edge/Firefox por separado ni dispositivos móviles físicos. CI E2E previa cubre Chromium y Firefox en un flujo y un SHA; no es compatibilidad completa.

## Estado de requisitos

RNF-01–09 siguen sin medición suficiente (RNF-04 tiene controles visuales de búsqueda/paginación, pero no rendimiento de listas extensas). Para RNF-18, uptime y MTTR permanecen sin demostrar. Hace falta una ventana de monitoreo representativa y un ambiente QA aislado aprobado.
