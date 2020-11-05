import 'dart:async';

import 'package:f_todo/model/list_model.dart';
import 'package:f_todo/model/model.dart';
import 'package:f_todo/repository/todo_repository.dart';
import 'package:f_todo/widget/todo_add.dart';
import 'package:f_todo/widget/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TodoList extends StatefulWidget {
  @override
  State createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  final TodoDataSource _dataSource = TodoDataSource();
  final StreamController<List<Todo>> _streamController = new StreamController();
  GlobalKey<AnimatedListState> _listKey;
  ListModel<Todo> _list;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    var data = await _dataSource.queryAllTodo();
    await Future.delayed(Duration(seconds: 1));
    _streamController.sink.add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("待办事项"),
      ),
      backgroundColor: Color(0xFF708090),
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
            removedItemBuilder: (index, item, animation) =>
                AnimatedContainer(duration: Duration(seconds: 1)),
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

  void _showBottomSheet(BuildContext context) async {
    var item = await showModalBottomSheet<Todo>(
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
    );
    if (item != null) {
      _list.insert(0, item);
    }
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
          onPressed: () async {
            await item.save();
            _list.insert(index, item);
          }),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}
