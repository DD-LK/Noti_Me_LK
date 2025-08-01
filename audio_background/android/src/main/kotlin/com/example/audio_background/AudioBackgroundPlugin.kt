package com.example.audio_background

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** AudioBackgroundPlugin */
class AudioBackgroundPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var context: Context

  companion object {
    var channel: MethodChannel? = null
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.audio_background")
    channel?.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
        "play" -> {
            val args = call.arguments as HashMap<String, Any>
            val intent = Intent(context, AudioBackgroundService::class.java)
            intent.action = "PLAY"
            intent.putExtra("mediaItem", args)
            context.startService(intent)
            result.success(null)
        }
        "pause" -> {
            val intent = Intent(context, AudioBackgroundService::class.java)
            intent.action = "PAUSE"
            context.startService(intent)
            result.success(null)
        }
        "stop" -> {
            val intent = Intent(context, AudioBackgroundService::class.java)
            intent.action = "STOP"
            context.startService(intent)
            result.success(null)
        }
        "seek" -> {
            val args = call.arguments as Map<String, Any>
            val position = (args["position"] as Number).toLong()
            val intent = Intent(context, AudioBackgroundService::class.java)
            intent.action = "SEEK"
            intent.putExtra("position", position)
            context.startService(intent)
            result.success(null)
        }
        "initialize" -> {
            // No-op
            result.success(null)
        }
        else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    channel = null
  }
}
