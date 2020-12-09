package com.kanade.f_todo.provider

import com.kanade.f_todo.entity.MscCalendar
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

interface CalendarProvider {
    fun getCalendar(): List<MscCalendar>

    fun login()

    fun logout()

    fun onAttachedToActivity(binding: ActivityPluginBinding)

    fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding)

    fun onDetachedFromActivityForConfigChanges()

    fun onDetachedFromActivity()
}