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
  void initState() {
    super.initState();
  }

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
          itemBuilder: (context, index) => _buildItem(list[index]),
          separatorBuilder: (context, index) => SizedBox(height: 8),
          itemCount: list.length,
        );
      },
    );
  }

  _buildItem(Todo item) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 50,
          alignment: Alignment.centerLeft,
          color: item.completed ? Colors.black26 : Colors.white,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Checkbox(
                  value: item.completed,
                  onChanged: (value) async {
                    Log.debug(
                        "待办事项id: ${item.id}, '${item.content}', 状态变更: ${value}");
                    item.completed = value;
                    await item.save();
                    setStateSafely(() {});
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
