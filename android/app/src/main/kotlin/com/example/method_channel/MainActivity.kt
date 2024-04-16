package com.example.method_channel

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    companion object{
        private val CHANNEL = "samples.flutter.dev/native"
        val handler = Handler(Looper.getMainLooper())
        private lateinit var flutterContext: FlutterEngine
        private lateinit var myRunnable:Runnable
        private fun sendEventToFlutter() {
            MethodChannel(flutterContext.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("reverseChannelStream", "")
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterContext = flutterEngine
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else if(call.method == "startService"){
                startPeriodicTask()
                result.success(true)
            }else if(call.method == "stopService"){
                handler.removeCallbacks(myRunnable);
                result.success(true)
            }else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        return batteryLevel
    }

    fun startPeriodicTask() {
        myRunnable = object : Runnable {
            override fun run() {
                // Do something here, like send a message to Flutter
                sendEventToFlutter()

                // Schedule the task to run again after 5 seconds
                handler.postDelayed(this, 5000)
            }
        }

        handler.postDelayed(myRunnable, 0) // Initial delay of 5 seconds
    }




}
