package com.example.geofencing_attendance.service

import android.Manifest
import android.app.Notification
import android.app.Service
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat
import  android.R
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import com.example.geofencing_attendance.MainActivity
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices


class GeofencingService() : Service(){
    private val CHANNEL_ID = "Geofencing Service"

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        setupGeofence()
        return START_STICKY
    }

    override fun onCreate() {
        super.onCreate()
//        createNotificationChannel()
    }
    override fun onBind(p0: Intent?): IBinder? {
        TODO("Not yet implemented")
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "your_channel_id"
            val channelName = "Your Channel Name"
            val channelDescription = "Your Channel Description"
            val importance = NotificationManager.IMPORTANCE_DEFAULT

            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val channelId = CHANNEL_ID // Use the same channel ID as above
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT)

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("Service Running")
            .setContentText("Your service is running in the foreground")
            .setSmallIcon(R.drawable.ic_notification_overlay) // Replace with your notification icon
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun setupGeofence(){
        val geofence = Geofence.Builder()
            .setCircularRegion(25.626795,85.109601,30f)
            .setExpirationDuration(Geofence.NEVER_EXPIRE)
            .setRequestId("Attendance")
            .setLoiteringDelay(500)
            .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER or Geofence.GEOFENCE_TRANSITION_EXIT or Geofence.GEOFENCE_TRANSITION_DWELL)
            .build()

        val geofencingRequest = GeofencingRequest.Builder()
            .addGeofence(geofence)
            .setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER)
            .build()

        val geofencingClient = LocationServices.getGeofencingClient(this)


        val pendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            Intent(this,GeofenceEventReceiver::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )

        if(pendingIntent == null){
            Log.d("Geofence","Pending Intent is null")
        }

       if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.M){
           if(checkSelfPermission(Manifest.permission.ACCESS_BACKGROUND_LOCATION) == PackageManager.PERMISSION_GRANTED){
               geofencingClient.addGeofences(geofencingRequest,pendingIntent)
                   .addOnSuccessListener(){
                       Log.d("Geofence","Successfully add Geofence")
                   }
                   .addOnFailureListener(){
                       Log.e("Geofence","Failed to add Geofence")
                   }
           }
       }
    }
}

