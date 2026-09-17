# Muhitlar (API manzillari)

Ilova qaysi serverga ulanishi **shu papkadagi fayllar** bilan belgilanadi. Kodda
hech narsa o'zgartirilmaydi — [`constants.dart`](../lib/core/constants/constants.dart)
dagi `DOMAIN` qiymatini `--dart-define-from-file` beradi.

| Fayl | Muhit | Manzil |
|---|---|---|
| `prod.json` | **Production** — real mijozlar serveri | `https://api.jobup24.uz` |
| `dev.json` | **Dev / test** — sinov serveri | `https://api-dev.jobup24.uz` |
| `local.json` | **Lokal** — shu kompyuterdagi backend, telefon Wi-Fi orqali ulanadi | avtomatik yoziladi (git'da yo'q) |

## ⚠ DEV serverida nima BOSHQACHA

Sinov serveri (`api-dev.jobup24.uz`) prod bilan **bitta mashinada**, lekin butunlay
alohida: o'z bazasi (`job_up_dev` — prod nusxasi, ya'ni ichida real anketalar bor)
va o'z JWT kaliti (dev tokeni prod'da ishlamaydi, teskarisi ham).

Tashqi kanallar u yerda **ataylab o'chirilgan** — nusxadagi haqiqiy raqamlarga
xabar ketmasligi uchun. Sinovda shuni kutib o'tirmang:

| | DEV | PROD |
|---|---|---|
| Tasdiqlash kodi (OTP) | har doim **123456**, SMS kelmaydi | real SMS |
| FCM push | **kelmaydi** (`FCM_ENABLED=0`) | keladi |
| Telegram bot | o'chiq | `@Jobup24bot` |
| Qo'ng'iroqlar (OnlinePBX) | o'chiq | ishlaydi |
| To'lov | **avtomatik** — tugma bosilsa darhol to'lanadi | jonli Payme kassasi |

## ✅ DEV'da TO'LOV AVTOMATIK

Sinov serverida to'lov uchun pul ham, Payme akkaunti ham kerak EMAS. Ilovadagi
har qanday "To'lash / Sotib olish" tugmasi bosilganda backend'ning o'z sahifasi
ochiladi, to'lov darhol yakunlanadi va mijoz "To'lov qabul qilindi" degan
sahifani ko'radi (Mini App ichida 2 soniyadan keyin o'zi yopiladi).

**Ilova tomonda hech narsa o'zgarmaydi** — serverdan kelgan `checkout_url` ni
odatdagidek ochaverasiz. Faqat u Payme o'rniga
`api-dev.jobup24.uz/api/v1/online-payments/test-pay/...` ga ishora qiladi.

Shu yo'l bilan sinaladigan oqimlar:

| Oqim | Natija |
|---|---|
| Balans to'ldirish | balans oshadi |
| Otklik paketi | hamyon faollashadi, kvota tushadi |
| Tarif obunasi | obuna `active`, 30 kunlik kvota beriladi |
| Shartnoma (operator havolasi) | shartnoma to'langan, varonka qulfi ochiladi |

Tekshirilgan (2026-09-17): balans 0 → 50 000, otklik hamyoni 10 ta, obuna
faollashdi — hammasi kassaga daromad yozib.

⚠ Qayta bosilsa ikkinchi marta pul yozilmaydi ("Allaqachon to'langan").
⚠ Bu faqat DEV'da: prod'da bu manzil 404 qaytaradi.

## Domen o'zgarsa

Faqat mos `*.json` dagi bitta qatorni almashtiring — boshqa hech qayerga
tegmaydi (`DOMAIN` dan `BASE_URL`, `BASE_IMAGE_URL` va Socket.IO manzili ham
o'zi hosil bo'ladi):

```json
{ "API_DOMAIN": "https://<yangi-domen>" }
```

## Lokal muhit

`local.json` **qo'lda yozilmaydi** — `tool/run.ps1` uni har safar kompyuterning
joriy Wi-Fi IP si bilan qayta yozadi (IP o'zgarganda o'zingiz qidirib o'tirmaysiz).
Shuning uchun u `.gitignore` da: har bir dasturchining IP si o'ziniki.

Shartlar:
- telefon va kompyuter **bitta Wi-Fi** da bo'lsin (telefon uchun `localhost` —
  telefonning o'zi, kompyuter emas);
- backend ishlab tursin: `cd backend && npm run dev` (`PORT=5024`);
- ochiq HTTP faqat **debug** build'da ruxsat etilgan
  ([android/app/src/debug/AndroidManifest.xml](../android/app/src/debug/AndroidManifest.xml)) —
  Android 9+ aks holda so'rovni jimgina bloklaydi.

## Tarqatish uchun APK

Xuddi shu fayllar build'da ham ishlatiladi — sinovchilarga DEV, mijozlarga PROD,
kod esa bir xil:

```powershell
./tool/build.ps1 dev            # sinov serveriga ulanadigan APK
./tool/build.ps1 prod -Aab      # Play Store uchun
```

`local` muhitini RELEASE qilib yig'ib bo'lmaydi (ochiq HTTP faqat debug'da) —
skript buni aytadi va `-DebugBuild` ni taklif qiladi.

## Yangi sozlama qo'shish

Uchala faylga ham bir xil kalit qo'shing va kodda
`String.fromEnvironment('<KALIT>')` bilan o'qing. Faylda bor, kodda yo'q kalit —
zararsiz; teskarisi — bo'sh satr.
