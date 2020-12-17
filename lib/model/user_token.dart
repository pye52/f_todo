import 'package:json_annotation/json_annotation.dart';

part 'user_token.g.dart';

@JsonSerializable()
class MscToken {
  String tokenType;
  @JsonKey(name: "expires_in")
  int expiresIn;
  @JsonKey(name: "ext_expires_in")
  int extExpiresIn;
  @JsonKey(name: "access_token")
  String accessToken;
  @JsonKey(name: "refresh_token")
  String refreshToken;
  MscToken();

  factory MscToken.fromJson(Map<String, dynamic> json) =>
      _$MscTokenFromJson(json);
  Map<String, dynamic> toJson() => _$MscTokenToJson(this);
}
