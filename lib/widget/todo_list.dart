import 'package:f_todo/model/model.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TodoList extends StatefulWidget {
  @override
  State createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Todo>>(
      future: Future(() async {
        return await Todo()
            .select(getIsDeleted: false)
            // .completed
            // .equals(false)
            .toList();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container();
        }
        var list = snapshot.data;
        Log.debug("待办事项列表数量: ${list.length}");
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) => TodoItem(list[index]),
          separatorBuilder: (context, index) => SizedBox(height: 8),
          itemCount: list.length,
        );
      },
    );
  }
}

class TodoItem extends StatefulWidget {
  final Todo item;
  TodoItem(this.item);
  @override
  State createState() => TodoItemState();
}

class TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    var item = widget.item;
    return Container(
      height: 50,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(
            item.completed ? Colors.grey : Colors.black,
          ),
          backgroundColor: MaterialStateProperty.all(
            item.completed ? Colors.black26 : Colors.white,
          ),
        ),
        onPressed: () {
          _onItemClicked(item, completed: !item.completed);
        },
        child: Row(
          children: [
            Checkbox(
                value: item.completed,
                onChanged: (value) async {
                  _onItemClicked(item, completed: value);
                }),
            Text(
              item.content,
              style: TextStyle(
                decoration: item.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemClicked(item, {completed = true}) async {
    Log.debug("待办事项id: ${item.id}, '${item.content}', 状态变更: $completed");
    item.completed = completed;
    await item.save();
    setStateSafely(() {});
  }
}
