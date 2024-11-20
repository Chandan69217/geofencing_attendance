package com.example.geofencing_attendance.channels

import android.app.ActivityManager
import android.content.Context
import android.content.Context.ACTIVITY_SERVICE
import android.content.Intent
import android.util.Log
import android.widget.Toast
import androidx.core.content.ContextCompat.getSystemService
import com.example.geofencing_attendance.service.GeofencingService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.Provider

class ServiceMethodChannels(private val flutterEngine: FlutterEngine,private val context: Context) {
    private val CHANNEL : String = "com.geofencing_attendance.service"
    private  lateinit var serviceIntent : Intent

    init {
        serviceIntent = Intent(context, GeofencingService::class.java)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,CHANNEL).setMethodCallHandler{ call,result ->
            when(call.method){
                "start" -> start()
                "stop" -> stop()
            }
        }
    }


    private fun start() {
        if(!getServiceIsRunning()){
            context.startService(serviceIntent)
            Toast.makeText(context,"Start is started", Toast.LENGTH_LONG).show()
        }
    }

    private fun getServiceIsRunning(): Boolean{
        val activityManager = context.getSystemService(ACTIVITY_SERVICE) as ActivityManager
        val runningServices = activityManager.getRunningServices(Int.MAX_VALUE)
        for (service in runningServices){
            if(GeofencingService::class.java.name.equals(service.service.className)){
                return  true
            }
        }
        return false
    }

    private fun stop() {
        if(getServiceIsRunning()){
            context.stopService(serviceIntent)
            Toast.makeText(context,"Service is stopped", Toast.LENGTH_LONG).show()
        }
    }
}


