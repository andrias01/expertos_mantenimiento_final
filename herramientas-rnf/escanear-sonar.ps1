<#
    Escanea los repositorios de SIGRA con el SonarQube local y VUELCA LA
    EVIDENCIA A DISCO, en herramientas-rnf\evidencias.

    Por que existe este script y no basta el tablero:
      El tablero de http://localhost:9000 vive dentro del volumen
      'sonarqube-data'. Si el volumen se borra, la evidencia de H-05 y el
      respaldo de mantenibilidad de RNF-20 desaparecen con el. La auditoria
      tiene que poder citar un archivo del repositorio, no una captura de una
      maquina que ya se apago.

    Por que importa -Version:
      SonarQube compara contra "la version anterior". Sin -Dsonar.projectVersion
      todos los analisis son "not provided" y el panel de New Code queda vacio:
      se puede decir "el codigo esta en A", pero NO "este mantenimiento no
      empeoro nada", que es justo la pregunta del proyecto de mantenimiento.
      Una version por mantenimiento (o por fecha) convierte a Sonar en
      instrumento de mantenimiento y no en una foto suelta.

    Escrito para PowerShell de Windows (5.1): sin '&&', sin '||', sin '\' de
    continuacion. El control de errores es explicito sobre $LASTEXITCODE.

    Uso tipico, desde cualquier carpeta:

      # una sola vez: crea proyectos y puertas de calidad
      powershell -ExecutionPolicy Bypass -File "<ruta>\escanear-sonar.ps1" -Configurar -Token "squ_..."

      # en cada auditoria o despues de cada mantenimiento aprobado
      powershell -ExecutionPolicy Bypass -File "<ruta>\escanear-sonar.ps1" -Proyecto ambos -Token "squ_..." -Version "M-03-paginacion"

      # solo volver a bajar la evidencia, sin reescanear
      powershell -ExecutionPolicy Bypass -File "<ruta>\escanear-sonar.ps1" -Proyecto evidencias -Token "squ_..."

    El token se saca de http://localhost:9000 -> My Account -> Security ->
    Generate Token (tipo User Token). Tambien se lee de $env:SONAR_TOKEN.
    NO se guarda en el repositorio.
#>

param(
    [ValidateSet('backend','frontend','ambos','evidencias')]
    [string]$Proyecto = 'ambos',

    [string]$Token = $env:SONAR_TOKEN,

    # Etiqueta de version del analisis. Por defecto, fecha + commit corto del
    # backend. Para un mantenimiento concreto, pasar su identificador.
    [string]$Version,

    # Salta 'gradlew compileJava testClasses jacocoTestReport' (~3 min) cuando
    # el build ya esta hecho y solo se quiere reescanear.
    [switch]$SinCompilar,

    # Crea los proyectos y las puertas de calidad. Idempotente en la practica:
    # si ya existen, SonarQube responde que estan duplicados y se sigue.
    [switch]$Configurar
)

# OJO: 'Continue', no 'Stop'. Ver la nota de levantar.ps1: en PS 5.1 cualquier
# linea de stderr de docker o gradlew se envuelve en ErrorRecord y abortaria el
# script aunque el comando haya ido bien.
$ErrorActionPreference = 'Continue'

$sonar = 'http://localhost:9000'

# --- rutas, calculadas desde la ubicacion del script -------------------------
$aqui       = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo       = Resolve-Path (Join-Path $aqui '..\..')
$backend    = Join-Path $repo 'software4-SIGRA-backend\SIGRA'
$frontend   = Join-Path $repo 'software4-SIGRA-frontend'
$evidencias = Join-Path $aqui 'evidencias'

Write-Host ''
Write-Host '=== SonarQube - escaneo y evidencia de RNF ===' -ForegroundColor Cyan

if (-not $Token) {
    throw 'Falta el token. Pasa -Token "squ_..." o define $env:SONAR_TOKEN. Se genera en http://localhost:9000 -> My Account -> Security.'
}

# En la API de SonarQube el token va como usuario y la clave queda vacia.
$auth = "${Token}:"

