# Acta de reunión — Reunión 3

| | |
| --- | --- |
| **Reunión** | 3 de 4 |
| **Fecha y hora** | Domingo 15 de noviembre de 2026, 8:00 pm |
| **Día del proyecto** | Día 12 |
| **Duración real** | ⬜ |
| **Quiénes asistieron** | ⬜ |
| **Quiénes faltaron** | ⬜ |
| **Grabación** | ⬜ *(enlace; el manual exige que quede grabada)* |
| **Acta escrita por** | ⬜ |
| **Corresponde a** | Entrega 2 · «Registro de defectos y **verificación inicial de RNF**» |

> **Estado: preparada antes de la reunión.** Las secciones 1 y 2 están llenas porque es lo que
> llevamos. Las secciones 3 a 8 se llenan durante la reunión o inmediatamente después.

---

## 1. Lo que veníamos debiendo

Esta es la parte incómoda y hay que empezar por ella, porque si no la decimos nosotros la va a
decir otro. Los siete compromisos de la reunión 1 estaban todos pendientes al llegar al 15 de
noviembre. Lo que se cerró hoy, se cerró hoy.

| ID | Compromiso de la R1 | Para cuándo | Estado real |
| --- | --- | --- | --- |
| C-01 | Medir el bundle y proponer umbral para RNF-08 | R2 · 11 nov | 🟡 **Cumplido tarde** (15-nov): 356,04 kB / 100,14 kB. Propuesta: bajar el aviso a 420 kB |
| C-02 | Reproducir H-08 y confirmarlo | 8 nov | 🟢 **Cumplido y superado** (15-nov): además **corregido y verificado** |
| C-03 | Conseguir los Apéndices 4.1 y 4.2 del SRS | R2 · 11 nov | 🔴 **No cumplido.** No se pidieron |
| C-04 | Llenar la matriz de impacto (A2) | R2 · 11 nov | 🔴 **No cumplido.** A2 sigue con las filas vacías |
| C-05 | Entregar los criterios de RNF a los analistas de prueba | R2 · 11 nov | 🔴 **No cumplido.** A3 nunca se les entregó |
| C-06 | Confirmar auditoría de autenticaciones fallidas (RNF-16) | R2 · 11 nov | 🟢 **Cumplido** (15-nov): `AuditoriaIntegracionIT` y `AuditoriaAspectTest` lo cubren |
| C-07 | Comparar matriz RBAC contra el Apéndice 4.1 | R2 · 11 nov | ⚪ **Bloqueado por C-03.** Sin el apéndice no hay contra qué comparar |

**Cómo decirlo, sin excusas y sin autoflagelación:** tres de siete cumplidos, uno bloqueado por
otro, y tres no cumplidos. Los tres no cumplidos tienen una causa común y hay que nombrarla:
**no registramos actividad entre el 8 y el 15 de noviembre**, mientras el equipo registró 97
actividades. Eso es un incumplimiento nuestro del §12 («las actividades se registran
diariamente»), no un malentendido. Lo corregimos hoy con las filas que llevamos al libro
compartido, y de aquí al cierre se registra el mismo día.

---

## 2. Lo que vamos a decir

### Andrés Felipe Vélez Alcaraz

**¿Qué realicé?**

Ejecuté la verificación inicial de requisitos no funcionales, que es lo que esta entrega pide, y
el resultado está en una sola tabla: el semáforo de los 21 requisitos. **Pasamos de 7 verificados
a 10, y de 11 sin instrumento a 4.**

Tres cosas concretas:

Primero, **el requisito de HTTPS ya se puede verificar y pasa**. El 8 de noviembre dijimos que no
había forma de comprobarlo porque no había ambiente de producción. Sí lo hay: el backend está en
Render y el frontend lo tiene apuntado en su configuración de producción. Lo medí: responde por
HTTPS, acepta TLS 1.2 y 1.3, **rechaza TLS 1.0**, y si uno entra por HTTP lo redirige. Eso cumple
el requisito completo, y cierra uno de los hallazgos.

