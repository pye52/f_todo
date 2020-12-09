import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio_log/dio_log.dart';
import 'package:f_todo/api/microsoft_dio.dart';
import 'package:f_todo/log/global_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MscLoginPage extends StatefulWidget {
  @override
  State createState() => MscLoginPageState();
}

const String client_id = "181ad653-2fdd-41e3-9463-3e3fd8569ada";
const String msc_redirect_uri = "https://www.kanade.ftodo.com";
const String msc_scope = "Calendars.ReadWrite";
const String msc_login_url =
    '''https://login.microsoftonline.com/common/oauth2/v2.0/authorize?
client_id=$client_id
&response_type=code
&redirect_uri=$msc_redirect_uri
&response_mode=query
&scope=$msc_scope''';
const String msc_token_url =
    "https://login.microsoftonline.com/commo/oauth2/v2.0/token";

class MscLoginPageState extends State<MscLoginPage> {
  List<int> _codeVerifier = List.empty(growable: true);
  WebViewController _controller;
  String _codeChallenge;

  @override
  void initState() {
    super.initState();
    var random = new Random();
    // 生成PKCE用到的code_verifier
    for (var i = 0; i < 48; i++) {
      _codeVerifier.add(random.nextInt(10));
    }
    var sha = sha256.convert(_codeVerifier);
    _codeChallenge = base64.encode(sha.bytes);
    var lastIndex = _codeChallenge.length - 1;
    // 必须去掉编码后最后一个'='
    if (_codeChallenge[lastIndex] == '=') {
      _codeChallenge = _codeChallenge.substring(0, lastIndex);
    }
  }

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
        initialUrl:
            "$msc_login_url&code_challenge=$_codeChallenge&code_challenge_method=S256",
        javascriptMode: JavascriptMode.unrestricted,
        onPageStarted: (url) {
          if (!url.startsWith(msc_redirect_uri)) {
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
          scheduleMicrotask(getAccessToken);
        },
      ),
    );
  }

  void getAccessToken() async {
    var response = await MicrosoftService.dio().post(
      msc_token_url,
      data: {
        "client_id": client_id,
        "scope": msc_scope,
        "redirect_uri": msc_redirect_uri,
        "grant_type": "authorization_code",
        "code_verifier": _codeVerifier,
      },
    );
    Log.debug("response: $response");
  }

  @override
  void dispose() {
    dismissDebugBtn();
    super.dispose();
  }
}
