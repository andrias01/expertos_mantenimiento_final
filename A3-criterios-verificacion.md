# A3 · Criterios de verificación de RNF

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Actividad RACI** | «Verificar requisitos no funcionales» — somos **A/R** |
| **Filtros** | Alimenta **F2** (criterios definidos) y **F4** (pruebas ejecutadas) |
| **Fuente de los enunciados** | SRS de SIGRA, sección «Requisitos no funcionales» |
| **Entrega** | 1 (Día 5), se refina en la 2, se ejecuta para la 3 |

> **La regla.** Un criterio sirve solo si otra persona lo puede ejecutar y obtener el mismo
> veredicto. Cada uno trae **comando**, **umbral** y **evidencia**. Si no se puede ejecutar, no es
> un criterio: es una intención.
>
> **Para F4.** Estos criterios tienen que estar en manos de los analistas de prueba **cuando
> diseñan sus casos**, no cuando ya ejecutaron. Si llegan después, se vuelven trabajo extra y no
> se corren.

---

## 0. Balance, para decirlo de entrada

| Estado | Cantidad | RNF |
| --- | --- | --- |
| 🟢 **Ejecutable hoy, sin trabajo adicional** | 7 | 10, 12, 13, 15, 16, 17, 20 (b) |
| 🟡 **Ejecutable con reservas que hay que declarar** | 3 | 14, 19, 20 (a) |
| 🟠 **Necesita una decisión del equipo primero** | 2 | 21, 11 |
| 🔴 **No verificable en el alcance de 15 días** | 9 | 01 a 09 (rendimiento) |

**De 21 requisitos no funcionales, 7 se verifican hoy y 9 no tienen cómo verificarse.** Esa es la
cifra que hay que llevar a la reunión del 8, y la razón por la que el rendimiento es el tema
central del diagnóstico.

---

## 1. Seguridad · RNF-10 a RNF-17 · titular José

### RNF-10 · Contraseñas con BCrypt factor ≥ 12 y salt única · 🟢

| | |
| --- | --- |
| **Criterio** | Ninguna respuesta de la API contiene el campo de contraseña ni el hash. El hash se genera con BCrypt, factor ≥ 12, con salt única por contraseña. En ningún caso se registra en logs. |
| **Comando** | `./gradlew test --tests '*AuthServiceImplTest' --tests '*AuthControllerTest'` |
| **Umbral** | Pruebas en verde. Cero ocurrencias de `$2a$` / `$2b$` en cualquier cuerpo de respuesta. Dos contraseñas iguales producen hashes distintos (salt única). |
| **Evidencia** | Salida del comando en el PR. |
| **Al revisar un PR** | Si agrega un DTO de respuesta que incluya un `Usuario`, confirmar que no arrastre el campo de contraseña por serialización. |

### RNF-11 · HTTPS con TLS 1.2+ en producción · 🟠

| | |
| --- | --- |
| **Criterio pleno** | El entorno de producción sirve por HTTPS con TLS 1.2 o superior. |
| **Estado** | **No verificable en el alcance**: no hay entorno de producción en operación ([H-10](A4-hallazgos-rnf.md)). |
| **Criterio sustituto, ejecutable hoy** | Ningún archivo del frontend construye una URL `http://` hacia el backend fuera de los entornos de desarrollo; todos los servicios leen de `environment.apiUrl`. |
| **Comando** | `grep -rn "http://" software4-SIGRA-frontend/src --include=*.ts \| grep -v environment.development` |
| **Umbral** | Cero resultados que apunten al backend. |
| **Evidencia** | Salida del comando. |
| **Qué declarar en el informe** | Que la verificación plena requiere el entorno de producción, y que lo verificado es la ausencia de URLs absolutas insegurasen el código. |

### RNF-12 · JWT HS256+ con emisión y expiración, sin datos sensibles · 🟢

