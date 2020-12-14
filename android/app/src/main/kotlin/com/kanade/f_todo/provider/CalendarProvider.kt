package com.kanade.f_todo.provider

import com.kanade.f_todo.entity.MscCalendar
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

interface CalendarProvider {
    fun getCalendar(): List<MscCalendar>

    fun login(result: MethodChannel.Result)
    
    fun refreshToken()

    fun logout()

    fun onAttachedToActivity(binding: ActivityPluginBinding)

    fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding)

    fun onDetachedFromActivityForConfigChanges()

    fun onDetachedFromActivity()
}