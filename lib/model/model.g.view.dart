// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// SqfEntityFormGenerator
// **************************************************************************

part of 'model.dart';

class TodoAdd extends StatefulWidget {
  TodoAdd(this._todos);
  final dynamic _todos;
  @override
  State<StatefulWidget> createState() => TodoAddState(_todos as Todo);
}

class TodoAddState extends State {
  TodoAddState(this.todos);
  Todo todos;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController txtUserId = TextEditingController();
  final TextEditingController txtTitle = TextEditingController();
  final TextEditingController txtContent = TextEditingController();
  final TextEditingController txtRemind = TextEditingController();
  final TextEditingController txtCreatedTime = TextEditingController();

  final TextEditingController txtCompletedTime = TextEditingController();

  @override
  void initState() {
    txtUserId.text = todos.userId == null ? '' : todos.userId.toString();
    txtTitle.text = todos.title == null ? '' : todos.title;
    txtContent.text = todos.content == null ? '' : todos.content;
    txtRemind.text = todos.remind == null ? '' : todos.remind.toString();
    txtCreatedTime.text =
        todos.createdTime == null ? '' : todos.createdTime.toString();

    txtCompletedTime.text =
        todos.completedTime == null ? '' : todos.completedTime.toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            (todos.id == null) ? Text('Add a new todos') : Text('Edit todos'),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    buildRowUserId(),
                    buildRowTitle(),
                    buildRowContent(),
                    buildRowRemind(),
                    buildRowCreatedTime(),
                    buildRowCompleted(),
                    buildRowCompletedTime(),
                    FlatButton(
                      child: saveButton(),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          // If the form is valid, display a Snackbar.
                          save();
                          /* Scaffold.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 2),
                              content: Text('Processing Data')));
                           */
                        }
                      },
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Widget buildRowUserId() {
    return TextFormField(
      validator: (value) {
        if (value.isNotEmpty && int.tryParse(value) == null) {
          return 'Please Enter valid number';
        }

        return null;
      },
      controller: txtUserId,
      decoration: InputDecoration(labelText: 'UserId'),
    );
  }

  Widget buildRowTitle() {
    return TextFormField(
      controller: txtTitle,
      decoration: InputDecoration(labelText: 'Title'),
    );
  }

  Widget buildRowContent() {
    return TextFormField(
      controller: txtContent,
      decoration: InputDecoration(labelText: 'Content'),
    );
  }

  Widget buildRowRemind() {
    return TextFormField(
      validator: (value) {
        if (value.isNotEmpty && int.tryParse(value) == null) {
          return 'Please Enter valid number';
        }

        return null;
      },
      controller: txtRemind,
      decoration: InputDecoration(labelText: 'Remind'),
    );
  }

  Widget buildRowCreatedTime() {
    return TextFormField(
      validator: (value) {
        if (value.isNotEmpty && int.tryParse(value) == null) {
          return 'Please Enter valid number';
        }

        return null;
      },
      controller: txtCreatedTime,
      decoration: InputDecoration(labelText: 'CreatedTime'),
    );
  }

  Widget buildRowCompleted() {
    return Row(
      children: <Widget>[
        Text('Completed?'),
        Checkbox(
          value: todos.completed ?? false,
          onChanged: (bool value) {
            setState(() {
              todos.completed = value;
            });
          },
        ),
      ],
    );
  }

  Widget buildRowCompletedTime() {
    return TextFormField(
      validator: (value) {
        if (value.isNotEmpty && int.tryParse(value) == null) {
          return 'Please Enter valid number';
        }

        return null;
      },
      controller: txtCompletedTime,
      decoration: InputDecoration(labelText: 'CompletedTime'),
    );
  }

  Container saveButton() {
    return Container(
      padding: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
          color: Color.fromRGBO(95, 66, 119, 1.0),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5.0)),
      child: Text(
        'Save',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  void save() async {
    todos
      ..userId = int.tryParse(txtUserId.text)
      ..title = txtTitle.text
      ..content = txtContent.text
      ..remind = int.tryParse(txtRemind.text)
      ..createdTime = int.tryParse(txtCreatedTime.text)
      ..completedTime = int.tryParse(txtCompletedTime.text);
    await todos.save();
    if (todos.saveResult.success) {
      Navigator.pop(context, true);
    } else {
      UITools(context).alertDialog(todos.saveResult.toString(),
          title: 'save Todo Failed!', callBack: () {});
    }
  }
}

class UserAdd extends StatefulWidget {
  UserAdd(this._user);
  final dynamic _user;
  @override
  State<StatefulWidget> createState() => UserAddState(_user as User);
}

class UserAddState extends State {
  UserAddState(this.user);
  User user;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController txtUserType = TextEditingController();
  final TextEditingController txtLoginTime = TextEditingController();
  final TextEditingController txtTimeForLoginTime = TextEditingController();
  final TextEditingController txtExpiresIn = TextEditingController();
  final TextEditingController txtAccessToken = TextEditingController();
  final TextEditingController txtRefreshToken = TextEditingController();

