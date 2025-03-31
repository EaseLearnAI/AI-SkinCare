plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ai_skincare"
    compileSdk = flutter.compileSdkVersion?.toInt() ?: 33 // 默认值为33，如果获取失败使用默认值
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.ai_skincare"
        minSdk = flutter.minSdkVersion?.toInt() ?: 21 // 默认值为21，如果获取失败使用默认值
        targetSdk = flutter.targetSdkVersion?.toInt() ?: 33 // 默认值为33，如果获取失败使用默认值
        versionCode = flutter.versionCode?.toInt() ?: 1 // 默认值为1，如果获取失败使用默认值
        versionName = flutter.versionName ?: "1.0" // 默认值为"1.0"，如果获取失败使用默认值

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            isShrinkResources = false  // 关闭移除未使用资源功能
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(kotlin("stdlib", "1.8.0")) // 或者您需要的具体版本
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // 确保使用最新版本
}