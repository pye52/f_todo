import 'package:f_todo/model/list_model.dart';
import 'package:f_todo/model/model.dart';
import 'package:f_todo/todo.dart';
import 'package:f_todo/widget/todo_add.dart';
import 'package:f_todo/widget/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  @override
  State createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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

  void _showBottomSheet(BuildContext context) async {
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
    Log.debug("添加结果: $item");
    if (item != null) {
      _list.insert(0, item);
    }
  }
}
