import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_log/dio_log.dart';
import 'package:f_todo/api/microsoft_dio.dart';
import 'package:f_todo/log/global_logger.dart';
import 'package:f_todo/model/model.dart';
import 'package:f_todo/model/msc_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MscLoginPage extends StatefulWidget {
  @override
  State createState() => MscLoginPageState();
}

const String _grant = "common";
const String _clientId = "181ad653-2fdd-41e3-9463-3e3fd8569ada";
const String _mscRedirectUri = "https://www.kanade.ftodo.com";
const String _mscScope = "Calendars.ReadWrite";
const String _mscLoginUrl =
    '''https://login.microsoftonline.com/$_grant/oauth2/v2.0/authorize?
client_id=$_clientId
&response_type=code
&redirect_uri=$_mscRedirectUri
&response_mode=query
&scope=$_mscScope''';
const String _mscTokenUrl =
    "https://login.microsoftonline.com/$_grant/oauth2/v2.0/token";

class MscLoginPageState extends State<MscLoginPage> {
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    showDebugBtn(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("登录微软帐号"),
      ),
      body: WebView(
        onWebViewCreated: (controller) {
          _controller = controller;
        },
        initialUrl: "$_mscLoginUrl",
        javascriptMode: JavascriptMode.unrestricted,
        onPageStarted: (url) {
          if (!url.startsWith(_mscRedirectUri)) {
            return;
          }
          // 登录成功，截取code，示例返回：https://www.kanade.ftodo.com/#code=M.R3_BAY.b91e965b-8cfb-5ad3-9ca2-b05868e20c72
          var successReg = RegExp(r"code=(.+)");
          var successMatcher = successReg.firstMatch(url);
          if (successMatcher == null) {
            var errorReg = RegExp(r"error=(.+)&");
            var errorDescReg = RegExp(r"error_description=(.+)");
            var errorMatcher = errorReg.firstMatch(url);
            var errorDescMatcher = errorDescReg.firstMatch(url);
            if (errorMatcher != null && errorDescMatcher != null) {
              var error = errorMatcher.group(1);
              var errorDesc = errorDescMatcher.group(1);
              Log.debug("error: $error, desc: $errorDesc");
            }
            return;
          }
          var code = successMatcher.group(1);
          Log.debug("login code: $code");
          _controller.loadUrl("about:blank");
          // 请求access_token
          scheduleMicrotask(() => getAccessToken(context, code));
        },
      ),
    );
  }

  void getAccessToken(BuildContext context, String code) async {
    var response = await MicrosoftService.dio().post(
      _mscTokenUrl,
      data: {
        "grant_type": "authorization_code",
        "client_id": _clientId,
        "scope": _mscScope,
        "code": code,
        "redirect_uri": _mscRedirectUri,
      },
      options: Options(
        contentType: "application/x-www-form-urlencoded",
      ),
    );
    var tokenResponse = UserToken.fromJson(response.data);
    var mscUser = User(
      userType: 1,
      expiresIn: tokenResponse.expiresIn,
      extExpiresIn: tokenResponse.extExpiresIn,
      token: tokenResponse.accessToken,
      loginTime: DateTime.now(),
    );
    mscUser.save();
    Log.debug("login success: ${mscUser.toJson()}");
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    dismissDebugBtn();
    super.dispose();
  }
}
