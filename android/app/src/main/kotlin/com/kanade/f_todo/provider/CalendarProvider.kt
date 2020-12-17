package com.kanade.f_todo.provider

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

interface CalendarProvider {
    fun init()
    
    fun login(result: MethodChannel.Result)
    
    fun refreshToken(result: MethodChannel.Result)

    fun logout(result: MethodChannel.Result)

    fun onAttachedToActivity(binding: ActivityPluginBinding)

    fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding)

    fun onDetachedFromActivityForConfigChanges()

    fun onDetachedFromActivity()
}