# A1 · Catálogo de RNF aplicables

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Actividad RACI** | «Identificar requisitos no funcionales» — somos **A/R** |
| **Fuente** | SRS de SIGRA (`SIGRA.docx`), sección «Requisitos no funcionales» y Apéndices 4.1 / 4.2 |
| **Entrega** | 1 (Día 5) · se mantiene vivo hasta el cierre |
| **Estado** | **Confirmado contra el SRS** el 7 de noviembre de 2026 |

> **Qué cambió al leer el SRS.** La primera versión de este catálogo se armó a partir de las
> menciones de RNF en el código y los README, y listaba 12 requisitos. El SRS tiene **21**, y nueve
> de los que faltaban son de rendimiento con umbrales numéricos explícitos. Dos consecuencias
> importantes:
>
> - **RNF-18 existe y cubre disponibilidad** (uptime ≥ 95 %, MTTR ≤ 4 h). El hallazgo H-06, que
>   afirmaba que ningún RNF la cubría, quedó **retirado por falso**.
> - El hueco de rendimiento es mucho mayor de lo que se había dicho: no es un requisito sin
>   instrumento, son **nueve**.

---

## 1. Catálogo completo

### 1.1 Rendimiento · RNF-01 a RNF-09 · titular Andrés

Nueve requisitos con umbrales numéricos. **Ninguno tiene hoy instrumento de medición** (hallazgo
[H-02](A4-hallazgos-rnf.md)).

| RNF | Enunciado del SRS | Umbral | Verificable hoy |
| --- | --- | --- | --- |
| **RNF-01** | Soportar hasta 20 usuarios registrados de forma concurrente, cumpliendo los tiempos de RNF-03 a RNF-08 | 20 usuarios | 🔴 no |
| **RNF-02** | Al menos 10 de esos 20 usuarios en lectura y escritura simultánea sin afectar los tiempos establecidos | 10 concurrentes | 🔴 no |
| **RNF-03** | El 95 % de las operaciones de autenticación se completan en menos de 4 s, medido desde el envío del formulario hasta la confirmación de acceso | 95 % < 4 s | 🔴 no |
| **RNF-04** | El 95 % de las operaciones CRUD sobre el catálogo (profesores, programas, asignaturas, RA) se completan en menos de 3 s | 95 % < 3 s | 🔴 no |
| **RNF-05** | El 95 % de los registros de calificación y observación se completan en menos de 3 s por transacción | 95 % < 3 s | 🔴 no |
| **RNF-06** | El 90 % de las consultas de estadísticas descriptivas se generan y muestran en menos de 5 s | 90 % < 5 s | 🔴 no |
| **RNF-07** | Permitir el registro de al menos 50 evaluaciones por asignatura por semestre sin degradación de los tiempos anteriores | 50 evaluaciones | 🔴 no |
| **RNF-08** | El 95 % de las páginas cargan completamente en menos de 3 s con conexión de al menos 5 Mbps, en escritorio y móvil | 95 % < 3 s | 🔴 no |
| **RNF-09** | Mantener los tiempos de RNF-03 a RNF-08 en las consultas de historial durante mínimo 4 meses de operación continua | sostenido 4 meses | 🔴 no |

### 1.2 Seguridad · RNF-10 a RNF-17 · titular José

