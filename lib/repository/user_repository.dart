import 'package:f_todo/model/model.dart';

class UserDataSource {
  Future<User> queryMscUser() => User()
      .select(getIsDeleted: false)
      .userType
      .equals(USER_TYPE_MICROSOFT)
      .toSingle();
}
