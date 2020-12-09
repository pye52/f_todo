import 'package:flutter/services.dart';

class CalendarPlugin {
  static const MethodChannel _channel = const MethodChannel('calendar_plugin');
  static Future<String> test() async {
    var result = await _channel.invokeMethod('test', null);
    return result;
  }
}