| RNF | Enunciado del SRS | Verificable hoy | Instrumento |
| --- | --- | --- | --- |
| **RNF-10** | Contraseñas con BCrypt, factor de trabajo mínimo 12, **salt única por contraseña**. Nunca guardadas, registradas ni mostradas en texto plano | 🟢 sí | `AuthServiceImplTest`, `AuthControllerTest` |
| **RNF-11** | En producción, **HTTPS con TLS 1.2 o superior** para credenciales, tokens, datos personales, calificaciones y observaciones | 🔴 no | — (ver [H-10](A4-hallazgos-rnf.md)) |
| **RNF-12** | JWT firmado con HS256 o superior, que incluya **fecha de emisión y de expiración**, y **no contenga** contraseñas ni información académica o personal sensible | 🟢 sí | `JwtServiceTest` |
| **RNF-13** | El servidor valida **firma y vigencia** del JWT antes de atender cada solicitud protegida, y aplica el control de acceso de la Matriz RBAC (Apéndice 4.1). Ocultar opciones en la interfaz no autoriza una operación | 🟢 sí | `PrivateEndpointAuthorizationArchitectureTest`, `SecurityRf05IntegrationIT`, Bruno `seguridad-rf05/` |
| **RNF-14** | **Validar y sanear** los datos recibidos antes de procesarlos o almacenarlos, y emplear consultas parametrizadas o equivalentes contra inyección SQL **y ejecución de contenido no autorizado** | 🟡 parcial | Jakarta Validation + JPA; sin prueba dedicada de saneamiento |
| **RNF-15** | El JWT expira a los 60 minutos como máximo. Vencido, se rechazan las solicitudes protegidas. **Al cerrar sesión, el cliente elimina el token almacenado** | 🟢 sí | `JwtServiceTest`, `JwtAuthenticationFilterTest`, `session.service.spec.ts` |
| **RNF-16** | Auditar autenticaciones **exitosas y fallidas**, y la creación, modificación, activación o inactivación de usuarios, asignaturas, RA, evaluaciones, calificaciones y observaciones. Cada registro con **usuario, fecha y hora, acción y resultado**. Conservación 5 años, *append-only*, no modificable por ningún rol | 🟢 sí | `AuditoriaIntegracionIT`, `AuditoriaAspectTest` |
| **RNF-17** | Los mensajes de error no revelan contraseñas, **tokens completos**, consultas de base de datos, rutas internas, trazas de ejecución ni datos de configuración | 🟢 sí | `HallazgosContratoErrorTest`, `ContratoError*Test`, `GlobalExceptionHandlerTest` |

### 1.3 Disponibilidad · RNF-18 · titular José

| RNF | Enunciado del SRS | Umbral | Verificable hoy |
| --- | --- | --- | --- |
| **RNF-18** | El sistema está disponible (uptime) al menos el 95 % de las veces que se ingresa. Ante una **caída crítica**, el MTTR no supera las **4 horas** desde el reporte o detección hasta el restablecimiento completo | uptime ≥ 95 % · MTTR ≤ 4 h | 🔴 no ([H-09](A4-hallazgos-rnf.md)) |

El SRS define la **clasificación de incidentes** que RNF-18 referencia (sección 3.3.3):

| Severidad | Definición del SRS | Ejemplo |
| --- | --- | --- |
| **Crítica** | Pérdida de datos o caída total del sistema | Caída del servidor, corrupción de la base de datos |
| **Alta** | Falla de una funcionalidad completa, sin afectar el uso general | El módulo de estadísticas no genera resultados |
| **Menor** | Errores de interfaz o comportamientos no bloqueantes | Errores visuales, lentitud puntual |

> ⚠️ **Dos escalas distintas, no confundirlas.** El SRS clasifica **incidentes** en
> Crítica / Alta / Menor. El manual operativo del proyecto clasifica **defectos** en
> Crítica / Alta / Media / Baja (§9.3), y es esa la que manda para el registro de errores y para
> la regla de «crítica y alta bloquean la entrega» (§7).

### 1.4 Compatibilidad · RNF-19 · titular Andrés

| RNF | Enunciado del SRS | Verificable hoy |
| --- | --- | --- |
| **RNF-19** | Operar correctamente en las **últimas 2 versiones de Chrome, Edge y Firefox**, en escritorio y móvil, conforme a la matriz de compatibilidad del Apéndice 4.2 | 🟡 parcial — E2E en Chromium y Firefox, un solo flujo ([H-03](A4-hallazgos-rnf.md)) |

### 1.5 Mantenibilidad · RNF-20 · titular ambos

| RNF | Enunciado del SRS | Verificable hoy |
| --- | --- | --- |
| **RNF-20** | **(a)** Pruebas automatizadas (unitarias y de integración) que cubran al menos el **70 % de la lógica de negocio de los módulos obligatorios**: autenticación (RF-04), control de acceso por rol (RF-05), cálculo de nivel de logro (RF-14) y generación de conclusiones (RF-16). **(b)** Documentación de API con OpenAPI/Swagger, incluyendo **todos los endpoints protegidos y sus códigos de respuesta** (200, 400, 401, 403, 404) | 🟡 parcial — ver abajo |

**Desglose de RNF-20, porque es el único RNF que el proyecto verifica a medias sin saberlo:**

