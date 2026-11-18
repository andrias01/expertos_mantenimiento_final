# DefectDojo — consolidar los hallazgos de ZAP, Trivy y Sonar en un tablero

Responde al pendiente de la §9 del [README de herramientas](../README.md): *«Consolidar en un
tablero los hallazgos de ZAP, Trivy, Sonar y Lighthouse»*.

> **Nada de este documento está ejecutado todavía.** Es el procedimiento y los archivos listos
> para correrlo. Por la regla de método de A4 (ACT-122, H-06, H-10: no escribir «esto funciona»
> antes de correrlo), los resultados se pegan aquí **después** de la primera corrida, y hasta
> entonces la §9 del README de herramientas se queda como está.

---

## 0. Qué gana el proyecto con esto, y qué no

**Lo que gana, y no lo da ninguna de las otras cinco herramientas:**

| | |
| --- | --- |
| **Deduplicación** | Trivy del backend trae 4 CRITICAL + 10 HIGH. Al reescanear la semana siguiente vuelven los mismos CVE. DefectDojo los reconoce como el mismo hallazgo en vez de 14 nuevos |
| **Estado por hallazgo** | Un CVE se cierra como *Mitigated*, *False Positive* o *Out of Scope*, con quién y cuándo. Hoy eso vive en prosa en `A4-hallazgos-rnf.md` |
| **Reaparición** | Con `reimport-scan`, un hallazgo arreglado que vuelve sale marcado **Reopened**. Eso es exactamente la pregunta «¿este mantenimiento degradó algo?» aplicada a seguridad |
| **El falso positivo queda registrado** | La vulnerabilidad de Sonar en el frontend (`new URL(url, 'http://relative.invalid')`) y los 6 HIGH del `npm` de la imagen base se marcan una vez y no vuelven a discutirse en cada corrida |

**Lo que NO hace, y hay que decirlo en la reunión para que nadie se confunda:**

- **No sustituye a `A6-semaforo-rnf.md`.** DefectDojo razona en vulnerabilidades, no en RNF.
  No sabe qué es «autenticación < 4 s» ni «contraste 4.5:1». De los 23 criterios solo toca
  los de seguridad (RNF-10 a 17), y de refilón.
- **No mide nada.** Es un almacén. Si el escaneo que entra es el falso verde de «120 PASS, 0 WARN»
  porque ZAP nunca se autenticó, DefectDojo lo muestra verde con total convicción.
- **No entra solo al CI**, que es donde de verdad serviría. Eso vuelve a depender de **H-01**
  (Andrés no tiene `admin` en el repositorio).

Dicho de frente: la objeción de la §9 —«una herramienta más que nadie alcanza a usar»— sigue en
pie si esto se monta y se abandona. Vale la pena **solo** si se convierte en el sitio único donde
se triagea la seguridad de la Entrega 3. Si no, el `evidencias/` y A6 ya cumplen.

---

## 1. Antes de clonar nada: los dos bloqueos reales

### 1.1 El puerto 8080 está ocupado

DefectDojo publica su nginx en **8080 por defecto**, y en esta máquina el 8080 es de
`sigra-backend`. El 8081 es el backend contra la base aislada, el 9000 Sonar, el 3001 Uptime Kuma,
el 4200 el frontend, el 5433 PostgreSQL.

**Se usa el 8084.** El puerto se cambia con `DD_PORT` en el `.env` de la carpeta clonada —
**no** en el override. Las listas `ports` de Compose se **concatenan** cuando hay override, no se
reemplazan: publicar `"8084:8080"` ahí dejaría el 8080 publicado igual y chocaría con el backend.

Comprobarlo antes de levantar, que es gratis:

```powershell
docker compose config | Select-String "published"
```

### 1.2 La memoria

En esta máquina hay 8 GB. DefectDojo levanta **seis contenedores** (nginx, uwsgi, celerybeat,
celeryworker, postgres, redis) y pide del orden de 2–2,5 GB. SonarQube ya se come ~2 GB, más el
PostgreSQL aislado, Uptime Kuma, el backend y Docker Desktop.

**No caben los dos a la vez con holgura.** Antes de levantar DefectDojo:

```powershell
docker compose -f "mantenimiento-rnf\herramientas-rnf\docker-compose.yml" stop sonarqube
```

`stop` conserva el volumen `sonarqube-data`, así que el tablero de Sonar no se pierde.
**No parar `uptime-kuma`**: cada hora apagado es una hora menos de ventana para RNF-18, que es el
criterio que solo mejora con el tiempo.

Excepción: si se va a usar el import por API de Sonar (§7), los dos tienen que estar arriba a la
vez. Eso es un rato, no el día entero.

---

## 2. Instalación

DefectDojo no se instala con una imagen suelta: se clona el repositorio, que trae el
`docker-compose.yml` con los seis servicios y el contenedor `initializer` que crea el esquema.

