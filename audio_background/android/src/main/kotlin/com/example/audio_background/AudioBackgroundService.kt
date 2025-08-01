package com.example.audio_background

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.session.MediaSession
import androidx.media3.ui.PlayerNotificationManager
import io.flutter.plugin.common.MethodChannel

class AudioBackgroundService : Service() {

    private lateinit var player: ExoPlayer
    private lateinit var mediaSession: MediaSession
    private lateinit var notificationManager: PlayerNotificationManager
    private var channel: MethodChannel? = null

    companion object {
        const val NOTIFICATION_ID = 1
        const val NOTIFICATION_CHANNEL_ID = "audio_background_channel"
    }

    override fun onCreate() {
        super.onCreate()
        player = ExoPlayer.Builder(this).build()
        mediaSession = MediaSession.Builder(this, player).build()
        channel = AudioBackgroundPlugin.channel

        createNotificationChannel()

        notificationManager = PlayerNotificationManager.Builder(this, NOTIFICATION_ID, NOTIFICATION_CHANNEL_ID)
            .setNotificationListener(object : PlayerNotificationManager.NotificationListener {
                override fun onNotificationPosted(notificationId: Int, notification: Notification, ongoing: Boolean) {
                    if (ongoing) {
                        startForeground(notificationId, notification)
                    } else {
                        stopForeground(false)
                    }
                }

                override fun onNotificationCancelled(notificationId: Int, dismissedByUser: Boolean) {
                    stopSelf()
                }
            })
            .build()

        notificationManager.setPlayer(player)
        notificationManager.setMediaSessionToken(mediaSession.sessionCompatToken)

        player.addListener(object : Player.Listener {
            override fun onIsPlayingChanged(isPlaying: Boolean) {
                val state = if (isPlaying) 2 else 1 // playing or paused
                channel?.invokeMethod("onStateChanged", state)
            }

            override fun onPlaybackStateChanged(playbackState: Int) {
                if (playbackState == Player.STATE_ENDED) {
                    channel?.invokeMethod("onStateChanged", 3) // completed
                }
            }
        })
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "PLAY" -> {
                @Suppress("UNCHECKED_CAST")
                val args = intent.getSerializableExtra("mediaItem") as HashMap<String, Any>
                val title = args["title"] as String
                val artist = args["artist"] as String
                val url = args["url"] as String
                val mediaItem = MediaItem.Builder()
                    .setUri(url)
                    .setMediaMetadata(
                        androidx.media3.common.MediaMetadata.Builder()
                            .setTitle(title)
                            .setArtist(artist)
                            .build()
                    )
                    .build()
                player.setMediaItem(mediaItem)
                player.prepare()
                player.play()
            }
            "PAUSE" -> player.pause()
            "STOP" -> {
                player.stop()
                stopSelf()
            }
            "SEEK" -> {
                val position = intent.getLongExtra("position", 0)
                player.seekTo(position)
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        notificationManager.setPlayer(null)
        mediaSession.release()
        player.release()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Audio Background Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    class MediaButtonReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val serviceIntent = Intent(context, AudioBackgroundService::class.java)
            context.startService(serviceIntent)
        }
    }
}