| | |
| --- | --- |
| **Criterio** | El token se firma con HS256 o superior, incluye los claims de emisión (`iat`) y expiración (`exp`), y **no contiene** contraseñas ni información académica o personal sensible. |
| **Comando** | `./gradlew test --tests '*JwtServiceTest'` |
| **Umbral** | Prueba en verde. Al decodificar el *payload* de un token emitido, los claims presentes son los necesarios para identificar al usuario y su rol — nada de notas, documentos ni datos personales. |
| **Evidencia** | Salida del comando, y el *payload* decodificado de un token de prueba. |
| **Al revisar un PR** | Si un mantenimiento agrega un claim al token, verificar que no sea información académica. Es la forma más fácil de romper RNF-12 sin darse cuenta. |

### RNF-13 · Validación del token y control de acceso RBAC · 🟢 el criterio más fuerte que tenemos

| | |
| --- | --- |
| **Criterio** | El servidor valida firma y vigencia del JWT antes de atender cada solicitud protegida. Toda ruta privada declara autorización explícita; ninguna queda solo detrás de `authenticated()`. Un rol sin permiso recibe `403`; sin token, `401`. El alcance por recurso se respeta: el profesor solo opera sobre sus asignaturas y el estudiante solo ve lo propio. |
| **Comando** | `./gradlew test --tests '*PrivateEndpointAuthorizationArchitectureTest'`<br>`./gradlew integrationTest --tests '*SecurityRf05IntegrationIT'`<br>Bruno: colección `seguridad-rf05/` (casos 401, 403 y alcance por rol) |
| **Umbral** | Las tres en verde. |
| **Evidencia** | Salida de los comandos; para endpoints nuevos, el caso Bruno correspondiente. |
| **Por qué es el mejor criterio del catálogo** | `PrivateEndpointAuthorizationArchitectureTest` recorre el **registro real de Spring MVC**, así que un endpoint nuevo sin `@PreAuthorize` la pone roja sola. No depende de que alguien se acuerde de escribir una prueba por endpoint: cubre los futuros. |
| **Pendiente** | Contrastar la Matriz RBAC implementada (`docs/security/RBAC_MATRIX.md`) contra el **Apéndice 4.1 del SRS**. Si difieren, es un hallazgo de RNF-13. |

### RNF-14 · Validar y sanear la entrada · 🟡

| | |
| --- | --- |
| **Criterio** | Toda entrada se valida antes de procesarse o almacenarse. Ninguna consulta construye SQL o JPQL por concatenación de entrada del usuario. El contenido almacenado no puede ejecutarse al mostrarse. |
| **Comando** | `grep -rnE '(createQuery\|createNativeQuery).*\+' software4-SIGRA-backend/SIGRA/src/main/java/`<br>`grep -rn '@Query' software4-SIGRA-backend/SIGRA/src/main/java/` → revisar que usen `:parametro`<br>`grep -rn 'innerHTML\|bypassSecurityTrust' software4-SIGRA-frontend/src --include=*.ts` |
| **Umbral** | Cero resultados en el primero y el tercero. En el segundo, cero `@Query` con concatenación. |
| **Evidencia** | Salida de los comandos, pegada en el PR. |
| **Reserva que hay que declarar** | **No hay prueba automatizada de saneamiento.** RNF-14 menciona «ejecución de contenido no autorizado» —es decir, XSS— y eso no está cubierto por ninguna prueba: Angular escapa por defecto, pero un `bypassSecurityTrustHtml` en un mantenibilidad futuro lo rompería sin que nada falle. El criterio es por inspección en F2. |

### RNF-15 · Expiración del token y cierre de sesión · 🟢

