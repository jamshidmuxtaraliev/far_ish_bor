<#
.SYNOPSIS
  Tarqatish uchun APK / AAB yig'adi va tayyor faylni `build/out/` ga qo'yadi.

.DESCRIPTION
  Qaysi serverga ulanishi `env/<muhit>.json` bilan belgilanadi (env/README.md) —
  ya'ni sinovchilarga DEV APK, mijozlarga PROD APK beriladi, kod bir xil.

.EXAMPLE
  .\tool\build.ps1 dev              # sinovchilarga - bitta APK (universal)
  .\tool\build.ps1 prod -Split      # hajmi kichik: har ABI uchun alohida APK
  .\tool\build.ps1 prod -Aab        # Play Store uchun .aab
  .\tool\build.ps1 dev -Install     # yig'ib, ulangan telefonga darhol o'rnatadi
  .\tool\build.ps1 dev -BuildName 1.0.1 -BuildNumber 3
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('dev', 'prod', 'local')]
    [string]$Env = 'prod',

    # Play Store uchun App Bundle (.aab). APK o'rniga.
    [switch]$Aab,

    # Har bir protsessor turi uchun alohida APK — universaldan ~2 barobar kichik.
    [switch]$Split,

    # Release emas, debug APK (ochiq HTTP ishlaydi — `local` muhiti uchun).
    # Nomi `-Debug` EMAS: u PowerShell'ning zahiralangan umumiy parametri.
    [switch]$DebugBuild,

    # Yig'ilgandan keyin ulangan telefonga o'rnatadi.
    [switch]$Install,

    # pubspec.yaml dagi versiyani bekor qiladi (masalan 1.0.1 / 3).
    [string]$BuildName,
    [string]$BuildNumber,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

$ErrorActionPreference = 'Stop'
$clientDir = Split-Path -Parent $PSScriptRoot
Set-Location $clientDir

# ── 1. Flutter buyrug'i ──
$fvm = Get-Command fvm -ErrorAction SilentlyContinue
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if ($fvm) {
    $exe = $fvm.Source; $pre = @('flutter')
} elseif ($flutterCmd) {
    $exe = $flutterCmd.Source; $pre = @()
    Write-Host "! fvm topilmadi - global flutter ishlatilyapti" -ForegroundColor Yellow
} else {
    Write-Host "Flutter SDK topilmadi. Avval o'rnating (client/CLAUDE.md)." -ForegroundColor Red
    exit 1
}

# ── 2. Muhit fayli ──
if ($Env -eq 'local') {
    # Lokal manzilni run.ps1 yozadi (joriy Wi-Fi IP).
    & "$PSScriptRoot/run.ps1" local -EnvOnly
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if (-not $DebugBuild) {
        Write-Host ""
        Write-Host "! LOCAL muhiti RELEASE build'da ishlamaydi." -ForegroundColor Yellow
        Write-Host "  Lokal backend http:// da, ochiq HTTP esa faqat debug build'da ruxsat etilgan." -ForegroundColor DarkGray
        Write-Host "  Buning o'rniga: .\tool\build.ps1 local -DebugBuild" -ForegroundColor DarkGray
        Write-Host ""
        exit 1
    }
}
$envFile = "env/$Env.json"
if (-not (Test-Path $envFile)) {
    Write-Host "$envFile topilmadi (env/README.md)." -ForegroundColor Red
    exit 1
}

# ── 3. Imzo kaliti ──
$mode = if ($DebugBuild) { 'debug' } else { 'release' }
if ($mode -eq 'release') {
    if (Test-Path 'android/key.properties') {
        Write-Host "Imzo: haqiqiy release kaliti" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "! android/key.properties yo'q - DEBUG kalit bilan imzolanadi." -ForegroundColor Yellow
        Write-Host "  Telefonga o'rnatiladi, lekin: Play Store qabul qilmaydi va keyin" -ForegroundColor DarkGray
        Write-Host "  haqiqiy kalitga o'tilganda foydalanuvchi ilovani o'chirib qayta" -ForegroundColor DarkGray
        Write-Host "  o'rnatishga majbur bo'ladi. Namuna: android/key.properties.example" -ForegroundColor DarkGray
        Write-Host ""
    }
}

