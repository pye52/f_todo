package com.kanade.f_todo.provider

import android.app.Activity
import android.util.Log
import com.google.gson.Gson
import com.kanade.f_todo.entity.UserToken
import com.kanade.f_todo.utils.AuthenticationHelper
import com.kanade.f_todo.utils.IAuthenticationHelperCreatedListener
import com.microsoft.identity.client.AuthenticationCallback
import com.microsoft.identity.client.IAuthenticationResult
import com.microsoft.identity.client.exception.MsalClientException
import com.microsoft.identity.client.exception.MsalException
import com.microsoft.identity.client.exception.MsalServiceException
import com.microsoft.identity.client.exception.MsalUiRequiredException
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class MscCalendarProvider : CalendarProvider {
    companion object {
        private const val TAG = "MscCalendarProvider"
    }

    private var authHelper: AuthenticationHelper? = null
    private var activity: Activity? = null
    private var methodResult: MethodChannel.Result? = null
    private var isSignedIn = false
    private var attemptInteractiveSignIn = false

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        AuthenticationHelper.getInstance(binding.activity.application, object : IAuthenticationHelperCreatedListener {
            override fun onCreated(helper: AuthenticationHelper) {
                authHelper = helper
                if (!isSignedIn) {
                    doSilentSignIn()
                }
                Log.d(TAG, "authHelper init")
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

    override fun login(result: MethodChannel.Result) {
        methodResult = result
        doSilentSignIn(true)
    }

    override fun refreshToken() {
        doSilentSignIn()
    }

    override fun logout() = signOut()

    private fun doSilentSignIn(shouldAttemptInteractive: Boolean = false) {
        if (!shouldAttemptInteractive) {
            methodResult = null
        }
        attemptInteractiveSignIn = shouldAttemptInteractive
        authHelper?.acquireTokenSilently(getAuthCallback())
        Log.d(TAG, "doSilentSignIn: $shouldAttemptInteractive")
    }

    private fun doInteractiveSignIn() {
        activity?.let {
            authHelper?.acquireTokenInteractively(it, getAuthCallback())
        }
    }
    
    private fun getAuthCallback(): AuthenticationCallback = object : AuthenticationCallback {
        override fun onSuccess(aResult: IAuthenticationResult?) {
            if (aResult == null) {
                Log.d(TAG, "login failed, user is null")
                return
            }
            methodResult?.run {
                val user = UserToken(
                        account = aResult.account.id,
                        loginTime = System.currentTimeMillis(),
                        expiresIn = aResult.expiresOn.time,
                        accessToken = aResult.accessToken,
                )
                val gson = Gson()
                success(gson.toJson(user))
                Log.d(TAG, String.format("login user: %s", user))
            }
            methodResult = null
        }

        override fun onError(exception: MsalException?) {
            when (exception) {
                is MsalUiRequiredException -> {
                    Log.w(TAG, "Interactive login required")
                    if (attemptInteractiveSignIn) {
                        doInteractiveSignIn()
                    }
                }
                is MsalClientException -> {
                    if (exception.getErrorCode() === "no_current_account" ||
                            exception.getErrorCode() === "no_account_found") {
                        Log.w("AUTH", "No current account, interactive login required")
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
                else -> Log.e(TAG, "other error: $exception")
            }
        }

        override fun onCancel() {
            Log.e(TAG, "Authentication canceled")
        }
    }

    private fun signOut() {
        authHelper?.signOut()
        isSignedIn = false
    }
}