# El marcador de posicion del README pegado literal es un error facil de
# cometer, y sin esta comprobacion el sintoma aparece cinco pasos despues: un
# 401 del escaner, tres minutos de espera inutil y la evidencia machacada.
# Paso el 16-nov.
if ($Token -in @('squ_...', 'TU_TOKEN', 'squ_xxx', '<token>')) {
    throw "El -Token que pasaste ('$Token') es el marcador de posicion del README, no un token real. Generalo en http://localhost:9000 -> My Account -> Security -> Generate Token."
}

# Y se comprueba contra el servidor, que es la unica prueba que vale. Ojo:
# /api/authentication/validate responde HTTP 200 con {"valid":false} cuando el
# token es malo, asi que hay que mirar el cuerpo y no el codigo HTTP.
$validacion = curl.exe -s -m 10 -u $auth "$sonar/api/authentication/validate"
if ($validacion -notmatch '"valid"\s*:\s*true') {
    throw ("El servidor rechazo el token. Respuesta: $validacion. Genera uno nuevo en " +
           "http://localhost:9000 -> My Account -> Security, o revisa la variable " +
           '$env:SONAR_TOKEN.')
}

if (-not (Test-Path $evidencias)) {
    New-Item -ItemType Directory -Path $evidencias | Out-Null
}

# --- 0. el servidor responde? ------------------------------------------------
$estado = curl.exe -s -m 10 "$sonar/api/system/status"
if ($LASTEXITCODE -ne 0 -or $estado -notmatch '"status"\s*:\s*"UP"') {
    throw "SonarQube no responde UP en $sonar. Levantalo con levantar.ps1 y espera 1-2 minutos (arranca un Elasticsearch dentro)."
}
Write-Host "Servidor  : $estado" -ForegroundColor DarkGray

# --- version del analisis ----------------------------------------------------
if (-not $Version) {
    $sha = ''
    if (Test-Path (Join-Path $repo 'software4-SIGRA-backend\.git')) {
        $sha = git -C (Join-Path $repo 'software4-SIGRA-backend') rev-parse --short HEAD
    }
    $Version = (Get-Date -Format 'yyyy-MM-dd')
    if ($sha) { $Version = "$Version-$sha" }
}
$sello = Get-Date -Format 'yyyy-MM-dd'
Write-Host "Version   : $Version" -ForegroundColor DarkGray
Write-Host "Evidencia : $evidencias" -ForegroundColor DarkGray
Write-Host ''

# =============================================================================
# 1. Configuracion (una vez)
# =============================================================================
function Invoke-SonarPost($ruta, $datos) {
    $r = curl.exe -s -u $auth -X POST "$sonar/$ruta" -d $datos
    if ($r -match '"errors"') {
        Write-Host "    aviso: $r" -ForegroundColor DarkYellow
    }
}

# OJO con una suposicion que resulto falsa: 'api/qualitygates/create' NO crea
# la puerta vacia. SonarQube 26.11 le anade por su cuenta las cuatro
# condiciones de 'Clean as You Code' sobre CODIGO NUEVO -marcadas en la API con
# "isCaycCondition":true-:
#     new_violations > 0 | new_coverage < 80
#     new_duplicated_lines_density > 3 | new_security_hotspots_reviewed < 100
# Asi que una puerta "de tres condiciones" tiene en realidad siete. Se dejan,
# porque sirven al criterio de no degradacion del mantenimiento, pero HAY QUE
# DECLARARLAS: no son del SRS.
function Quitar-Condicion($nombrePuerta, $metrica) {
    $j = curl.exe -s -u $auth "$sonar/api/qualitygates/show?name=$([uri]::EscapeDataString($nombrePuerta))"
    foreach ($bloque in [regex]::Matches($j, '\{[^{}]*\}')) {
        if ($bloque.Value -match ('"metric"\s*:\s*"' + $metrica + '"')) {
            if ($bloque.Value -match '"id"\s*:\s*"([^"]+)"') {
                Invoke-SonarPost 'api/qualitygates/delete_condition' "id=$($Matches[1])"
                Write-Host "    quitada la condicion '$metrica' de '$nombrePuerta'" -ForegroundColor DarkGray
            }
        }
    }
}

