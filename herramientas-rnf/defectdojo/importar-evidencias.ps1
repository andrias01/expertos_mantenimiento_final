<#
    Sube a DefectDojo los informes que ya estan en herramientas-rnf/evidencias/.

    Escrito para PowerShell de Windows (5.1), igual que levantar.ps1:
      - sin '&&' ni '||', sin ternario, sin '-Form' (eso es PowerShell 7)
      - la subida multipart se hace con curl.exe, que viene con Windows 10/11,
        porque Invoke-RestMethod de 5.1 no sabe armar multipart/form-data

    Uso:
      powershell -ExecutionPolicy Bypass -File "<ruta>\importar-evidencias.ps1" -Clave "<contrasena de admin>"
      powershell -ExecutionPolicy Bypass -File "<ruta>\importar-evidencias.ps1" -Token "<api token>"

    Cada corrida crea un Test nuevo dentro del mismo Engagement, asi que el
    historico se acumula. Para que DefectDojo cierre solo los hallazgos arreglados
    en vez de apilar duplicados, ver -Reimportar.
#>

param(
    [string]$Url        = 'http://localhost:8084',
    [string]$Usuario    = 'admin',
    [string]$Clave      = '',
    [string]$Token      = '',
    [string]$Engagement = 'Mantenimiento nov-2026',
    [string]$TipoProducto = 'Software 4 - UCO',
    # Reimportar: en vez de crear un Test nuevo, actualiza el Test que tenga el
    # mismo test_title. Es lo que hace que un hallazgo arreglado aparezca como
    # 'Mitigated' y uno que vuelve aparezca como 'Reopened'. Usarlo de la segunda
    # corrida en adelante.
    [switch]$Reimportar
)

# 'Continue' y no 'Stop', por lo mismo que en levantar.ps1: curl.exe escribe en
# stderr cosas que no son errores y con 'Stop' el script se cae solo.
$ErrorActionPreference = 'Continue'

$aqui       = Split-Path -Parent $MyInvocation.MyCommand.Path
$evidencias = Resolve-Path (Join-Path $aqui '..\evidencias')
$endpoint   = 'import-scan'
if ($Reimportar) { $endpoint = 'reimport-scan' }

Write-Host ''
Write-Host '=== Importar evidencias de RNF a DefectDojo ===' -ForegroundColor Cyan
Write-Host "DefectDojo : $Url"
Write-Host "Evidencias : $evidencias"
Write-Host "Endpoint   : /api/v2/$endpoint/"
Write-Host ''

# --- 0. DefectDojo responde? -------------------------------------------------
try {
    $null = Invoke-WebRequest -Uri "$Url/login" -UseBasicParsing -TimeoutSec 15
} catch {
    throw "DefectDojo no responde en $Url. Levantalo primero (README seccion 2) o corrige -Url."
}

# --- 1. token ----------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($Token)) {
    if ([string]::IsNullOrWhiteSpace($Clave)) {
        throw 'Falta -Clave (la contrasena de admin) o -Token. La contrasena sale de: docker compose logs initializer | Select-String "Admin password:"'
    }
    Write-Host '[1/4] Pidiendo token a /api/v2/api-token-auth/...' -ForegroundColor Yellow
    $cuerpo = @{ username = $Usuario; password = $Clave } | ConvertTo-Json -Compress
    try {
        $rta = Invoke-RestMethod -Method Post -Uri "$Url/api/v2/api-token-auth/" -ContentType 'application/json' -Body $cuerpo -TimeoutSec 30
    } catch {
        throw "No se pudo autenticar como '$Usuario'. Revisa la contrasena. Detalle: $($_.Exception.Message)"
    }
    $Token = $rta.token
    Write-Host "      Token obtenido ($($Token.Length) caracteres)." -ForegroundColor Green
} else {
    Write-Host '[1/4] Usando el token pasado por parametro.' -ForegroundColor DarkGray
}

# --- 2. que parsers tiene ESTA instalacion -----------------------------------
# No se asume el nombre del scan_type: se comprueba. Un scan_type mal escrito
# devuelve un 400 con una lista de doscientas opciones y es ilegible.
Write-Host '[2/4] Leyendo los parsers disponibles en /api/v2/test_types/...' -ForegroundColor Yellow
$cabeceras = @{ Authorization = "Token $Token" }
$tipos = @()
try {
    $pagina = Invoke-RestMethod -Uri "$Url/api/v2/test_types/?limit=1000" -Headers $cabeceras -TimeoutSec 60
    $tipos  = $pagina.results | ForEach-Object { $_.name }
    Write-Host "      $($tipos.Count) parsers registrados." -ForegroundColor Green
} catch {
    Write-Host "      No se pudo leer test_types: $($_.Exception.Message)" -ForegroundColor DarkYellow
    Write-Host '      Se continua sin comprobar los nombres.' -ForegroundColor DarkYellow
}

