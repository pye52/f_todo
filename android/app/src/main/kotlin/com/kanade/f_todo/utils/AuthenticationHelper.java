// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// <AuthHelperSnippet>
package com.kanade.f_todo.utils;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.kanade.f_todo.R;
import com.microsoft.identity.client.AuthenticationCallback;
import com.microsoft.identity.client.IPublicClientApplication;
import com.microsoft.identity.client.ISingleAccountPublicClientApplication;
import com.microsoft.identity.client.PublicClientApplication;
import com.microsoft.identity.client.exception.MsalException;

public class AuthenticationHelper {
    private static AuthenticationHelper INSTANCE = null;
    private ISingleAccountPublicClientApplication mPCA = null;
    private final String[] mScopes = { "User.Read", "Calendars.Read" };

    private AuthenticationHelper(Context ctx, final IAuthenticationHelperCreatedListener listener) {
        PublicClientApplication.createSingleAccountPublicClientApplication(ctx, R.raw.msal_config,
                new IPublicClientApplication.ISingleAccountApplicationCreatedListener() {
                    @Override
                    public void onCreated(ISingleAccountPublicClientApplication application) {
                        mPCA = application;
                        listener.onCreated(INSTANCE);
                    }

                    @Override
                    public void onError(MsalException exception) {
                        Log.e("AUTHHELPER", "Error creating MSAL application", exception);
                        listener.onError(exception);
                    }
                });
    }

    public static synchronized void getInstance(Context ctx, IAuthenticationHelperCreatedListener listener) {
        if (INSTANCE == null) {
            INSTANCE = new AuthenticationHelper(ctx, listener);
        } else {
            listener.onCreated(INSTANCE);
        }
    }

    public static synchronized AuthenticationHelper getInstance() {
        if (INSTANCE == null) {
            throw new IllegalStateException("AuthenticationHelper has not been initialized from MainActivity");
        }
        return INSTANCE;
    }

    public void acquireTokenInteractively(Activity activity, AuthenticationCallback callback) {
        mPCA.signIn(activity, null, mScopes, callback);
    }

    public void acquireTokenSilently(AuthenticationCallback callback) {
        String authority = mPCA.getConfiguration().getDefaultAuthority().getAuthorityURL().toString();
        mPCA.acquireTokenSilentAsync(mScopes, authority, callback);
    }

    public void signOut(ISingleAccountPublicClientApplication.SignOutCallback signOutCallback) {
        mPCA.signOut(signOutCallback);
    }
}