| | |
| --- | --- |
| **Criterio** | El JWT expira a los 60 minutos como máximo. Vencido, las solicitudes protegidas se rechazan con `401`. Al cerrar sesión, el cliente elimina el token almacenado. |
| **Comando** | Backend: `./gradlew test --tests '*JwtServiceTest' --tests '*JwtAuthenticationFilterTest'`<br>Frontend: `npx ng test --no-watch` (cubre `session.service.spec.ts`, `sesion.spec.ts`, `interceptors.spec.ts`) |
| **Umbral** | Todas en verde. `JWT_EXPIRATION_MS` ≤ 3600000. |
| **Evidencia** | Salida de los dos comandos. |

### RNF-16 · Historial de auditoría append-only · 🟢

| | |
| --- | --- |
| **Criterio** | Se auditan las autenticaciones **exitosas y fallidas**, y la creación, modificación, activación e inactivación de usuarios, asignaturas, RA, evaluaciones, calificaciones y observaciones. Cada registro incluye **usuario, fecha y hora, acción y resultado**. La tabla no admite `UPDATE` ni `DELETE` por ningún rol. |
| **Comando** | `./gradlew integrationTest --tests '*AuditoriaIntegracionIT'`<br>`./gradlew test --tests '*AuditoriaAspectTest'`<br>Verificación directa: `psql ... -c "UPDATE sigra.<tabla_auditoria> SET ..."` debe **fallar** |
| **Umbral** | Pruebas en verde. El `UPDATE` manual devuelve error de permiso o de regla. Los cuatro campos mínimos están presentes en cada registro. |
| **Evidencia** | Salida de las pruebas y del `psql` mostrando el rechazo. |
| **Ojo al verificar** | Que el `UPDATE` no afecte filas **no** demuestra que esté bloqueado: puede ser que el `WHERE` no casó. El criterio exige que la operación sea **rechazada**. |
| **Lo que más se olvida** | El SRS exige auditar las autenticaciones **fallidas**, no solo las exitosas. Vale confirmarlo explícitamente. |

### RNF-17 · Los errores no exponen detalles técnicos · 🟢

| | |
| --- | --- |
| **Criterio** | Ningún campo de ninguna respuesta de error contiene contraseñas, **tokens completos**, consultas de base de datos, rutas internas, trazas de ejecución ni datos de configuración. En el frontend, el mensaje se decide por el status HTTP y nunca se muestra el cuerpo de la respuesta. |
| **Comando** | Backend: `./gradlew test --tests '*HallazgosContratoErrorTest' --tests '*ContratoError*' --tests '*GlobalExceptionHandlerTest'`<br>Frontend: `npx ng test --no-watch` (cubre `login-error.spec.ts`, `mensaje-de-error.spec.ts`, `estudiante-error.spec.ts`) |
| **Umbral** | Todas en verde. |
| **Evidencia** | Salida de los dos comandos. |
| **Al revisar un PR** | Si agrega un `@ControllerAdvice` de módulo, verificar que **no** declare un método para `Exception.class` — eso lo atiende el manejador global, y declararlo en un módulo crea un empate de precedencia. Ya pasó: es el H-02 de `scripts_andres/hallazgos-manejo-errores.md`. |

---

## 2. Rendimiento · RNF-01 a RNF-09 · titular Andrés · 🔴

**Ninguno de los nueve tiene instrumento** ([H-02](A4-hallazgos-rnf.md)). Esta sección no lista
criterios ejecutables porque no existen todavía: lista lo que **se puede** hacer en 15 días y lo
que hay que **declarar fuera de alcance**.

### Lo que el SRS exige

