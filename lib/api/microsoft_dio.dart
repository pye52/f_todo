import 'package:dio/dio.dart';
import 'package:dio_log/dio_log.dart';
import 'package:f_todo/model/model.dart';
import 'package:f_todo/model/user_token.dart';
import 'package:f_todo/todo.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

const String _grant = "common";
const String _clientId = "181ad653-2fdd-41e3-9463-3e3fd8569ada";
const String mscRedirectUri = "https://www.kanade.ftodo.com";
const String _mscScope = "offline_access Calendars.ReadWrite";
const String mscLoginUrl =
    '''https://login.microsoftonline.com/$_grant/oauth2/v2.0/authorize?
 client_id=$_clientId
 &response_type=code
 &redirect_uri=$mscRedirectUri
 &response_mode=query
 &scope=$_mscScope''';
const String _mscTokenUrl =
    "https://login.microsoftonline.com/$_grant/oauth2/v2.0/token";

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
  static Future<Response<Map<String, dynamic>>> getAccessToken(String code) =>
      _instance._dio.post(
        _mscTokenUrl,
        data: {
          "grant_type": "authorization_code",
          "client_id": _clientId,
          "scope": _mscScope,
          "code": code,
          "redirect_uri": mscRedirectUri,
        },
        options: Options(
          contentType: "application/x-www-form-urlencoded",
        ),
      );
  static Future<Response<Map<String, dynamic>>> refreshToken(
          String refreshToken) =>
      _instance._dio.post(_mscTokenUrl, data: {
        "grant_type": "refresh_token",
        "client_id": _clientId,
        "scope": _mscScope,
        "refresh_token": refreshToken,
      });
  static Future<BoolResult> signOut(User user) => user.delete();
}

extension Constructor on Map<String, dynamic> {
  User convertToUser() {
    var token = MscToken.fromJson(this);
    var currentTime = DateTime.now();
    var user = User(
      userType: USER_TYPE_MICROSOFT,
      expiresIn: currentTime.millisecondsSinceEpoch + (token.expiresIn * 1000),
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      loginTime: currentTime,
    );
    return user;
  }
}
