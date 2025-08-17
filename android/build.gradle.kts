plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    //id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_core_module"
    compileSdk = 35
    buildFeatures {
        buildConfig = true
    }
    defaultConfig {
        minSdk = 21
    }
    kotlin {
        jvmToolchain(17)
    }
}

dependencies {
    implementation(kotlin("stdlib"))

}