  @override
  void initState() {
    txtUserType.text = user.userType == null ? '' : user.userType.toString();
    txtLoginTime.text =
        user.loginTime == null ? '' : UITools.convertDate(user.loginTime);
    txtTimeForLoginTime.text =
        user.loginTime == null ? '' : UITools.convertTime(user.loginTime);

    txtExpiresIn.text = user.expiresIn == null ? '' : user.expiresIn.toString();
    txtAccessToken.text = user.accessToken == null ? '' : user.accessToken;
    txtRefreshToken.text = user.refreshToken == null ? '' : user.refreshToken;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (user.id == null) ? Text('Add a new user') : Text('Edit user'),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    buildRowUserType(),
                    buildRowLoginTime(),
                    buildRowExpiresIn(),
                    buildRowAccessToken(),
                    buildRowRefreshToken(),
                    FlatButton(
                      child: saveButton(),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          // If the form is valid, display a Snackbar.
                          save();
                          /* Scaffold.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 2),
                              content: Text('Processing Data')));
                           */
                        }
                      },
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Widget buildRowUserType() {
    return TextFormField(
      validator: (value) {
        if (value.isNotEmpty && int.tryParse(value) == null) {
          return 'Please Enter valid number';
        }

        return null;
      },
      controller: txtUserType,
      decoration: InputDecoration(labelText: 'UserType'),
    );
  }

  Widget buildRowLoginTime() {
    return Row(children: <Widget>[
      Expanded(
        flex: 1,
        child: TextFormField(
          onTap: () => DatePicker.showDatePicker(context,
              showTitleActions: true,
              theme: UITools.mainDatePickerTheme,
              minTime: DateTime.parse('1900-01-01'),
              onConfirm: (sqfSelectedDate) {
            txtLoginTime.text = UITools.convertDate(sqfSelectedDate);
            txtTimeForLoginTime.text = UITools.convertTime(sqfSelectedDate);
            setState(() {
              final d = DateTime.tryParse(txtLoginTime.text) ??
                  user.loginTime ??
                  DateTime.now();
              user.loginTime = DateTime(sqfSelectedDate.year,
                      sqfSelectedDate.month, sqfSelectedDate.day)
                  .add(Duration(
                      hours: d.hour, minutes: d.minute, seconds: d.second));
            });
          },
              currentTime: DateTime.tryParse(txtLoginTime.text) ??
                  user.loginTime ??
                  DateTime.now(),
              locale: UITools.mainDatePickerLocaleType),
          controller: txtLoginTime,
          decoration: InputDecoration(labelText: 'LoginTime'),
        ),
      ),
      Expanded(
          flex: 1,
          child: TextFormField(
            onTap: () => DatePicker.showTimePicker(context,
                showTitleActions: true, theme: UITools.mainDatePickerTheme,
                onConfirm: (sqfSelectedDate) {
              txtTimeForLoginTime.text = UITools.convertTime(sqfSelectedDate);
              setState(() {
                final d = DateTime.tryParse(txtLoginTime.text) ??
                    user.loginTime ??
                    DateTime.now();
                user.loginTime = DateTime(d.year, d.month, d.day).add(Duration(
                    hours: sqfSelectedDate.hour,
                    minutes: sqfSelectedDate.minute,
                    seconds: sqfSelectedDate.second));
                txtLoginTime.text = UITools.convertDate(user.loginTime);
              });
            },
                currentTime: DateTime.tryParse(
                        '${UITools.convertDate(DateTime.now())} ${txtTimeForLoginTime.text}') ??
                    user.loginTime ??
                    DateTime.now(),
                locale: UITools.mainDatePickerLocaleType),
            controller: txtTimeForLoginTime,
            decoration: InputDecoration(labelText: ''),
          ))
    ]);
  }

  Widget buildRowExpiresIn() {
    return TextFormField(
      validator: (value) {
        if (value.isNotEmpty && int.tryParse(value) == null) {
          return 'Please Enter valid number';
        }

        return null;
      },
      controller: txtExpiresIn,
      decoration: InputDecoration(labelText: 'ExpiresIn'),
    );
  }

  Widget buildRowAccessToken() {
    return TextFormField(
      controller: txtAccessToken,
      decoration: InputDecoration(labelText: 'AccessToken'),
    );
  }

  Widget buildRowRefreshToken() {
    return TextFormField(
      controller: txtRefreshToken,
      decoration: InputDecoration(labelText: 'RefreshToken'),
    );
  }

  Container saveButton() {
    return Container(
      padding: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
          color: Color.fromRGBO(95, 66, 119, 1.0),
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5.0)),
      child: Text(
        'Save',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  void save() async {
    var _loginTime = DateTime.tryParse(txtLoginTime.text);
    final _loginTimeTime = DateTime.tryParse(txtTimeForLoginTime.text);
    if (_loginTime != null && _loginTimeTime != null) {
      _loginTime = _loginTime.add(Duration(
          hours: _loginTimeTime.hour,
          minutes: _loginTimeTime.minute,
          seconds: _loginTimeTime.second));
    }

    user
      ..userType = int.tryParse(txtUserType.text)
      ..loginTime = _loginTime
      ..expiresIn = int.tryParse(txtExpiresIn.text)
      ..accessToken = txtAccessToken.text
      ..refreshToken = txtRefreshToken.text;
    await user.save();
    if (user.saveResult.success) {
      Navigator.pop(context, true);
    } else {
      UITools(context).alertDialog(user.saveResult.toString(),
          title: 'save User Failed!', callBack: () {});
    }
  }
}
