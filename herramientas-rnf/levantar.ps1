<#
    Levanta las herramientas de verificacion de RNF y carga el esquema y los
    seeds en el PostgreSQL aislado.

    Escrito para PowerShell de Windows (5.1), que es el que usa Andres:
      - sin '\' de continuacion de linea
      - sin redireccion '<' (se usa Get-Content | docker exec -i)
      - sin '&&' ni '||' (no existen en 5.1)

    Uso, desde cualquier carpeta:
      powershell -ExecutionPolicy Bypass -File "<ruta>\levantar.ps1"

    Es idempotente: se puede volver a correr. Para recargar el esquema desde
    cero, pasar -Recrear.
#>

param(
    [switch]$Recrear
)

# OJO: 'Continue', no 'Stop'.
# En PowerShell 5.1, cualquier linea que un ejecutable nativo (docker, psql)
# escriba en stderr se envuelve en un ErrorRecord y, con 'Stop', aborta el
# script aunque el comando haya terminado con exito. psql escribe avisos
# perfectamente normales ahi ("schema sigra already exists, skipping").
# El control de errores de este script es explicito: se revisa $LASTEXITCODE
# y se lanza 'throw' a mano donde corresponde.
$ErrorActionPreference = 'Continue'

# --- rutas, calculadas desde la ubicacion del script -------------------------
$aqui     = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo     = Resolve-Path (Join-Path $aqui '..\..')
$backend  = Join-Path $repo 'software4-SIGRA-backend'
$esquema  = Join-Path $backend 'docs\db\SIGRA_SCHEMA_CURRENT.sql'
$seedDir  = Join-Path $backend 'bruno\SIGRA\seed'

Write-Host ''
Write-Host '=== Herramientas de verificacion de RNF - SIGRA ===' -ForegroundColor Cyan
Write-Host "Repositorio: $repo"
Write-Host ''

if (-not (Test-Path $esquema)) {
    throw "No se encontro el esquema en: $esquema"
}

# --- 0. Docker vivo? ---------------------------------------------------------
docker version --format '{{.Server.Version}}' | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'Docker no responde. Abre Docker Desktop y espera a que diga "Engine running".'
}

# --- 1. red compartida -------------------------------------------------------
$red = docker network ls --filter name=sigra-rnf --format '{{.Name}}'
if ($red -ne 'sigra-rnf') {
    Write-Host '[1/5] Creando la red sigra-rnf...' -ForegroundColor Yellow
    docker network create sigra-rnf | Out-Null
} else {
    Write-Host '[1/5] La red sigra-rnf ya existe.' -ForegroundColor DarkGray
}

# --- 2. contenedores ---------------------------------------------------------
if ($Recrear) {
    Write-Host '[2/5] -Recrear: borrando el PostgreSQL aislado y su volumen...' -ForegroundColor Yellow
    try { docker compose -f (Join-Path $aqui 'docker-compose.yml') rm -sf sigra-pg-rnf } catch {}
    try { docker volume rm sigra-rnf_sigra-pg-rnf-data } catch {}
}

Write-Host '[2/5] Levantando contenedores (uptime-kuma, postgres, sonarqube)...' -ForegroundColor Yellow
docker compose -f (Join-Path $aqui 'docker-compose.yml') up -d
if ($LASTEXITCODE -ne 0) { throw 'docker compose up fallo.' }

# --- 3. esperar a PostgreSQL -------------------------------------------------
Write-Host '[3/5] Esperando a que PostgreSQL acepte conexiones...' -ForegroundColor Yellow
$listo = $false
foreach ($i in 1..40) {
    try {
        docker exec sigra-pg-rnf pg_isready -U postgres -d postgres | Out-Null
        if ($LASTEXITCODE -eq 0) { $listo = $true; break }
    } catch {}
    Start-Sleep -Seconds 2
}
if (-not $listo) { throw 'PostgreSQL no respondio en 80 segundos. Revisa: docker logs sigra-pg-rnf' }
Write-Host '      PostgreSQL listo.' -ForegroundColor Green

