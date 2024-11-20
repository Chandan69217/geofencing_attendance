package com.example.geofencing_attendance.service

import android.app.ActivityManager
import android.app.IntentService
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Context.ACTIVITY_SERVICE
import android.content.Intent
import android.os.Build
import android.widget.Toast
import androidx.core.content.ContextCompat.startForegroundService
import io.flutter.Log

class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        context?.startService(Intent(context, GeofencingService::class.java))
    }
}
