# José, esto es lo que se hizo hoy

**15 de noviembre de 2026** · Andrés Felipe Vélez Alcaraz → José Alejandro Valencia
Verificación inicial de RNF para la Entrega 2 · reunión 3, hoy 8:00 pm

> **Lee primero esto, en 2 minutos, y después abre [A6](A6-semaforo-rnf.md).** Al final de esta
> nota están las cuatro cosas que te toca hacer a ti.

---

## 1. En una frase

El producto **ya está desplegado** —y eso no lo sabíamos el 8 de noviembre—, así que dos requisitos
que habíamos declarado imposibles de verificar resultaron medibles; se construyó el instrumento de
rendimiento que faltaba; y **se corrigió H-08**, el único incumplimiento documentable del SRS que
teníamos.

**El semáforo pasó de 7 🟢 / 3 🟡 / 13 🔴 a 9 🟢 / 9 🟡 / 5 🔴**, sobre 23 criterios.

> **Por qué 23 y no 21.** RNF-18 se cuenta como dos (uptime y MTTR se verifican con instrumentos
> distintos) y RNF-20 también (cobertura y OpenAPI). Es la misma base para las dos fechas, así que
> la comparación es válida. Si alguien pregunta en la reunión, esa es la respuesta.

---

## 2. Lo que cambió, requisito por requisito

### 🟢 RNF-11 (HTTPS con TLS 1.2+) — **pasó de rojo a verde**

Este es **tuyo**, y es el que mejor se ve en la reunión.

El 8 de noviembre dijimos «no verificable sin entorno de producción». **Sí hay producción**: el
backend está en `https://software4-sigra-backend.onrender.com`, y la URL estaba a la vista en
`src/environments/environment.ts:3` del frontend. Render termina TLS por defecto, que es
exactamente lo que el requisito pide.

Medido:

| Lo que exige el SRS | Resultado |
| --- | --- |
| HTTPS en producción | ✅ HTTPS sobre HTTP/2, `/actuator/health` → 200 `UP` |
| TLS 1.2 **o superior** | ✅ 1.2 → 200 · 1.3 → 200 |
| Que no se acepte menos | ✅ TLS 1.0 **rechazado** en el handshake (exit 35) |
| Que no quede tráfico en claro | ✅ HTTP → **301** hacia HTTPS |

**Cierra [H-10](A4-hallazgos-rnf.md).** Comandos exactos en [A6 §3.1](A6-semaforo-rnf.md) y en A3 §1.

> ⚠️ **La reserva, y hay que decirla:** esto verifica el **backend**. El frontend está en Vercel y
> hay que medirle lo mismo, pero **su URL de producción no está escrita en ningún archivo de los dos
> repositorios**. Quedó como pedido **P-08**.

### 🟢 RNF-20 (a) — **H-08 corregido y verificado**

Este es el que tú reportaste el 8 de noviembre y es **el más fuerte que llevamos**, porque es el
único incumplimiento del SRS que habíamos encontrado y lo cerramos nosotros.

El cambio son 4 líneas en `SIGRA/build.gradle`:

```diff
  'co.edu.uco.sigra.auth.security',
- 'co.edu.uco.sigra.config'
- // Nivel de logro: agregar 'co.edu.uco.sigra.estadisticas.service*' cuando exista RF-14.
+ 'co.edu.uco.sigra.config',
+ // RF-14 (calculo de nivel de logro) y RF-16 (generacion de conclusiones):
+ // el SRS los nombra como modulos obligatorios del RNF-20 (a). Hallazgo H-08.
+ 'co.edu.uco.sigra.estadisticas.service*'
```

**Lo medí antes de tocar nada**, porque si la cobertura hubiera estado por debajo del 70 % el
cambio habría roto el build de todo el equipo la noche de una entrega:

| Módulo del SRS | Paquete | Cobertura |
| --- | --- | --- |
| Global | — | **92,39 %** |
| RF-04 | `auth.service` / `.impl` / `auth.controller` | 92,14 % / 100 % / 100 % |
| RF-05 | `auth.security` / `config` | 74,47 % / 96,21 % |
| **RF-14 y RF-16** | `estadisticas.service` | **96,48 %** ← nuevo |
| **RF-14 y RF-16** | `estadisticas.service.impl` | **93,69 %** ← nuevo |

`./gradlew jacocoTestCoverageVerification` → **BUILD SUCCESSFUL**.

