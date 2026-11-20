
// Samakan compileSdk seluruh plugin Android Flutter dengan aplikasi utama.
// Beberapa plugin lama (termasuk firebase_messaging 14.x) masih menetapkan API 33,
// sehingga pemeriksaan AAR gagal ketika dependensinya membutuhkan API 34+.
subprojects {
    fun enforceCompileSdk36() {
        val androidExtension = project.extensions.findByName("android") ?: return
        val setter = androidExtension.javaClass.methods.firstOrNull { method ->
            method.name in setOf("setCompileSdk", "setCompileSdkVersion", "compileSdkVersion") &&
                method.parameterCount == 1 &&
                method.parameterTypes[0] == Int::class.javaPrimitiveType
        } ?: throw GradleException(
            "Tidak dapat mengatur compileSdk=36 untuk modul ${project.path}"
        )
        setter.invoke(androidExtension, 36)
        project.logger.lifecycle("${project.path}: compileSdk dipaksa ke 36")
    }

    plugins.withId("com.android.library") {
        project.afterEvaluate { enforceCompileSdk36() }
    }
    plugins.withId("com.android.application") {
        project.afterEvaluate { enforceCompileSdk36() }
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory.dir("../../build").get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory =
        newBuildDir.dir(project.name)

    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
