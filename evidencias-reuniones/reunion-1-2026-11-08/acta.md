# Acta de reunión — Reunión 1

| | |
| --- | --- |
| **Reunión** | 1 de 4 |
| **Fecha y hora** | Domingo 8 de noviembre de 2026, 8:00 pm |
| **Día del proyecto** |Día 5 *(por confirmar — ver decisión 1)* |
| **Duración real** | ⬜ |
| **Quiénes asistieron** | ⬜ |
| **Quiénes faltaron** | ⬜ |
| **Grabación** | ⬜ *(enlace; el manual exige que quede grabada)* |
| **Acta escrita por** | ⬜ |
| **Corresponde a** | Entrega 1 · Diagnóstico y planeación |

> **Estado: preparada antes de la reunión.** Las secciones 1 y 2 están llenas porque es lo que
> llevamos. Las secciones 3 a 8 se llenan durante la reunión o inmediatamente después.

---

## 1. Lo que veníamos debiendo

Primera reunión, no hay compromisos anteriores.

---

## 2. Lo que vamos a decir

### Andrés Felipe Vélez Alcaraz

**¿Qué realicé?**

Partimos del SRS y sacamos la lista completa: SIGRA tiene 21 requisitos no funcionales. Sobre esa
lista revisamos los dos repositorios para ver con qué se puede comprobar cada uno. La red de
pruebas del proyecto es grande —102 clases en el backend, 74 pruebas en el frontend, 490
peticiones en Bruno, y una prueba que verifica sola que ninguna ruta privada quede sin permiso—
así que **siete requisitos se pueden verificar hoy sin trabajo extra**. Pero **nueve no tienen con
qué**: todo el grupo de rendimiento. Dejamos la lista con un titular por atributo entre José y yo,
los criterios de verificación con su comando, y el registro de hallazgos: nueve abiertos, tres de
severidad alta.

**¿Qué realizaré?**

Cuando el Product Owner priorice los mantenimientos, llenamos la matriz de impacto: por cada
requerimiento, qué atributos toca, qué requisitos compromete y con qué criterio se verifica. Eso
es lo que el filtro F2 necesita para cerrar, así que queremos tenerlo antes de que empiece el
desarrollo. Yo además voy a medir el tamaño del build para poder proponer un límite concreto del
RNF-08.

**¿Qué impedimentos tengo?**

Tres, y los dos primeros necesitan que el equipo decida:

1. **Los nueve requisitos de rendimiento no se pueden medir.** El SRS pone números: entrar en
   menos de 4 segundos, guardar en menos de 3, estadísticas en menos de 5, 20 usuarios al mismo
   tiempo. No hay prueba de carga ni medición de tiempos. Traemos una propuesta de alcance mínimo,
   pero hay que decidir qué se mide y qué se declara fuera del alcance, y eso se decide hoy, no el
   día 15.
2. **La revisión de librerías del backend está apagada.** Son dos variables del repositorio.
   Mientras siga así, las dependencias del backend no están revisadas; el frontend sí las revisa
   en cada ejecución.
3. **Nos faltan los Apéndices 4.1 y 4.2 del SRS.** El 4.2 dice qué navegadores y dispositivos
   exige el RNF-19, y sin eso estamos adivinando el alcance. El 4.1 es la matriz de permisos y la
   necesitamos para compararla con lo que está programado.

### José Alejandro Valencia

**¿Qué realicé?**

Me encargué de los atributos de seguridad, disponibilidad y auditoría. De los ocho requisitos de
seguridad, cinco se pueden verificar hoy con pruebas que ya existen: contraseñas, token,
permisos, auditoría y mensajes de error. Los otros dos tienen problema: el RNF-11 pide HTTPS en
producción y no hay ambiente de producción para comprobarlo, y el RNF-14 no tiene una prueba
dedicada de validación de datos, así que queda por inspección.

El hallazgo más importante que traigo es el **H-08**. El RNF-20 pide 70 % de cobertura de pruebas
en cuatro módulos que el SRS nombra uno por uno: autenticación, permisos por rol, cálculo del
nivel de logro y generación de conclusiones. Revisé la configuración de JaCoCo y solo vigila los
dos primeros. O sea que el cálculo del nivel de logro y las conclusiones pueden quedar por debajo
del 70 % y el build no falla. El archivo tiene hasta un comentario que dice «agregar esto cuando
exista RF-14», y RF-14 ya existe hace rato y tiene pruebas: el comentario quedó viejo. **Es el
único hallazgo que es un incumplimiento del SRS y no una herramienta que falta, y se arregla con
dos líneas.**