**Y se probó la otra mitad, que es el criterio de cierre que nos pusimos nosotros en A3 §5:** no
basta con que pase, hay que probar que **fallaría** si la cobertura bajara. Subiendo el umbral de
esa regla a 0,99 de forma temporal:

```
Rule violated for package co.edu.uco.sigra.estadisticas.service.impl: ... is 0.93, but expected minimum is 0.99
Rule violated for package co.edu.uco.sigra.estadisticas.service:      ... is 0.96, but expected minimum is 0.99
```

JaCoCo **nombra** los dos paquetes. Antes del cambio eran invisibles: el cálculo del nivel de logro
podía caer al 10 % y el build seguía verde. El umbral quedó en 0,7, que es el del SRS.

> 🔴 **Lo que falta y es tuyo: abrir el PR.** El cambio vive en la copia de trabajo del backend. Sin
> el PR integrado, RNF-20 (a) **sigue incumplido en `develop`**. Ver §5 de esta nota.

### 🟡 RNF-18 (uptime) — medido, con reserva

Se montó `jmeter/RNF-18-disponibilidad.jmx`: un hilo, `GET /actuator/health` cada 2 s, con dos
aserciones (código 200 **y** cuerpo que contenga `UP`).

```
summary =     90 in 00:03:31 =    0.4/s Avg:   332 Min:   270 Max:  1620 Err:     0 (0.00%)
```

**90 de 90 muestras exitosas.** p50 289 ms · p90 327 ms · p95 526 ms · p99 1 472 ms.

> ⚠️ **Queda amarillo a propósito, y esto es importante que lo digas igual que yo:** 100 % en una
> ventana de **208 segundos** no es «uptime ≥ 95 %». El requisito habla de un periodo de operación.
> Lo que demostramos es que el servicio responde y que **ahora existe un instrumento repetible**,
> que antes no existía. Escribir «uptime del 100 %» sería el dato inflado que el §10 del manual
> prohíbe, y si alguien nos lo pilla perdemos la credibilidad del resto del informe.

**El MTTR sigue sin dato**, y no por falta de herramienta: se mide con el registro de una caída real
y no ha habido ninguna. El veredicto honesto es **«sin evento que medir»**, que no es «cumple» ni
«no cumple». Es tu decisión **D-3** para el PO.

### 🟡 RNF-01, 03, 04, 06 — instrumento listo, sin ejecutar

`jmeter/RNF-01-06-rendimiento.jmx`, con los umbrales del SRS puestos como **Duration Assertion**
(login < 4 000 ms, catálogo < 3 000 ms, estadísticas < 5 000 ms) y `-Jusuarios=20`, que es RNF-01
literal. La contraseña **no** está en el archivo: se pasa con `-Jclave=`.

> ⚠️ **Por qué no lo ejecuté, y es un hallazgo en sí mismo:** el `.env` del backend apunta a
> `aws-0-us-east-1.pooler.supabase.com`, que es **la misma base de datos que usa el despliegue de
> Render**. Levantar el backend «en local» con ese `.env` **no es local**: los 20 usuarios le caen a
> la base compartida del equipo, hoy, la noche de una entrega. Sería una prueba de carga en
> producción disfrazada de prueba local.
>
> Lo correcto es PostgreSQL local en Docker con `docs/db/SIGRA_SCHEMA_CURRENT.sql` y un `.env`
> aparte. La receta está en [`jmeter/README.md` §4.1](jmeter/README.md).

### 🟡 RNF-08 — bundle medido (cierra el compromiso C-01)

El presupuesto **ya existía** y nunca lo habíamos leído: `angular.json:51-62` declara `initial` con
aviso a 500 kB y error a 1 MB, y se evalúa en cada `ng build` del CI. El valor real:

```
Initial chunk files | Names         |  Raw size | Estimated transfer size
                    | Initial total | 356.04 kB |               100.14 kB
```

**Cumple con 29 % de margen.** Propuesta: **bajar el aviso de 500 kB a 420 kB**, que deja 18 % de
crecimiento y detecta una regresión antes de que el margen se agote.

---

## 3. Lo que descubrí cruzando el CSV de Mantis con el libro del equipo

Esto es lo nuevo y lo que más peso tiene en la reunión. Son tres hallazgos nuevos.

### 🔴 H-11 · La incidencia 0000053 no tiene dueño y **bloquea la entrega**

