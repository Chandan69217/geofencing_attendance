package com.example.geofencing_attendance.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.R
import android.os.Build
import io.flutter.plugin.common.MethodChannel

class GeofenceEventReceiver : BroadcastReceiver() {
    private final var CHANNEL_ID : String = "Attendance Notification"

    override fun onReceive(context: Context, intent: Intent) {


        val geofenceEvent = GeofencingEvent.fromIntent(intent)
        if(geofenceEvent == null){
            Log.d("Geofence","GeofenceEvent is Null")
            return
        }

        if(geofenceEvent.hasError()){
            Log.e("Geofence","Fetching Event error")
            return
        }

        val geofenceTransition = geofenceEvent.geofenceTransition

        val eventType: String = when (geofenceTransition) {
            Geofence.GEOFENCE_TRANSITION_ENTER -> "ENTER"
            Geofence.GEOFENCE_TRANSITION_EXIT -> "EXIT"
            Geofence.GEOFENCE_TRANSITION_DWELL -> "DWELL"
            else -> "UNKNOWN"
        }
        showNotification(context,eventType);
        Log.d("Geofence",eventType)
        val flutterEngine = FlutterEngineHolder.flutterEngine
        if(flutterEngine != null){
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger,"com.geofencing_attendance.geofenceEvent").invokeMethod("geofenceEvent",eventType)
        }
    }


    private fun showNotification(context : Context , eventType : String){
        val notificationManager = context.getSystemService(Service.NOTIFICATION_SERVICE) as NotificationManager

        if(Build.VERSION.SDK_INT>= Build.VERSION_CODES.O){
            val notificationChannel = NotificationChannel(CHANNEL_ID,"Geofencing Attendance",
                NotificationManager.IMPORTANCE_DEFAULT)
            notificationChannel.description = "This Channel is used to notify you when you reached to the office & when you exit"

            val notification = NotificationCompat.Builder(context)
                .setSmallIcon(R.drawable.ic_notification_overlay)
                .setContentTitle("Geofence Attendance")
                .setContentText("Your Attendance is marked as : " + eventType)
                .setChannelId(CHANNEL_ID)
                .build()
            notificationManager.createNotificationChannel(notificationChannel)
            notificationManager.notify(100,notification)
        }else{
            val notification = NotificationCompat.Builder(context)
                .setSmallIcon(R.drawable.ic_notification_overlay)
                .setContentTitle("Geofence Attendance")
                .setContentText("Your Attendance is marked as : " + eventType)
                .build()
            notificationManager.notify(100,notification)
        }
    }
}