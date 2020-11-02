import 'package:f_todo/todo.dart';
import 'package:logger/logger.dart';

import 'log_output_console.dart';
import 'log_output_file.dart';

class Log {
  Logger _logger;

  Log._() {
    /// 总是不输出颜色（IDE和写入文件都不需要颜色）
    _logger = Logger(
      printer: release ? WriteFileLogPrinter() : PrettyPrinter(colors: false),
      filter: CKLogFilter(),
      output: release ? LogFileOutput() : LogConsoleOutput(),
    );
  }

  static void log(Level level, dynamic message) =>
      _instance._logger.log(level, message);
  static void debug(String message) => _instance._logger.d(message);
  static void info(String message) => _instance._logger.i(message);
  static void warning(String message) => _instance._logger.w(message);
  static void error(String message) => _instance._logger.e(message);

  static final Log _instance = Log._();
  factory Log.getInstance() => _instance;
}

class CKLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return !(release && event.level == Level.debug);
  }
}

class WriteFileLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    if (event.message is List<String>) {
      return event.message;
    }
    return [event.message.toString()];
  }
}
