// File: android/app/build.gradle.kts

// THÊM: Dòng import cần thiết cho JavaVersion
import org.gradle.api.JavaVersion

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ntmotel"
    compileSdk = 35 // Bạn có thể giữ 34 hoặc 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.ntmotel"
        minSdk = 21
        targetSdk = 35 // Bạn có thể giữ 34 hoặc 35
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // SỬA: Cú pháp đúng cho Kotlin DSL
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8" // Nên đặt là 1.8 cho nhất quán
    }
}

flutter {
    source = "../.."
}

// THÊM: Khối dependencies với cú pháp Kotlin
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}