import 'package:f_todo/model/model.dart';
import 'package:f_todo/plugin/calendar_plugin.dart';
import 'package:f_todo/repository/user_repository.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MscLoginButton extends StatefulWidget {
  @override
  _MscLoginButtonState createState() => _MscLoginButtonState();
}

class _MscLoginButtonState extends State<MscLoginButton> {
  final UserDataSource _userSource = UserDataSource();
  Future<User> _mscLoginFun;

  @override
  void initState() {
    super.initState();
    _mscLoginFun = Future(_isMscLogin);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _mscLoginFun,
      builder: (context, snapshot) {
        return _buildMscLoginButton(context, snapshot.data);
      },
    );
  }

  Future<User> _isMscLogin() async {
    var mscUser = await _userSource.queryMscUser();
    if (mscUser == null) {
      return null;
    }
    // 检查token是否超时
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (mscUser.expiresIn > currentTime) {
      return mscUser;
    }
    return null;
  }

  TextButton _buildMscLoginButton(BuildContext context, User user) {
    bool isLogin = user != null;
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(16),
        primary: Colors.black,
      ),
      onPressed: isLogin
          ? null
          : () async {
              var user = await CalendarPlugin.mscLogin();
              var saveResult = await _userSource.saveMscUser(user);
              Log.debug("save result: $saveResult");
              setState(() {});
            },
      child: Row(
        children: [
          Icon(Icons.mail),
          const Padding(padding: const EdgeInsets.only(left: 8)),
          Expanded(
            child: Text(
              isLogin ? "已登录微软账号" : "登录微软帐号",
              style: TextStyle(fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
