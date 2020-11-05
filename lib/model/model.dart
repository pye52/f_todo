import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

import '../tools/helper.dart';
import 'view.list.dart';

part 'model.g.dart';
part 'model.g.view.dart';

const TODO_TABLE_NAME = "todos";

const tableTodo = SqfEntityTable(
    tableName: TODO_TABLE_NAME,
    primaryKeyName: "id",
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: true,
    fields: [
      SqfEntityField('userId', DbType.integer),
      SqfEntityField("title", DbType.text),
      SqfEntityField("content", DbType.text),
      SqfEntityField("completed", DbType.bool, defaultValue: false),
    ]);

const _DB_VERSION = 1;
const _MODEL_NAME = "dbModel";
const _DB_NAME = "todos.db";
@SqfEntityBuilder(dbModel)
const dbModel = SqfEntityModel(
  modelName: _MODEL_NAME,
  databaseName: _DB_NAME,
  databaseTables: [tableTodo],
  formTables: [tableTodo],
  dbVersion: _DB_VERSION,
);