# --- 3. que se sube ----------------------------------------------------------
# Producto separado para backend y frontend: tienen dueno, superficie y cadena de
# dependencias distintas, y mezclarlos arruina la deduplicacion.
$lotes = @(
    @{
        Archivo  = 'zap\zap-api-admin-2026-11-16.xml'
        ScanType = 'ZAP Scan'
        Producto = 'SIGRA Backend'
        Titulo   = 'ZAP API autenticado (admin) 2026-11-16'
        Nota     = 'Requiere el XML. El guion zap/escanear-api-autenticado.sh solo emite -J (JSON) y -r (HTML): hay que anadirle -x. Ver README seccion 6.'
    },
    @{
        Archivo  = 'trivy-backend-16nov.json'
        ScanType = 'Trivy Scan'
        Producto = 'SIGRA Backend'
        Titulo   = 'Trivy imagen backend 2026-11-16'
        Nota     = ''
    },
    @{
        Archivo  = 'trivy-frontend-deps-2026-11-16.json'
        ScanType = 'Trivy Scan'
        Producto = 'SIGRA Frontend'
        Titulo   = 'Trivy dependencias frontend 2026-11-16'
        Nota     = ''
    },
    @{
        Archivo  = 'trivy-frontend-2026-11-16.json'
        ScanType = 'Trivy Scan'
        Producto = 'SIGRA Frontend'
        Titulo   = 'Trivy imagen frontend 2026-11-16'
        Nota     = 'Los 6 HIGH de esta imagen son del npm de la imagen base (PkgPath bajo node_modules/npm/), no son de SIGRA. Se marcan como fuera de alcance en DefectDojo, no se cierran como arreglados.'
    }
)

Write-Host '[3/4] Subiendo informes...' -ForegroundColor Yellow
$resumen = @()

foreach ($lote in $lotes) {

    $ruta = Join-Path $evidencias $lote.Archivo

    if (-not (Test-Path $ruta)) {
        Write-Host "      OMITIDO (no existe)  $($lote.Archivo)" -ForegroundColor DarkYellow
        if ($lote.Nota) { Write-Host "         $($lote.Nota)" -ForegroundColor DarkYellow }
        $resumen += [pscustomobject]@{ Informe = $lote.Archivo; Estado = 'no existe'; Hallazgos = '-' }
        continue
    }

    if ($tipos.Count -gt 0 -and ($tipos -notcontains $lote.ScanType)) {
        Write-Host "      OMITIDO (el parser '$($lote.ScanType)' no existe en esta instalacion)  $($lote.Archivo)" -ForegroundColor DarkYellow
        $resumen += [pscustomobject]@{ Informe = $lote.Archivo; Estado = 'parser desconocido'; Hallazgos = '-' }
        continue
    }

    # verified=false a proposito: 'verified' en DefectDojo significa que una
    # persona confirmo el hallazgo. Importar doscientos CVE como verificados es la
    # misma mentira que el falso verde de Sonar, solo que al reves. Se verifican a
    # mano, uno por uno, en el tablero.
    $argumentos = @(
        '-s', '-S', '-X', 'POST', "$Url/api/v2/$endpoint/",
        '-H', "Authorization: Token $Token",
        '-F', "file=@$ruta",
        '-F', "scan_type=$($lote.ScanType)",
        '-F', "product_type_name=$TipoProducto",
        '-F', "product_name=$($lote.Producto)",
        '-F', "engagement_name=$Engagement",
        '-F', "test_title=$($lote.Titulo)",
        '-F', 'auto_create_context=true',
        '-F', 'minimum_severity=Info',
        '-F', 'active=true',
        '-F', 'verified=false',
        '-F', 'close_old_findings=false'
    )

    $salida = & curl.exe @argumentos

    $texto   = ($salida -join '')
    $ok      = $false
    $cuantos = '-'
    $json    = $null
    try {
        $json = $texto | ConvertFrom-Json
        if ($json.PSObject.Properties.Name -contains 'test') {
            $ok = $true
            if ($json.PSObject.Properties.Name -contains 'statistics') {
                $cuantos = $json.statistics.after.total
            }
        }
    } catch { }

    if ($ok) {
        Write-Host "      OK  $($lote.Archivo)  ->  $($lote.Producto) / test $($json.test)" -ForegroundColor Green
        $resumen += [pscustomobject]@{ Informe = $lote.Archivo; Estado = "test $($json.test)"; Hallazgos = $cuantos }
    } else {
        Write-Host "      FALLO  $($lote.Archivo)" -ForegroundColor Red
        $corte = [Math]::Min(400, $texto.Length)
        Write-Host "         $($texto.Substring(0, $corte))" -ForegroundColor Red
        $resumen += [pscustomobject]@{ Informe = $lote.Archivo; Estado = 'fallo'; Hallazgos = '-' }
    }
    if ($lote.Nota) { Write-Host "         $($lote.Nota)" -ForegroundColor DarkGray }
}

# --- 4. resumen --------------------------------------------------------------
Write-Host ''
Write-Host '[4/4] Resumen:' -ForegroundColor Yellow
$resumen | Format-Table -AutoSize
Write-Host "Tablero: $Url/product" -ForegroundColor Cyan
Write-Host ''
Write-Host 'Recordatorio: nada de esto es evidencia hasta que se mire. El numero que' -ForegroundColor DarkGray
Write-Host 'importa no es cuantos hallazgos entraron, sino cuantos quedaron triados.'  -ForegroundColor DarkGray
Write-Host ''
