import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:kanban/bloc/project_bloc.dart';
import 'package:kanban/models/task.dart';

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
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
                  child: Container(
                    child: TextFormField(
                      style: TextStyle(fontSize: 16),
                      maxLength: 50,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "Title",
                        labelText: "Title",
                        fillColor: Colors.white,
                        filled: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
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
                  )),
              Padding(
                padding: EdgeInsets.all(12),
                child: TextFormField(
                  maxLength: 300,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  maxLines: 6,
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: "Description",
                    labelText: "Description",
                    fillColor: Colors.white,
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
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
                    Text("Has Due Date", style: TextStyle(color: Colors.black)),
                    Spacer(),
                    Switch(
                        value: hasDueDate,
                        onChanged: (val) {
                          setState(() {
                            hasDueDate = val;
                          });
                        })
                  ],
                ),
              ),
              if (hasDueDate)
                Padding(
                    padding: EdgeInsets.all(12),
                    child: Container(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: CalendarDatePicker(
                          //use24hFormat: true,
                        firstDate: DateTime.now().add(Duration(hours: 24)),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                          initialDate: dueDate,
                          onDateChanged: (DateTime dateTime) {
                            dueDate = dateTime;
                          }),
                    ))
            ],
          ),
        ),
      ),
    );
  }
}
