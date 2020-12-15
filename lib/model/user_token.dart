import 'package:json_annotation/json_annotation.dart';

part 'user_token.g.dart';

@JsonSerializable()
class MscToken {
  String tokenType;
  int expiresIn;
  String accessToken;
  MscToken();

  factory MscToken.fromJson(Map<String, dynamic> json) =>
      _$MscTokenFromJson(json);
  Map<String, dynamic> toJson() => _$MscTokenToJson(this);
}
