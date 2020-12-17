import 'package:f_todo/model/model.dart';
import 'package:f_todo/module/login/msc_login.dart';
import 'package:f_todo/plugin/calendar_plugin.dart';
import 'package:f_todo/repository/user_repository.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MscLoginLayout extends StatefulWidget {
  @override
  _MscLoginLayoutState createState() => _MscLoginLayoutState();
}

class _MscLoginLayoutState extends State<MscLoginLayout> {
  final UserDataSource _userSource = UserDataSource();
  bool _login = false;
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
      _login = true;
      return mscUser;
    }
    var refreshUser = await CalendarPlugin.mscRefreshToken();
    if (refreshUser != null) {
      _userSource.refreshMscUser(refreshUser, mscUser);
      _login = true;
      return refreshUser;
    }
    return null;
  }

  TextButton _buildMscLoginButton(BuildContext context, User user) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(16),
        primary: Colors.black,
      ),
      onPressed: _login
          ? null
          : () async {
              var user = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MscLoginPage()),
              );
              EasyLoading.show(
                status: '请稍候...',
                maskType: EasyLoadingMaskType.black,
              );
              var saveResult = await _userSource.saveMscUser(user);
              Log.debug("save login result: $saveResult");
              EasyLoading.dismiss();
              setState(() {
                _login = user != null;
              });
            },
      child: Row(
        children: [
          Icon(Icons.mail),
          const Padding(padding: const EdgeInsets.only(left: 8)),
          Expanded(
            child: Builder(builder: (context) {
              if (_login) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        "已登录微软账号",
                        style: TextStyle(fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        var signOut = await CalendarPlugin.mscSignOut();
                        if (signOut) {
                          setState(() {
                            _login = false;
                          });
                        }
                      },
                      child: Text("注销"),
                    ),
                  ],
                );
              } else {
                return Text(
                  "登录微软帐号",
                  style: TextStyle(fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
