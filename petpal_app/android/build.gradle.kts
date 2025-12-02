plugins {
    id("com.android.application") version "8.9.1" apply false
    // Align with Flutter/AGP bundled Kotlin (2.1.0) to avoid classpath conflicts
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    // Let Flutter tooling provide the plugin version
    id("dev.flutter.flutter-gradle-plugin") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