| Campo | Valor |
| --- | --- |
| Resumen | «Falla intermitente al cargar combos de semestre/asignatura/RA en múltiples módulos, presente en todos los roles» |
| Informador | `jnarvaez` (Juan José, analista de pruebas), 14-nov |
| **Asignada a** | **(vacío)** |
| Prioridad / severidad | **alta / mayor** → por el §7, **bloquea la entrega** |
| Reproducibilidad | **a veces** |
| Estado | **nueva** · y no está en la hoja «Reparto» del libro |

**Por qué es nuestro:** «intermitente» y «a veces» en varios módulos y todos los roles es
concurrencia, no lógica de negocio. Una regla mal escrita falla siempre; esto falla a veces. Y hay
un antecedente escrito en el propio registro del equipo: **ERR-002**, donde Tomás Gómez documentó
que en Estadísticas «una respuesta vieja podía sobrescribir la más reciente» porque las peticiones
no cancelaban las anteriores. Si ese patrón se repitió en los módulos de filtros en cascada
(0000044, 0000045, 0000047), **0000053 es la misma causa raíz replicada**.

**Y es el mejor argumento que tenemos para que el equipo adopte JMeter:** 20 hilos vuelven
**determinista** un fallo que a mano es «a veces». No es burocracia de calidad, es la forma de
cazar un defecto abierto de severidad alta que hoy nadie tiene asignado.

### 🔴 H-12 · Las dos incidencias que el equipo nos asignó se resolvieron sin nuestra validación

**Este hallazgo es contra nosotros, y conviene que lo presentemos nosotros.**

La hoja «Guía y reglas» del libro dice textualmente:

> **Especialistas RNF** — José Alejandro, Andrés Vélez — *Definen y validan los patrones de
> paginación y buscadores.*

Y Mantis clasifica **exactamente esas dos** en la categoría **«No Funcionalidad»** — son las únicas
dos del tablero con esa categoría:

| ID | Resumen | Estado | ¿Validamos? |
| --- | --- | --- | --- |
| **0000040** | Varias tablas no tienen paginación | resuelta | **No** |
| **0000038** | Listados largos (≈500 docentes) sin buscador | **asignada desde el 8-nov** | **No** |

Tomás Marín hizo lo correcto en la 0000040 (reusó el patrón de Materias en siete listados), pero la
decisión del patrón la tomó él. Y la 0000038 lleva **siete días** sin movimiento. Hay hasta una nota
de Andrea (ACT-073) coordinando el patrón que nos correspondía a nosotros.

**Se corrige con un documento de una página** (compromiso C-12): tamaño de página, que la paginación
respete el filtro activo —que es justo lo que falló en **ERR-001**—, vuelta a la página 1, mínimo de
caracteres de búsqueda y estado vacío.

### 🔴 H-13 · Ninguna incidencia está cerrada en Mantis

**0 de 31.** 22 resueltas, 6 nuevas, 3 asignadas. Y 12 de las «resueltas» siguen con resolución
`abierta` en vez de `corregida` — entre ellas **tus dos**, 0000029 y 0000030.

Las reglas del propio equipo definen `cerrada` como «revisión técnica + pruebas + PR mergeado +
documentación al día». Mientras ninguna llegue ahí, el indicador **«% de cambios con trazabilidad
completa» es honestamente 0 %**, y lo decimos nosotros antes de que alguien lo llene con un número
optimista.

### ⬆️ H-03 sube de media a **alta**

El producto ganó **ocho módulos** entre el 8 y el 15 de noviembre (Reportes R1/R2/R6, Estudiante
`me`, Facultad, `semestres/mios`, `auditoria/mis-eventos`, Reportes por facultad, Estadísticas en
tres páginas, nombres separados **con migración de datos**) y la suite E2E de navegador sigue siendo
**un solo archivo**: `e2e/auth.spec.ts`. Varios de esos módulos tienen reglas de alcance por rol y
ninguna prueba de navegador las recorre.

### ✅ Y una buena, sobre tu incidencia 0000029

La revisé: **el bloqueo tras 5 intentos fallidos está implementado y probado**
(`Usuario.intentosFallidos`, `fechaBloqueo`, `estaBloqueado`, respuesta 423 documentada en OpenAPI,
cubierto por `AuthControllerTest` y `UsuarioTest`). Ojo: el bloqueo es **RF-04**, un requisito
funcional, no un RNF — pero RF-04 es uno de los cuatro módulos obligatorios del RNF-20, así que nos
toca de refilón. **Lo único que falta es cerrar la resolución en Mantis.**