function Configurar-Backend {
    Invoke-SonarPost 'api/projects/create' 'name=SIGRA backend&project=sigra-backend'

    # La condicion de cobertura SI sale del SRS (RNF-20 a). Las otras tres son
    # criterio nuestro y hay que presentarlas asi.
    Invoke-SonarPost 'api/qualitygates/create' 'name=SIGRA RNF-20'
    Invoke-SonarPost 'api/qualitygates/create_condition' 'gateName=SIGRA RNF-20&metric=coverage&op=LT&error=70'
    Invoke-SonarPost 'api/qualitygates/create_condition' 'gateName=SIGRA RNF-20&metric=sqale_rating&op=GT&error=2'
    Invoke-SonarPost 'api/qualitygates/create_condition' 'gateName=SIGRA RNF-20&metric=reliability_rating&op=GT&error=2'
    Invoke-SonarPost 'api/qualitygates/create_condition' 'gateName=SIGRA RNF-20&metric=security_rating&op=GT&error=2'
    Invoke-SonarPost 'api/qualitygates/select' 'gateName=SIGRA RNF-20&projectKey=sigra-backend'
}

function Configurar-Frontend {
    Invoke-SonarPost 'api/projects/create' 'name=SIGRA frontend&project=sigra-frontend'

    # La MISMA puerta, MENOS COBERTURA, y el motivo hay que declararlo en el
    # informe: 'ng test --code-coverage' no corre en local (H-14, Node por
    # debajo del minimo de Angular 22), asi que el frontend se escanea sin lcov.
    # Dejarle la condicion de cobertura la haria fallar por falta de dato, no
    # por falta de calidad: seria un semaforo mentiroso.
    Invoke-SonarPost 'api/qualitygates/create' 'name=SIGRA RNF-20 sin cobertura'
    Invoke-SonarPost 'api/qualitygates/create_condition' 'gateName=SIGRA RNF-20 sin cobertura&metric=sqale_rating&op=GT&error=2'
    Invoke-SonarPost 'api/qualitygates/create_condition' 'gateName=SIGRA RNF-20 sin cobertura&metric=reliability_rating&op=GT&error=2'
    Invoke-SonarPost 'api/qualitygates/create_condition' 'gateName=SIGRA RNF-20 sin cobertura&metric=security_rating&op=GT&error=2'
    Invoke-SonarPost 'api/qualitygates/select' 'gateName=SIGRA RNF-20 sin cobertura&projectKey=sigra-frontend'

    # Y se quita la condicion que SonarQube anadio sola y que aqui es una mina:
    # 'new_coverage < 80' sobre un proyecto del que NO tenemos cobertura haria
    # fallar la puerta en cuanto haya codigo nuevo, por falta de dato y no por
    # falta de calidad. Es el mismo motivo por el que esta puerta existe.
    Quitar-Condicion 'SIGRA RNF-20 sin cobertura' 'new_coverage'
}

# Si el proyecto no existe en el servidor, EL ESCANER LO CREA SOLO, y lo crea
# mal para lo que necesitamos: con la clave como nombre y con la puerta POR
# DEFECTO ('Sonar way'), cuyas condiciones son todas sobre codigo nuevo. En un
# primer analisis eso devuelve status OK con la lista de condiciones VACIA: un
# verde que no evalua nada. Paso exactamente eso con sigra-frontend el 16-nov.
# Por eso se comprueba antes de escanear y no solo con -Configurar.
function Confirmar-Proyecto($clave) {
    $r = curl.exe -s -u $auth "$sonar/api/projects/search?projects=$clave"
    if ($r -match '"total"\s*:\s*0') {
        Write-Host "    el proyecto '$clave' no existe en el servidor. Creandolo con su puerta de calidad..." -ForegroundColor Yellow
        if ($clave -eq 'sigra-backend') { Configurar-Backend } else { Configurar-Frontend }
    }
}

if ($Configurar) {
    Write-Host '[1] Creando proyectos y puertas de calidad...' -ForegroundColor Yellow
    Configurar-Backend
    Configurar-Frontend
    Write-Host '    listo.' -ForegroundColor Green
    Write-Host ''
}

# =============================================================================
# 2. Escaneos
# =============================================================================

