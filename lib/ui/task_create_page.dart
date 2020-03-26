import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kanban/bloc/project_bloc.dart';

import 'package:kanban/models/task.dart';
import 'home_page.dart';

class TaskCreatePage extends StatefulWidget {
  @override
  _TaskCreatePageState createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends State<TaskCreatePage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Task task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (formKey.currentState.validate()) {
                var title = titleController.text;
                var description = descriptionController.text;

                task = Task.create(title: title, description: description);

                projectBloc.addTask(task);

                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(12),
                child: TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: "Title", labelText: "Title"),
                  validator: (String value) {
                    if (value.trim().isEmpty) {
                      return "Title cannot be empty.";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(hintText: "Description", labelText: "Description"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
