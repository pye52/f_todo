import 'package:logger/logger.dart';

import 'log_console.dart';

class LogConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    event.lines.forEach(print);
    LogConsole.add(event);
  }
}
