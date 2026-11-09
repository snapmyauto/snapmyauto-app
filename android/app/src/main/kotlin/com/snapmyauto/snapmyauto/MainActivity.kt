package com.snapmyauto.snapmyauto

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "snapmyauto/splash")
            .setMethodCallHandler { call, result ->
                if (call.method != "setAccent") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                // android 13+ remembers this and uses it on the next launch
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    val theme = if (call.arguments == "blue") {
                        R.style.LaunchThemeBlue
                    } else {
                        R.style.LaunchTheme
                    }
                    splashScreen.setSplashScreenTheme(theme)
                }
                result.success(null)
            }
    }
}