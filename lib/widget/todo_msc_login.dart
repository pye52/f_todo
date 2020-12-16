import 'package:f_todo/model/model.dart';
import 'package:f_todo/plugin/calendar_plugin.dart';
import 'package:f_todo/repository/user_repository.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MscLoginButton extends StatefulWidget {
  @override
  _MscLoginButtonState createState() => _MscLoginButtonState();
}

class _MscLoginButtonState extends State<MscLoginButton> {
  final UserDataSource _userSource = UserDataSource();
  bool _loginState = false;
  Future<User> _loginFun;

  @override
  void initState() {
    super.initState();
    _loginFun = Future(_loginActual);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _loginFun,
      builder: (context, snapshot) {
        return _buildMscLoginButton(context, snapshot.data);
      },
    );
  }

  Future<User> _loginActual() async {
    var mscUser = await _userSource.queryMscUser();
    if (mscUser == null) {
      return null;
    }
    // 检查token是否超时
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (mscUser.expiresIn > currentTime) {
      _loginState = true;
      return mscUser;
    }
    return null;
  }

  TextButton _buildMscLoginButton(BuildContext context, User user) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(16),
        primary: Colors.black,
      ),
      onPressed: _loginState
          ? null
          : () async {
              EasyLoading.show(
                status: '请稍候...',
                maskType: EasyLoadingMaskType.black,
              );
              var user = await CalendarPlugin.mscLogin();
              var saveResult = await _userSource.saveMscUser(user);
              Log.debug("save login result: $saveResult");
              EasyLoading.dismiss();
              setState(() {
                _loginState = user != null;
              });
            },
      child: Row(
        children: [
          Icon(Icons.mail),
          const Padding(padding: const EdgeInsets.only(left: 8)),
          Expanded(
            child: Text(
              _loginState ? "已登录微软账号" : "登录微软帐号",
              style: TextStyle(fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
