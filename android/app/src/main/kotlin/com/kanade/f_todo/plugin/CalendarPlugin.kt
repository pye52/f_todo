package com.kanade.f_todo.plugin

import android.util.Log
import com.kanade.f_todo.handle.CalendarHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class CalendarPlugin : FlutterPlugin, ActivityAware {
    companion object {
        private const val TAG = "CalendarPlugin"
    }
    private var methodChannel: MethodChannel? = null
    private val handler by lazy { CalendarHandler() }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        MethodChannel(binding.binaryMessenger, "calendar_plugin").run {
            setMethodCallHandler(handler)
            methodChannel = this
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        Log.d(TAG, "onDetachedFromEngine")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        handler.onAttachedToActivity(binding)
        Log.d(TAG, "onAttachedToActivity")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        handler.onReattachedToActivityForConfigChanges(binding)
        Log.d(TAG, "onReattachedToActivityForConfigChanges")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        handler.onDetachedFromActivityForConfigChanges()
        Log.d(TAG, "onDetachedFromActivityForConfigChanges")
    }

    override fun onDetachedFromActivity() {
        handler.onDetachedFromActivity()
        Log.d(TAG, "onDetachedFromActivity")
    }
}