---

## 4. Los dos bloqueos que no son nuestra culpa, y hay que decirlo así

### H-01 · El SCA del backend sigue apagado, **8 días después**

Lo reconfirmé de forma autoritativa, no leyendo el workflow:

```
$ gh api repos/juancabernal/software4-SIGRA-backend/actions/variables
{"variables":[],"total_count":0}
```

**Cero variables.** Los dos trabajos de seguridad se saltan en cada corrida, y el propio workflow
advierte en su comentario que *skipped* **no significa auditado**.

Y verifiqué por qué no lo arreglamos nosotros:

```
$ gh api repos/juancabernal/software4-SIGRA-backend --jq '.permissions'
{"admin":false,"maintain":false,"pull":true,"push":true,"triage":true}
```

Crear una variable de repositorio exige `admin`; lo nuestro es `push`. **No es desgana: es falta de
permiso.** Eso convierte H-01 en un pedido al admin, no en una tarea nuestra, y conviene decirlo con
esas palabras porque llevamos 8 días cargando con algo que no podemos hacer.

### Docker Desktop no está arrancado

Bloquea las dos cosas que faltan: PostgreSQL local para los 20 usuarios, y SonarQube local. Es un
clic, y lo resuelvo yo mañana.

**Sobre SonarQube**, el plan quedó en dos caminos (A3 §7.2):

| Camino | Qué da | Bloqueo |
| --- | --- | --- |
| **SonarQube Community en Docker** | La nota de mantenibilidad hoy, sin depender de nadie | Docker Desktop |
| **SonarCloud en el CI** | Permanente, y **gratis en repos públicos** (los dos lo son: verificado con `gh repo view`) | `SONAR_TOKEN` → **mismo bloqueo de permisos que H-01** |

Conviene pedir el token **en el mismo momento** que las variables de SCA: es la misma pantalla de
Settings, así es un solo favor en vez de dos.

---

## 5. Lo que te toca a ti, José

| # | Qué | Para cuándo |
| --- | --- | --- |
| **1** | **Abrir el PR del fix de H-08** en el backend, y meter en el mismo PR la corrección del README (eso cierra **H-07**, que quedó más desactualizado por este cambio). El mensaje de commit está abajo en §7 | **lun 16 nov** · C-08 |
| **2** | **Perseguir a Jean Paul** para que lo apruebe. Sin PR integrado, RNF-20 (a) sigue incumplido en `develop` y el logro no cuenta | hoy, en la reunión |
| **3** | **Decir tu parte del guion** en la reunión. Está escrita en [acta.md §2](evidencias-reuniones/reunion-3-2026-11-15/acta.md), sección «José Alejandro Valencia» | hoy 8 pm |
| **4** | **Plantear la decisión D-3 al PO**: el MTTR queda como «sin evento que medir». Si no queda decidido **por escrito**, es un criterio de finalización incumplido y nos lo cobran a nosotros | hoy 8 pm |
| **5** | **Cerrar la resolución de 0000029 y 0000030 en Mantis** (pasarlas a `corregida`). Son tuyas y están implementadas | esta semana |
| **6** | Conmigo: el documento de una página con el patrón de paginación y buscador, que cierra **H-12** | lun 16 nov · C-12 |

---

## 6. Lo incómodo, para que no te sorprenda en la reunión

**De los 7 compromisos de la reunión 1, cumplimos 2, uno tarde, 3 no, y 1 quedó bloqueado por
otro.** La causa común está escrita y no se maquilla: **no registramos actividad entre el 8 y el 15
de noviembre, mientras el equipo registraba 97 actividades.** Eso incumple el §12 («las actividades
se registran diariamente») y el §11 evalúa el cumplimiento individual «sobre evidencias
verificables, no únicamente en la percepción de los compañeros».

| ID | Compromiso | Estado |
| --- | --- | --- |
| C-01 | Medir el bundle (RNF-08) | 🟡 cumplido tarde (hoy) |
| C-02 | Reproducir H-08 | 🟢 cumplido **y superado**: además corregido |
| C-03 | Conseguir los Apéndices 4.1 y 4.2 | 🔴 no cumplido — no se pidieron |
| C-04 | Llenar A2 | 🔴 no cumplido |
| C-05 | Entregar A3 a los analistas de prueba | 🔴 no cumplido |
| C-06 | Auditoría de autenticaciones fallidas | 🟢 cumplido (hoy) |
| C-07 | Matriz RBAC vs. Apéndice 4.1 | ⚪ bloqueado por C-03 |

