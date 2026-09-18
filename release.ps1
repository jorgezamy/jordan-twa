# Genera un .aab nuevo para Play Store.
#
# Uso (PowerShell, desde esta carpeta):
#   1. El keystore vive donde diga signingKey.path en twa-manifest.json
#      (hoy C:\Users\jorge\keys\jordan-android.keystore)
#      (fuera de OneDrive y de git; la copia de respaldo esta en Drive).
#   2. .\release.ps1
#   3. Sube app-release-bundle.aab a Play Console.
#
# Cada corrida sube el versionCode en 1 y pone ese mismo numero en la URL de
# inicio (/?appv=N). El sitio (jordan/src/components/appUpdate) lee ese numero
# para saber que version de la app tiene instalada cada usuario y compararla
# con MIN_APP_VERSION. No edites appVersionCode ni startUrl a mano.

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# La ruta del keystore sale de twa-manifest.json (signingKey.path), no esta fija aqui.
$ksPath = ([System.IO.File]::ReadAllText((Join-Path $PSScriptRoot "twa-manifest.json")) | ConvertFrom-Json).signingKey.path
if (-not (Test-Path $ksPath)) {
    throw "No existe el keystore en $ksPath (copialo de Drive, o corrige signingKey.path en twa-manifest.json)."
}

$manifestPath = Join-Path $PSScriptRoot "twa-manifest.json"
$utf8 = New-Object System.Text.UTF8Encoding($false)

# Leer SIEMPRE como UTF-8: Get-Content en PowerShell 5.1 lee ANSI y rompe los acentos
# ("Jordan" con tilde queda como basura en el nombre de la app).
$raw = [System.IO.File]::ReadAllText($manifestPath, $utf8)
$next = [int]($raw | ConvertFrom-Json).appVersionCode + 1

# Reemplazo de texto (no ConvertTo-Json) para no reformatear el archivo.
$raw = $raw -replace '"startUrl":\s*"[^"]*"', "`"startUrl`": `"/?appv=$next`""
# UTF-8 sin BOM: con BOM, Bubblewrap no puede leer el JSON.
[System.IO.File]::WriteAllText($manifestPath, $raw, $utf8)

# Suelta bloqueos de una corrida anterior (un Gradle vivo o OneDrive sincronizando
# app\build causan "EBUSY: resource busy or locked" en `bubblewrap update`).
if (Test-Path ".\gradlew.bat") {
    $env:JAVA_HOME = ([System.IO.File]::ReadAllText("$env:USERPROFILE\.bubblewrap\config.json") | ConvertFrom-Json).jdkPath
    & .\gradlew.bat --stop | Out-Null
}
foreach ($d in "app\build", "build", ".gradle") {
    if (Test-Path $d) { Remove-Item $d -Recurse -Force -ErrorAction SilentlyContinue }
}

# `update` regenera el proyecto Android y sube appVersionCode a $next.
bubblewrap update
if ($LASTEXITCODE -ne 0) { throw "bubblewrap update fallo." }

$actual = [int]([System.IO.File]::ReadAllText($manifestPath, $utf8) | ConvertFrom-Json).appVersionCode
if ($actual -ne $next) {
    throw "appVersionCode es $actual pero startUrl usa appv=$next. Corrige twa-manifest.json y repite."
}

bubblewrap build
if ($LASTEXITCODE -ne 0) { throw "bubblewrap build fallo." }

Write-Host ""
Write-Host "Listo: app-release-bundle.aab (versionCode $next)." -ForegroundColor Green
