# A5 · Informe de calidad — Verificación de requisitos no funcionales

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Actividad RACI** | «Verificar requisitos no funcionales» — somos **A/R** |
| **Entrega** | 3 (Día 15) · se presenta en la revisión final |
| **Criterio de finalización que sustenta** | §13: «Los requisitos no funcionales fueron verificados» |
| **Estado** | ⬜ Esqueleto — se llena en la fase de validación |

> **Qué es este documento.** Es el entregable con el que se mide nuestro rol y la única evidencia
> de que el criterio de finalización del §13 se cumple. El manual lo nombra como «informe de
> calidad», distinto del informe de pruebas que elaboran los analistas de prueba.
>
> **Cómo se escribe.** Cada afirmación va con su evidencia. Si una casilla no tiene evidencia, el
> veredicto es amarillo o rojo, nunca verde. Un informe honesto con rojos declarados vale más que
> uno en verde que no resiste una pregunta.

---

## 1. Resumen ejecutivo

> *Para llenar al final. Tres párrafos máximo: qué se verificó, cuál fue el resultado y qué queda
> abierto. Quien lea solo esto debe quedar bien informado.*

| | |
| --- | --- |
| Mantenimientos ejecutados | ⬜ |
| RNF comprometidos en total | ⬜ |
| RNF verificados y cumplidos | ⬜ |
| RNF con deuda técnica documentada | ⬜ |
| RNF declarados fuera de alcance | ⬜ |
| Hallazgos abiertos al cierre | ⬜ |
| **¿Se cumple el criterio §13?** | ⬜ Sí / No / Con reservas |

---

## 2. Semáforo de RNF

La tabla central del informe. Una fila por cada RNF comprometido por algún mantenimiento.

| RNF | Atributo | Criterio aplicado | Veredicto | Evidencia | Verificó |
| --- | --- | --- | --- | --- | --- |
| | | | ⬜ | | |

**Leyenda:** 🟢 Cumple · 🟡 Cumple con reservas (explicar cuáles) · 🔴 No verificado o no cumple
· ⚪ No aplicable a los mantenimientos ejecutados

---

## 3. Verificación por atributo de calidad

Una subsección por cada uno de los cinco atributos que el §3.5 nos exige revisar. Si un atributo
no se vio afectado por ningún mantenimiento, se dice explícitamente — «no aplicable» también es un
resultado, siempre que esté justificado.

### 3.1 Seguridad

| | |
| --- | --- |
| RNF involucrados | |
| Mantenimientos que la afectaron | |
| Criterios ejecutados | |
| Resultado | |
| Evidencia | |

*Observaciones.*

### 3.2 Rendimiento

| | |
| --- | --- |
| RNF involucrados | RNF-01 a RNF-09 (nueve requisitos) |
| Mantenimientos que lo afectaron | |
| Criterios ejecutados | |
| Resultado | |
| Evidencia | |

**Desglose obligatorio**, porque son nueve y no se pueden resumir en un veredicto único:

| RNF | Umbral del SRS | Veredicto | Evidencia |
| --- | --- | --- | --- |
| RNF-01 | 20 usuarios concurrentes | ⬜ | |
| RNF-02 | 10 en lectura/escritura simultánea | ⬜ | |
| RNF-03 | 95 % autenticación < 4 s | ⬜ | |
| RNF-04 | 95 % CRUD catálogo < 3 s | ⬜ | |
| RNF-05 | 95 % calificaciones < 3 s | ⬜ | |
| RNF-06 | 90 % estadísticas < 5 s | ⬜ | |
| RNF-07 | 50 evaluaciones por asignatura | ⬜ | |
| RNF-08 | 95 % páginas < 3 s | ⬜ | |
| RNF-09 | Sostenido 4 meses | ⬜ | |

*Observaciones. Si al cierre siguieron sin instrumento (H-02), decirlo con esas palabras: no se
pudo verificar, y por qué. Para los que se midieron a mano, declarar la reserva: una muestra
pequeña en local no demuestra el percentil 95 con 20 usuarios concurrentes.*

### 3.3 Disponibilidad

| | |
| --- | --- |
| RNF involucrado | **RNF-18** — uptime ≥ 95 %, MTTR ≤ 4 h ante caída crítica |
| Criterio aplicado | |
| Resultado | |
| Evidencia | |

*Observaciones. RNF-18 existe en el SRS y es explícito; lo que falta es medición (H-09). Declarar
si se verificó con el criterio sustituto —arranque limpio, `/actuator/health` en `UP`, y
degradación correcta del frontend ante backend caído— o si se declaró fuera de alcance por no
haber entorno en operación. Y recordar que el SRS define la clasificación de incidentes
(Crítica / Alta / Menor) en la sección 3.3.3, distinta de la escala de defectos del manual.*

### 3.4 Compatibilidad

| | |
| --- | --- |
| RNF involucrados | RNF-19 |
| Navegadores verificados | |
| Resultado | |
| Evidencia | |

