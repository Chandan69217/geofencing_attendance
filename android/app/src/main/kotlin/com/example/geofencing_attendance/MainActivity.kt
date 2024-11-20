package com.example.geofencing_attendance

import android.app.ActivityManager
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import com.example.geofencing_attendance.channels.ServiceMethodChannels
import com.example.geofencing_attendance.service.FlutterEngineHolder
import com.example.geofencing_attendance.service.GeofencingService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(){

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineHolder.flutterEngine = flutterEngine
        ServiceMethodChannels(flutterEngine,context)
//       if(!getServiceIsRunning()){
//           val serviceIntent = Intent(this, GeofencingService::class.java)
//           if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//               startForegroundService(serviceIntent)
//               startForegroundService(serviceIntent)
//           }else{
//               startService(serviceIntent)
//           }
//       }

    }


}
