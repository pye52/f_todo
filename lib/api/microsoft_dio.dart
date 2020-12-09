import 'package:dio/dio.dart';
import 'package:dio_log/dio_log.dart';
import 'package:f_todo/todo.dart';

class MicrosoftService {
  static final _instance = MicrosoftService._();
  Dio _dio;
  factory MicrosoftService.getInstance() => _instance;

  MicrosoftService._() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: 50000,
        receiveTimeout: 50000,
      ),
    );

    /// 在debug或profile模式时，添加dio的日志输出拦截器
    if (!release) {
      _dio.interceptors.add(DioLogInterceptor());
    }
  }
  static Dio dio() => _instance._dio;
}
