# A5 · Informe de calidad — Verificación de requisitos no funcionales

**Proyecto de Mantenimiento de Software · SIGRA**
Especialistas en requisitos no funcionales: Andrés Felipe Vélez Alcaraz · José Alejandro Valencia

| | |
| --- | --- |
| **Actividad RACI** | «Verificar requisitos no funcionales» — somos **A/R** |
| **Entrega** | 3 (Día 15) · se presenta en la revisión final |
| **Criterio de finalización que sustenta** | §13: «Los requisitos no funcionales fueron verificados» |
| **Estado** | 🟡 **Borrador avanzado · 15 de noviembre de 2026.** Las cifras son reales y verificadas; las secciones 5, 8 y 9 esperan las decisiones de la reunión 3 |
| **Dato vivo** | El semáforo con la evidencia de cada criterio está en **[A6](A6-semaforo-rnf.md)** y se mantiene allí hasta el cierre. Este informe lo resume y lo firma |

> **Qué es este documento.** Es el entregable con el que se mide nuestro rol y la única evidencia
> de que el criterio de finalización del §13 se cumple. El manual lo nombra como «informe de
> calidad», distinto del informe de pruebas que elaboran los analistas de prueba.
>
> **Cómo se escribe.** Cada afirmación va con su evidencia. Si una casilla no tiene evidencia, el
> veredicto es amarillo o rojo, nunca verde. Un informe honesto con rojos declarados vale más que
> uno en verde que no resiste una pregunta.

---

## 1. Resumen ejecutivo

> **Borrador del 15 de noviembre.** Se cierra el martes 17 con las decisiones de tratamiento que
> falten.

De los **21 requisitos no funcionales** del SRS —**23 criterios**, porque RNF-18 y RNF-20 se
verifican en dos mitades cada uno— la verificación inicial de esta entrega deja **9 cumplidos con
evidencia ejecutable, 9 cumplidos con una reserva declarada y 5 sin veredicto**. El 8 de noviembre
las cifras eran 7, 3 y 13.

Lo que movió la aguja no fue trabajo de documentación: fue descubrir que **el producto ya está en
operación** —backend en Render, frontend en Vercel— y medirlo. Eso convirtió en verificables dos
requisitos que habíamos declarado imposibles de comprobar (RNF-11 y el uptime de RNF-18), y obligó
a retirar un hallazgo que se había levantado sobre una premisa falsa. Además se construyó el
instrumento que faltaba para el rendimiento (Apache JMeter, dos planes versionados) y **se corrigió
el único incumplimiento documentable del SRS que habíamos encontrado**: la verificación de
cobertura vigilaba dos de los cuatro módulos que el SRS nombra uno por uno, y hoy vigila los
cuatro.

Lo que no se resolvió y condiciona el cierre: el análisis de seguridad de las dependencias del
backend **sigue apagado ocho días después** y no está en nuestras manos encenderlo; la red de
pruebas de navegador **no creció con el producto**, que ganó ocho módulos en una semana; y hay una
incidencia de severidad mayor **sin responsable asignado** cuyo perfil es exactamente el de un
defecto de concurrencia. Y una parte que nos corresponde reconocer: **las dos únicas incidencias
que Mantis clasifica como no funcionales son las que el equipo nos asignó, y ninguna pasó por
nuestra validación.**

| | Valor al 15-nov | Fuente |
| --- | --- | --- |
| Incidencias de mantenimiento en el tablero | **31** (18 de esta fase) | `estado de mantis.csv` |
| Criterios de RNF verificados | **23** | [A6](A6-semaforo-rnf.md) |
| 🟢 Cumplen con evidencia ejecutable | **9** | A6 §2 |
| 🟡 Cumplen con reserva declarada | **9** | A6 §2 |
| 🔴 Sin veredicto o fuera de alcance | **5** | A6 §2 |
| Hallazgos cerrados con evidencia | **2** (H-08, H-10) | [A4](A4-hallazgos-rnf.md) |
| Hallazgos en corrección | **4** (H-02, H-04, H-05, H-09) | A4 |
| Hallazgos abiertos | **7**, de los cuales **3 de severidad alta** (H-01, H-03, H-11) | A4 |
| Cobertura global del backend | **92,39 %** | `jacocoTestReport` |
| **¿Se cumple el criterio §13?** | ⏳ **Aún no.** Falta el PR de H-08 integrado, y las decisiones de tratamiento de los 5 rojos y los 9 amarillos | — |

---

## 2. Semáforo de RNF

El semáforo completo —los 23 criterios con su umbral del SRS, su veredicto y la salida de comando
que lo sostiene— vive en **[A6 · Semáforo de RNF](A6-semaforo-rnf.md)** y se mantiene actualizado
ahí hasta el cierre. Esta es la vista de una página.

| Atributo | 🟢 | 🟡 | 🔴 | Lo que define el resultado |
| --- | --- | --- | --- | --- |
| **Seguridad** (RNF-10 a 17) | 7 | 1 | 0 | Fuerte. RNF-11 pasó a verde al medir TLS contra Render. Solo RNF-14 queda por inspección, sin prueba de saneamiento |
| **Rendimiento** (RNF-01 a 09) | 0 | 5 | 4 | El instrumento existe y falta ejecutarlo. RNF-09 es fuera de alcance; RNF-02, 05 y 07 necesitan datos sembrados |
| **Disponibilidad** (RNF-18) | 0 | 1 | 1 | Uptime medido con reserva de ventana; MTTR sin ningún evento que medir |
| **Compatibilidad** (RNF-19) | 0 | 1 | 0 | Chromium y Firefox automatizados, **un solo flujo**. Edge y móvil no se prueban |
| **Mantenibilidad** (RNF-20) | 2 | 0 | 0 | Cobertura de los cuatro módulos obligatorios y OpenAPI verificada por pruebas |
| **Accesibilidad** (RNF-21) | 0 | 1 | 0 | Corregido a mano por UI/UX; sin verificación automatizada |
| **Total** | **9** | **9** | **5** | 23 criterios |

**Leyenda:** 🟢 Cumple con evidencia ejecutable · 🟡 Cumple con reserva declarada · 🔴 Sin
veredicto, sin instrumento o fuera de alcance.

> **La regla que nos aplicamos y que sostiene este informe:** si la casilla de evidencia está
> vacía, el veredicto no puede ser verde. Los nueve verdes tienen detrás una salida de comando
> reproducible, pegada en A6 o en A4.

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
