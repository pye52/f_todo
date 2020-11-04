import 'package:f_todo/model/list_model.dart';
import 'package:f_todo/model/model.dart';
import 'package:f_todo/todo.dart';
import 'package:f_todo/widget/todo_add.dart';
import 'package:f_todo/widget/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TodoList extends StatefulWidget {
  @override
  State createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  final GlobalKey<AnimatedListState> _listKey =
      new GlobalKey<AnimatedListState>();
  ListModel<Todo> _list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("待办事项"),
      ),
      backgroundColor: Color(0xFF708090),
      body: FutureBuilder<List<Todo>>(
        future: Future(() => Todo()
            .select(getIsDeleted: false)
            // .completed
            // .equals(false)
            .orderByDesc(TodoFields.id.fieldName)
            .toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container();
          }
          _list = new ListModel(
            listKey: _listKey,
            initialItems: snapshot.data,
            removedItemBuilder: (index, item, animation) => TodoItem(
              index: index,
              item: item,
              animation: animation,
              dismissCallback: (direction, item) =>
                  _dismissItem(context, direction, item),
            ),
          );
          return AnimatedList(
            key: _listKey,
            padding: const EdgeInsets.all(0),
            initialItemCount: _list.length,
            itemBuilder: (context, index, animation) => TodoItem(
              index: index,
              item: _list[index],
              animation: animation,
              dismissCallback: (direction, item) =>
                  _dismissItem(context, direction, item),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showBottomSheet(context);
        },
      ),
    );
  }

  void _showBottomSheet(context) async {
    var item = await showModalBottomSheet<Todo>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: TodoAddBottomSheet(),
        ),
      ),
    );
    Log.debug("添加完毕: ${item?.id}");
    if (item != null) {
      _list.insert(0, item);
    }
  }

  _dismissItem(context, direction, item) {
    var index = _list.data.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _list.removeAt(index);
    }
    var recover = false;
    final snackBar = SnackBar(
      content: Text("待办事项已删除"),
      action: SnackBarAction(
          label: "撤销",
          onPressed: () {
            item.recover().whenComplete(() {
              // 撤销删除
              recover = true;
              _list.insert(index, item);
              Log.debug("待办事项删除操作已撤销: ${item.id}");
            });
          }),
    );
    Scaffold.of(context).showSnackBar(snackBar).closed.then((value) {
      // 若删除动作未被撤销，则从数据库完全删除
      if (!recover) {
        item.delete(true).whenComplete(() {
          Log.debug("待办事项已完全删除: ${item.id}");
        });
      }
    });
  }
}