**¿Qué realizaré?**

Comparar la matriz de permisos que está programada contra el Apéndice 4.1 del SRS, en cuanto lo
consigamos: si hay diferencias, es un hallazgo del RNF-13. También voy a confirmar que la
auditoría está registrando los intentos de inicio de sesión fallidos, porque el SRS lo exige
explícitamente en el RNF-16 y no solo los exitosos.

**¿Qué impedimentos tengo?**

Necesito que se decida qué hacemos con el **RNF-18**, el de disponibilidad. Pide 95 % de
disponibilidad y máximo 4 horas para levantar el sistema si se cae, y no hay forma de medir
ninguna de las dos cosas porque no hay un ambiente en operación durante el proyecto. Hay dos
caminos: declararlo fuera del alcance con justificación, o aceptar un criterio parecido que sí
podamos comprobar, como que el backend arranque bien, que el servicio de salud responda y que el
frontend muestre un mensaje decente cuando el backend esté caído. Lo que no quiero es llegar al
día 15 sin que eso esté decidido.

---

## 3. Lo que respondió el equipo

| Qué planteamos | Qué respondieron | Quién lo dijo | ¿Quedó decidido? |
| --- | --- | --- | --- |
| Fechas reales de la Entrega 2 y 3 | | | ⬜ |
| Alcance de rendimiento: qué se mide y qué se declara fuera | | | ⬜ |
| Qué hacer con RNF-18 | | | ⬜ |
| Activar la revisión de librerías del backend (H-01) | | | ⬜ |
| Arreglar el umbral de JaCoCo (H-08) | | | ⬜ |
| Que ningún requerimiento pase F2 sin su fila en la matriz | | | ⬜ |
| Entrega de los Apéndices 4.1 y 4.2 | | | ⬜ |

---

## 4. Decisiones que quedaron tomadas

| # | Decisión | Responsable | Para cuándo |
| --- | --- | --- | --- |
| 1 | Fecha real del día 1 del proyecto y de las entregas 2 y 3 | | |
| 2 | | | |

---

## 5. Compromisos nuevos

> Copiar a la tabla de compromisos del [README](../README.md).

| ID | Compromiso | Quién | Para cuándo |
| --- | --- | --- | --- |
| C-01 | Medir el bundle y proponer umbral para RNF-08 | Andrés | R2 · 11 nov |
| C-02 | Reproducir H-08 y confirmarlo | José | 8 nov |
| C-03 | Conseguir los Apéndices 4.1 y 4.2 | Ambos | R2 · 11 nov |
| C-04 | Llenar la matriz de impacto (A2) | Ambos | R2 · 11 nov |
| C-05 | Entregar los criterios a los analistas de prueba | Ambos | R2 · 11 nov |
| C-06 | Confirmar auditoría de autenticaciones fallidas | José | R2 · 11 nov |
| C-07 | Comparar matriz RBAC contra el Apéndice 4.1 | José | R2 · 11 nov |

---

## 6. Impedimentos que siguen abiertos

| Impedimento | A quién le toca resolverlo | Desde cuándo |
| --- | --- | --- |
| | | |

---

## 7. Evidencia que quedó en esta carpeta

| Archivo | Qué es |
| --- | --- |
| `Entrega1-RNF-Velez-Valencia.docx` | El documento de la entrega (está en la carpeta de arriba) |
| | |

---

## 8. Notas nuestras

Lo que hay que recordar de esta reunión:

- Si el equipo no se compromete con el acuerdo de que **ningún requerimiento pasa F2 sin su fila
  en la matriz de impacto**, nuestro rol se queda sin filtro y hay que volverlo a plantear en la
  reunión 2. Es el punto que más nos importa.
- Si la lista de mantenimientos priorizada no llega antes del día 8, no alcanzamos a tener la
  matriz antes del desarrollo. Eso hay que dejarlo dicho para que después no nos lo cobren a
  nosotros.
- Ojo con no presentar los hallazgos como si el proyecto estuviera mal hecho. La red de pruebas es
  grande y hay que reconocerlo. Varios de los hallazgos se cierran usando lo que ya existe.
