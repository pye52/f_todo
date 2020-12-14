// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'msc_login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserToken _$UserTokenFromJson(Map<String, dynamic> json) {
  return UserToken()
    ..tokenType = json['token_type'] as String
    ..scope = json['scope'] as String
    ..expiresIn = json['expires_in'] as int
    ..extExpiresIn = json['ext_expires_in'] as int
    ..accessToken = json['access_token'] as String;
}

Map<String, dynamic> _$UserTokenToJson(UserToken instance) => <String, dynamic>{
      'token_type': instance.tokenType,
      'scope': instance.scope,
      'expires_in': instance.expiresIn,
      'ext_expires_in': instance.extExpiresIn,
      'access_token': instance.accessToken,
    };