# El escaner va en Docker a proposito: agregar el plugin de Sonar al
# build.gradle del producto seria un PR al repositorio del equipo que no nos
# corresponde abrir. Dentro de la red sigra-rnf el servidor se llama 'sonarqube'
# y NO 'localhost'. Cada -D va entre comillas dobles: sin ellas, PS 5.1 parte el
# argumento y el escaner muere con "Unrecognized option: .host.url=...".
function Invoke-Escaner($rutaProyecto, $argumentos) {
    Push-Location $rutaProyecto
    $comunes = @(
        "-Dsonar.host.url=http://sonarqube:9000",
        "-Dsonar.token=$Token",
        "-Dsonar.projectVersion=$Version"
    )
    # OJO con el '| Out-Host': sin el, la salida del escaner se queda en la
    # tuberia y la funcion devuelve EL LOG COMPLETO ademas del codigo, asi que
    # el 'if ($codigo -ne 0)' de abajo se cumple siempre y se imprime
    # "el escaner salio con codigo <log entero>" aunque haya ido bien.
    # Paso el 16-nov con el frontend.
    docker run --rm --network sigra-rnf -v "${PWD}:/usr/src" sonarsource/sonar-scanner-cli ($comunes + $argumentos) | Out-Host
    $codigo = $LASTEXITCODE
    Pop-Location
    return $codigo
}

if ($Proyecto -eq 'backend' -or $Proyecto -eq 'ambos') {
    Write-Host '[2] Backend...' -ForegroundColor Yellow
    if (-not (Test-Path $backend)) { throw "No se encontro el backend en: $backend" }
    Confirmar-Proyecto 'sigra-backend'

    if (-not $SinCompilar) {
        Write-Host '    gradlew compileJava testClasses jacocoTestReport (~3 min)' -ForegroundColor DarkGray
        Push-Location $backend
        .\gradlew compileJava testClasses jacocoTestReport
        $codigoGradle = $LASTEXITCODE
        Pop-Location
        if ($codigoGradle -ne 0) {
            throw "gradlew fallo con codigo $codigoGradle. Sin jacocoTestReport, Sonar reportaria 0 % de cobertura y la puerta fallaria por falta de dato."
        }
    }

    $codigo = Invoke-Escaner $backend @(
        "-Dsonar.projectKey=sigra-backend",
        "-Dsonar.sources=src/main",
        "-Dsonar.tests=src/test",
        "-Dsonar.java.binaries=build/classes/java/main",
        "-Dsonar.java.test.binaries=build/classes/java/test",
        "-Dsonar.coverage.jacoco.xmlReportPaths=build/reports/jacoco/test/jacocoTestReport.xml"
    )
    if ($codigo -ne 0) {
        Write-Host "    el escaner salio con codigo $codigo" -ForegroundColor Red
        $huboFallo = $true
    }
    Write-Host ''
}

if ($Proyecto -eq 'frontend' -or $Proyecto -eq 'ambos') {
    Write-Host '[3] Frontend...' -ForegroundColor Yellow
    if (-not (Test-Path $frontend)) { throw "No se encontro el frontend en: $frontend" }
    Confirmar-Proyecto 'sigra-frontend'

    # Sin lcov: ver la nota de la puerta "sin cobertura" mas arriba (H-14).
    $codigo = Invoke-Escaner $frontend @(
        "-Dsonar.projectKey=sigra-frontend",
        "-Dsonar.sources=src",
        "-Dsonar.tests=e2e",
        "-Dsonar.exclusions=**/node_modules/**,**/dist/**,**/*.spec.ts,**/public/**",
        "-Dsonar.sourceEncoding=UTF-8"
    )
    if ($codigo -ne 0) {
        Write-Host "    el escaner salio con codigo $codigo" -ForegroundColor Red
        $huboFallo = $true
    }
    Write-Host ''
}

# Si el escaneo fallo NO se sigue. Antes se seguia, y el resultado era lo peor
# posible: tres minutos esperando a una cola que no tenia nada que procesar y
# seis archivos de evidencia sobrescritos con respuestas de error.
if ($huboFallo) {
    Write-Host 'El escaneo fallo. No se espera ni se baja evidencia, para no sobrescribir la buena.' -ForegroundColor Red
    Write-Host ''
    exit 1
}