| RNF | Umbral | ¿Alcanzable en 15 días? |
| --- | --- | --- |
| RNF-01 | 20 usuarios concurrentes | ❌ Requiere herramienta de carga |
| RNF-02 | 10 en lectura/escritura simultánea | ❌ Requiere herramienta de carga |
| RNF-03 | 95 % de autenticaciones < 4 s | 🟡 Medición manual con muestra pequeña |
| RNF-04 | 95 % de CRUD de catálogo < 3 s | 🟡 Medición manual con muestra pequeña |
| RNF-05 | 95 % de registros de calificación < 3 s | 🟡 Medición manual con muestra pequeña |
| RNF-06 | 90 % de estadísticas < 5 s | 🟡 Medición manual con muestra pequeña |
| RNF-07 | 50 evaluaciones por asignatura/semestre | 🟡 Verificable con datos de prueba |
| RNF-08 | 95 % de páginas < 3 s con ≥ 5 Mbps | 🟡 Presupuesto de bundle + medición manual |
| RNF-09 | Sostenido 4 meses | ❌ Fuera de la ventana del proyecto |

### Alcance propuesto, en orden de costo

**1 · Presupuesto de bundle (preventivo, RNF-08)**

| | |
| --- | --- |
| **Criterio** | El bundle inicial no supera el presupuesto declarado. |
| **Comando** | `npx ng build` con `budgets` en `angular.json` |
| **Umbral** | **Medir primero el valor actual** y fijar el tope apenas por encima, para que detecte crecimiento sin romper el build de entrada. |
| **Evidencia** | Salida de `ng build` con la tabla de tamaños y el presupuesto evaluado. |
| **Por qué primero** | Es lo único de esta lista que **previene regresiones** en lugar de solo medir el estado actual. |

**2 · Medición manual de tiempos (RNF-03 a RNF-06)**

| | |
| --- | --- |
| **Criterio** | Sobre los flujos tocados por cada mantenimiento, el tiempo observado cumple el umbral del RNF correspondiente. |
| **Método** | Panel de red del navegador (o `curl -w "%{time_total}"` para la API), 10 repeticiones por operación, con el backend y PostgreSQL locales. |
| **Umbral** | El del RNF: < 4 s autenticación, < 3 s CRUD y calificaciones, < 5 s estadísticas. |
| **Evidencia** | Tabla de mediciones con las 10 muestras y captura del panel. |
| **Reserva obligatoria en el informe** | Una muestra de 10 en local **no demuestra el percentil 95 con 20 usuarios concurrentes**. Lo que demuestra es que el orden de magnitud es correcto y que el mantenimiento no degradó el tiempo. Hay que escribirlo con esas palabras. |

**3 · Verificación de volumen (RNF-07)**

| | |
| --- | --- |
| **Criterio** | Con 50 evaluaciones registradas en una asignatura y semestre, los tiempos de RNF-04 a RNF-06 se mantienen. |
| **Método** | Sembrar 50 evaluaciones con los seeds de Bruno y repetir la medición del punto 2. |
| **Evidencia** | Script de siembra y tabla comparativa antes/después. |

**4 · Declarar fuera de alcance, con justificación (RNF-01, 02, 09)**

Veinte usuarios concurrentes, diez simultáneos en lectura y escritura, y cuatro meses de operación
continua **no se pueden verificar** sin herramienta de carga y sin entorno de producción. Se
declara así en [A5](A5-informe-calidad.md), con decisión de tratamiento, que es lo que el §7 exige
para lo que no se corrige. Un «fuera de alcance» justificado cumple; un silencio, no.

---

## 3. Disponibilidad · RNF-18 · titular José · 🟠

| | |
| --- | --- |
| **Criterio pleno** | Uptime ≥ 95 % de las veces que se ingresa a la aplicación; MTTR ≤ 4 h ante caída crítica. |
| **Estado** | **No verificable en el alcance**: sin entorno en operación y sin monitoreo ([H-09](A4-hallazgos-rnf.md)). |
| **Criterio sustituto, ejecutable hoy** | **(a)** El backend arranca con el esquema validado y `/actuator/health` responde `UP`. **(b)** Con el backend caído, el frontend muestra el mensaje de usuario definido, no una pantalla en blanco ni una traza. |
| **Comando** | (a) `curl --fail http://localhost:8080/actuator/health`<br>(b) `npx ng test --no-watch` cubre el status `0` en `login-error.spec.ts`; el smoke SSR del CI valida la contingencia de API |
| **Umbral** | (a) `{"status":"UP"}`. (b) Mensaje «No fue posible conectar con el servidor. Verifica tu conexión e intenta nuevamente.» |
| **Evidencia** | Salida del `curl` y de las pruebas. |
| **Decisión pendiente** | Llevar a la reunión del 8: ¿se declara RNF-18 fuera de alcance, o se acepta el criterio sustituto como verificación parcial? Lo decide el Product Owner. |

