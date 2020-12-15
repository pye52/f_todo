// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MscToken _$MscTokenFromJson(Map<String, dynamic> json) {
  return MscToken()
    ..tokenType = json['tokenType'] as String
    ..expiresIn = json['expiresIn'] as int
    ..accessToken = json['accessToken'] as String;
}

Map<String, dynamic> _$MscTokenToJson(MscToken instance) => <String, dynamic>{
      'tokenType': instance.tokenType,
      'expiresIn': instance.expiresIn,
      'accessToken': instance.accessToken,
    };
