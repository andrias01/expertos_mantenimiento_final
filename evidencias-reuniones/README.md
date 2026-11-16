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
| C-01 | Medir el bundle actual y proponer un umbral para RNF-08 | Andrés | R1 · 8 nov | R2 · 11 nov | 🟡 **Cumplido tarde** | 15 nov | 356,04 kB / 100,14 kB · corrida de CI 43684672703 · [A3 §2.3](../A3-criterios-verificacion.md) |
| C-02 | Reproducir H-08 y confirmar que los paquetes de `estadisticas` no están vigilados | José | R1 · 8 nov | R1 · 8 nov | 🟢 **Cumplido y superado** — además **corregido** | 15 nov | [A4 H-08](../A4-hallazgos-rnf.md) · diff de 4 líneas en `build.gradle` · `BUILD SUCCESSFUL` |
| C-03 | Conseguir los Apéndices 4.1 y 4.2 del SRS | Ambos | R1 · 8 nov | R2 · 11 nov | 🔴 **No cumplido** — no se pidieron formalmente | | Se vuelve a pedir en R3 (C-14) |
| C-04 | Llenar la matriz de impacto (A2) con los mantenimientos priorizados | Ambos | R1 · 8 nov | R2 · 11 nov | 🔴 **No cumplido** — A2 sigue con las filas vacías | | Se reprograma a R4 (C-13) |
| C-05 | Entregar los criterios de RNF a los analistas de prueba | Ambos | R1 · 8 nov | R2 · 11 nov | 🔴 **No cumplido** — A3 nunca se les entregó | | Se entrega al terminar R3 (C-11) |
| C-06 | Confirmar que la auditoría registra autenticaciones fallidas (RNF-16) | José | R1 · 8 nov | R2 · 11 nov | 🟢 **Cumplido** | 15 nov | `AuditoriaIntegracionIT`, `AuditoriaAspectTest` · [A6 §2.2](../A6-semaforo-rnf.md) |
| C-07 | Comparar la matriz RBAC implementada contra el Apéndice 4.1 | José | R1 · 8 nov | R2 · 11 nov | ⚪ **Bloqueado por C-03** | | Sin el apéndice no hay contra qué comparar |
| C-08 | Abrir el PR del fix de H-08 + corrección del README (H-07) | José | R3 · 15 nov | lun 16 nov | 🟡 **Cumplido a medias** | 16 nov | El fix **está integrado** en `develop` (`bb72c07`, PR #117). La corrección del README del backend (H-07) **no** entró en ese PR y sigue pendiente |
| C-09 | Correr los 20 usuarios de JMeter contra PostgreSQL local | Andrés | R3 · 15 nov | lun 16 nov | ⬜ Pendiente | | |
| C-10 | Escanear los dos repos con SonarQube local y adjuntar la nota de mantenibilidad | Andrés | R3 · 15 nov | lun 16 nov | ⬜ Pendiente | | |
| C-11 | Entregar A3 a Santiago Torres y Juan José Narváez (rescata C-05) | Ambos | R3 · 15 nov | hoy, al terminar R3 | ⬜ Pendiente | | |
| C-12 | Documento de una página con el patrón de paginación y de buscador (cierra H-12) | Ambos | R3 · 15 nov | lun 16 nov | ⬜ Pendiente | | |
| C-13 | Llenar A2 con una fila por incidencia resuelta y su veredicto de RNF (rescata C-04) | Ambos | R3 · 15 nov | mar 17 nov | ⬜ Pendiente | | |
| C-14 | Pedir formalmente los Apéndices 4.1 y 4.2 (rescata C-03) | Andrés | R3 · 15 nov | hoy, en R3 | ⬜ Pendiente | | |
| C-15 | Registrar actividades en el libro del equipo **el mismo día**, de aquí al cierre | Ambos | R3 · 15 nov | diario | ⬜ Pendiente | | [registros-equipo-rnf.md](../registros-equipo-rnf.md) |

**Estados:** ⬜ Pendiente · 🟢 Cumplido · 🟡 Cumplido parcialmente (explicar) · 🔴 No cumplido
(explicar) · ⚪ Ya no aplica (explicar por qué)

> **Balance al 15 de noviembre: 2 cumplidos, 1 cumplido tarde, 3 no cumplidos y 1 bloqueado, de
> siete.** La causa común de los tres no cumplidos está escrita y no se maquilla: **no registramos
> actividad entre el 8 y el 15 de noviembre**, mientras el equipo registraba 97 actividades. Es un
> incumplimiento del §12 («las actividades se registran diariamente»), está anotado como hallazgo
> [H-12](../A4-hallazgos-rnf.md) contra nosotros mismos, y C-15 es la corrección.

---

## Compromisos que le pedimos al equipo

Lo que nosotros necesitamos de otros para poder avanzar. Si algo de acá se queda quieto, se vuelve
un impedimento que hay que nombrar en la siguiente reunión.

| ID | Qué pedimos | A quién | Pedido en | Estado | Nota |
| --- | --- | --- | --- | --- | --- |
| P-01 | Confirmar las fechas de la Entrega 2 y la Entrega 3 | PO / SM | R1 · 8 nov | 🔴 **Sin resolver, y ahora contradictorio** | El libro del equipo dice E2 = sáb 14 y E3 = mar 17 · 8 pm; el Word de la Entrega 1 dice E2 = dom 15 · 8 pm y E3 = mar 17 · 11 pm. Hay que decidir cuál manda |
| P-02 | La lista de mantenimientos priorizada | PO / SM | R1 · 8 nov | 🟢 **Resuelto** | Llegó: son las 18 incidencias de Mantis, repartidas en la hoja «Reparto». **Pero 0000053 no está en esa hoja** (ver P-09) |
| P-03 | Decisión sobre el alcance de rendimiento (RNF-01 a 09) | Equipo | R1 · 8 nov | ⬜ **Se replantea en R3 como D-1 y D-2** | Ya no es «no hay instrumento»: hay JMeter. La decisión ahora es RNF-02/05/07 (se miden o son deuda) y RNF-09 (fuera de alcance) |
| P-04 | Decisión sobre RNF-18 (disponibilidad) | PO / SM | R1 · 8 nov | 🟡 **Parcialmente resuelto por los hechos** | El uptime ya se mide (100 % en 208 s). Queda solo el MTTR, que se replantea como D-3 |
| P-05 | Activar las variables del SCA del backend (H-01) | **Admin del repo: Juan Camilo / Jean Paul** | R1 · 8 nov | 🔴 **Sin resolver · 9 días** | Reconfirmado por API: `actions/variables` → `total_count: 0`. Nuestro permiso es `push`, **no `admin`**: no lo podemos hacer nosotros |
| P-06 | Arreglar el umbral de JaCoCo para RF-14 y RF-16 (H-08) | Por asignar | R1 · 8 nov | 🟢 **Resuelto — lo hicimos nosotros** | Falta el PR y la aprobación de Jean Paul (C-08) |
| P-07 | Acordar que ningún requerimiento pasa F2 sin su fila en A2 | Equipo | R1 · 8 nov | 🔴 **Sin resolver, y se nota** | 14 de 18 incidencias se resolvieron sin fila en A2. Hay que volver a plantearlo, y asumir la parte que nos toca: tampoco llenamos A2 |
| P-08 | La URL de producción del frontend en Vercel | Quien hizo el despliegue | R3 · 15 nov | 🟢 **Resuelto** · 16 nov | `https://sigra.vercel.app`, encontrada en la auditoría de José. Responde TLS 1.2/1.3 con HSTS; falta comprobarle el rechazo de TLS 1.0 |
| P-12 | Asignar dueño a **OBS-01** (cuatro vistas con error genérico) | SM | **16 nov** | ⬜ Nuevo | **No se pide crear ticket**: el procedimiento del equipo es revisar las existentes. La nota va en 0000041 y 0000048, que son las abiertas que tocan esas pantallas. Severidad media provisional, la de José |
| P-13 | Decidir la política de cabeceras HTTP del despliegue (**OBS-02**) | Quien administre Vercel | **16 nov** | ⬜ Nuevo | HSTS sí; CSP, X-Frame-Options y las demás no se observaron. Puede cerrarse con una decisión escrita, sin cambio |
| P-09 | Asignar dueño a la incidencia **0000053** | SM | **R3 · 15 nov** | ⬜ Nuevo | Alta/mayor del 14-nov, sin asignar. Según el §7, alta **bloquea la entrega** |
| P-10 | Token de SonarCloud en los secretos de Actions | Admin del repo | **R3 · 15 nov** | ⬜ Nuevo | Gratis en repos públicos y los dos lo son. **Misma pantalla que P-05**: conviene pedirlo junto |
| P-11 | Pasar a `cerrada` las incidencias con PR integrado | Jean Paul / SM | **R3 · 15 nov** | ⬜ Nuevo | Hoy **0 de 31** están cerradas, así que el indicador de trazabilidad completa es 0 % |

---

## Resumen de las cuatro reuniones

| # | Fecha y hora | Día | Carpeta | Acta | Qué se evalúa ahí |
| --- | --- | --- | --- | --- | --- |
| 1 | dom 8 nov · 8:00 pm | 5 | [reunion-1-2026-11-08](reunion-1-2026-11-08/) | 🟡 preparada, sin llenar lo que se respondió | Entrega 1 · diagnóstico y planeación |
| 2 | mié 11 nov · 6:00 pm | 8 | [reunion-2-2026-11-11](reunion-2-2026-11-11/) | 🔴 **sin acta** | Avance antes de la Entrega 2 |
| 3 | dom 15 nov · 8:00 pm | 12 | [reunion-3-2026-11-15](reunion-3-2026-11-15/) | 🟢 [acta preparada](reunion-3-2026-11-15/acta.md) | Verificación de RNF · [semáforo](../A6-semaforo-rnf.md) |
| 4 | mar 17 nov · 11:00 pm | 14 | [reunion-4-2026-11-17](reunion-4-2026-11-17/) | ⬜ | Cierre · informe de calidad |

> El día del proyecto está calculado suponiendo que el día 1 fue el 4 de noviembre.
> **Hay que confirmarlo en la reunión del 8** (compromiso P-01) y corregir esta tabla si cambia.

---

## Indicadores que salen de acá

Estos dos los pide el manual en el §10 y se calculan directo de las tablas de arriba. Conviene
llevarlos calculados a las reuniones 3 y 4.

| Indicador | Cómo se saca | Último valor (15-nov) |
| --- | --- | --- |
| % de compromisos cumplidos | Filas 🟢 ÷ total de filas de la tabla de compromisos | **2 de 7 = 29 %** (3 de 7 = 43 % contando el cumplido tarde). Las 8 filas nuevas de la R3 no cuentan todavía: no han vencido |
| % de lo pedido al equipo que se resolvió | Filas resueltas ÷ total de la tabla de pedidos | **2 de 7 = 29 %** de los pedidos de la R1 (P-02 y P-06; P-04 parcial). Los cuatro nuevos, P-08 a P-11, se piden hoy |

El manual dice que los indicadores «deben reflejar resultados reales» y que no se deben alterar
datos para aparentar cumplimiento. Si un número queda bajo, va bajo y se explica por qué.
