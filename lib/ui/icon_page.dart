import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kanban/bloc/project_bloc.dart';
import 'package:kanban/models/project.dart';

class IconPage extends StatefulWidget {
  final Project project;

  IconPage({@required this.project});

  @override
  _IconPageState createState() => _IconPageState();
}

class _IconPageState extends State<IconPage> {
  final scrollController = ScrollController();
  Map<String, IconData> iconsMap;
  Map<String, IconData> allIconsMap;
  double height, elevation = 0;

  @override
  void initState() {
    super.initState();

    allIconsMap = Map.fromEntries(FontAwesomeIconsMap.keys
        .where((key) => FontAwesomeIconsMap[key] is IconDataDuotone == false)
        .map((key) => MapEntry(key, FontAwesomeIconsMap[key])));
    iconsMap = allIconsMap;

    scrollController.addListener(() {
      if (this.mounted) {
        if (scrollController.offset <= 0 && elevation == 8) {
          setState(() {
            elevation = 0;
          });
        } else if (scrollController.offset > 0 && elevation == 0) {
          setState(() {
            elevation = 8;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          elevation: elevation,
          backgroundColor: Colors.lightBlue,
          title: Text("${iconsMap.length} icon${iconsMap.isEmpty ? '' : 's'}"),
          bottom: PreferredSize(
              child: Container(
                  child: Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CupertinoTextField(
                    style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.bodyText2.color),
                    placeholder: "Seaerch for icons",
                    onChanged: (val) {
                      setState(() {
                        var keys = allIconsMap.keys.where((key) => key.contains(val));
                        iconsMap = Map.fromEntries(keys.map((key) => MapEntry(key, FontAwesomeIconsMap[key])));
                      });
                    },
                  ),
                ),
              )),
              preferredSize: Size.fromHeight(50)),
        ),
        backgroundColor: Colors.lightBlue,
        body: Container(height: height, child: IconGridView(scrollController: scrollController, iconsMap: iconsMap, onIconTapped: onIconTapped)));
  }

  void onIconTapped(String iconString) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Use this icon for \n${widget.project.name}?'),
          content: Flex(
            direction: Axis.vertical,
            children: <Widget>[SizedBox(height: 24), Transform.scale(scale: 2, child: Icon(FontAwesomeIconsMap[iconString])), SizedBox(height: 24)],
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel")),
            CupertinoActionSheetAction(
                onPressed: () {
                  projectBloc.updateIcon(widget.project, iconString);
                  Navigator.pop(context);
                },
                child: Text("Confirm"),
                isDefaultAction: true),
          ],
        );
      },
    );
  }
}

class IconGridView extends StatelessWidget {
  final Map<String, IconData> iconsMap;
  final ValueChanged<String> onIconTapped;
  final ScrollController scrollController;

  IconGridView({this.scrollController, this.iconsMap, this.onIconTapped}) : assert(iconsMap != null);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        controller: scrollController,
        crossAxisCount: 8,
        children: iconsMap.keys
            .map((key) => IconButton(
                  icon: Icon(iconsMap[key], color: Colors.white),
                  onPressed: () => onIconTapped(key),
                ))
            .toList());
  }
}
