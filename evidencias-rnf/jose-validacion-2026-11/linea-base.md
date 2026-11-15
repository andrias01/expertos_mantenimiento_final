# Línea base de la validación integral

**Fecha:** 15 de noviembre de 2026
**Autor de esta evidencia:** José Alejandro Valencia
**Rama de evidencias:** `test/rnf-jose-validacion-integral`

## Alcance y salvaguardas

Se revisaron los artefactos previos y se recorrió la aplicación desplegada con una sesión por rol. Backend y frontend se consultaron en modo lectura; no se cambiaron sus archivos, no se ejecutaron cargas en producción, no se enviaron formularios de escritura y no se alteraron datos.

La aplicación observada fue `https://sigra.vercel.app`. El backend de referencia es `https://software4-sigra-backend.onrender.com`. El SRS `SIGRA.docx` y los Apéndices 4.1/4.2 no están en el repositorio de mantenimiento ni en los documentos de Entrega 1 disponibles; la trazabilidad exacta contra ellos sigue bloqueada.

## Repositorios y versiones revisadas

| Repositorio | Rama / versión revisada | Resultado |
| --- | --- | --- |
| Backend SIGRA | `docs/swagger-auth-auditoria`, `c1b1950bc88f51de3eff4471e29d598482d0774e` | Limpio al iniciar y al cierre; solo lectura |
| Frontend SIGRA | `jose-valencia/release-main-role-views-20261012`, `9a5fa537708fb711318a9b353c481289299c7240` | Limpio; solo lectura |
| Mantenimiento | `test/rnf-jose-validacion-integral` | Único destino de esta evidencia |

El commit `d6fa7e1` citado en A4/A6 no existe en el clon backend revisado. Por ello, sus cifras no se atribuyen al SHA local ni al despliegue productivo, cuyo SHA no se pudo confirmar.

## Evidencia previa que se conserva

- `jmeter/resultados/rnf18-render.jtl`: 90/90 respuestas a `/actuator/health`, un hilo, unos 208 s. Es una sonda breve y no demuestra el uptime ≥95 % ni MTTR.
- A4/A6: cobertura global histórica de 92,39 % sobre `d6fa7e1`. El resultado no acredita el HEAD actual. El XML local de JaCoCo no identifica SHA.
- CI backend #199 para `c1b1950`: `clean test jacocoTestCoverageVerification`; el job llamado de integración no llama `integrationTest`. Los jobs de SCA aparecen `SKIPPED`.
- CI frontend #72 para `9a5fa53`: Playwright sin omisiones para un flujo de login con backend de prueba. No cubre las pantallas actuales ni producción; el JUnit local contiene 18 casos omitidos.
- La base anterior conserva 9 criterios verdes, 9 parciales y 5 sin verificar (23 criterios/21 RNF). El acta preparada de reunión 3 contiene otra cifra; se mantiene la discrepancia, no se reemplaza ninguna cifra histórica.

No se repitieron las pruebas anteriores que conservan utilidad y versión identificada. No se ejecutaron nuevas suites: JaCoCo de CI corresponde al mismo SHA inspeccionado, y las pruebas de integración/carga requieren PostgreSQL QA aislado que no quedó demostrado.

## Fuentes nuevas

- Navegador integrado: revisión inicial sin sesión y recorridos ADMINISTRADOR, PROFESOR y ESTUDIANTE, con pantallas y rutas documentadas en los archivos enlazados desde [resumen-ejecutivo.md](resumen-ejecutivo.md).
- Código local: inspección estática de seguridad y mantenibilidad, sin modificarlo ni ejecutar pruebas.
- Salidas de prueba previas: se conservaron y clasificaron por SHA/ambiente cuando esos datos existen.

## Límites de esta línea base

El navegador integrado no proporcionó una captura exportable y redactable en archivo ni un registro HTTP exportable. Las pantallas con cuentas y datos académicos no se publican en bruto. La inspección de rutas y estados no sustituye una prueba automatizada de API, una prueba de rendimiento, una auditoría WCAG ni una matriz de compatibilidad completa.