# =============================================================================
# 3. Evidencia a disco
# =============================================================================

# El escaner NO deja el resultado listo: sube un informe y el servidor lo
# procesa despues, en su propia cola (Compute Engine). Preguntar a la API en
# ese hueco devuelve la puerta en 'NONE' y las medidas del analisis anterior
# -o ninguna-, que parece un fallo del escaneo y no lo es. Paso el 16-nov con
# el frontend. De ahi esta espera.
function Esperar-Procesamiento {
    for ($i = 0; $i -lt 90; $i++) {
        $r = curl.exe -s -u $auth "$sonar/api/ce/activity_status"
        if ($r -notmatch '"pending"') {
            # Respuesta vacia, 401 o algo que no es esta API: esperar 3 minutos
            # a que "termine" seria mentirse. Se corta y se dice por que.
            Write-Host "    el servidor no contesto a api/ce/activity_status (respuesta: '$r'). Se corta la espera." -ForegroundColor Red
            return $false
        }
        if ($r -match '"pending"\s*:\s*0' -and $r -match '"inProgress"\s*:\s*0') {
            if ($r -notmatch '"failing"\s*:\s*0') {
                Write-Host "    aviso: el servidor reporta tareas fallidas -> $r" -ForegroundColor DarkYellow
            }
            return $true
        }
        Start-Sleep -Seconds 2
    }
    Write-Host '    aviso: el servidor sigue procesando tras 3 minutos. La evidencia puede quedar incompleta.' -ForegroundColor Red
    return $false
}

if ($Proyecto -ne 'evidencias') {
    Write-Host '[4] Esperando a que el servidor procese el informe...' -ForegroundColor Yellow
    Esperar-Procesamiento | Out-Null
}

Write-Host '[5] Bajando la evidencia...' -ForegroundColor Yellow

$metricas = 'coverage,line_coverage,branch_coverage,sqale_rating,sqale_index,sqale_debt_ratio,reliability_rating,security_rating,bugs,vulnerabilities,code_smells,security_hotspots,duplicated_lines_density,ncloc,complexity,cognitive_complexity,files,functions,classes,comment_lines_density'

$claves = @()
if ($Proyecto -eq 'backend'  -or $Proyecto -eq 'ambos' -or $Proyecto -eq 'evidencias') { $claves += 'sigra-backend' }
if ($Proyecto -eq 'frontend' -or $Proyecto -eq 'ambos' -or $Proyecto -eq 'evidencias') { $claves += 'sigra-frontend' }

# Baja un recurso a un archivo SOLO si la respuesta sirve. Importante: 'curl
# -o' CREA el archivo igual cuando el servidor contesta 401 o con un cuerpo
# vacio, y asi se machacaron los seis archivos de evidencia del frontend,
# dejandolos en 0 bytes. Se escribe a un temporal y solo se mueve encima si el
# contenido es utilizable; si no, se conserva el archivo anterior.
function Guardar-Evidencia($url, $destino) {
    $tmp = "$destino.tmp"
    curl.exe -s -u $auth $url -o $tmp
    $contenido = ''
    if (Test-Path $tmp) { $contenido = [string](Get-Content -Raw $tmp) }
    if ([string]::IsNullOrWhiteSpace($contenido) -or $contenido -match '"errors"\s*:') {
        if (Test-Path $tmp) { Remove-Item $tmp -Force }
        $nombre = Split-Path -Leaf $destino
        Write-Host "    aviso: respuesta no utilizable para $nombre; se conserva el archivo anterior" -ForegroundColor DarkYellow
        return $false
    }
    Move-Item $tmp $destino -Force
    return $true
}

