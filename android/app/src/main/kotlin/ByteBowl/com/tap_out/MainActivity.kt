package com.bytebowl.tapout

import android.os.PowerManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {
    private var wakeLock: PowerManager.WakeLock? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.app/wakelock")
            .setMethodCallHandler { call, result ->
                if (call.method == "acquireWakeLock") {
                    Log.d("MainActivity", "Acquiring wake lock")
                    acquireWakeLock()
                    result.success(null)
                } else if (call.method == "releaseWakeLock") {
                    Log.d("MainActivity", "Releasing wake lock")
                    releaseWakeLock()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun acquireWakeLock() {
        if (wakeLock == null) {
            val powerManager: PowerManager = getSystemService(POWER_SERVICE) as PowerManager
            wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "MyApp::WakeLock")
            wakeLock?.acquire()
            Log.d("MainActivity", "Wake lock acquired")
        } else {
            Log.d("MainActivity", "Wake lock already held")
        }
    }

    private fun releaseWakeLock() {
        if (wakeLock != null && wakeLock?.isHeld == true) {
            wakeLock?.release()
            wakeLock = null
            Log.d("MainActivity", "Wake lock released")
        } else {
            Log.d("MainActivity", "No wake lock to release")
        }
    }
}
