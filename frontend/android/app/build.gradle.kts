plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ferreteria.ferreteria_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.ferreteria.ferreteria_app"
        // mobile_scanner ^5.x requiere minSdk >= 21.
        // flutter_extension default: 24 (compilamos con 24 explícito para que no se rompa si Flutter cambia el default).
        minSdk = 24
        // targetSdk 34 = Play Store 2025 baseline (Flutter 3.41 default = 36, lo bajamos a 34 para
        // mantener compatibilidad con permission_handler 11.x y evitar pedir POST_NOTIFICATIONS).
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
