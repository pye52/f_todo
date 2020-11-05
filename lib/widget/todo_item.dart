import 'package:f_todo/model/model.dart';
import 'package:f_todo/module/todo_detail.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef DismissCallback = void Function(
    BuildContext context, DismissDirection direction, Todo item);

class TodoItem extends StatefulWidget {
  final int index;
  final Todo item;
  final Animation<double> animation;
  final DismissCallback onItemDismissed;
  TodoItem({
    @required this.index,
    @required this.item,
    @required this.animation,
    @required this.onItemDismissed,
  });
  @override
  State createState() => TodoItemState();
}

class TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: widget.animation
          .drive(CurveTween(curve: Curves.linear))
          .drive(Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))),
      transformHitTests: !widget.animation.isCompleted,
      child: _child(widget.item),
    );
  }

  Widget _child(Todo item) {
    return Container(
      height: 60,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Dismissible(
        key: ValueKey(item),
        confirmDismiss: (direction) async {
          await item.delete();
          widget.onItemDismissed(context, direction, item);
          return true;
        },
        child: TextButton(
          style: TextButton.styleFrom(
            primary: item.completed ? Colors.grey : Colors.black,
            backgroundColor: item.completed ? Colors.black26 : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TodoDetail(item: item)),
            );
          },
          child: _buildItemChild(item),
        ),
      ),
    );
  }

  Widget _buildItemChild(Todo item) {
    return Row(
      children: [
        Checkbox(
            value: item.completed,
            onChanged: (completed) async {
              Log.debug(
                  "待办事项id: ${item.id}, '${item.title}', 状态变更: $completed");
              item.completed = completed;
              item.save().whenComplete(() {
                setStateSafely(() {});
              });
            }),
        Text(
          item.title,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            decoration: item.completed
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
