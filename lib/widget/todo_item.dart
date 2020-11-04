import 'package:f_todo/model/model.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef DismissCallback = void Function(DismissDirection direction, Todo item);

class TodoItem extends StatefulWidget {
  final int index;
  final Todo item;
  final Animation<double> animation;
  final DismissCallback dismissCallback;
  TodoItem({
    @required this.index,
    @required this.item,
    @required this.animation,
    @required this.dismissCallback,
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
          var result = await item.delete().whenComplete(() {
            Log.debug("待办事项已标记删除: ${item.id}");
            widget.dismissCallback(direction, item);
          });
          if (!result.success) {
            Log.debug("删除失败: ${result.errorMessage}");
            return false;
          }
          return true;
        },
        child: TextButton(
          style: TextButton.styleFrom(
            primary: item.completed ? Colors.grey : Colors.black,
            backgroundColor: item.completed ? Colors.black26 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            _onItemClick(item, completed: !item.completed);
          },
          child: _buildItemChild(item),
        ),
      ),
    );
  }

  Widget _buildItemChild(item) {
    return Row(
      children: [
        Checkbox(
            value: item.completed,
            onChanged: (value) async {
              _onItemClick(item, completed: value);
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

  void _onItemClick(item, {completed = true}) async {
    Log.debug("待办事项id: ${item.id}, '${item.title}', 状态变更: $completed");
    item.completed = completed;
    await item.save();
    setStateSafely(() {});
  }
}
