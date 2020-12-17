// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MscToken _$MscTokenFromJson(Map<String, dynamic> json) {
  return MscToken()
    ..tokenType = json['tokenType'] as String
    ..expiresIn = json['expires_in'] as int
    ..extExpiresIn = json['ext_expires_in'] as int
    ..accessToken = json['access_token'] as String
    ..refreshToken = json['refresh_token'] as String;
}

Map<String, dynamic> _$MscTokenToJson(MscToken instance) => <String, dynamic>{
      'tokenType': instance.tokenType,
      'expires_in': instance.expiresIn,
      'ext_expires_in': instance.extExpiresIn,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
    };
