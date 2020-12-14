import 'package:json_annotation/json_annotation.dart';

part 'msc_login.g.dart';

@JsonSerializable()
class UserToken {
  @JsonKey(name: "token_type")
  String tokenType;
  String scope;
  @JsonKey(name: "expires_in")
  int expiresIn;
  @JsonKey(name: "ext_expires_in")
  int extExpiresIn;
  @JsonKey(name: "access_token")
  String accessToken;

  UserToken();

  factory UserToken.fromJson(Map<String, dynamic> json) =>
      _$UserTokenFromJson(json);
  Map<String, dynamic> toJson() => _$UserTokenToJson(this);
}
