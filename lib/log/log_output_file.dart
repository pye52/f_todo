import 'dart:io';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LogFileOutput extends LogOutput {
  static const String _logDir = 'log';
  static const int _clearFileDay = 7;
  @override
  void init() async {
    super.init();
    await _clearFiles(_clearFileDay);
    await _createLogFile();
  }

  @override
  void output(OutputEvent event) async {
    final date = DateTime.now();
    final dateStr = date.toIso8601String();
    final level = event.level.toString();
    event.lines.forEach((e) async {
      await _writeLogToFile('[$dateStr] [$level]: $e');
    });
  }

  Future<String> get _appDir async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _logFile async {
    final dir = await _appDir;
    final date = _stringFromDate();
    return File('$dir/$_logDir/$date');
  }

  Future<File> _createLogFile() async {
    final logFile = await _logFile;
    final isExist = await logFile.exists();
    if (isExist) {
      return logFile;
    } else {
      try {
        final rs = await logFile.create(recursive: true);
        return rs;
      } on FileSystemException catch (e) {
        print('[Log] create logFile error: ${e.toString()}');
        return Future.error(e);
      }
    }
  }

  Future<File> _writeLogToFile(String log) async {
    final logFile = await _logFile;
    final isExist = await logFile.exists();
    if (!isExist) {
      return Future.error(FileSystemException);
    }
    try {
      final rs = logFile.writeAsString('\n$log', mode: FileMode.append);
      return rs;
    } on FileSystemException catch (e) {
      print('[Log] write to file error: ${e.toString()}');
      return Future.error(e);
    }
  }

  String _stringFromDate({DateTime date, String formate = 'yyyyMMDD'}) {
    final DateTime d = date ?? DateTime.now();
    final formatter = DateFormat(formate);
    return formatter.format(d);
  }

  static Future<void> _clearFiles(int outday) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileDir = Directory('${dir.path}/$_logDir');
    final isExist = await fileDir.exists();
    if (!isExist) {
      return;
    }

    final list = await fileDir.list().toList();
    list.forEach((e) async {
      final name = basenameWithoutExtension(e.path);
      final now = DateTime.now();
      try {
        final fileDate = DateTime.parse(name);
        final duration = now.difference(fileDate);
        if (duration.inDays >= outday) {
          await e.delete();
        }
      } catch (e) {
        print('[LogFileOutput] _clearFiles parse file name to date error: $e');
      }
    });
  }
}
