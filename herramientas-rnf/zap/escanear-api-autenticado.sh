#!/usr/bin/env bash
# Escaneo ZAP ACTIVO y AUTENTICADO contra el backend local de 8081 (RNF-13, RNF-14, RNF-17, OBS-02).
#
# Requisitos: pila local arriba (levantar.ps1) y backend de 8081 contra sigra-pg-rnf.
# ADVERTENCIA: es activo y entra autenticado -> ESCRIBE en la base local. Respalda antes:
#   docker exec -e PGPASSWORD=rnf_local_solo_pruebas sigra-pg-rnf \
#     pg_dump -U postgres -d postgres -n sigra -f /tmp/antes-de-zap.sql
# Nunca contra Render ni Vercel sin autorizacion escrita.
#
# Uso: bash zap/escanear-api-autenticado.sh [correo] [fecha] [etiqueta]
set -euo pipefail
# MSYS_NO_PATHCONV se aplica SOLO a docker: exportarlo global le pasa a curl una ruta
# /e/... que el curl de Windows no sabe escribir y el script muere con exit 23.
AQUI="$(cd "$(dirname "$0")/.." && pwd)"
W="$AQUI/evidencias/zap"
CORREO="${1:-admin.bruno@uco.net.co}"
FECHA="${2:-$(date +%Y-%m-%d)}"
ETIQUETA="${3:-admin}"

# 1. Spec al dia. La PRIMERA peticion a /v3/api-docs tarda ~7 s (springdoc la genera); la segunda, 0,2 s.
curl -s --max-time 90 -o "$W/openapi-8081.json" http://localhost:8081/v3/api-docs
# Se cuenta con grep y no con python: python es un binario de Windows y no sabe abrir
# la ruta /e/... que usa Git Bash.
echo "OpenAPI: $(grep -o '"/api/v1/[^"]*"' "$W/openapi-8081.json" | sort -u | wc -l) rutas"

# 2. JWT del rol pedido.
TOK=$(curl -s --max-time 20 -X POST http://localhost:8081/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"correoInstitucional\":\"$CORREO\",\"contrasena\":\"PasswordSeguro123*\"}" \
  | python -c "import sys,json;print(json.load(sys.stdin)['token'])")
echo "JWT de $CORREO obtenido (${#TOK} caracteres; caduca en 60 min)"

# 3. El token va en un FICHERO DE PROPIEDADES, no en -config.
#    ZAP parte la linea de ordenes por espacios: "-config ...replacement=Bearer <token>"
#    deja el token como argumento suelto y la cabecera NO se inyecta. El sintoma es un
#    informe de 0 hallazgos con 401 en todas las instancias.
printf 'replacer.full_list(0).description=jwt\nreplacer.full_list(0).enabled=true\nreplacer.full_list(0).matchtype=REQ_HEADER\nreplacer.full_list(0).matchstr=Authorization\nreplacer.full_list(0).regex=false\nreplacer.full_list(0).replacement=Bearer %s\nreplacer.full_list(0).initiators=\n' "$TOK" > "$W/jwt.prop"

# 4. Escanear.
MSYS_NO_PATHCONV=1 docker run --rm --add-host=host.docker.internal:host-gateway -v "$W:/zap/wrk/:rw" \
  zaproxy/zap-stable zap-api-scan.py \
  -t /zap/wrk/openapi-8081.json -f openapi \
  -O http://host.docker.internal:8081 \
  -J "zap-api-$ETIQUETA-$FECHA.json" -r "zap-api-$ETIQUETA-$FECHA.html" \
  -x "zap-api-$ETIQUETA-$FECHA.xml" -I \
  -z "-configfile /zap/wrk/jwt.prop"

# 5. El token queda en claro en jwt.prop: borrarlo.
rm -f "$W/jwt.prop"
# El XML (-x) no se usa para leer: es el UNICO formato que acepta el parser
# "ZAP Scan" de DefectDojo. Ver defectdojo/README.md seccion 6.
echo "Informes en evidencias/zap/zap-api-$ETIQUETA-$FECHA.{json,html,xml}"
