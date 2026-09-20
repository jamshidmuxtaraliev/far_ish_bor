<#
  JobUp24 — PowerShell qisqartmalari.

  Bu fayl loyihada NAMUNA sifatida turadi; ishlashi uchun foydalanuvchining
  PowerShell profiliga ko'chiriladi:

      notepad $PROFILE          # fayl yo'q bo'lsa avval:  New-Item $PROFILE -Force

  Undan keyin terminalni qayta oching va ISTALGAN papkadan:

      jobup            # dev serveri bilan telefonda ishga tushiradi
      jobup prod       # production
      jobup local      # shu kompyuterdagi backend (Wi-Fi IP avtomatik)
      jobup dev --release

      jobup-build            # dev APK yig'adi
      jobup-build prod -Install   # prod APK yig'ib telefonga o'rnatadi

  ⚠ Flutter ni PATH ga qo'shish SHART EMAS — tool/_sdk.ps1 uni o'zi topadi.
#>

# Loyiha ildizi — boshqa diskka ko'chirsangiz shu yo'lni o'zgartiring.
$env:JOBUP24_CLIENT = 'D:\MySoft\JobUp24\client'

function jobup {
    <#
    .SYNOPSIS
      JobUp24 mobil ilovasini ulangan telefonda ishga tushiradi.
      Argumentlar tool/run.ps1 ga o'zgarishsiz uzatiladi.
    #>
    # Joriy papkani BUZMAYMIZ: skript o'zi kerakli papkaga o'tadi, biz esa
    # chaqiruvdan keyin foydalanuvchini o'z joyida qoldiramiz.
    $here = Get-Location
    try {
        & (Join-Path $env:JOBUP24_CLIENT 'tool\run.ps1') @args
    } finally {
        Set-Location $here
    }
}

function jobup-build {
    <#
    .SYNOPSIS
      JobUp24 APK/AAB yig'adi. Argumentlar tool/build.ps1 ga uzatiladi.
    #>
    $here = Get-Location
    try {
        & (Join-Path $env:JOBUP24_CLIENT 'tool\build.ps1') @args
    } finally {
        Set-Location $here
    }
}
