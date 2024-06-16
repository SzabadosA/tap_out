package com.bytebowl.tapout

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.os.PowerManager
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import com.pravera.flutter_foreground_task.service.ForegroundService

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

        // Register lifecycle callbacks
        application.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
            override fun onActivityPaused(activity: Activity) {}
            override fun onActivityStarted(activity: Activity) {}
            override fun onActivityDestroyed(activity: Activity) {
                if (activity == this@MainActivity) {
                    stopService(Intent(this@MainActivity, ForegroundService::class.java))
                }
            }
            override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
            override fun onActivityStopped(activity: Activity) {}
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
            override fun onActivityResumed(activity: Activity) {}
        })
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
