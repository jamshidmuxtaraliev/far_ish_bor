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
| To'lov (Payme) | `is_test=1` → **test.paycom.uz** (pul yechilmaydi) | jonli kassa |

⚠ To'lov haqida: dev'da Payme `is_test=1` qilingan, ya'ni ilova yasagan
`checkout_url` sandbox hostiga (`test.paycom.uz`) ketadi va **haqiqiy pul
yechilmaydi**. Ammo kassaning `merchant_id` si hamon jonliniki — sandbox uni
tanimay "Поставщик не найден" deb qaytarishi mumkin. Ya'ni ilovadagi oqim
(intent yaratish → `checkout_url` olish → ochish) to'liq sinaladi, Payme
sahifasining o'zi esa xato beradi. To'lovni oxirigacha sinash kerak bo'lsa
Payme kabinetida **alohida sandbox kassa** ochilib, uning `merchant_id`/kaliti
dev bazasiga yozilishi kerak.

⛔ `is_test` ni dev'da 0 ga QAYTARMANG: u holda ilova jonli kassaga olib boradi
va sinovchi rostdan to'lab qo'ysa, Payme webhook'i **prod**ga ketadi (kabinetdagi
callback manzili o'sha) — pul yechiladi, lekin hech qayerga bog'lanmaydi.

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
