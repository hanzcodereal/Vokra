plugins {
    id("com.android.application")

    // Kotlin sudah tersedia secara bawaan di AGP 9.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dark.ZSNZ"

    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.dark.ZSNZ"

        minSdk = flutter.minSdkVersion
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Konfigurasi release.
        }
    }
}

dependencies {
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.0.4"
    )
}

flutter {
    source = "../.."
}
