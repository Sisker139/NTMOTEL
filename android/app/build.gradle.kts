// File: android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // 🔑 Firebase plugin
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin (phải có)
}

android {
    namespace = "com.example.ntmotel" // 🔧 Sửa theo namespace của bạn
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.ntmotel" // 🔧 Sửa theo app ID thật
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Hoặc release nếu có keystore riêng
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}