Segundo, **ya hay instrumento de medición de rendimiento**, que era el hueco más grande que
reportamos. Monté JMeter con dos planes de prueba, versionados en el repositorio, con los umbrales
del propio documento de requisitos puestos como condición de fallo: entrar en menos de 4 segundos,
catálogo en menos de 3, estadísticas en menos de 5, y 20 usuarios al mismo tiempo. El de
disponibilidad ya corrió contra Render: **90 sondeos, 90 exitosos, el servicio responde en 330
milisegundos de promedio**.

Tercero, **el bundle del frontend quedó medido**: 356 kilobytes sin comprimir, 100 transferidos,
contra un presupuesto de 500 que ya existía en el proyecto y que nadie había leído. Cumple con 29 %
de margen, y propongo bajar el aviso a 420 para que detecte el crecimiento antes de que se agote.

**¿Qué realizaré?**

Correr los 20 usuarios concurrentes, que es lo único que falta para cerrar cuatro requisitos de
rendimiento. Y lo voy a correr contra una base de datos local, no contra la nuestra, por una razón
que quiero que quede clara: **el archivo de configuración del backend apunta a Supabase, que es la
misma base que usa Render**. Levantarlo «en local» con esa configuración no es local. Correr una
prueba de carga ahí sería hacerle una prueba de carga a producción con todos ustedes trabajando
encima. Eso no lo voy a hacer.

**¿Qué impedimentos tengo?**

Dos, y los dos son de otros:

1. **El análisis de dependencias del backend sigue apagado, ocho días después.** Lo pedimos el 8
   de noviembre. Lo verifiqué hoy consultando GitHub directamente: **cero variables de
   repositorio**, los dos trabajos de seguridad se saltan en cada corrida. Y verifiqué por qué no
   lo arreglo yo: tengo permiso de escritura, **no de administrador**. Necesito que un
   administrador cree dos variables. Son dos campos en una pantalla de Settings. Y pido aprovechar
   el mismo momento para agregar el token de SonarCloud, porque es la misma pantalla y nos da la
   nota de mantenibilidad.
2. **Nos faltan los Apéndices 4.1 y 4.2 del documento de requisitos.** Este es un incumplimiento
   mío: era mi compromiso de la reunión 1 y no lo pedí formalmente. Lo pido ahora. El 4.2 define
   qué navegadores y dispositivos hay que cubrir, y sin él el alcance de compatibilidad lo estamos
   suponiendo.

### José Alejandro Valencia

**¿Qué realicé?**

**Cerré el hallazgo H-08, que era el único incumplimiento del documento de requisitos que
teníamos**, y lo cerré con corrección aplicada, no con un informe.

El requisito pide 70 % de cobertura de pruebas en cuatro módulos que el documento nombra uno por
uno: autenticación, permisos por rol, cálculo del nivel de logro y generación de conclusiones. La
configuración solo vigilaba los dos primeros. Son cuatro líneas de cambio. Lo medí antes de
tocarlo: los cuatro módulos ya estaban por encima del 70 % —el de nivel de logro y conclusiones
está en 96 % y 94 %— así que **el cambio no rompe nada: solo hace que el build empiece a vigilar lo
que el documento exige**. La cobertura global está en 92,39 %.

Y lo probé de las dos maneras, porque esto era el criterio que nos pusimos nosotros mismos: que
pase, y que **falle si la cobertura bajara**. Subí el umbral temporalmente a 99 % y la herramienta
nombró los dos paquetes nuevos. Antes de este cambio eran invisibles: el cálculo del nivel de logro
podía caer al 10 % de cobertura y el build seguía verde.

También revisé la incidencia 0000029, la del bloqueo tras cinco intentos fallidos, que es mía:
**está implementada y probada**. Lo único que falta es cerrar la resolución en Mantis.

**¿Qué realizaré?**

Abrir el Pull Request del cambio de cobertura, que Jean Paul tiene que aprobar porque nosotros no
aprobamos integraciones. En el mismo PR va la corrección del README, que contradice a la
configuración. Y entregarles los criterios de verificación a Santiago y Juan José, que es un
compromiso que debíamos desde el 11 y que les sirve para sus casos de prueba.

**¿Qué impedimentos tengo?**

