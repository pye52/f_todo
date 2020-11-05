import 'package:f_todo/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TodoDetail extends StatelessWidget {
  final Todo item;
  TodoDetail({@required this.item});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: Column(
        children: [
          Text(item.title),
        ],
      ),
    );
  }
}