| Parte | Estado | Evidencia |
| --- | --- | --- |
| (a) Cobertura ≥ 70 % global | 🟢 | `build.gradle:99-104`, regla global |
| (a) RF-04 autenticación | 🟢 | Regla por paquete sobre `auth.service*` y `auth.controller` |
| (a) RF-05 control de acceso | 🟢 | Regla por paquete sobre `auth.security` y `config` |
| (a) **RF-14 nivel de logro** | 🔴 | **No está en la lista de paquetes vigilados** ([H-08](A4-hallazgos-rnf.md)) |
| (a) **RF-16 conclusiones** | 🔴 | **No está en la lista de paquetes vigilados** ([H-08](A4-hallazgos-rnf.md)) |
| (b) OpenAPI/Swagger | 🟢 | springdoc 3.1.1 + 10 clases `*ApiDocumentacionIT` |

### 1.6 Accesibilidad · RNF-21 · titular Andrés

| RNF | Enunciado del SRS | Verificable hoy |
| --- | --- | --- |
| **RNF-21** | WCAG 2.1 nivel AA en lo aplicable a una web responsive: **contraste ≥ 4.5:1** entre texto y fondo, **navegación completa por teclado en los formularios de registro de notas y observaciones**, y **etiquetas descriptivas (labels/ARIA) en todos los campos**. La guía de estilos visual debe adoptarse sin afectar estos mínimos | 🔴 no automatizado ([H-04](A4-hallazgos-rnf.md)) |

---

## 2. Resumen de cobertura

> **Actualizado el 15 de noviembre de 2026.** El semáforo vivo, con la evidencia de cada veredicto,
> está en [A6](A6-semaforo-rnf.md). Esta tabla guarda la comparación entre las dos fechas.

Base de 23 criterios: RNF-18 cuenta como dos (uptime y MTTR se verifican distinto) y RNF-20
también (cobertura y OpenAPI).

| Estado | 8-nov | 15-nov | RNF al 15 de noviembre |
| --- | --- | --- | --- |
| 🟢 **Verificado con evidencia** | 7 | **9** | 10, **11**, 12, 13, 15, 16, 17, **20 (a)**, 20 (b) |
| 🟡 **Parcial, con reserva declarada** | 3 | **9** | **01**, **03**, **04**, **06**, **08**, 14, **18 (uptime)**, 19, **21** |
| 🔴 **Sin instrumento o fuera de alcance** | 13 | **5** | 02, 05, 07, 09, 18 (MTTR) |

**Lo que movió la aguja entre las dos fechas:** el producto **ya está desplegado** (backend en
Render, frontend en Vercel), lo que volvió medibles RNF-11 y el uptime de RNF-18; se creó el
instrumento de rendimiento con JMeter; y RNF-20 (a) pasó a cumplir completo al corregir H-08.

**Lo que sigue en rojo, y por qué:** RNF-02, RNF-05 y RNF-07 necesitan datos sembrados (alcanzable
antes del cierre); RNF-09 pide cuatro meses de operación continua, **fuera de la ventana del
proyecto**; y el MTTR de RNF-18 no tiene ninguna caída registrada que medir.

### 2.1 Los cinco atributos que el manual nos exige revisar

| Atributo del §3.5 | RNF del SRS | Estado |
| --- | --- | --- |
| **Seguridad** | 10, 11, 12, 13, 14, 15, 16, 17 | 🟡 Fuerte en autorización, auditoría y errores. Hueco: TLS (H-10) y SCA del backend (H-01) |
| **Rendimiento** | 01, 02, 03, 04, 05, 06, 07, 08, 09 | 🔴 **Ningún instrumento para nueve requisitos** |
| **Disponibilidad** | 18 | 🔴 Requisito claro, sin medición de uptime ni MTTR |
| **Compatibilidad** | 19 | 🟡 Chromium y Firefox automatizados; Edge y móvil, no |
| **Mantenibilidad** | 20 | 🟡 Cobertura vigilada en 2 de los 4 módulos obligatorios |

---

## 3. Aplicabilidad por mantenimiento

Se llena cuando el Product Owner priorice el backlog. Para deducir la columna de RNF, usar la
heurística de la sección 4.

