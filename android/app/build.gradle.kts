plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
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

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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
