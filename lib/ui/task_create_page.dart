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

  String titleCharCount = '0/50', desCharCount = '0/250';

  DateTime dueDate = DateTime.now().add(Duration(hours: 24 - DateTime.now().hour));

  bool hasDueDate = false;

  Task task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 8,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (formKey.currentState.validate()) {
                var title = titleController.text;
                var description = descriptionController.text;

                task = Task.create(title: title, description: description, dueDate: hasDueDate ? dueDate : null);

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
                  maxLength: 50,
                  maxLengthEnforced: false,
                  controller: titleController,
                  decoration: InputDecoration(hintText: "Title", labelText: "Title"),
                  validator: (String value) {
                    if (value.trim().isEmpty) {
                      return "Title cannot be empty.";
                    }
                    if (value.trim().length > 50) {
                      return "Title cannot be more than 50 characters.";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: TextFormField(
                  maxLength: 300,
                  maxLengthEnforced: false,
                  maxLines: 6,
                  controller: descriptionController,
                  decoration: InputDecoration(hintText: "Description", labelText: "Description"),
                  validator: (String value) {
                    if (value == null || value.isEmpty) return null;
                    if (value.trim().length > 300) {
                      return "Description cannot be more than 300 characters.";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    Text("Has Due Date"),
                    Spacer(),
                    CupertinoSwitch(
                        value: hasDueDate,
                        onChanged: (val) {
                          setState(() {
                            hasDueDate = val;
                          });
                        })
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Text("Due Date"),
              ),
              Padding(
                  padding: EdgeInsets.all(12),
                  child: Container(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    child: CupertinoDatePicker(
                        use24hFormat: true,
                        initialDateTime: dueDate,
                        onDateTimeChanged: (DateTime dateTime) {
                          dueDate = dateTime;
                        },
                        mode: CupertinoDatePickerMode.dateAndTime),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