*Observaciones. Declarar el alcance real: Edge no se prueba automáticamente —Chromium es el
sustituto por compartir motor— y Android tampoco.*

### 3.5 Mantenibilidad

| | |
| --- | --- |
| Cobertura al cierre | |
| Análisis estático | |
| Documentación actualizada | |
| Resultado | |
| Evidencia | |

---

## 4. Hallazgos: estado al cierre

Resumen de [A4](A4-hallazgos-rnf.md). **Ningún hallazgo crítico o alto puede quedar abierto**
(§7 y §13).

| ID | Severidad | Hallazgo | Estado final | Evidencia de cierre |
| --- | --- | --- | --- | --- |
| H-01 | **Alta** | SCA de dependencias del backend apagado | ⬜ | |
| H-02 | **Alta** | Nueve requisitos de rendimiento (RNF-01 a 09) sin instrumento | ⬜ | |
| H-08 | **Alta** | RNF-20 vigila la cobertura de 2 de los 4 módulos obligatorios | ⬜ | |
| H-03 | Media | E2E de navegador con un solo flujo | ⬜ | |
| H-04 | Media | RNF-21 sin verificación automatizada | ⬜ | |
| H-05 | Media | Sin análisis estático de código | ⬜ | |
| H-09 | Media | RNF-18 sin medición de uptime ni MTTR | ⬜ | |
| H-10 | Media | RNF-11 (TLS 1.2+) no verificable sin entorno de producción | ⬜ | |
| H-07 | Baja | README contradice a `build.gradle` sobre JaCoCo | ⬜ | |
| ~~H-06~~ | — | ~~Ningún RNF cubre disponibilidad~~ | **Retirado por falso** | RNF-18 existe en el SRS |
| | | *(hallazgos nuevos del período)* | | |

---

## 5. Decisiones de tratamiento

El §7 exige que los hallazgos de severidad media y baja tengan «una decisión de tratamiento antes
del cierre». Aquí van, con quién decidió y cuándo.

| ID | Decisión | Justificación | Quién decidió | Fecha |
| --- | --- | --- | --- | --- |
| | Se corrige / se acepta como deuda técnica / fuera de alcance | | | |

> Una casilla vacía en esta tabla es un criterio de finalización incumplido. Un rojo con decisión
> escrita cumple; un rojo sin decisión, no.

---

## 6. Indicadores

Los del §10 que dependen de nuestro rol. **Con datos reales**: «no se deben fijar metas arbitrarias
ni alterar datos para aparentar cumplimiento».

| Indicador | Fórmula | Valor |
| --- | --- | --- |
| % de cambios con trazabilidad de calidad | Mantenimientos con fila en A2 ÷ total | ⬜ |
| % de verificación de RNF ejecutada | RNF con veredicto ÷ RNF comprometidos | ⬜ |
| Hallazgos de RNF identificados / corregidos | Conteo de A4 | ⬜ |
| % de usos de IA con evidencia de verificación | Entradas con verificación real ÷ total | ⬜ |

---

## 7. Riesgos que quedan vivos

Lo que el siguiente equipo que mantenga SIGRA debería saber. Esta sección es la más útil a largo
plazo y la que más se omite en los informes de cierre.

| Riesgo | Atributo | Por qué queda abierto | Recomendación |
| --- | --- | --- | --- |
| | | | |

---

## 8. Conclusiones para la retrospectiva

> *Dos o tres, concretas y accionables. No «hay que comunicarse mejor», sino un cambio verificable
> en el proceso.*

Las que ya tenemos sustentadas desde el análisis del manual, para contrastar al final con lo que
realmente pasó:

1. Un registro sin criterio de salida y sin revisión independiente no es un control, es un
   archivo. Los criterios de RNF funcionan solo cuando son condición de salida de un filtro.
2. Participar desde el diagnóstico cambia el resultado: los atributos de calidad no se pueden
   agregar al final.
3. Lo que no es medible no se verifica. Los RNF sin instrumento llegaron al cierre sin veredicto,
   y eso se sabía desde el día 5.

---

## 9. Declaración de cierre del rol

> *Para firmar al final, y solo si es cierto.*

Como especialistas en requisitos no funcionales declaramos que los requisitos no funcionales
comprometidos por los mantenimientos ejecutados fueron verificados según los criterios
documentados en [A3](A3-criterios-verificacion.md), con la evidencia referenciada en este informe.
Los RNF que no pudieron verificarse están declarados como tales, con su justificación y su
decisión de tratamiento.

| | |
| --- | --- |
| Andrés Felipe Vélez Alcaraz | ⬜ fecha |
| José Alejandro Valencia | ⬜ fecha |

---

[Guía del rol](GUIA-TRABAJO-RNF.md) · [A1 Catálogo](A1-catalogo-rnf.md) · [A2 Matriz de impacto](A2-matriz-impacto-calidad.md) · [A3 Criterios](A3-criterios-verificacion.md) · [A4 Hallazgos](A4-hallazgos-rnf.md)