---

## 4. Compatibilidad · RNF-19 · titular Andrés · 🟡

| | |
| --- | --- |
| **Criterio** | Los flujos tocados funcionan en las dos últimas versiones de Chrome, Edge y Firefox, en escritorio y móvil. |
| **Comando** | `npm run e2e` (Playwright, Chromium y Firefox, contra backend real) |
| **Umbral** | Suite en verde en ambos navegadores. |
| **Evidencia** | Reporte de Playwright, que el CI publica como artefacto (`sigra-e2e-<run_id>`). |
| **Reservas que hay que declarar** | **(1)** La suite solo recorre el login ([H-03](A4-hallazgos-rnf.md)). **(2)** **Edge no se prueba automáticamente**: Chromium es un sustituto razonable por compartir motor, pero hay que decirlo así, no afirmar que Edge está probado. **(3)** Móvil no se prueba automáticamente; se verifica con el emulador de dispositivo del navegador y captura. |
| **Pendiente** | Obtener el **Apéndice 4.2** del SRS (matriz de compatibilidad de pruebas) para fijar qué versiones y dispositivos hay que cubrir exactamente. Sin él, el alcance de RNF-19 lo estamos suponiendo. |

---

## 5. Mantenibilidad · RNF-20 · titular ambos

RNF-20 tiene dos partes y hay que verificarlas por separado.

### RNF-20 (a) · Cobertura ≥ 70 % de los módulos obligatorios · 🟡

| | |
| --- | --- |
| **Criterio** | La cobertura no baja del 70 % ni globalmente ni en **ninguno de los cuatro módulos obligatorios**: autenticación (RF-04), control de acceso por rol (RF-05), cálculo de nivel de logro (RF-14) y generación de conclusiones (RF-16). |
| **Comando** | `./gradlew test jacocoTestCoverageVerification` |
| **Umbral** | 0.7 global y 0.7 por paquete en los cuatro módulos. |
| **Evidencia** | Salida del comando; reporte HTML en `build/reports/jacoco/`. |
| **Estado real** | **El umbral solo vigila dos de los cuatro.** `build.gradle:105-120` incluye los paquetes de `auth` y `config`, pero **no** los de `estadisticas`, donde viven RF-14 y RF-16. Es [H-08](A4-hallazgos-rnf.md), y es el único incumplimiento documentable del SRS en este lote. |
| **Criterio de cierre de H-08** | Agregar `co.edu.uco.sigra.estadisticas.service*` a la lista `includes` y comprobar que el comando falla si esa cobertura baja del 70 %. |

### RNF-20 (b) · Documentación OpenAPI de los endpoints protegidos · 🟢

| | |
| --- | --- |
| **Criterio** | Todos los endpoints protegidos están documentados en OpenAPI/Swagger, con sus posibles códigos de respuesta: 200, 400, 401, 403 y 404. |
| **Comando** | `./gradlew integrationTest --tests '*ApiDocumentacionIT'` |
| **Umbral** | Las 10 clases `*ApiDocumentacionIT` en verde. Un endpoint nuevo sin documentación de códigos debe hacer fallar la prueba de su módulo. |
| **Evidencia** | Salida del comando; contrato en `http://localhost:8080/v3/api-docs`. |
| **Al revisar un PR** | Si agrega un endpoint protegido, confirmar que trae su documentación con los cinco códigos. Es un requisito del SRS, no una cortesía. |

