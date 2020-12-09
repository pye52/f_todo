import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dio_log/dio_log.dart';
import 'package:f_todo/model/list_model.dart';
import 'package:f_todo/model/model.dart';
import 'package:f_todo/module/login/msc_login.dart';
import 'package:f_todo/repository/todo_repository.dart';
import 'package:f_todo/todo.dart';
import 'package:f_todo/widget/todo_add.dart';
import 'package:f_todo/widget/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class TodoList extends StatefulWidget {
  @override
  State createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  final TodoDataSource _dataSource = TodoDataSource();
  final StreamController<List<Todo>> _streamController = new StreamController();
  final AsyncMemoizer _initMemoizer = AsyncMemoizer();
  GlobalKey<AnimatedListState> _listKey;
  ListModel<Todo> _list;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _permissionCheck(BuildContext context) async {
    var status = await Permission.calendar.status;
    if (status.isPermanentlyDenied && Platform.isAndroid && mounted) {
      // 已被禁止询问
      var action = SnackBarAction(label: "打开", onPressed: openAppSettings);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("需要授予读取系统日历的权限"),
        action: action,
      ));
    }
    Log.debug(
        "当前日历权限\nisUndetermined: ${status.isUndetermined}\nisGranted: ${status.isGranted}\nisDenied: ${status.isDenied}\nisRestricted: ${status.isRestricted}\nisPermanentlyDenied: ${status.isPermanentlyDenied}");
    if (!status.isGranted) {
      var requestStatus = await Permission.calendar.request();
      if (!requestStatus.isGranted) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("当前无权限读取系统日历"),
        ));
      }
      Log.debug(
          "请求后日历权限\nisUndetermined: ${requestStatus.isUndetermined}\nisGranted: ${requestStatus.isGranted}\nisDenied: ${requestStatus.isDenied}\nisRestricted: ${requestStatus.isRestricted}\nisPermanentlyDenied: ${requestStatus.isPermanentlyDenied}");
    }
  }

  void _fetchData() {
    _dataSource.queryAllTodo().then((data) => _streamController.sink.add(data));
  }

  @override
  Widget build(BuildContext context) {
    _initMemoizer.runOnce(() => _permissionCheck(context));
    return Scaffold(
      appBar: AppBar(
        title: Text("待办事项"),
      ),
      backgroundColor: Color(0xFF708090),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
              ),
              child: Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CircleAvatar(
                    child: Text("User"),
                  ),
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16),
                primary: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MscLoginPage()),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.mail),
                  const Padding(padding: const EdgeInsets.only(left: 8)),
                  Expanded(
                    child: Text(
                      "登录微软帐号",
                      style: TextStyle(fontWeight: FontWeight.normal),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Todo>>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                "正在获取数据...",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            );
          }
          _listKey = GlobalKey<AnimatedListState>();
          _list = ListModel(
            listKey: _listKey,
            initialItems: snapshot.data,
            removedItemBuilder: (index, item, animation) {
              return Container();
            },
          );
          return RefreshIndicator(
            child: AnimatedList(
              key: _listKey,
              padding: const EdgeInsets.all(0),
              initialItemCount: _list.length,
              itemBuilder: (context, index, animation) => TodoItem(
                index: index,
                item: _list[index],
                animation: animation,
                onItemDismissed: _dismissItem,
              ),
            ),
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              _fetchData();
              return;
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          if (_list == null) {
            Scaffold.of(context).showSnackBar(
              SnackBar(content: Text("列表数据获取中...")),
            );
            return;
          }
          _showBottomSheet(context);
        },
      ),
    );
  }

  @override
  void deactivate() {
    _streamController.close();
    super.deactivate();
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<Todo>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: TodoAddBottomSheet(),
          ),
        );
      },
    ).then((item) {
      if (item != null) {
        _list.insert(0, item);
      }
    });
  }

  void _dismissItem(
      BuildContext context, DismissDirection direction, Todo item) {
    var index = _list.data.indexWhere((element) => element.id == item.id);
    if (index == -1) {
      return;
    }
    Scaffold.of(context).hideCurrentSnackBar();
    _list.removeAt(index);
    final snackBar = SnackBar(
      content: Text("待办事项已删除"),
      action: SnackBarAction(
        label: "撤销",
        onPressed: () => item.save().then((value) {
          _list.insert(index, item);
        }),
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