Que el MTTR del requisito de disponibilidad **no tiene cómo medirse y no es culpa de la
herramienta**: se mide con el registro de una caída real, y no ha habido ninguna. Mi propuesta es
que quede escrito como «sin evento que medir», que no es ni cumple ni incumple. Pero eso lo tiene
que decidir el Product Owner, porque si no queda decidido por escrito es un criterio de
finalización incumplido y nos lo cobran a nosotros.

---

## 2.1 Las tres cosas que hay que levantar aunque incomoden

**(a) La incidencia 0000053 no tiene dueño y bloquea la entrega.**

Reportada por Juan José el 14 de noviembre: «falla intermitente al cargar combos de
semestre/asignatura/RA en múltiples módulos, presente en todos los roles», reproducibilidad *a
veces*. **Prioridad alta, severidad mayor, sin asignar.** Según el §7 del manual, alta bloquea la
entrega. Y no está en la hoja de reparto del libro.

Esto es nuestro por perfil: «intermitente» y «a veces» en varios módulos y todos los roles es
concurrencia, no lógica de negocio. Hay un antecedente escrito en el propio registro del equipo:
**ERR-002**, donde Tomás documentó que en Estadísticas una respuesta vieja podía sobrescribir la
más reciente porque las peticiones no se cancelaban. Si ese patrón se repitió en los módulos de
filtros en cascada, 0000053 es la misma causa replicada. Y es exactamente el defecto que 20 hilos
de JMeter vuelven determinista y que una prueba manual nunca va a reproducir.

**Lo que pedimos:** que se le asigne dueño esta noche, preferiblemente a quien trabajó el patrón de
filtros en cascada.

**(b) Las dos incidencias que el equipo nos asignó se resolvieron sin nuestra validación.**

La hoja de reglas del libro dice: «Especialistas RNF — definen y validan los patrones de paginación
y buscadores». Mantis clasifica **exactamente esas dos** —0000040 y 0000038— en la categoría «No
Funcionalidad», las únicas dos del tablero con esa categoría.

La 0000040 está resuelta y Tomás hizo lo correcto, reusar el patrón de Materias en siete listados.
Pero la decisión del patrón la tomó él. Y la 0000038 lleva **siete días en «asignada»** sin
movimiento. Lo registramos como hallazgo contra nosotros (H-12) porque es nuestro rol y la
evidencia de que lo ejercimos no existe. Lo corregimos con una página con el patrón escrito, antes
del martes.

**(c) Ninguna de las 31 incidencias está cerrada en Mantis.**

22 resueltas, 6 nuevas, 3 asignadas, **0 cerradas**. Las reglas del propio equipo definen
«cerrada» como revisión técnica + pruebas + PR integrado + documentación al día. Mientras ninguna
llegue ahí, el indicador «% de cambios con trazabilidad completa» —uno de los tres que el libro
deja para llenar a mano— es honestamente **0 %**. Lo decimos ahora para que nadie lo llene con un
número optimista, porque el §10 prohíbe alterar datos para aparentar cumplimiento.

---

## 3. Lo que respondió el equipo

| Qué planteamos | Qué respondieron | Quién lo dijo | ¿Quedó decidido? |
| --- | --- | --- | --- |
| Asignar dueño a la incidencia 0000053 | | | ⬜ |
| Activar las variables del SCA del backend (H-01) + token de SonarCloud | | | ⬜ |
| Aprobar el PR del fix de cobertura (H-08) | | | ⬜ |
| Decisión D-1: RNF-02, RNF-05 y RNF-07 — se miden o se aceptan como deuda | | | ⬜ |
| Decisión D-2: RNF-09 fuera de alcance con justificación | | | ⬜ |
| Decisión D-3: RNF-18 MTTR — «sin evento que medir» | | | ⬜ |
| H-03: al menos un spec E2E por rol, o deuda técnica declarada | | | ⬜ |
| Entrega de los Apéndices 4.1 y 4.2 | | | ⬜ |
| URL de producción del frontend en Vercel (P-08) | | | ⬜ |
| Pasar a `cerrada` las incidencias con PR integrado (H-13) | | | ⬜ |

