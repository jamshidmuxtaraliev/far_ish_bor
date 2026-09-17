import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ── Release imzo kaliti ─────────────────────────────────────────
// `android/key.properties` bo'lsa — HAQIQIY kalit bilan imzolanadi.
// Bo'lmasa — debug kalit (ilova telefonga o'rnatiladi, lekin: Play Store qabul
// qilmaydi; har bir kompyuterning debug kaliti boshqacha, shuning uchun bir
// mashinada yig'ilgan APK ikkinchisinikining ustiga yangilanmaydi; keyin
// haqiqiy kalitga o'tilganda foydalanuvchi ilovani O'CHIRIB qayta o'rnatishga
// majbur bo'ladi — ma'lumotlari bilan birga).
// Kalit fayli va parollari git'da saqlanmaydi — tool/build.ps1 va
// env/README.md ga qarang.
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKey = keystorePropertiesFile.exists()
val keystoreProperties = Properties()
if (hasReleaseKey) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
} else {
    logger.warn("[jobUp24] android/key.properties yo'q — release build DEBUG kalit bilan imzolanadi.")
}

android {
    namespace = "uz.jobUp24.jobUp24"
    // east_quest bilan bir xil — Yandex MapKit 16 KB page size uchun
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        // east_quest bilan bir xil — Yandex MapKit 4.22.0 AAR Java 21 bytecode talab qiladi
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "uz.jobUp24.jobUp24"
        // east_quest bilan bir xil — Yandex MapKit minSdk 26 talab qiladi
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 16 KB page size support (Android 15+, Google Play requirement)
    // .so fayllar APK/AAB da siqilmasdan saqlanadi — to'g'ri alignment uchun shart
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                // Kalit berilmaguncha `flutter run --release` ishlab tursin.
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // east_quest bilan bir xil — Java 21 core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Yandex MapKit — ishlar xaritasi. yandex_mapkit 4.2.1 plugin 4.22.0-full ga qulflangan
    // (16 KB page size mos). App va plugin bir xil versiyada — versiya konflikti bo'lmasin.
    implementation("com.yandex.android:maps.mobile:4.22.0-full")
}
