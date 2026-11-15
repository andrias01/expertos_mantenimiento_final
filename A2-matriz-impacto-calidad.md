# A2 · Matriz de impacto en atributos de calidad

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Actividad RACI** | «Análisis de impacto» — somos **R/C** (ejecutamos o acompañamos; la responsabilidad general es de desarrollo) |
| **Filtro** | **F2 · Diseño** — nuestra parte del criterio de salida es «criterios definidos» |
| **Entrega** | 1 (estructura) · 2 (completa) |
| **Estado** | Estructura lista — **las filas se llenan cuando el Product Owner priorice el backlog** |

> **El acuerdo que hay que conseguir en la reunión del 8.** Ningún requerimiento de mantenimiento
> pasa F2 sin su fila en esta matriz. Es lo que convierte nuestro rol en un filtro y no en un
> documento que se lee al final. Sin ese acuerdo, el equipo puede desarrollar sin nosotros y
> nuestro trabajo llega tarde por diseño.

---

## 1. Matriz maestra

Una fila por mantenimiento. Para deducir la columna de RNF, usar la heurística de
[A1 §4](A1-catalogo-rnf.md#4-heurística-qué-toca-qué).

| ID | Mantenimiento | Tipo | Módulos | Atributos afectados | RNF comprometidos | Riesgo | Sev. | Criterio | Veredicto | Verificó |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MNT-01 | | | | | | | | | ⬜ Pendiente | |
| MNT-02 | | | | | | | | | ⬜ Pendiente | |
| MNT-03 | | | | | | | | | ⬜ Pendiente | |

**Leyenda de veredicto:** ⬜ Pendiente · 🟢 Verificado · 🟡 Verificado con reservas · 🔴 No cumple

---

## 2. Cómo se llena cada columna

| Columna | Qué poner | De dónde sale |
| --- | --- | --- |
| **ID** | `MNT-01`, correlativo | Lo asigna el Product Owner al priorizar |
| **Mantenimiento** | Una línea con lo que se pide | Backlog del PO |
| **Tipo** | Correctivo · adaptativo · perfectivo · preventivo | Lo clasifica el PO (§3.1 del manual) |
| **Módulos** | Carpetas que se tocan: `auth`, `estudiantes`, … | Del análisis de impacto de desarrollo |
| **Atributos afectados** | De los cinco del §3.5: seguridad, rendimiento, disponibilidad, compatibilidad, mantenibilidad | **Nosotros** |
| **RNF comprometidos** | `RNF-13`, `RNF-17`, … | **Nosotros**, con la heurística de A1 §4 |
| **Riesgo** | Qué se rompe si no se verifica, en términos del usuario | **Nosotros** |
| **Sev.** | Crítica · alta · media · baja | **En conjunto**, nunca uno solo |
| **Criterio** | Enlace a la fila de [A3](A3-criterios-verificacion.md) | **Nosotros** |
| **Veredicto** | Resultado de ejecutar el criterio | **Nosotros**, en la fase de verificación |
| **Verificó** | Nombre y fecha | Quien ejecutó |

### Reglas al llenar

1. **El riesgo se escribe en términos del usuario, no del código.** No «falta `@PreAuthorize`»
   sino «un estudiante podría consultar los datos de otro estudiante».
2. **Si una fila no tiene criterio, F2 no cierra.** Esa es nuestra parte del filtro.
3. **Los 21 RNF del SRS cubren los cinco atributos**, así que toda fila debería poder nombrar al
   menos un RNF. Si no encuentras ninguno, vuelve a [A1](A1-catalogo-rnf.md) antes de escribir
   «ninguno»: es lo que nos pasó con la disponibilidad, donde RNF-18 existía y no lo habíamos visto.
4. **La severidad la decidimos entre los dos**, y si es crítica o alta se lleva al equipo, porque
   bloquea la entrega (§7).

---

## 3. Ficha ampliada

Para mantenimientos que tocan varios atributos o cuya fila no alcanza. Se copia una por cada
mantenimiento complejo, debajo de esta sección.

```markdown
### MNT-0X · <título del mantenimiento>

| Campo | Contenido |
| --- | --- |
| Tipo | Correctivo / adaptativo / perfectivo / preventivo |
| Solicitado por | |
| Responsable de desarrollo | |
| Módulos tocados | |
| **Atributos de calidad afectados** | |
| **RNF comprometidos** | |

**Qué se toca y por qué importa para la calidad.**
<Dos o tres frases. Qué parte del producto cambia y qué atributo pone en juego.>

**Funcionalidades existentes que hay que volver a probar.**
<Lista. Esta es la parte que más se omite y la que evita la regresión.
No es «el módulo X»: es «el flujo de registrar una calificación en una evaluación activa».>

**Riesgos identificados.**
| # | Riesgo | Atributo | Severidad | Mitigación |
| --- | --- | --- | --- | --- |
| 1 | | | | |

**Criterios de verificación aplicables.**
| RNF | Criterio | Comando | Veredicto |
| --- | --- | --- | --- |
| | | | ⬜ |

**Veredicto F2.** Aprobado / rechazado · fecha · quién
**Veredicto F4.** Aprobado / rechazado · fecha · quién
```

---

## 4. Lo que miramos en cada F2

Checklist corto, el mismo de la [guía §7.1](GUIA-TRABAJO-RNF.md#71-f2--diseño--con-el-revisor-técnico):

- [ ] ¿Está identificado el impacto sobre funcionalidades **que ya existían**?
- [ ] ¿Qué atributos de calidad toca? ¿Están en esta matriz?
- [ ] ¿Qué RNF quedan comprometidos?
- [ ] ¿Cada RNF comprometido tiene un criterio **medible** en A3?
- [ ] ¿El criterio dice con qué comando se comprueba y qué evidencia queda?
- [ ] ¿Introduce dependencias nuevas?
- [ ] ¿Toca `auth`, `security` o `auditoria`? → José
- [ ] ¿Agrega rutas, formularios o vistas? → Andrés
- [ ] ¿Toca mensajes de error? → los dos (RNF-17)
- [ ] **¿Qué funcionalidades existentes hay que volver a probar por culpa de este cambio?**

> La última casilla es la que decide si la regresión aparece en F2 o en F4. «Impacto identificado»
> se cumple con un párrafo genérico; lo que sirve es la lista concreta de qué reprobar.

---

## 5. Registro de participación en F2

Para poder demostrar en las reuniones que participamos desde el diseño, no al final.

| Fecha | Mantenimiento | Quién revisó | Veredicto | Observación dejada |
| --- | --- | --- | --- | --- |
| | | | | |

---

[Guía del rol](GUIA-TRABAJO-RNF.md) · [A1 Catálogo](A1-catalogo-rnf.md) · [A3 Criterios](A3-criterios-verificacion.md) · [A4 Hallazgos](A4-hallazgos-rnf.md) · [A5 Informe](A5-informe-calidad.md) · [A6 Semáforo](A6-semaforo-rnf.md)

---

## 6. Evidencia complementaria de validación integral · 15-nov-2026

El recorrido real por los tres roles confirmó el control visual 403 entre roles probados, logout y redirección de rutas privadas. También mostró errores genéricos en rutas de RA, estudiantes, reportes y estadísticas; su causa sigue pendiente. No se cambia el impacto original de los mantenimientos ni se presume cumplimiento por inspección parcial.

El detalle de las rutas, restricciones y hallazgos está en [resumen-ejecutivo](evidencias-rnf/jose-validacion-2026-11/resumen-ejecutivo.md), [informes de navegador](evidencias-rnf/jose-validacion-2026-11/navegador-administrador.md) y [hallazgos](evidencias-rnf/jose-validacion-2026-11/hallazgos.md).
