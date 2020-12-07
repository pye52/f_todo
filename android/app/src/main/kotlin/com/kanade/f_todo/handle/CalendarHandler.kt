package com.kanade.f_todo.handle

import com.kanade.f_todo.provider.CalendarProvider
import com.kanade.f_todo.provider.MscCalendarProvider
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CalendarHandler : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "Calendar"
    }
    private val providers = arrayListOf<CalendarProvider>(MscCalendarProvider())

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "login" -> providers.forEach { it.login() }
            "logout" -> providers.forEach { it.logout() }
            "getCalendar" -> result.success(providers.map { it.getCalendar() }.toList())
        }
    }

    fun onAttachedToActivity(binding: ActivityPluginBinding) {
        providers.forEach {
            it.onAttachedToActivity(binding)
        }
    }

    fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        providers.forEach {
            it.onReattachedToActivityForConfigChanges(binding)
        }
    }

    fun onDetachedFromActivityForConfigChanges() {
        providers.forEach {
            it.onDetachedFromActivityForConfigChanges()
        }
    }

    fun onDetachedFromActivity() {
        providers.forEach {
            it.onDetachedFromActivity()
        }
    }
}