# Mantenibilidad y calidad de código

## JaCoCo y CI

- Backend inspeccionado en `c1b1950bc88f51de3eff4471e29d598482d0774e`. `SIGRA/build.gradle` conserva el umbral global de instrucciones de 70 % y reglas por paquete para autenticación/control de acceso y configuración.
- La lista de paquetes no incluye `co.edu.uco.sigra.estadisticas.service*`. El comentario del mismo archivo dice agregarlo “cuando exista RF-14”, aunque el repositorio ya contiene servicios de RF-14/RF-16. Así, el build inspeccionado no aplica el 70 % por módulo a esas dos funciones obligatorias.
- El commit `d6fa7e1` al que A4/A6 atribuye la corrección de H-08 no existe en el clon y no es ancestro comprobado del HEAD revisado. H-08 no se considera cerrado para este SHA.
- La CI #199 sobre `c1b1950` corre `clean test jacocoTestCoverageVerification`; el job rotulado de integración no invoca `integrationTest`. La cobertura global 91,13 % de un XML local ignorado no contiene SHA identificable; no se usa como evidencia reproducible. No se repitió la suite equivalente de CI.
- Dependency Review y OWASP Dependency-Check aparecen `SKIPPED`; no son aprobaciones SCA.

## OpenAPI

Springdoc y clases `*ApiDocumentacionIT` existen en el backend. La CI #199 no ejecuta la tarea `integrationTest`, por lo que esas clases no tienen resultado acreditado en esa corrida. La prueba de acceso a `/v3/api-docs` en el backend productivo agotó 20 s sin recibir bytes; el estado efectivo es **no verificado**. La regla pública de `SecurityConfig` y la nota de Swagger privado en la documentación de riesgos deben reconciliarse.

## Frontend

- HEAD revisado: `9a5fa537708fb711318a9b353c481289299c7240`. La evidencia de CI #72 usa este SHA y cubre un solo flujo de login con Playwright; no equivale a recorrer todas las vistas ni a certificar producción.
- El XML JUnit local contiene 18 pruebas omitidas; esos casos no cuentan como PASS.
- Inspección estática de `src/app`: el servicio de sesión emplea `sessionStorage`; el patrón de almacenamiento es legible por scripts de la misma página. No se encontró uso directo de `innerHTML` o `bypassSecurityTrust` en la búsqueda de fuentes examinada; eso no es una auditoría exhaustiva de sinks.

## Acciones recomendadas al equipo de desarrollo

1. Hacer que la regla por paquete del build actual cubra RF-14/RF-16 y publicar un resultado firmado por SHA.
2. Separar/nombrar correctamente trabajos unitarios e integración; ejecutar integración solo contra PostgreSQL QA aislado.
3. Ejecutar las pruebas OpenAPI y revisar todos los códigos 200/400/401/403/404 exigidos por RNF-20(b).
4. Aclarar si Swagger debe ser público y actualizar el control o la documentación según la decisión aprobada.
5. Restaurar los escaneos SCA o documentar explícitamente por qué se omiten.
