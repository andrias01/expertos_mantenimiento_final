# Evidencias de reuniones · Especialistas en RNF

Carpeta donde Andrés y José guardamos la evidencia de cada reunión del equipo y el seguimiento de
lo que cada uno se comprometió a hacer.

**Para qué sirve.** El manual exige que las reuniones queden grabadas (§6) y que las actividades
se registren con evidencia (§9.1). Pero además nos sirve para algo más práctico: poder comparar de
una reunión a la siguiente si cumplimos lo que dijimos que íbamos a hacer. En la reunión uno decís
«voy a hacer X»; en la reunión dos tiene que poder verse si X se hizo. Esa comparación es la
**tabla de compromisos** de más abajo, y es lo que el 20 % de la nota individual («cumplimiento de
responsabilidades individuales», §11) va a mirar.

---

## Cómo se usa

### Después de cada reunión, el mismo día

1. Entrar a la carpeta de la reunión (`reunion-N-FECHA/`).
2. Copiar `PLANTILLA-acta.md` como `acta.md` y llenarla.
3. Guardar ahí la evidencia: grabación o enlace a ella, capturas del tablero, capturas del chat
   donde quedó un acuerdo, el PDF o PNG de lo que presentamos.
4. **Actualizar la tabla de compromisos de este README.** Es el paso que más se olvida y el más
   importante: es lo único que permite hacer el cruce entre reuniones.

### Antes de cada reunión

1. Abrir la tabla de compromisos y filtrar los que son nuestros con estado `Pendiente`.
2. Eso es exactamente lo que hay que responder en el «¿qué realicé?» — no hay que acordarse de
   nada, está escrito.
3. Si alguno quedó sin cumplir, llevar la razón. Un compromiso incumplido y explicado se ve mucho
   mejor que uno incumplido y escondido.

### Nombres de archivo

Para que no se mezcle nada, usamos este formato:

```
reunion-1-2026-11-08/
├── acta.md                          ← el acta, siempre con este nombre
├── grabacion.txt                    ← el enlace a la grabación (no el video, pesa mucho)
├── presentacion.pdf                 ← lo que mostramos, si mostramos algo
├── captura-tablero-2026-11-08.png   ← capturas: qué es + fecha
└── captura-acuerdo-f2.png
```

---

## Tabla de compromisos

La tabla maestra. **Una fila por compromiso**, de cualquiera de los dos. Se actualiza después de
cada reunión y nunca se borra una fila: si algo no se cumplió, se marca como tal y se explica.

| ID | Compromiso | Quién | Prometido en | Para cuándo | Estado | Cumplido en | Evidencia |
| --- | --- | --- | --- | --- | --- | --- | --- |
| C-01 | Medir el bundle actual y proponer un umbral para RNF-08 | Andrés | R1 · 8 nov | R2 · 11 nov | ⬜ Pendiente | | |
| C-02 | Reproducir H-08 y confirmar que los paquetes de `estadisticas` no están vigilados | José | R1 · 8 nov | R1 · 8 nov | ⬜ Pendiente | | |
| C-03 | Conseguir los Apéndices 4.1 y 4.2 del SRS | Ambos | R1 · 8 nov | R2 · 11 nov | ⬜ Pendiente | | |
| C-04 | Llenar la matriz de impacto (A2) con los mantenimientos priorizados | Ambos | R1 · 8 nov | R2 · 11 nov | ⬜ Pendiente | | |
| C-05 | Entregar los criterios de RNF a los analistas de prueba | Ambos | R1 · 8 nov | R2 · 11 nov | ⬜ Pendiente | | |
| C-06 | Confirmar que la auditoría registra autenticaciones fallidas (RNF-16) | José | R1 · 8 nov | R2 · 11 nov | ⬜ Pendiente | | |
| C-07 | Comparar la matriz RBAC implementada contra el Apéndice 4.1 | José | R1 · 8 nov | R2 · 11 nov | ⬜ Pendiente | | |

**Estados:** ⬜ Pendiente · 🟢 Cumplido · 🟡 Cumplido parcialmente (explicar) · 🔴 No cumplido
(explicar) · ⚪ Ya no aplica (explicar por qué)

> Las primeras siete filas salen de lo que vamos a decir en la reunión del 8. Las demás se agregan
> a medida que se prometan cosas.

---

## Compromisos que le pedimos al equipo

Lo que nosotros necesitamos de otros para poder avanzar. Si algo de acá se queda quieto, se vuelve
un impedimento que hay que nombrar en la siguiente reunión.

| ID | Qué pedimos | A quién | Pedido en | Estado | Nota |
| --- | --- | --- | --- | --- | --- |
| P-01 | Confirmar las fechas de la Entrega 2 y la Entrega 3 | PO / SM | R1 · 8 nov | ⬜ | |
| P-02 | La lista de mantenimientos priorizada | PO / SM | R1 · 8 nov | ⬜ | Sin esto no podemos tener la matriz antes del desarrollo |
| P-03 | Decisión sobre el alcance de rendimiento (RNF-01 a 09) | Equipo | R1 · 8 nov | ⬜ | Qué se mide a mano y qué se declara fuera de alcance |
| P-04 | Decisión sobre RNF-18 (disponibilidad) | PO / SM | R1 · 8 nov | ⬜ | Fuera de alcance, o criterio sustituto |
| P-05 | Activar las variables del SCA del backend (H-01) | Admin del repo | R1 · 8 nov | ⬜ | Son dos variables |
| P-06 | Arreglar el umbral de JaCoCo para RF-14 y RF-16 (H-08) | Por asignar | R1 · 8 nov | ⬜ | Dos líneas; cierra un incumplimiento del SRS |
| P-07 | Acordar que ningún requerimiento pasa F2 sin su fila en A2 | Equipo | R1 · 8 nov | ⬜ | **El acuerdo más importante para nuestro rol** |

---

## Resumen de las cuatro reuniones

| # | Fecha y hora | Día | Carpeta | Acta | Qué se evalúa ahí |
| --- | --- | --- | --- | --- | --- |
| 1 | dom 8 nov · 8:00 pm | 5 | [reunion-1-2026-11-08](reunion-1-2026-11-08/) | ⬜ | Entrega 1 · diagnóstico y planeación |
| 2 | mié 11 nov · 6:00 pm | 8 | [reunion-2-2026-11-11](reunion-2-2026-11-11/) | ⬜ | Avance antes de la Entrega 2 |
| 3 | dom 15 nov · 8:00 pm | 12 | [reunion-3-2026-11-15](reunion-3-2026-11-15/) | ⬜ | Verificación de RNF · semáforo |
| 4 | mar 17 nov · 11:00 pm | 14 | [reunion-4-2026-11-17](reunion-4-2026-11-17/) | ⬜ | Cierre · informe de calidad |

> El día del proyecto está calculado suponiendo que el día 1 fue el 4 de noviembre.
> **Hay que confirmarlo en la reunión del 8** (compromiso P-01) y corregir esta tabla si cambia.

---

## Indicadores que salen de acá

Estos dos los pide el manual en el §10 y se calculan directo de las tablas de arriba. Conviene
llevarlos calculados a las reuniones 3 y 4.

| Indicador | Cómo se saca | Último valor |
| --- | --- | --- |
| % de compromisos cumplidos | Filas 🟢 ÷ total de filas de la tabla de compromisos | — |
| % de lo pedido al equipo que se resolvió | Filas ⬜ resueltas ÷ total de la tabla de pedidos | — |

El manual dice que los indicadores «deben reflejar resultados reales» y que no se deben alterar
datos para aparentar cumplimiento. Si un número queda bajo, va bajo y se explica por qué.
