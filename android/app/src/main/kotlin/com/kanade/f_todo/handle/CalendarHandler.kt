package com.kanade.f_todo.handle

import android.util.Log
import com.kanade.f_todo.provider.CalendarProvider
import com.kanade.f_todo.provider.MscCalendarProvider
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class CalendarHandler : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "CalendarHandler"
    }
    private val providers = arrayListOf<CalendarProvider>(MscCalendarProvider())

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall: ${call.method}")
        when (call.method) {
            "login" -> providers.forEach { it.login(result) }
            "refreshToken" -> providers.forEach { it.refreshToken() }
            "logout" -> providers.forEach { it.logout() }
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