# --- 4. esquema y seeds ------------------------------------------------------
# Orden tomado del CI del frontend, job "E2E integrada", paso
# "Crear esquema y seeds en PostgreSQL efimero". No cambiar el orden:
# seed-asignaturas necesita el search_path puesto en sigra.
function Cargar-Sql {
    param(
        [string]$Ruta,
        [string]$Etiqueta,
        [switch]$ConSearchPath,
        # Para seeds que no son imprescindibles para medir RNF: si fallan se avisa
        # y se sigue, en vez de dejar la base a medias.
        [switch]$Opcional,
        [string]$NotaSiFalla
    )

    if (-not (Test-Path $Ruta)) {
        Write-Host "      OMITIDO (no existe): $Etiqueta" -ForegroundColor DarkYellow
        return
    }
    $argumentos = @('exec', '-i', '-e', 'PGPASSWORD=rnf_local_solo_pruebas', 'sigra-pg-rnf',
                    'psql', '-U', 'postgres', '-d', 'postgres', '-v', 'ON_ERROR_STOP=1', '-q')
    if ($ConSearchPath) { $argumentos += @('-c', 'SET search_path TO sigra, public') }
    $argumentos += @('-f', '-')

    Get-Content -Raw -Encoding UTF8 $Ruta | docker @argumentos | Out-Null
    if ($LASTEXITCODE -ne 0) {
        if ($Opcional) {
            Write-Host "      FALLO (no bloqueante)  $Etiqueta" -ForegroundColor DarkYellow
            if ($NotaSiFalla) { Write-Host "         $NotaSiFalla" -ForegroundColor DarkYellow }
            return
        }
        throw "Fallo al cargar $Etiqueta"
    }
    Write-Host "      OK  $Etiqueta" -ForegroundColor Green
}

Write-Host '[4/5] Cargando esquema y seeds...' -ForegroundColor Yellow
Cargar-Sql -Ruta $esquema -Etiqueta 'SIGRA_SCHEMA_CURRENT.sql (19 tablas)'

# El baseline NO alcanza para arrancar el backend: crea 19 tablas y las entidades
# JPA esperan 20. Falta historial_auditoria, que vive en una migracion aparte que
# nadie integro al baseline. Sin esto, con JPA_DDL_AUTO=validate el backend falla
# con "Schema validation: missing table [historial_auditoria]". Ver ERR-022.
Cargar-Sql -Ruta (Join-Path $backend 'docs\db\RF19_historial_auditoria_migration.sql') `
    -Etiqueta 'RF19_historial_auditoria_migration.sql (la tabla 20, ver ERR-022)'
Cargar-Sql -Ruta (Join-Path $seedDir 'seed-auth.sql')              -Etiqueta 'seed-auth.sql'
Cargar-Sql -Ruta (Join-Path $seedDir 'seed-roles.sql')             -Etiqueta 'seed-roles.sql'
Cargar-Sql -Ruta (Join-Path $seedDir 'seed-asignaturas.sql')       -Etiqueta 'seed-asignaturas.sql' -ConSearchPath
Cargar-Sql -Ruta (Join-Path $seedDir 'seed-semestres.sql')         -Etiqueta 'seed-semestres.sql'
Cargar-Sql -Ruta (Join-Path $seedDir 'seed-asignaturas-roles.sql') -Etiqueta 'seed-asignaturas-roles.sql' -Opcional `
    -NotaSiFalla 'Esperado: el seed es del 6-oct y omite fecha_matricula, que la migracion RF08 del 11-oct dejo NOT NULL. Ver ERR-021. No afecta a JMeter: auth, asignaturas y semestres ya estan cargados.'

# --- 5. resumen --------------------------------------------------------------
Write-Host ''
Write-Host '[5/5] Listo. Estado de los contenedores:' -ForegroundColor Yellow
docker ps --filter name=sigra-pg-rnf --filter name=sonarqube --filter name=uptime-kuma --format '      {{.Names}}  {{.Status}}  {{.Ports}}'

$tablas = docker exec -e PGPASSWORD=rnf_local_solo_pruebas sigra-pg-rnf psql -U postgres -d postgres -t -A -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='sigra'"
$usuarios = docker exec -e PGPASSWORD=rnf_local_solo_pruebas sigra-pg-rnf psql -U postgres -d postgres -t -A -c "SELECT count(*) FROM sigra.usuario"

Write-Host ''
Write-Host "      Tablas en el schema sigra : $tablas" -ForegroundColor Green
Write-Host "      Usuarios sembrados        : $usuarios" -ForegroundColor Green
Write-Host ''
Write-Host 'Siguiente paso: levantar el backend contra ESTA base (no contra Supabase).' -ForegroundColor Cyan
Write-Host '  Ver README.md, seccion 2.' -ForegroundColor Cyan
Write-Host ''
Write-Host '  SonarQube    http://localhost:9000   (admin / admin la primera vez)'
Write-Host '  Uptime Kuma  http://localhost:3001   (crea tu usuario la primera vez)'
Write-Host '  PostgreSQL   localhost:5433  base postgres  schema sigra  usuario postgres'
Write-Host ''
