<#
.SYNOPSIS
  Ilovani ulangan telefonda BITTA buyruq bilan ishga tushiradi.

.DESCRIPTION
  Qaysi serverga ulanish `env/<muhit>.json` bilan belgilanadi (env/README.md).
  `local` muhitida fayl har safar kompyuterning JORIY Wi-Fi IP si bilan qayta
  yoziladi — IP o'zgarganda qo'lda tahrirlash kerak emas.

.EXAMPLE
  .\tool\run.ps1                 # dev/test serveri (standart)
  .\tool\run.ps1 prod            # production
  .\tool\run.ps1 local           # shu kompyuterdagi backend, Wi-Fi orqali
  .\tool\run.ps1 local -Ip 192.168.1.50 -Port 5024
  .\tool\run.ps1 prod -- --release
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('dev', 'prod', 'local')]
    [string]$Env = 'dev',

    # Lokal muhit uchun: avtomatik aniqlangan IP o'rniga shu manzil ishlatiladi.
    [string]$Ip,

    # Lokal backend porti — backend/.env dagi PORT bilan bir xil bo'lishi SHART.
    [int]$Port = 5024,

    # Faqat env/<muhit>.json ni tayyorlab chiqadi, `flutter run` ni chaqirmaydi.
    # VS Code launch.json dagi preLaunchTask shu rejimda chaqiradi.
    [switch]$EnvOnly,

    # Qolgan hamma narsa `flutter run` ga o'zgarishsiz uzatiladi.
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

$ErrorActionPreference = 'Stop'
$clientDir = Split-Path -Parent $PSScriptRoot
Set-Location $clientDir

# ── 1. Flutter buyrug'ini topamiz: FVM bo'lsa u, bo'lmasa global flutter ──
# Loyiha .fvmrc da versiyaga qadalgan (3.44.0), shuning uchun FVM afzal.
$fvm = Get-Command fvm -ErrorAction SilentlyContinue
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if ($fvm) {
    $exe = $fvm.Source
    $pre = @('flutter')
} elseif ($flutter) {
    $exe = $flutter.Source
    $pre = @()
    Write-Host "! fvm topilmadi - global flutter ishlatilyapti (.fvmrc: 3.44.0 emas bo'lishi mumkin)" -ForegroundColor Yellow
} elseif ($EnvOnly) {
    # -EnvOnly faqat env faylini yozadi; SDK bu bosqichda kerak emas.
    $exe = $null
    $pre = @()
} else {
    Write-Host ""
    Write-Host "Flutter SDK topilmadi." -ForegroundColor Red
    Write-Host "  dart pub global activate fvm"
    Write-Host "  fvm install ; fvm use 3.44.0"
    Write-Host "keyin 'fvm flutter doctor' hamma qatorda ✓ berishi kerak."
    Write-Host ""
    exit 1
}

# ── 2. Lokal muhit: Wi-Fi IP sini aniqlab env/local.json ni yangilaymiz ──
if ($Env -eq 'local') {
    if (-not $Ip) {
        # Standart shlyuzi bor va ishlab turgan adapter = tarmoqqa chiqadigan adapter.
        $cfg = Get-NetIPConfiguration |
            Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } |
            Select-Object -First 1
        if ($cfg) { $Ip = $cfg.IPv4Address.IPAddress }
    }
    if (-not $Ip) {
        Write-Host "Wi-Fi IP aniqlanmadi. Qo'lda bering: .\tool\run.ps1 local -Ip 192.168.x.x" -ForegroundColor Red
        exit 1
    }

    $domain = "http://${Ip}:${Port}"
    $json = "{`n  `"API_DOMAIN`": `"$domain`"`n}`n"
    Set-Content -Path 'env/local.json' -Value $json -Encoding utf8 -NoNewline
    Write-Host "Lokal manzil: $domain" -ForegroundColor Cyan
    Write-Host "  (backend ishlab tursin: cd ..\backend ; npm run dev)" -ForegroundColor DarkGray

    # Backend javob beryaptimi — telefonda kutib o'tirmaslik uchun oldindan.
    try {
        $probe = Invoke-WebRequest -Uri "$domain/api/v1/health" -TimeoutSec 3 -UseBasicParsing
        if ($probe.StatusCode -eq 200) { Write-Host "Backend javob berdi." -ForegroundColor Green }
    } catch {
        Write-Host "! Backend bu manzilda javob bermadi - telefon ham ulana olmaydi." -ForegroundColor Yellow
        Write-Host "  Tekshiring: backend ishlayaptimi, Windows Firewall $Port portini ochganmi." -ForegroundColor DarkGray
    }
}

$envFile = "env/$Env.json"
if (-not (Test-Path $envFile)) {
    Write-Host "$envFile topilmadi (env/README.md ga qarang)." -ForegroundColor Red
    exit 1
}

# ── 3. DEV muhitining o'ziga xosliklarini eslatamiz ──
# Sinov serverida baza prod NUSXASI, lekin tashqi kanallar ataylab o'chirilgan —
# sinovchi "SMS kelmadi / push kelmadi" deb vaqt yo'qotmasin.
if ($Env -eq 'dev') {
    Write-Host "DEV: SMS/push/Telegram bot O'CHIQ - tasdiqlash kodi har doim 123456" -ForegroundColor Yellow
}

Write-Host "Muhit: $Env  ->  $envFile" -ForegroundColor Cyan
if ($EnvOnly) { exit 0 }

$argv = $pre + @('run', "--dart-define-from-file=$envFile")
if ($FlutterArgs) { $argv += ($FlutterArgs | Where-Object { $_ -ne '--' }) }

& $exe @argv
exit $LASTEXITCODE
