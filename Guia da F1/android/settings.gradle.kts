pluginManagement {
    val flutterSdkPath = {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        assert(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        // Força o download de PLUGINS por HTTP ignorando o firewall do Senac
        maven {
            url = uri("http://dl.google.com/dl/android/maven2/")
            isAllowInsecureProtocol = true
        }
        maven {
            url = uri("http://repo.maven.apache.org/maven2/")
            isAllowInsecureProtocol = true
        }
        maven {
            url = uri("http://plugins.gradle.org/m2/")
            isAllowInsecureProtocol = true
        }
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.3.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

include(":app")