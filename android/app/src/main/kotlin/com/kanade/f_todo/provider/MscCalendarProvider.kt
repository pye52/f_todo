package com.kanade.f_todo.provider

import android.app.Activity
import android.util.Log
import com.google.gson.Gson
import com.kanade.f_todo.entity.UserToken
import com.kanade.f_todo.utils.AuthenticationHelper
import com.kanade.f_todo.utils.IAuthenticationHelperCreatedListener
import com.microsoft.identity.client.AuthenticationCallback
import com.microsoft.identity.client.IAuthenticationResult
import com.microsoft.identity.client.ISingleAccountPublicClientApplication
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
                    methodResult = null
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

    override fun init() = Unit

    override fun login(result: MethodChannel.Result) {
        methodResult = result
        doSilentSignIn(true)
    }

    override fun refreshToken(result: MethodChannel.Result) {
        methodResult = result
        doSilentSignIn()
    }

    override fun logout(result: MethodChannel.Result) {
        methodResult = result
        signOut()
    }

    private fun doSilentSignIn(shouldAttemptInteractive: Boolean = false) {
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
            Log.d(TAG, "onSuccess, methodResult: $methodResult")
            if (aResult == null) {
                Log.d(TAG, "login or refresh failed, user is null")
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
                Log.d(TAG, String.format("user: %s", user))
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
                    return
                }
                is MsalClientException -> {
                    if (exception.getErrorCode() === "no_current_account" ||
                            exception.getErrorCode() === "no_account_found") {
                        Log.w(TAG, "No current account, interactive login required")
                        if (attemptInteractiveSignIn) {
                            doInteractiveSignIn()
                        }
                        // 由于首次login时仍然会抛出该异常(先抛异常再跳转到登录activity)
                        // 此时阻断后续置空methodResult的执行，否则会导致登录成功后无法回调flutter端
                        return
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
            methodResult?.error(exception?.errorCode, exception?.message, null)
            methodResult = null
        }

        override fun onCancel() {
            Log.e(TAG, "Authentication canceled")
            methodResult = null
        }
    }

    private fun signOut() {
        authHelper?.signOut(object : ISingleAccountPublicClientApplication.SignOutCallback {
            override fun onSignOut() {
                Log.d(TAG, "sign out success")
                methodResult?.success(true)
            }

            override fun onError(exception: MsalException) {
                Log.d(TAG, "sign out error: ${exception.errorCode}, message: ${exception.message}")
                methodResult?.error(exception.errorCode, exception.message, null)
                methodResult = null
            }
        })
        isSignedIn = false
    }
}