| ID | Mantenimiento | Tipo | Módulos tocados | RNF comprometidos | Titular |
| --- | --- | --- | --- | --- | --- |
| MNT-01 | *(pendiente de priorización)* | | | | |
| MNT-02 | | | | | |
| MNT-03 | | | | | |

**Tipos de mantenimiento según el SRS** (sección «Tipo de mantenimiento»): correctivo, adaptativo,
perfectivo y **evolutivo**. El manual operativo del proyecto habla de correctivo, adaptativo,
perfectivo y **preventivo**. Al clasificar, usar la del manual —es el documento que rige este
proyecto— y anotar la del SRS si hay diferencia.

---

## 4. Heurística: qué toca qué

Si el mantenimiento toca lo de la izquierda, los RNF de la derecha quedan comprometidos **por
defecto** y hay que verificarlos o justificar por qué no aplican.

| Si el mantenimiento toca… | Quedan comprometidos | Revisa |
| --- | --- | --- |
| Un endpoint nuevo o cambia su ruta | **RNF-13**, RNF-20 (b) *(hay que documentarlo en Swagger con sus códigos)* | José |
| El flujo de login | RNF-03, RNF-10, RNF-12, RNF-15, RNF-16, RNF-17 | José |
| `security/`, `SecurityConfig`, guards o `@PreAuthorize` | **RNF-13**, RNF-15, RNF-20 (a) | José |
| `auditoria/` o la tabla de historial | **RNF-16**, RNF-09 | José |
| Cualquier entrada de usuario que se almacene | **RNF-14** *(validar y sanear, no solo parametrizar)* | José |
| Una consulta o agregación de estadísticas | **RNF-06**, RNF-20 (a) *(RF-14 y RF-16 son módulos obligatorios)* | Ambos |
| CRUD del catálogo (profesores, programas, asignaturas, RA) | **RNF-04** | Ambos |
| Registro de calificaciones u observaciones | **RNF-05**, RNF-16, **RNF-21** | Ambos |
| Un `@ControllerAdvice` o un mensaje de error | **RNF-17** (los dos lados) | Ambos |
| Una vista, ruta o formulario del frontend | **RNF-08**, RNF-19, **RNF-21** | Andrés |
| Un formulario de notas u observaciones | **RNF-21** *(es el caso nombrado explícitamente en el SRS)* | Andrés |
| Un badge, estado o indicador visual | **RNF-21** *(el color nunca solo)* | Andrés |
| Agrega una dependencia nueva | Seguridad (SCA) + RNF-08 (tamaño del bundle) | Ambos |
| El esquema de base de datos | RNF-16 si toca auditoría; RNF-18 *(`ddl-auto=validate` impide arrancar si no cuadra)* | José |
| Configuración de despliegue o CORS | **RNF-11**, RNF-18 | José |
| `app.routes.server.ts` o el render mode | RNF-08; y seguridad si prerenderiza una ruta privada | Andrés |

---

## 5. Pendientes de este artefacto

- [x] ~~Leer del SRS el enunciado de RNF-01, RNF-12 y RNF-20~~ — hecho el 7 de noviembre.
- [x] ~~Confirmar si la numeración tiene huecos~~ — no los tiene: son 21 correlativos.
- [ ] Obtener el **Apéndice 4.2** (matriz de compatibilidad de pruebas) para cerrar el criterio de
      RNF-19: define qué navegadores, versiones y dispositivos hay que cubrir.
- [ ] Obtener el **Apéndice 4.1** (Matriz RBAC) en su versión vigente y contrastarla con
      `docs/security/RBAC_MATRIX.md` del frontend, para confirmar que lo implementado coincide con
      lo especificado.
- [ ] Preguntar al Product Owner cómo se va a medir RNF-18 (uptime y MTTR) si no hay entorno de
      producción con monitoreo durante el proyecto.
- [ ] Llenar la tabla de la sección 3 en cuanto exista el backlog priorizado.

---

[Guía del rol](GUIA-TRABAJO-RNF.md) · [A2 Matriz de impacto](A2-matriz-impacto-calidad.md) · [A3 Criterios](A3-criterios-verificacion.md) · [A4 Hallazgos](A4-hallazgos-rnf.md) · [A5 Informe](A5-informe-calidad.md) · [A6 Semáforo](A6-semaforo-rnf.md)
