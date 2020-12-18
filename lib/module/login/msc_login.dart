import 'dart:async';

import 'package:dio_log/overlay_draggable_button.dart';
import 'package:f_todo/api/microsoft_dio.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 当前通过MSAL库进行登录
class MscLoginPage extends StatefulWidget {
  @override
  State createState() => MscLoginPageState();
}

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
        initialUrl: "$mscLoginUrl",
        javascriptMode: JavascriptMode.unrestricted,
        onPageStarted: (url) {
          if (!url.startsWith(mscRedirectUri)) {
            return;
          }
          _controller.loadUrl("about:blank");
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
            Navigator.of(context).pop(null);
            return;
          }
          var code = successMatcher.group(1);
          Log.debug("login code: $code");
          // 请求access_token
          scheduleMicrotask(() => getAccessToken(context, code));
        },
      ),
    );
  }

  void getAccessToken(BuildContext context, String code) async {
    var response = await MicrosoftService.getAccessToken(code);
    var user = response.data.convertToUser();
    Log.debug("login success: ${user.toJson()}");
    Navigator.of(context).pop(user);
  }

  @override
  void dispose() {
    dismissDebugBtn();
    super.dispose();
  }
}