```powershell
cd "E:\Card SK hynix 2TB\Documents\Escritorio Documentos\Semestre 9\Software 4\Trabajo\SIGRA"
git clone https://github.com/DefectDojo/django-DefectDojo
cd django-DefectDojo
```

> Se clona **fuera** del repositorio de SIGRA, al lado. No es código del proyecto y no debe
> acabar en un commit.

Copiar el override y fijar el puerto:

```powershell
$dd = "E:\Card SK hynix 2TB\Documents\Escritorio Documentos\Semestre 9\Software 4\Trabajo\SIGRA\django-DefectDojo"
$hr = "E:\Card SK hynix 2TB\Documents\Escritorio Documentos\Semestre 9\Software 4\Trabajo\SIGRA\repositorio\mantenimiento-rnf\herramientas-rnf"

Copy-Item "$hr\defectdojo\docker-compose.override.yml" $dd
Set-Content -Path "$dd\.env" -Value "DD_PORT=8084" -Encoding utf8
```

El override hace **una sola cosa**: mete `uwsgi` y `celeryworker` en la red `sigra-rnf`, la misma
donde viven `sonarqube` y `sigra-pg-rnf`, para que §7 sea posible. Si no se va a usar Sonar por
API, se puede no copiar.

La red tiene que existir (la crea `levantar.ps1`):

```powershell
docker network create sigra-rnf
```

Falla con *«network with name sigra-rnf already exists»* si ya está, y eso está bien.

---

## 3. Primer arranque y la contraseña

```powershell
docker compose up -d
```

La primera vez **tarda hasta 3 minutos**: el `initializer` crea el esquema y siembra los 200 y pico
tipos de prueba. Hasta que termine, el 8084 responde 502.

La contraseña de `admin` **se genera sola y solo se imprime una vez**:

```powershell
docker compose logs initializer | Select-String "Admin password:"
```

**Anotarla en el momento.** Si el log ya rotó o se perdió:

```powershell
docker compose exec uwsgi ./manage.py shell -c "from django.contrib.auth.models import User; u = User.objects.get(username='admin'); u.set_password('CambiarEsto123!'); u.save()"
```

Tablero: <http://localhost:8084>

> Misma trampa que SonarQube en §4.1 del README de herramientas: la credencial inicial es de un
> solo uso. Allí costó la cuenta `admin`.

---

## 4. Cómo se organiza, antes de subir nada

DefectDojo tiene cuatro niveles. Decidirlos ahora evita rehacerlo:

```
Product Type : Software 4 - UCO
  Product    : SIGRA Backend          Product : SIGRA Frontend
    Engagement : Mantenimiento nov-2026  (uno por entrega)
      Test : ZAP API autenticado (admin) 2026-11-16
      Test : Trivy imagen backend 2026-11-16
      Test : SonarQube API 2026-11-16
```

**Backend y frontend van como productos separados.** Tienen superficie, dueño y cadena de
dependencias distintas, y mezclarlos rompe la deduplicación: un CVE de `npm` y uno de una librería
Java nunca son el mismo hallazgo, pero los títulos se parecen lo suficiente para que el algoritmo
lo dude.

No hay que crear nada a mano: `auto_create_context=true` en el import los crea.

---

## 5. Subir lo que ya está en `evidencias/`

```powershell
powershell -ExecutionPolicy Bypass -File "$hr\defectdojo\importar-evidencias.ps1" -Clave "<la contrasena del paso 3>"
```

El guion:

1. comprueba que DefectDojo responde;
2. pide un token a `/api/v2/api-token-auth/`;
3. **lee `/api/v2/test_types/` y comprueba que el `scan_type` existe** antes de subir — un
   `scan_type` mal escrito devuelve un 400 con una lista de doscientas opciones, ilegible;
4. sube cada informe a `/api/v2/import-scan/` con `auto_create_context=true`;
5. imprime una tabla con el id del Test y cuántos hallazgos entraron.

De la **segunda corrida en adelante**, con `-Reimportar`: apunta a `/api/v2/reimport-scan/` y
actualiza el Test que tenga el mismo `test_title` en vez de crear uno nuevo. Eso es lo que marca
los arreglados como *Mitigated* y los que vuelven como *Reopened*.

**`verified=false` a propósito.** En DefectDojo «verified» significa que una persona confirmó el
hallazgo. Importar 14 CVE de Trivy como verificados es el falso verde de Sonar al revés: un número
que nadie miró presentado como juicio. Se verifican a mano en el tablero.

---

## 6. ZAP: hay que generar el XML, el JSON no sirve

El parser **`ZAP Scan` lee el informe XML**. El guion
[`zap/escanear-api-autenticado.sh`](../zap/escanear-api-autenticado.sh) emitía solo `-J` (JSON) y
`-r` (HTML), que son los dos formatos que **no** entran.

