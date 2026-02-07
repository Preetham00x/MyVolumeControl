package com.volumecontrol.volume_control_overlay

import android.content.Context
import android.media.AudioManager
import android.service.quicksettings.TileService
import android.graphics.drawable.Icon

class VolumeTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        // Update tile state when user sees it
        qsTile?.let { tile ->
            tile.label = "Volume"
            tile.contentDescription = "Tap to show volume control"
            tile.updateTile()
        }
    }

    override fun onClick() {
        super.onClick()
        // Show the system volume UI
        showVolumePanel()
    }

    private fun showVolumePanel() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        // Adjust volume by 0 to just show the UI
        audioManager.adjustStreamVolume(
            AudioManager.STREAM_MUSIC,
            AudioManager.ADJUST_SAME,
            AudioManager.FLAG_SHOW_UI
        )
    }
}
