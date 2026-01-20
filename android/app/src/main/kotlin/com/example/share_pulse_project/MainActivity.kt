package com.example.share_pulse_project

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.Build
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "native/device"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getDeviceData") {
                try {
                    result.success(getDeviceData())
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getDeviceData(): Map<String, Any> {

        /* ---------------- BATTERY ---------------- */
        val batteryManager =
            getSystemService(Context.BATTERY_SERVICE) as BatteryManager

        val batteryLevel =
            batteryManager.getIntProperty(
                BatteryManager.BATTERY_PROPERTY_CAPACITY
            )

        val batteryIntent = registerReceiver(
            null,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        )

        val temp =
            batteryIntent?.getIntExtra(
                BatteryManager.EXTRA_TEMPERATURE,
                0
            ) ?: 0

        val batteryTemp = temp / 10.0

        val healthInt =
            batteryIntent?.getIntExtra(
                BatteryManager.EXTRA_HEALTH,
                BatteryManager.BATTERY_HEALTH_UNKNOWN
            )

        val batteryHealth = when (healthInt) {
            BatteryManager.BATTERY_HEALTH_GOOD -> "Good"
            BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Overheat"
            BatteryManager.BATTERY_HEALTH_DEAD -> "Dead"
            BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "Over Voltage"
            BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE -> "Failure"
            else -> "Unknown"
        }

        /* ---------------- WIFI ---------------- */
        val wifiManager =
            applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

        val wifiInfo = wifiManager.connectionInfo
        val ssid = wifiInfo.ssid ?: "Unknown"
        val rssi = wifiInfo.rssi
        val ipAddress = wifiInfo.ipAddress

        val localIp =
            "${ipAddress and 0xff}." +
                    "${ipAddress shr 8 and 0xff}." +
                    "${ipAddress shr 16 and 0xff}." +
                    "${ipAddress shr 24 and 0xff}"

        /* ---------------- CARRIER ---------------- */
        val telephonyManager =
            getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

        val carrierName =
            telephonyManager.networkOperatorName ?: "Unknown"

        val simState = when (telephonyManager.simState) {
            TelephonyManager.SIM_STATE_READY -> "READY"
            TelephonyManager.SIM_STATE_ABSENT -> "ABSENT"
            TelephonyManager.SIM_STATE_NETWORK_LOCKED -> "LOCKED"
            TelephonyManager.SIM_STATE_PIN_REQUIRED -> "PIN_REQUIRED"
            TelephonyManager.SIM_STATE_PUK_REQUIRED -> "PUK_REQUIRED"
            else -> "UNKNOWN"
        }

        /* ---------------- DEVICE ---------------- */
        val deviceName = Build.MODEL ?: "Unknown"
        val androidVersion = Build.VERSION.RELEASE ?: "Unknown"

        /* ---------------- PLACEHOLDERS (Next step) ---------------- */
        val stepCount = 0          // next: TYPE_STEP_COUNTER
        val activity = "Unknown"   // next: Activity Recognition API

        /* ---------------- RETURN MAP ---------------- */
        return mapOf(
            "batteryLevel" to batteryLevel,
            "batteryTemp" to batteryTemp,
            "batteryHealth" to batteryHealth,
            "stepCount" to stepCount,
            "activity" to activity,
            "ssid" to ssid,
            "rssi" to rssi,
            "localIP" to localIp,
            "carrier" to carrierName,
            "simState" to simState,
            "deviceName" to deviceName,
            "androidVersion" to androidVersion,
            "timestamp" to System.currentTimeMillis()
        )
    }
}
