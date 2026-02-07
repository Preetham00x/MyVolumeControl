package com.volumecontrol.volume_control_overlay

import android.content.Context
import android.media.AudioManager
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import flutter.overlay.window.flutter_overlay_window.OverlayService as BaseOverlayService

class OverlayService : BaseOverlayService() {
    private val CHANNEL = "com.volumecontrol/volume"

    override fun onStartCommand(intent: android.content.Intent?, flags: Int, startId: Int): Int {
        val result = super.onStartCommand(intent, flags, startId)
        
        // Register method channel for the overlay's flutter engine
        overlayFlutterEngine?.let { engine ->
            MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, callResult ->
                when (call.method) {
                    "showVolumeUI" -> {
                        showSystemVolumeUI()
                        callResult.success(null)
                    }
                    else -> {
                        callResult.notImplemented()
                    }
                }
            }
        }
        
        return result
    }

    private fun showSystemVolumeUI() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.adjustStreamVolume(
            AudioManager.STREAM_MUSIC,
            AudioManager.ADJUST_SAME,
            AudioManager.FLAG_SHOW_UI
        )
    }
}
