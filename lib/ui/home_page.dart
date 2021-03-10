import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_review/app_review.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kanban/models/project.dart';
import 'package:kanban/models/task.dart';
import 'task_create_page.dart';
import 'package:kanban/bloc/project_bloc.dart';
import 'package:kanban/utils/datetime_extension.dart';
import 'icon_page.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final nameEditingController = TextEditingController();

  @override
  void initState() {
    projectBloc.fetchAllProjects();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TaskCreatePage()));
                  })
            ],
            title: StreamBuilder(
                stream: projectBloc.currentProject,
                builder: (_, AsyncSnapshot<Project> snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.name);
                  }
                  return Text('');
                }),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: StreamBuilder(
                    stream: projectBloc.allTodo,
                    builder: (_, snapshot) {
                      return Column(
                        children: [Text('Todo'), Text(snapshot.hasData ? '${snapshot.data.length}' : '')],
                      );
                    },
                  ),
                ),
                Tab(
                  child: StreamBuilder(
                    stream: projectBloc.allDoing,
                    builder: (_, snapshot) {
                      return Column(
                        children: [Text('Doing'), Text(snapshot.hasData ? '${snapshot.data.length}' : '')],
                      );
                    },
                  ),
                ),
                Tab(
                  child: StreamBuilder(
                    stream: projectBloc.allDone,
                    builder: (_, snapshot) {
                      return Column(
                        children: [Text('Done'), Text(snapshot.hasData ? '${snapshot.data.length}' : '')],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          body: TabBarView(
            children: [
              Container(
                color: Colors.lightBlue,
                child: StreamBuilder(
                  stream: projectBloc.allTodo,
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      var todos = snapshot.data;

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 12,
                            ),
                            ...buildChildren(todos)
                          ],
                        ),
                      );
                    }

                    return Container();
                  },
                ),
              ),
              Container(
                color: Colors.redAccent,
                child: StreamBuilder(
                  stream: projectBloc.allDoing,
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      var doings = snapshot.data;

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 12,
                            ),
                            ...buildChildren(doings)
                          ],
                        ),
                      );
                    }

                    return Container();
                  },
                ),
              ),
              Container(
                color: Colors.blueAccent,
                child: StreamBuilder(
                  stream: projectBloc.allDone,
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      var dones = snapshot.data;

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 12,
                            ),
                            ...buildChildren(dones)
                          ],
                        ),
                      );
                    }

                    return Container();
                  },
                ),
              ),
            ],
          ),
          drawer: Drawer(
              child: Material(
            color: Colors.white,
            child: SingleChildScrollView(
                child: StreamBuilder(
              stream: projectBloc.allProjects,
              builder: (_, AsyncSnapshot<List<Project>> snapshot) {
                return Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    SizedBox(height: 48),
                    Container(
                      child: ListTile(
                        title: Text(
                          "My Kanban",
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          projectBloc.getKanban();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Container(
                        child: Flex(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Flexible(
                          child: Divider(),
                          flex: 1,
                        ),
                        Flexible(
                          child: ListTile(
                              title: Text(
                            "Projects",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black),
                          )),
                          flex: 1,
                        ),
                        Flexible(
                          child: Divider(),
                          flex: 1,
                        )
                      ],
                    )),
                    if (snapshot.hasData)
                      for (var p in snapshot.data)
                        Container(
                          //color: (widget.project.id == p.id && widget.isKanban == false) ? appBarColor : Colors.transparent,
                          child: ListTile(
                            leading: Icon(
                              FontAwesomeIconsMap[p.icon],
                              color: Colors.black54,
                            ),
                            title: Text(
                              p.name,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text("${p.tasks.where((t) => t.isDone).toList().length}/${p.tasks.length}"),
                            onTap: () {
                              projectBloc.getProjectById(p.uid);
                              Navigator.pop(context);
                            },
                            onLongPress: () => onProjectListTileLongPressed(p),
                          ),
                        ),
                    Container(
                      color: Colors.transparent,
                      child: ListTile(
                          title: Icon(Icons.add),
                          onTap: () {
                            showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Name Your Project'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      TextField(
                                        controller: nameEditingController,
                                      )
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel")),
                                    TextButton(
                                        onPressed: () {
                                          var name = nameEditingController.text;
                                          if (name.isNotEmpty) {
                                            nameEditingController.clear();

                                            String uid = projectBloc.createProject(name);
                                            projectBloc.getProjectById(uid);
                                            Navigator.pop(context);
                                            Navigator.pop(context);

                                            AppReview.isRequestReviewAvailable.then((isAvailable) {
                                              if (isAvailable) {
                                                AppReview.requestReview;
                                              }
                                            });
                                          }
                                        },
                                        child: Text("Confirm")),
                                  ],
                                );
                              },
                            );
                          }),
                    )
                  ],
                );
              },
            )),
          ))),
    );
  }

  List<Widget> buildChildren(List<Task> tasks) {
    print(tasks);
    return tasks.map((e) {
      return Dismissible(
        key: UniqueKey(),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Material(
            elevation: 4,
            color: Colors.white,
            child: ListTile(
              title: Text(e.title),
              onTap: () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (_) {
                      if (e.description == null || e.description.isEmpty) {
                        return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    e.title,
                                    style: TextStyle(fontSize: 20, color: Colors.black),
                                  ),
                                  Spacer(),
                                  Text(e.dueDate == null ? "" : "Due by ${e.dueDate.toLocal().toCustomString()}",
                                      style: TextStyle(color: Colors.black54)),
                                  Divider(),
                                  Text(e.createdDate == null ? "" : "Created on ${e.createdDate.toLocal().toCustomString()}",
                                      style: TextStyle(color: Colors.black54)),
                                  SizedBox(height: 12)
                                ],
                              ),
                            ));
                      }

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                          color: Colors.white,
                        ),
                        child: DraggableScrollableSheet(
                          expand: false,
                          maxChildSize: 0.9,
                          builder: (_, scrollController) {
                            return SingleChildScrollView(
                                //physics: NeverScrollableScrollPhysics(),
                                controller: scrollController,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        e.title,
                                        style: TextStyle(fontSize: 20, color: Colors.black),
                                      ),
                                      Divider(),
                                      Flexible(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: Text(
                                            e.description ?? "",
                                            style: TextStyle(fontSize: 16, color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      if (e.dueDate != null) Divider(),
                                      Text(e.dueDate == null ? "" : "Due by ${e.dueDate.toLocal().toCustomString()}",
                                          style: TextStyle(color: Colors.black54)),
                                      Divider(),
                                      Text(e.createdDate == null ? "" : "Created on ${e.createdDate.toLocal().toCustomString()}",
                                          style: TextStyle(color: Colors.black54))
                                    ],
                                  ),
                                ));
                          },
                        ),
                      );
                    });
              },
            ),
          ),
        ),
        direction: DismissDirection.horizontal,
        background: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20.0),
            color: Colors.transparent,
            child: Icon(
              Icons.forward,
              color: Colors.white,
            ),
          ),
        ),
        secondaryBackground: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.0),
            color: Colors.red,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            projectBloc.removeTask(e);
          } else {
            projectBloc.updateTaskStatus(e);
          }
        },
      );
      // return Custom.CustomDismissible(
      //   direction: Custom.DismissDirection.horizontal,
      //
      //   key: dismissibleKeys[e],
      //   child: Padding(
      //     padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      //     child: Material(
      //       elevation: 4,
      //       color: Colors.white,
      //       child: ListTile(
      //         title: Text(e.title),
      //         onTap: () {
      //           showModalBottomSheet(
      //               isScrollControlled: true,
      //               context: context,
      //               builder: (_) {
      //                 if (e.description == null || e.description.isEmpty) {
      //                   return Container(
      //                       height: 200,
      //                       decoration: BoxDecoration(
      //                         borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      //                         color: Colors.white,
      //                       ),
      //                       child: Padding(
      //                         padding: EdgeInsets.all(12),
      //                         child: Column(
      //                           mainAxisSize: MainAxisSize.min,
      //                           children: <Widget>[
      //                             Text(
      //                               e.title,
      //                               style: TextStyle(fontSize: 20, color: Colors.black),
      //                             ),
      //                             Spacer(),
      //                             Text(e.dueDate == null ? "" : "Due by ${e.dueDate.toLocal().toCustomString()}",
      //                                 style: TextStyle(color: Colors.black54)),
      //                             Divider(),
      //                             Text(e.createdDate == null ? "" : "Created on ${e.createdDate.toLocal().toCustomString()}",
      //                                 style: TextStyle(color: Colors.black54)),
      //                             SizedBox(height: 12)
      //                           ],
      //                         ),
      //                       ));
      //                 }
      //
      //                 return Container(
      //                   decoration: BoxDecoration(
      //                     borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      //                     color: Colors.white,
      //                   ),
      //                   child: DraggableScrollableSheet(
      //                     expand: false,
      //                     maxChildSize: 0.9,
      //                     builder: (_, scrollController) {
      //                       return SingleChildScrollView(
      //                           //physics: NeverScrollableScrollPhysics(),
      //                           controller: scrollController,
      //                           child: Padding(
      //                             padding: EdgeInsets.all(12),
      //                             child: Column(
      //                               mainAxisSize: MainAxisSize.min,
      //                               children: <Widget>[
      //                                 Text(
      //                                   e.title,
      //                                   style: TextStyle(fontSize: 20, color: Colors.black),
      //                                 ),
      //                                 Divider(),
      //                                 Flexible(
      //                                   child: Container(
      //                                     width: MediaQuery.of(context).size.width,
      //                                     child: Text(
      //                                       e.description ?? "",
      //                                       style: TextStyle(fontSize: 16, color: Colors.black),
      //                                     ),
      //                                   ),
      //                                 ),
      //                                 SizedBox(
      //                                   height: 12,
      //                                 ),
      //                                 if (e.dueDate != null) Divider(),
      //                                 Text(e.dueDate == null ? "" : "Due by ${e.dueDate.toLocal().toCustomString()}",
      //                                     style: TextStyle(color: Colors.black54)),
      //                                 Divider(),
      //                                 Text(e.createdDate == null ? "" : "Created on ${e.createdDate.toLocal().toCustomString()}",
      //                                     style: TextStyle(color: Colors.black54))
      //                               ],
      //                             ),
      //                           ));
      //                     },
      //                   ),
      //                 );
      //               });
      //         },
      //       ),
      //     ),
      //   ),
      //   confirmDismiss: (direction) async {
      //     if (direction == Custom.DismissDirection.endToStart) {
      //       projectBloc.removeTask(e);
      //       // setState(() {
      //       //   currentTask = null;
      //       //   dismissibleKeys.remove(e);
      //       //
      //       //   switch (e.status) {
      //       //     case TaskStatus.todo:
      //       //       todoTask.remove(e);
      //       //       break;
      //       //     case TaskStatus.doing:
      //       //       doingTask.remove(e);
      //       //       break;
      //       //     case TaskStatus.done:
      //       //       doneTask.remove(e);
      //       //       break;
      //       //     default:
      //       //       break;
      //       //   }
      //       //   computeHeight();
      //       //   projectBloc.removeTask(e);
      //       // });
      //       return true;
      //     } else {
      //       projectBloc.updateTaskStatus(e);
      //     }
      //     return false;
      //   },
      //   onDismissed: (direction) {},
      //   onResize: () {},
      // );
    }).toList();
  }

  void onProjectListTileLongPressed(Project p) => showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                isDestructiveAction: false,
                child: Text('Edit Name'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog<bool>(
                    context: context,
                    builder: (context) {
                      nameEditingController.text = p.name;
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(height: 12),
                            TextField(
                              controller: nameEditingController,
                            )
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel")),
                          TextButton(
                              onPressed: () {
                                var name = nameEditingController.text;
                                if (name.isNotEmpty) {
                                  nameEditingController.clear();
                                  //scaffoldKey.currentState.closeDrawer();
                                  Navigator.pop(context);
                                  p.name = name;
                                  print(p.name);
                                  projectBloc.updateProject(p);
                                }
                              },
                              child: Text("Confirm")),
                        ],
                      );
                    },
                  );
                },
              ),
              CupertinoActionSheetAction(
                child: Text('Change Icon'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => IconPage(project: p)));
                },
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                child: Text('Remove ${p.name}'),
                onPressed: () {
                  Navigator.pop(context);
                  onRemoveTapped(p);
                },
              ),
            ],
          ));

  void onRemoveTapped(Project p) => showCupertinoModalPopup<bool>(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
                message: Text("Are you sure?"),
                cancelButton: CupertinoActionSheetAction(
                  isDefaultAction: true,
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    child: Text('Remove ${p.name}'),
                    onPressed: () {
                      //scaffoldKey.currentState.closeDrawer();
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              )).then((value) {
        if (value != null && value) {
          projectBloc.deleteProject(p);
        }
      });

  void showSnackBar(String msg) {
    assert(msg != null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        action: SnackBarAction(
            label: "Dismiss",
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            })));
  }

  void showRemoveAllDialog() => showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return CupertinoActionSheet(
          message: Text("Remove all tasks"),
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  projectBloc.removeAllTasks();
                  Navigator.pop(context);
                },
                child: Text("Confirm"),
                isDestructiveAction: true),
          ],
        );
      });
}