---

## 6. Accesibilidad · RNF-21 · titular Andrés · 🟠

| | |
| --- | --- |
| **Criterio** | Cero violaciones de impacto `serious` o `critical`. Contraste ≥ 4.5:1 entre texto y fondo. **Navegación completa por teclado en los formularios de registro de notas y observaciones** — el SRS los nombra explícitamente. `label` o `aria-label` en **todos** los campos de formulario. |
| **Comando propuesto** | `@axe-core/playwright` dentro de la suite E2E existente |
| **Umbral** | Cero violaciones `serious` y `critical`. |
| **Evidencia** | Reporte de axe adjunto al PR. |
| **Estado** | **No automatizado** ([H-04](A4-hallazgos-rnf.md)). |
| **Criterio manual aceptable mientras tanto** | axe DevTools en Chrome sobre la vista tocada, con captura; y recorrido por teclado del formulario documentado paso a paso (orden de foco, foco visible, operable sin ratón). Es más lento y no previene regresiones, pero **deja evidencia**, que es lo que exige el §13. |

---

## 7. Seguridad de dependencias · transversal · 🔴 en el backend

| | |
| --- | --- |
| **Criterio** | Ninguna dependencia nueva o actualizada introduce una vulnerabilidad conocida de severidad moderada o superior. |
| **Comando** | Frontend: `npm audit --audit-level=high` — **ya corre en CI**<br>Backend: *Dependency Review* y `./gradlew dependencyCheckAnalyze` — **apagados** |
| **Umbral** | Cero hallazgos de severidad `moderate` o superior. |
| **Evidencia** | Salida del paso de CI. |
| **Estado** | Asimétrico: el frontend sí, el backend no ([H-01](A4-hallazgos-rnf.md)). Corrección más barata del registro. |

---

## 8. Suite completa de verificación

Todo lo ejecutable, de una sola vez, al preparar una entrega:

```bash
# Backend — desde software4-SIGRA-backend/SIGRA
./gradlew clean test jacocoTestCoverageVerification
./gradlew integrationTest                      # requiere PostgreSQL y SIGRA/.env
curl --fail http://localhost:8080/actuator/health

# Frontend — desde software4-SIGRA-frontend
npx ng build
npx ng test --no-watch
npm audit --audit-level=high
npm run e2e                                    # requiere backend arriba; ver e2e:preflight

# Verificaciones por inspección
grep -rnE '(createQuery|createNativeQuery).*\+' software4-SIGRA-backend/SIGRA/src/main/java/
grep -rn 'innerHTML\|bypassSecurityTrust' software4-SIGRA-frontend/src --include=*.ts
grep -rn 'http://' software4-SIGRA-frontend/src --include=*.ts | grep -v environment.development
```

Guardar la salida de cada comando: **es la evidencia**, y sin ella el veredicto no puede ser verde.

---

## 9. Pendientes de este artefacto

- [ ] Medir el bundle actual y proponer un umbral concreto para RNF-08.
- [ ] Llevar a la reunión del 8 la decisión sobre RNF-18 y sobre el alcance de rendimiento.
- [ ] Obtener el **Apéndice 4.2** para cerrar el criterio de RNF-19.
- [ ] Obtener el **Apéndice 4.1** y contrastarlo con la matriz RBAC implementada.
- [ ] Entregar este documento a los analistas de prueba **antes** de que diseñen sus casos.
- [ ] Por cada mantenimiento aprobado, añadir su criterio específico y enlazarlo desde
      [A2](A2-matriz-impacto-calidad.md).

---

[Guía del rol](GUIA-TRABAJO-RNF.md) · [A1 Catálogo](A1-catalogo-rnf.md) · [A2 Matriz de impacto](A2-matriz-impacto-calidad.md) · [A4 Hallazgos](A4-hallazgos-rnf.md) · [A5 Informe](A5-informe-calidad.md)
