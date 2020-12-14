package com.kanade.f_todo.provider

import android.app.Activity
import android.util.Log
import com.kanade.f_todo.entity.MscCalendar
import com.kanade.f_todo.entity.User
import com.kanade.f_todo.utils.AuthenticationHelper
import com.kanade.f_todo.utils.IAuthenticationHelperCreatedListener
import com.microsoft.identity.client.AuthenticationCallback
import com.microsoft.identity.client.IAuthenticationResult
import com.microsoft.identity.client.exception.MsalClientException
import com.microsoft.identity.client.exception.MsalException
import com.microsoft.identity.client.exception.MsalServiceException
import com.microsoft.identity.client.exception.MsalUiRequiredException
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.JSONUtil
import io.flutter.plugin.common.MethodChannel

class MscCalendarProvider : CalendarProvider {
    companion object {
        private const val TAG = "Calendar"
    }

    private var authHelper: AuthenticationHelper? = null
    private var activity: Activity? = null
    private var isSignedIn = false
    private var attemptInteractiveSignIn = false
    private var accessToken = ""

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        AuthenticationHelper.getInstance(binding.activity.application, object : IAuthenticationHelperCreatedListener {
            override fun onCreated(helper: AuthenticationHelper) {
                authHelper = helper
                if (!isSignedIn) {
                    doSilentSignIn()
                }
            }

            override fun onError(exception: MsalException) {
                Log.e(TAG, "Error creating auth helper", exception)
            }
        })
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onDetachedFromActivity() {
        activity = null
        authHelper = null
        signOut()
        attemptInteractiveSignIn = false
    }

    override fun getCalendar(): List<MscCalendar> {
        TODO("Not yet implemented")
    }

    override fun login(result: MethodChannel.Result) = doSilentSignIn(true, result)

    override fun refreshToken() = doSilentSignIn()

    override fun logout() = signOut()

    private fun doSilentSignIn(shouldAttemptInteractive: Boolean = false, result: MethodChannel.Result? = null) {
        attemptInteractiveSignIn = shouldAttemptInteractive
        authHelper?.acquireTokenSilently(getAuthCallback(result))
    }

    private fun doInteractiveSignIn() {
        activity?.let {
            authHelper?.acquireTokenInteractively(it, getAuthCallback())
        }
    }
    
    private fun getAuthCallback(result: MethodChannel.Result? = null): AuthenticationCallback = object : AuthenticationCallback {
        override fun onSuccess(aResult: IAuthenticationResult?) {
            if (aResult == null) {
                Log.d(TAG, "login failed, user is null")
                return
            }
            result?.run {
                val user = User(
                        account = aResult.account.id,
                        loginTime = System.currentTimeMillis(),
                        expiresIn = aResult.expiresOn.time,
                        token = aResult.accessToken,
                )
                success(JSONUtil.wrap(user))
            }
            Log.d(TAG, String.format("Access token: %s", accessToken))
        }

        override fun onError(exception: MsalException?) {
            when (exception) {
                is MsalUiRequiredException -> {
                    Log.d(TAG, "Interactive login required")
                    if (attemptInteractiveSignIn) {
                        doInteractiveSignIn()
                    }
                }
                is MsalClientException -> {
                    if (exception.getErrorCode() === "no_current_account" ||
                            exception.getErrorCode() === "no_account_found") {
                        Log.d("AUTH", "No current account, interactive login required")
                        if (attemptInteractiveSignIn) {
                            doInteractiveSignIn()
                        }
                    } else {
                        // Exception inside MSAL, more info inside MsalError.java
                        Log.e(TAG, "Client error authenticating", exception)
                    }
                }
                is MsalServiceException -> {
                    // Exception when communicating with the auth server, likely config issue
                    Log.e(TAG, "Service error authenticating", exception)
                }
            }
        }

        override fun onCancel() {
            Log.d(TAG, "Authentication canceled")
        }
    }

    private fun signOut() {
        authHelper?.signOut()
        isSignedIn = false
    }
}