---

## 4. Decisiones que quedaron tomadas

| # | Decisión | Responsable | Para cuándo |
| --- | --- | --- | --- |
| 1 | | | |
| 2 | | | |

---

## 5. Compromisos nuevos

> Copiar a la tabla de compromisos del [README](../README.md).

| ID | Compromiso | Quién | Para cuándo |
| --- | --- | --- | --- |
| C-08 | Abrir el PR del fix de H-08 + corrección del README (H-07) | José | lun 16 nov |
| C-09 | Correr los 20 usuarios de JMeter contra PostgreSQL local | Andrés | lun 16 nov |
| C-10 | Escanear los dos repos con SonarQube local y adjuntar la nota de mantenibilidad | Andrés | lun 16 nov |
| C-11 | Entregar A3 a Santiago Torres y Juan José Narváez (compromiso C-05, vencido) | Ambos | hoy, al terminar la reunión |
| C-12 | Documento de una página con el patrón de paginación y de buscador (cierra H-12) | Ambos | lun 16 nov |
| C-13 | Llenar A2 con una fila por incidencia resuelta y su veredicto de RNF | Ambos | mar 17 nov |
| C-14 | Pedir formalmente los Apéndices 4.1 y 4.2 (C-03, vencido) | Andrés | hoy, en la reunión |
| C-15 | Registrar actividades en el libro el mismo día, de aquí al cierre | Ambos | diario |

---

## 6. Impedimentos que siguen abiertos

| Impedimento | A quién le toca resolverlo | Desde cuándo |
| --- | --- | --- |
| Variables de SCA del backend sin crear (H-01) | Admin del repo: Juan Camilo / Jean Paul | **8 nov · 8 días** |
| Apéndices 4.1 y 4.2 del SRS sin entregar | Product Owner | 8 nov |
| Incidencia 0000053 sin dueño, severidad alta | Scrum Master | 14 nov |
| URL de producción del frontend desconocida | Quien hizo el despliegue en Vercel | 15 nov |

---

## 7. Evidencia que quedó en esta carpeta

| Archivo | Qué es |
| --- | --- |
| [`A6-semaforo-rnf.md`](../../A6-semaforo-rnf.md) | El semáforo de los 21 RNF, con las tres mediciones nuevas |
| [`jmeter/`](../../jmeter/) | Los dos planes de prueba y su README |
| `jmeter/resultados/rnf18-render.jtl` | Datos crudos del sondeo de disponibilidad (90 muestras) |
| `jmeter/resultados/rnf18-render-reporte/index.html` | Informe HTML de JMeter |
| [`registros-equipo-rnf.md`](../../registros-equipo-rnf.md) | Filas para pegar en el libro compartido del equipo |
| `estado de mantis.csv` | Exportación de Mantis del 15-nov usada para H-11, H-12 y H-13 |
| ⬜ | Grabación o enlace |

---

## 8. Notas nuestras

- **Empezar por lo que debíamos.** Si abrimos con los logros y alguien saca los compromisos
  pendientes, perdemos la credibilidad del resto. Tres de siete cumplidos, dicho de frente.
- **El dato que más pesa a favor es H-08 corregido**, porque es el único incumplimiento del SRS que
  habíamos reportado y lo cerramos nosotros, con prueba de que la regla ahora muerde. Pero no sirve
  de nada sin el PR aprobado: insistir en eso con Jean Paul antes de que termine la reunión.
- **No inflar RNF-18.** 90 de 90 en tres minutos y medio no es «uptime del 100 %». Decir la
  reserva en voz alta nos cuesta cero y nos protege si alguien pregunta.
- **H-12 es un hallazgo contra nosotros y conviene presentarlo nosotros.** Que el equipo vea que
  aplicamos el mismo criterio para adentro que para afuera es lo que hace que nos crean el resto.
- Ojo con el calendario: el libro del equipo dice Entrega 2 = sábado 14 y Entrega 3 = martes 17 a
  las 8 pm; el documento Word dice Entrega 2 = domingo 15 a las 8 pm. **Hay que confirmar cuál
  manda**, porque cambia qué estamos entregando esta noche.
