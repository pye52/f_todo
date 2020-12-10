import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
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
&scope=$_mscScope
&code_challenge_method=S256''';
const String _mscTokenUrl =
    "https://login.microsoftonline.com/$_grant/oauth2/v2.0/token";

class MscLoginPageState extends State<MscLoginPage> {
  WebViewController _controller;
  String _codeVerifier;
  String _codeChallenge;

  @override
  void initState() {
    super.initState();
    _codeVerifier = "";
    var random = new Random();
    // 生成PKCE用到的code_verifier
    for (var i = 0; i < 48; i++) {
      _codeVerifier += random.nextInt(10).toString();
    }
    _codeVerifier = "ThisIsntRandomButItNeedsToBe43CharactersLong";
    List<int> bytes = utf8.encode(_codeVerifier);
    var sha = sha256.convert(bytes).toString();
    var shaBytes = utf8.encode(sha.toString());
    Log.debug("sha: $sha, string: ${sha.toString()}");
    _codeChallenge = base64.encode(shaBytes);
    // var lastIndex = _codeChallenge.length - 1;
    // // 必须去掉编码后最后一个'='
    // if (_codeChallenge[lastIndex] == '=') {
    //   _codeChallenge = _codeChallenge.substring(0, lastIndex);
    // }
    Log.debug("code verifier: $_codeVerifier, code challenge: $_codeChallenge");
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
        initialUrl: "$_mscLoginUrl&code_challenge=$_codeChallenge",
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
          Log.debug("login code: $code, code verifier: $_codeVerifier");
          _controller.loadUrl("about:blank");
          // 请求access_token
          scheduleMicrotask(() => getAccessToken(code));
        },
      ),
    );
  }

  void getAccessToken(String code) async {
    var response = await MicrosoftService.dio().post(
      _mscTokenUrl,
      data: {
        "grant_type": "authorization_code",
        "client_id": _clientId,
        "scope": _mscScope,
        "code": code,
        "redirect_uri": _mscRedirectUri,
        "code_verifier": _codeVerifier,
      },
      options: Options(
        contentType: "application/x-www-form-urlencoded",
      ),
    );
    Log.debug("response: $response");
  }

  @override
  void dispose() {
    dismissDebugBtn();
    super.dispose();
  }
}