# ── 4. Yig'amiz ──
$target = if ($Aab) { 'appbundle' } else { 'apk' }
$argv = $pre + @('build', $target, "--$mode", "--dart-define-from-file=$envFile")
if ($Split -and -not $Aab) { $argv += '--split-per-abi' }
if ($BuildName)   { $argv += "--build-name=$BuildName" }
if ($BuildNumber) { $argv += "--build-number=$BuildNumber" }
if ($FlutterArgs) { $argv += ($FlutterArgs | Where-Object { $_ -ne '--' }) }

Write-Host "Muhit: $Env  |  $target  |  $mode" -ForegroundColor Cyan
if ($Env -eq 'dev') {
    # Sinovchi APK ni olgach nimaga duch kelishini oldindan bilsin.
    Write-Host "  api-dev.jobup24.uz | SMS/push/bot O'CHIQ | tasdiqlash kodi 123456" -ForegroundColor DarkGray
}
& $exe @argv
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# ── 5. Natijani build/out/ ga tushunarli nom bilan ko'chiramiz ──
# `app-release.apk` degan nom bilan uchta muhitning fayli aralashib ketadi.
$version = (Select-String -Path 'pubspec.yaml' -Pattern '^version:\s*(.+)$').Matches[0].Groups[1].Value.Trim()
$stamp = Get-Date -Format 'yyyyMMdd-HHmm'
$outDir = 'build/out'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$sources = if ($Aab) {
    @("build/app/outputs/bundle/$mode/app-$mode.aab")
} elseif ($Split) {
    Get-ChildItem "build/app/outputs/flutter-apk/app-*-$mode.apk" | ForEach-Object { $_.FullName }
} else {
    @("build/app/outputs/flutter-apk/app-$mode.apk")
}

$made = @()
foreach ($src in $sources) {
    if (-not (Test-Path $src)) { continue }
    $ext = [System.IO.Path]::GetExtension($src)
    $abi = ''
    if ($Split) {
        $m = [regex]::Match([System.IO.Path]::GetFileName($src), "^app-(.+)-$mode\.apk$")
        if ($m.Success) { $abi = "-$($m.Groups[1].Value)" }
    }
    $dst = Join-Path $outDir "jobup24-$Env-$version$abi-$stamp$ext"
    Copy-Item $src $dst -Force
    $made += $dst
}

if (-not $made) {
    Write-Host "Yig'ildi, lekin natija fayli topilmadi." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Tayyor:" -ForegroundColor Green
foreach ($f in $made) {
    $mb = [math]::Round((Get-Item $f).Length / 1MB, 1)
    Write-Host "  $f  ($mb MB)"
}

# ── 6. Ixtiyoriy: telefonga o'rnatish ──
if ($Install) {
    if ($Aab) {
        Write-Host "! .aab telefonga to'g'ridan-to'g'ri o'rnatilmaydi (u faqat Play Store uchun)." -ForegroundColor Yellow
        exit 0
    }
    $adb = Get-Command adb -ErrorAction SilentlyContinue
    if (-not $adb -and $env:ANDROID_HOME) {
        $candidate = Join-Path $env:ANDROID_HOME 'platform-tools/adb.exe'
        if (Test-Path $candidate) { $adb = Get-Item $candidate }
    }
    if (-not $adb) {
        Write-Host "! adb topilmadi - faylni telefonga qo'lda tashlab o'rnating." -ForegroundColor Yellow
        exit 0
    }
    # -Split bo'lsa universal yo'q; eng keng tarqalgan arm64 ni tanlaymiz.
    $apk = $made | Where-Object { $_ -like '*arm64*' } | Select-Object -First 1
    if (-not $apk) { $apk = $made[0] }
    Write-Host "O'rnatilmoqda: $apk" -ForegroundColor Cyan
    & $adb.Source install -r $apk
}