Ya se le añadió `-x`. Para tener el XML del escaneo del 16 de noviembre hay que **volver a
correrlo**, con todo lo que eso exige y que no cambia:

- backend del 8081 contra `sigra-pg-rnf`, **nunca contra Render ni Vercel**;
- `pg_dump` antes, porque el escaneo autenticado **escribe** (dejó 112 facultades basura y 435
  filas de auditoría la vez pasada);
- el JWT va en fichero de propiedades con `-z "-configfile /zap/wrk/jwt.prop"`, no en `-config`.

Todo eso está en §6.2 y §6.5 del [README de herramientas](../README.md#62-el-procedimiento-que-ya-está-en-un-guion).

Mientras no exista el XML, el guion de importación **salta ZAP y lo dice**; los tres informes de
Trivy sí entran.

---

## 7. SonarQube: por API, no por archivo (opcional)

Los `sonar-*-2026-11-16-*.json` de `evidencias/` son volcados de la API de Sonar, **no** un formato
que DefectDojo sepa leer. Hay dos caminos:

**a) `SonarQube API Import`** — DefectDojo llama él mismo a la API de Sonar. En el tablero:

1. *Configuration → Tool Configuration*: nueva, tipo **SonarQube**,
   URL `http://sonarqube:9000/api` — **el nombre del contenedor, no `localhost`**, que dentro de
   uwsgi es el propio uwsgi; por eso el override mete a `uwsgi` en la red `sigra-rnf`.
   Autenticación: el token `squ_...` como *API key*.
2. En el producto *SIGRA Backend* → *Settings → Add API Scan Configuration*, con el *Service key*
   = la clave del proyecto en Sonar.
3. Importar con `scan_type=SonarQube API Import` y **sin archivo**.

**b) Convertir los JSON a `Generic Findings Import`.** Más trabajo y hay que mantener el conversor.

Recomendado: **(a)**, y solo si se quiere que los *code smells* de accesibilidad (`Web:S6845`,
`Web:S6825`) convivan con los hallazgos de seguridad. Si no, Sonar ya tiene su propio tablero y
duplicarlo no aporta.

Lo que **sí** conviene meter en DefectDojo aunque Sonar se quede fuera: el falso positivo de
`new URL(url, 'http://relative.invalid')`, marcado como *False Positive* con la nota del TLD
reservado (RFC 2606), para no volver a discutirlo.

---

## 8. Lighthouse: probablemente no entra, y no pasa nada

No consta un parser de Lighthouse. Comprobarlo en la instalación, que es un segundo:

```powershell
$t = Invoke-RestMethod -Uri "http://localhost:8084/api/v2/test_types/?limit=1000" -Headers @{Authorization="Token $tok"}
$t.results | Where-Object { $_.name -match 'ight' } | Select-Object name
```

Si no sale nada, las opciones son `Generic Findings Import` con un conversor a mano, o dejarlo
fuera. **Dejarlo fuera.** TTI y contraste son RNF-08 y RNF-21, no vulnerabilidades; su sitio es
A6 y el `lighthouserc.json`, donde los umbrales del SRS ya son aserciones que fallan solas.

---

## 9. Las trampas, para no repetir las de Sonar

| Trampa | Síntoma | Qué hacer |
| --- | --- | --- |
| El 8080 por defecto | El 8084 no responde, o el backend deja de responder | `DD_PORT` en `.env`, **no** `ports:` en el override: las listas se concatenan |
| `initializer` tarda 3 min | 502 en el 8084 | Esperar. `docker compose logs -f initializer` |
| La contraseña se imprime una vez | No hay forma de entrar | Anotarla, o `manage.py shell` del §3 |
| `localhost` dentro del contenedor | Sonar «no responde» desde DefectDojo | `http://sonarqube:9000`, con los dos en `sigra-rnf` |
| ZAP en JSON | El import devuelve 400 | Generar el XML con `-x` |
| Importar todo como `verified` | Tablero lleno de hallazgos «confirmados» que nadie miró | `verified=false`, triar a mano |
| `close_old_findings=true` en el primer import | Cierra hallazgos que nunca se revisaron | Queda en `false` en el guion |

---

## 10. Apagar

```powershell
cd "E:\Card SK hynix 2TB\Documents\Escritorio Documentos\Semestre 9\Software 4\Trabajo\SIGRA\django-DefectDojo"
docker compose stop
```

`stop`, no `down -v`: `down -v` borra el PostgreSQL de DefectDojo y con él todo el triaje, que es
justamente lo único que esta herramienta aporta y no está en ningún otro sitio.

Y volver a levantar Sonar:

```powershell
docker compose -f "$hr\docker-compose.yml" start sonarqube
```

---

[README de herramientas](../README.md) · [A4 Hallazgos](../../A4-hallazgos-rnf.md) · [A6 Semáforo](../../A6-semaforo-rnf.md)
