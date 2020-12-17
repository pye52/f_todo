import 'dart:convert';

import 'package:f_todo/model/model.dart';
import 'package:f_todo/model/user_token.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/services.dart';

class CalendarPlugin {
  static const MethodChannel _channel = const MethodChannel('calendar_plugin');
  static void mscInit() {
    _channel.invokeMethod('init', null);
  }

  static Future<User> mscLogin() async {
    try {
      var result = await _channel.invokeMethod('login', null);
      var jsonMap = json.decode(result);
      var userToken = MscToken.fromJson(jsonMap);
      var mscUser = User(
        expiresIn: userToken.expiresIn,
        token: userToken.accessToken,
        loginTime: DateTime.now(),
      );
      Log.debug("msc login result: $result");
      return mscUser;
    } catch (e) {
      Log.debug("exception: $e");
    }
    return null;
  }

  static Future<User> mscRefreshToken() async {
    try {
      var result = await _channel.invokeMethod('refreshToken', null);
      var jsonMap = json.decode(result);
      var userToken = MscToken.fromJson(jsonMap);
      var mscUser = User(
        expiresIn: userToken.expiresIn,
        token: userToken.accessToken,
        loginTime: DateTime.now(),
      );
      Log.debug("msc refresh result: $result");
      return mscUser;
    } catch (e) {
      Log.debug("exception: $e");
    }
    return null;
  }

  static Future<bool> mscSignOut() async {
    try {
      return await _channel.invokeMethod('logout', null);
    } catch (e) {
      Log.debug("exception: $e");
    }
    return false;
  }
}
