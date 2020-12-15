import 'package:f_todo/model/model.dart';

class UserDataSource {
  Future<User> queryMscUser() => User()
      .select(getIsDeleted: false)
      .userType
      .equals(USER_TYPE_MICROSOFT)
      .toSingle();

  Future<int> saveMscUser(User user) {
    user.userType = USER_TYPE_MICROSOFT;
    return user.save();
  }
}
