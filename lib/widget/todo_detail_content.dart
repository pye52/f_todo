import 'package:f_todo/model/model.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TodoDetailContent extends StatefulWidget {
  final Todo item;
  TodoDetailContent({@required this.item});
  @override
  _TodoDetailContentState createState() => _TodoDetailContentState();
}

class _TodoDetailContentState extends State<TodoDetailContent> {
  TextEditingController _contentController;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.item.content);
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(8),
      child: _buildContent(widget.item),
    );
  }

  Widget _buildContent(Todo item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          focusNode: _focusNode,
          controller: _contentController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "任务内容",
          ),
          strutStyle: StrutStyle(
            forceStrutHeight: true,
            leading: 0.3,
          ),
          maxLines: null,
          expands: true,
          onEditingComplete: () {
            var recoverContent = item.content;
            item.content = _contentController.text;
            item.save().catchError((e) {
              Log.debug("待办事项内容变更异常: ${e?.toString()}");
              // 保存失败则恢复之前的标题
              item.content = recoverContent;
              _contentController.text = recoverContent;
              Scaffold.of(context).showSnackBar(
                SnackBar(content: Text("任务保存异常")),
              );
            });
            _focusNode.unfocus();
          },
          textInputAction: TextInputAction.done,
        ),
      ),
    );
  }
}
