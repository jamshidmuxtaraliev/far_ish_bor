<#
.SYNOPSIS
  Flutter va adb buyruqlarini topadi — PATH da bo'lmasa ham.

.DESCRIPTION
  `run.ps1` va `build.ps1` ikkalasi ham shu faylni dot-source qiladi:
      . "$PSScriptRoot/_sdk.ps1"

  ⚠ NEGA KERAK: bu mashinalarda Flutter `D:\tools\flutter` ga o'rnatilgan,
  lekin PATH ga QO'SHILMAGAN. Ilgari skriptlar faqat `Get-Command flutter` ga
  tayanardi, shuning uchun har safar qo'lda
      $env:PATH = "D:\tools\flutter\bin;$env:PATH"
  yozish kerak bo'lardi — buni unutgan odam "Flutter SDK topilmadi" xatosini
  olardi, holbuki SDK joyida turardi.

  Topilgan SDK ning `bin` papkasi shu jarayonning PATH iga qo'shiladi, ya'ni
  Gradle/dart kabi ichki chaqiruvlar ham ishlaydi.
#>

# Flutter qidiriladigan joylar — tartib muhim (birinchi topilgani olinadi).
# Yangi mashina qo'shilsa shu ro'yxatga yo'l qo'shing.
$script:FlutterSearchPaths = @(
    'D:/tools/flutter/bin/flutter.bat',
    'C:/tools/flutter/bin/flutter.bat',
    'C:/src/flutter/bin/flutter.bat',
    "$env:LOCALAPPDATA/flutter/bin/flutter.bat",
    "$env:USERPROFILE/fvm/default/bin/flutter.bat"
)

<#
.SYNOPSIS
  Flutter ni topadi. Qaytaradi: @{ Exe = <yo'l>; Pre = @() | @('flutter') }
  `Pre` — `fvm` topilganda `@('flutter')`, ya'ni chaqiruv `fvm flutter ...`.
  Topilmasa $null.
#>
function Resolve-FlutterCommand {
    # 1. FVM afzal — loyiha .fvmrc da versiyaga qadalgan (3.44.0).
    $fvm = Get-Command fvm -ErrorAction SilentlyContinue
    if ($fvm) { return @{ Exe = $fvm.Source; Pre = @('flutter'); Source = 'fvm' } }

    # 2. PATH dagi global flutter.
    $onPath = Get-Command flutter -ErrorAction SilentlyContinue
    if ($onPath) { return @{ Exe = $onPath.Source; Pre = @(); Source = 'PATH' } }

    # 3. Ma'lum o'rnatish joylari.
    foreach ($candidate in $script:FlutterSearchPaths) {
        if ($candidate -and (Test-Path $candidate)) {
            # Gradle va dart kabi ichki chaqiruvlar uchun PATH ga qo'shamiz.
            $bin = Split-Path -Parent $candidate
            if ($env:PATH -notlike "*$bin*") { $env:PATH = "$bin;$env:PATH" }
            return @{ Exe = $candidate; Pre = @(); Source = $bin }
        }
    }

    return $null
}

<#
.SYNOPSIS
  Flutter ni topadi, topilmasa tushunarli xabar bilan skriptni to'xtatadi.
#>
function Get-FlutterCommandOrExit {
    $f = Resolve-FlutterCommand
    if (-not $f) {
        Write-Host ''
        Write-Host 'Flutter SDK topilmadi.' -ForegroundColor Red
        Write-Host '  Qidirilgan joylar:' -ForegroundColor DarkGray
        Write-Host '    - fvm (PATH)' -ForegroundColor DarkGray
        Write-Host '    - flutter (PATH)' -ForegroundColor DarkGray
        foreach ($p in $script:FlutterSearchPaths) {
            Write-Host "    - $p" -ForegroundColor DarkGray
        }
        Write-Host '  Boshqa joyda bo`lsa tool/_sdk.ps1 dagi ro`yxatga qo`shing.' -ForegroundColor DarkGray
        Write-Host ''
        exit 1
    }
    if ($f.Source -ne 'fvm') {
        Write-Host "Flutter: $($f.Exe)" -ForegroundColor DarkGray
    }
    return $f
}

<#
.SYNOPSIS
  adb ni topadi (PATH → ANDROID_HOME → standart Android SDK joyi).
  Topilmasa $null — chaqiruvchi o'zi hal qiladi (adb majburiy emas).
#>
function Resolve-AdbPath {
    $onPath = Get-Command adb -ErrorAction SilentlyContinue
    if ($onPath) { return $onPath.Source }

    $roots = @($env:ANDROID_HOME, $env:ANDROID_SDK_ROOT, "$env:LOCALAPPDATA/Android/Sdk")
    foreach ($root in $roots) {
        if (-not $root) { continue }
        $candidate = Join-Path $root 'platform-tools/adb.exe'
        if (Test-Path $candidate) { return (Resolve-Path $candidate).Path }
    }
    return $null
}
