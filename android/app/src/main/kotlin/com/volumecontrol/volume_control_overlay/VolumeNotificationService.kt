package com.volumecontrol.volume_control_overlay

import android.app.*
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class VolumeNotificationService : Service() {
    
    companion object {
        const val CHANNEL_ID = "volume_control_channel"
        const val NOTIFICATION_ID = 1001
        const val ACTION_SHOW_VOLUME = "com.volumecontrol.ACTION_SHOW_VOLUME"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_SHOW_VOLUME -> {
                showVolumePanel()
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Volume Control",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Tap to show volume control"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        // Intent to show volume when notification is tapped
        val volumeIntent = Intent(this, VolumeNotificationService::class.java).apply {
            action = ACTION_SHOW_VOLUME
        }
        val volumePendingIntent = PendingIntent.getService(
            this, 0, volumeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_silent_mode_off)
            .setContentTitle("Volume Control")
            .setContentText("Tap to show volume slider")
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setContentIntent(volumePendingIntent)
            .build()
    }

    private fun showVolumePanel() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.adjustStreamVolume(
            AudioManager.STREAM_MUSIC,
            AudioManager.ADJUST_SAME,
            AudioManager.FLAG_SHOW_UI
        )
    }
}
