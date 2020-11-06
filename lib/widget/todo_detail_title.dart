import 'package:f_todo/model/model.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TodoDetailTitle extends StatefulWidget {
  final Todo item;
  TodoDetailTitle({@required this.item});
  @override
  _TodoDetailTitleState createState() => _TodoDetailTitleState();
}

class _TodoDetailTitleState extends State<TodoDetailTitle> {
  TextEditingController _titleController;
  FocusNode _focusNode;
  bool _completed;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _focusNode = FocusNode();
    _completed = widget.item.completed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      alignment: Alignment.centerLeft,
      child: Card(
        child: _buildTitle(widget.item),
      ),
    );
  }

  Widget _buildTitle(Todo item) {
    return Row(
      children: [
        Checkbox(
            value: _completed,
            onChanged: (completed) {
              item.completed = completed;
              item.completedTime = DateTime.now().millisecondsSinceEpoch;
              item.save().whenComplete(() {
                setStateSafely(() {
                  _completed = completed;
                });
              }).catchError((e) {
                item.completed = !_completed;
                Log.debug("待办事项状态变更异常: ${e?.toString()}");
              });
            }),
        Expanded(
          child: TextField(
            focusNode: _focusNode,
            controller: _titleController,
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
            style: TextStyle(
              fontSize: 20,
              color: item.completed ? Colors.grey : Colors.black,
              decoration: item.completed
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
            onEditingComplete: () {
              var recoverTitle = item.title;
              item.title = _titleController.text;
              item.save().catchError((e) {
                Log.debug("待办事项标题变更异常: ${e?.toString()}");
                // 保存失败则恢复之前的标题
                item.title = recoverTitle;
                _titleController.text = recoverTitle;
                Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text("任务保存异常")),
                );
              });
              _focusNode.nextFocus();
            },
            textInputAction: TextInputAction.next,
          ),
        ),
      ],
    );
  }
}
