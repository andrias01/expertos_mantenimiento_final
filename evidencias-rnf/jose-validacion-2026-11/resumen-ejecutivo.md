# Resumen ejecutivo · validación integral RNF

**Corte:** 15 de noviembre de 2026 · **Responsable:** José Alejandro Valencia
**Resultado:** revisión complementaria; no se declara cumplimiento completo de ningún RNF basándose solo en esta auditoría.

## Qué se reutilizó y qué se hizo

Se reutilizaron las 90 sondas de salud, la cobertura histórica sobre otro SHA, la CI backend #199, la CI frontend #72 y las incidencias Mantis existentes. No se repitieron pruebas equivalentes ni se cargó producción.

Como evidencia nueva se revisó el login sin autenticación, se recorrieron los módulos visibles con ADMINISTRADOR, PROFESOR y ESTUDIANTE, se comprobaron dos rutas cruzadas (403), logout y rutas privadas tras logout, se observó HSTS/TLS en Vercel y se inspeccionaron los controles de seguridad y la regla JaCoCo en el código local. Véanse [línea base](linea-base.md), [navegador ADMINISTRADOR](navegador-administrador.md), [navegador PROFESOR](navegador-profesor.md), [navegador ESTUDIANTE](navegador-estudiante.md), [seguridad](seguridad.md), [disponibilidad](disponibilidad.md), [mantenibilidad](mantenibilidad.md) y [hallazgos](hallazgos.md).

## Semáforo de 23 criterios / 21 RNF

| RNF | Prueba | Evidencia previa | Evidencia nueva | Resultado actual | Hallazgo / límite |
| --- | --- | --- | --- | --- | --- |
| 01 | 20 usuarios concurrentes | JMeter preparado; sin corrida QA | Ninguna carga | Pendiente | QA aislado no demostrado |
| 02 | 10 lecturas/escrituras simultáneas | Sin instrumento completo | No se hicieron escrituras | Pendiente | Requiere dataset sintético QA |
| 03 | 95 % login <4 s | Aserción JMeter preparada | Login real sin cronometraje de protocolo | Pendiente | No sustituye percentiles |
| 04 | 95 % CRUD catálogo <3 s | Plan JMeter; H-02 | Controles de búsqueda/filtro visibles | Parcial | No se midieron tiempos ni listas de 500 |
| 05 | 95 % calificaciones <3 s | Sin dataset/prueba válida | No se registraron notas | Pendiente | QA con evaluación y matrícula |
| 06 | 90 % estadísticas <5 s | Plan preparado | Estadísticas de PROFESOR mostró error genérico | No cumple evidencia | OBS-01; sin medición de tiempo |
| 07 | 50 evaluaciones sin degradación | Sin instrumento | No se crearon evaluaciones | Pendiente | No sembrar producción |
| 08 | 95 % páginas <3 s a 5 Mbps escritorio/móvil | Bundle 356,04 kB; no tiempo real | 608×667 sin overflow horizontal en dos pantallas | Parcial | Falta red limitada y tiempos |
| 09 | Rendimiento sostenido 4 meses | Sin ventana de 4 meses | Ninguna | Pendiente/fuera de ventana | Decisión de proyecto; falta historial suficiente |
| 10 | BCrypt ≥12, salt única, no texto plano | Pruebas previas de Auth | Código actual usa BCrypt(12); no se inspeccionaron credenciales | Parcial | No se midió coste/sal ni almacenamiento real |
| 11 | HTTPS TLS ≥1.2 | Sonda anterior en Render | Vercel: 200 sobre TLS 1.2/1.3; certificado validado y HSTS | Parcial | TLS 1.0 inconcluso; backend/schema no verificados en esta prueba |
| 12 | JWT HS256+, iat/exp sin datos sensibles | JwtServiceTest previo | Login y sesión por rol sin leer token | Parcial | No se inspeccionó token en vivo |
| 13 | Firma/vigencia + RBAC del Apéndice 4.1 | Tests de arquitectura/integración previos | 403 en rutas cruzadas; ruta privada sin sesión redirige | Parcial | Backend endpoints y Apéndice 4.1 pendientes |
| 14 | Validar/sanear entrada y parametrizar | Jakarta Validation + JPA | Inspección estática parcial, sin ataque ni prueba de saneamiento | Parcial | Falta prueba de XSS/SQLi en QA |
| 15 | Expira ≤60 min y token se elimina al salir | Tests previos de JWT/session | Logout volvió al login; F5 conservó sesión antes de logout | Parcial | Expiración/storage no inspeccionados directamente |
| 16 | Auditoría de eventos por 5 años, append-only | Tests de auditoría previos | UI admin carga y se declara solo lectura | Parcial | No se probó persistencia o UPDATE/DELETE en DB; fallo de auditoría no fatal en el aspecto |
| 17 | Errores sin datos sensibles | Tests de contrato previos | Mensajes genéricos; no se vieron errores de consola | Parcial | No se capturaron respuestas API; OBS-01 |
| 18 uptime | ≥95 % | 90/90 health en ~208 s, un hilo | Sin serie temporal nueva; pantallas con fallos puntuales | No demostrado | La sonda no acredita ventana operativa |
| 18 MTTR | ≤4 h ante caída crítica | Sin incidentes medibles | No se midió incidente/restauración | Pendiente | Requiere bitácora operacional |
| 19 | Últimas 2 versiones Chrome/Edge/Firefox escritorio/móvil | E2E Chromium/Firefox, un flujo/sha | Solo navegador integrado, viewport 608×667 | Parcial | Apéndice 4.2 y navegadores/dispositivos faltan |
| 20(a) | ≥70 % en RF-04/05/14/16 | A6 cita 92,39 % sobre `d6fa7e1` | `c1b1950` no regla por paquete `estadisticas`; CI #199 no corre integración | No verificable por módulo en HEAD inspeccionado | H-08 sigue abierto para esta rama; no se midió cobertura actual de RF-14/16 |
| 20(b) | OpenAPI todos endpoints/códigos | springdoc + 10 clases `*ApiDocumentacionIT` | GET productivo agotó 20 s; clase no ejecutada por CI #199 | No verificado | Reconciliar `permitAll` con la documentación de riesgos |
| 21 | WCAG AA, teclado, labels, contraste | UI revisada manualmente antes; sin automatización | Labels observados; sin contraste/teclado completo | Pendiente | Apéndice 4.2 y pruebas WCAG faltan |

## Prioridades y decisiones

1. **Desarrollo/operaciones:** reproducir OBS-01 en QA y correlacionar respuestas con IDs de solicitud del lado servidor; no atribuir causa a concurrencia.
2. **Mantenedores backend:** añadir verificación de RF-14/RF-16 al build de la rama actual y publicar cobertura por SHA; ejecutar integraciones contra QA aislado.
3. **Operaciones/seguridad:** confirmar la política para Swagger y cabeceras HTTP; resolver la discrepancia entre `permitAll` y “Swagger privado por defecto”.
4. **Equipo del proyecto/PO:** aportar SRS y Apéndices 4.1/4.2, definir ventana de disponibilidad y aceptar/rechazar la situación de pantallas en construcción.
5. **QA:** preparar PostgreSQL QA con datos sintéticos y plan aprobado antes de JMeter, pruebas negativas API, persistencia, expiración o verificaciones que escriban.

No se cambió backend/frontend ni se realizó merge. La rama y los cambios del repositorio de mantenimiento se publicarán para revisión en PR, sin auto-merge.
