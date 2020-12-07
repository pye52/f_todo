package com.kanade.f_todo.plugin

import com.kanade.f_todo.handle.CalendarHandler
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class CalendarPlugin : FlutterPlugin, ActivityAware {
    private var methodChannel: MethodChannel? = null
    private val handler by lazy { CalendarHandler() }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        MethodChannel(binding.binaryMessenger, "calendar_plugin").run {
            setMethodCallHandler(handler)
            methodChannel = this
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        handler.onAttachedToActivity(binding)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        handler.onReattachedToActivityForConfigChanges(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        handler.onDetachedFromActivityForConfigChanges()
    }

    override fun onDetachedFromActivity() {
        handler.onDetachedFromActivity()
    }
}