foreach ($clave in $claves) {
    $corto = $clave -replace '^sigra-',''
    $base  = Join-Path $evidencias "sonar-$corto-$sello"

    Guardar-Evidencia "$sonar/api/measures/component?component=$clave&metricKeys=$metricas" "$base-medidas.json"   | Out-Null
    Guardar-Evidencia "$sonar/api/qualitygates/project_status?projectKey=$clave"            "$base-puerta.json"    | Out-Null
    Guardar-Evidencia "$sonar/api/issues/search?components=$clave&ps=500"                   "$base-issues.json"    | Out-Null
    Guardar-Evidencia "$sonar/api/hotspots/search?project=$clave&ps=500"                    "$base-hotspots.json"  | Out-Null
    Guardar-Evidencia "$sonar/api/project_analyses/search?project=$clave"                   "$base-analisis.json"  | Out-Null
    # Que puerta tiene asignada: es la prueba de que no se quedo con la de por
    # defecto, que es lo que pasa cuando el escaner crea el proyecto el solo.
    Guardar-Evidencia "$sonar/api/qualitygates/get_by_project?project=$clave" "$base-puerta-asignada.json" | Out-Null

    # Resumen legible, para no tener que abrir los JSON en la reunion.
    # A prueba de nulos: 'Get-Content -Raw' de un archivo vacio devuelve $null,
    # y [regex]::Matches($null, ...) lanza ArgumentNullException. Paso el 16-nov.
    $puerta  = ''
    $medidas = ''
    if (Test-Path "$base-puerta.json")  { $puerta  = [string](Get-Content -Raw "$base-puerta.json") }
    if (Test-Path "$base-medidas.json") { $medidas = [string](Get-Content -Raw "$base-medidas.json") }

    $veredicto = 'desconocido'
    if ($puerta -match '"status"\s*:\s*"(OK|ERROR|WARN|NONE)"') { $veredicto = $Matches[1] }

    # Cuantas condiciones evaluo de verdad. Un 'OK' con la lista vacia NO es un
    # veredicto: es la puerta por defecto, que solo mira codigo nuevo y en un
    # primer analisis no tiene nada que mirar. Hay que verlo, no suponerlo.
    $condiciones = ([regex]::Matches($puerta, '"metricKey"')).Count

    # Que puerta tiene asignada, que es lo que explica el numero de arriba.
    $cualPuerta = ''
    $gj = curl.exe -s -u $auth "$sonar/api/qualitygates/get_by_project?project=$clave"
    if ($gj -match '"name"\s*:\s*"([^"]+)"') { $cualPuerta = $Matches[1] }

    Write-Host ''
    Write-Host "  $clave" -ForegroundColor Cyan
    if ($veredicto -eq 'OK' -and $condiciones -gt 0) {
        Write-Host "    Puerta de calidad : OK  ($cualPuerta, $condiciones condiciones)" -ForegroundColor Green
    } elseif ($veredicto -eq 'OK') {
        Write-Host "    Puerta de calidad : OK pero SIN CONDICIONES -> no evalua nada" -ForegroundColor Red
        Write-Host "                        puerta asignada: '$cualPuerta'. Corre con -Configurar" -ForegroundColor Red
    } elseif ($veredicto -eq 'NONE') {
        Write-Host "    Puerta de calidad : NONE -> el servidor aun no habia procesado el informe" -ForegroundColor Red
    } else {
        Write-Host "    Puerta de calidad : $veredicto  ($cualPuerta, $condiciones condiciones)" -ForegroundColor Red
    }
    foreach ($m in @('sqale_rating','reliability_rating','security_rating','coverage','sqale_index','bugs','vulnerabilities','code_smells','security_hotspots','duplicated_lines_density','ncloc')) {
        if ($medidas -match "\{""metric"":""$m"",""value"":""([^""]+)""") {
            Write-Host ("    {0,-26}: {1}" -f $m, $Matches[1])
        }
    }
}

Write-Host ''
Write-Host 'Hecho. Tablero: http://localhost:9000/projects' -ForegroundColor Green
Write-Host ''
Write-Host 'Recordatorios al citar esto en el informe:' -ForegroundColor DarkYellow
Write-Host '  - La letra A de mantenibilidad RESPALDA a RNF-20; el SRS no exige una nota de Sonar.'
Write-Host '  - "0 vulnerabilidades" es SOLO del codigo propio: el escaner registra'
Write-Host '    "Dependency analysis skipped". Las dependencias se miran con Trivy o'
Write-Host '    dependencyCheckAnalyze, y ahi hay 4 CRITICAL y 10 HIGH (16-nov).'
Write-Host '  - Los security hotspots no son vulnerabilidades confirmadas.'
Write-Host ''