**La estrategia para la reunión es empezar por esto**, no por los logros. Si abrimos celebrando
H-08 y alguien saca los compromisos pendientes, perdemos la credibilidad del resto. Tres de siete,
dicho de frente, y después lo que sí se hizo.

**Ya está corregido lo que se podía corregir hoy:** las 14 actividades, 4 usos de IA y 7 errores
están listos para pegar en el libro, en
[`registros-equipo-rnf.md`](registros-equipo-rnf.md). **Revisa los correlativos antes de pegar**
(arrancan en ACT-098 y ERR-012) por si alguien agregó filas entremedio.

### Una lección de método que nos pasó dos veces

**Dos de catorce hallazgos se levantaron asumiendo en vez de comprobando, y los dos se cayeron:**

- **H-06**: dijimos que ningún RNF cubría disponibilidad. RNF-18 existía. **Retirado el 7-nov.**
- **H-10**: dijimos que no había producción para verificar TLS. Sí había, y la URL estaba en
  `environment.ts`. **Cerrado hoy** — y el requisito **cumple**.

La regla que sale de ahí, y que vale para la retrospectiva: **antes de escribir «no se puede
verificar», abrir el archivo donde estaría la respuesta.** Un hallazgo falso nos cuesta más
credibilidad que uno que no encontramos. Los dos quedan en la tabla de A4 a propósito: retirar un
hallazgo en silencio es peor que haberlo abierto.

---

## 7. Dónde está cada cosa

| Archivo | Qué es | Estado |
| --- | --- | --- |
| **[A6-semaforo-rnf.md](A6-semaforo-rnf.md)** | **Nuevo.** El semáforo de los 23 criterios con la evidencia de cada veredicto. **Es la herramienta de la reunión** | ⭐ empieza por aquí |
| [A4-hallazgos-rnf.md](A4-hallazgos-rnf.md) | 2 hallazgos cerrados, 4 en corrección, 4 nuevos (H-11…H-14), uno que sube de severidad | actualizado |
| [A3-criterios-verificacion.md](A3-criterios-verificacion.md) | Los criterios con su comando. RNF-11 y RNF-18 reescritos; nueva §7.2 de SonarQube | actualizado |
| [A1-catalogo-rnf.md](A1-catalogo-rnf.md) · [A5-informe-calidad.md](A5-informe-calidad.md) | A1 con la comparación 8-nov/15-nov; A5 pasó de esqueleto a **borrador avanzado** | actualizado |
| [registros-equipo-rnf.md](registros-equipo-rnf.md) | **Nuevo.** Las filas para pegar en el Excel del equipo | ⭐ hay que pegarlas |
| [evidencias-reuniones/reunion-3-2026-11-15/acta.md](evidencias-reuniones/reunion-3-2026-11-15/acta.md) | **Nuevo.** Tu guion y el mío, el seguimiento de C-01…C-07 y los compromisos nuevos C-08…C-15 | ⭐ léelo antes de las 8 |
| [jmeter/](jmeter/) | **Nuevo.** Los dos planes, el README con la receta, y el `.jtl` de las 90 muestras | — |
| [evidencias-reuniones/README.md](evidencias-reuniones/README.md) | Tabla de compromisos con estado real, y 4 pedidos nuevos al equipo (P-08…P-11) | actualizado |
| [GUIA-TRABAJO-RNF.md](GUIA-TRABAJO-RNF.md) | Bitácora §9 al día + la lección de método | actualizado |

**El fix de H-08 no está en este repositorio**: está en la copia de trabajo del backend, en
`software4-SIGRA-backend/SIGRA/build.gradle`. Compruébalo con:

```bash
git -C software4-SIGRA-backend diff SIGRA/build.gradle
```

Y para regenerar el informe HTML de JMeter (no se versiona, son 127 archivos de librerías):

```bash
jmeter -g mantenimiento-rnf/jmeter/resultados/rnf18-render.jtl \
       -o mantenimiento-rnf/jmeter/resultados/rnf18-render-reporte
```

---

Cualquier cosa que no cuadre, dímelo **antes** de la reunión y no durante. Si uno de los dos
contradice al otro en vivo, el equipo deja de creernos los dos.

— Andrés
