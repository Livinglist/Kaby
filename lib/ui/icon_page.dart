import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kanban/bloc/project_bloc.dart';
import 'package:kanban/utils/list_extension.dart';

class IconPage extends StatefulWidget {
  @override
  _IconPageState createState() => _IconPageState();
}

class _IconPageState extends State<IconPage> {
  Map<String, IconData> iconsMap;
  Map<String, IconData> allIconsMap;
  double height;

  @override
  void initState() {
    super.initState();

    allIconsMap = Map.fromEntries(FontAwesomeIconsMap.keys
        .where((key) => FontAwesomeIconsMap[key] is IconDataDuotone == false)
        .map((key) => MapEntry(key, FontAwesomeIconsMap[key])));
    iconsMap = allIconsMap;
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: Text("${iconsMap.length} icon${iconsMap.isEmpty ? '' : 's'}"),
          bottom: PreferredSize(
              child: Container(
                  child: Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CupertinoTextField(
                    style: TextStyle(fontSize: 20),
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
        backgroundColor: Colors.white,
        body: Container(
          height: height,
          child: GridView.count(
              crossAxisCount: 8,
              children: List.generate(iconsMap.length, (index) {
                return IconButton(
                  icon: Icon(iconsMap.values.elementAt(index)),
                  onPressed: () => onIconTapped(iconsMap.keys.elementAt(index)),
                );
              })),
        ));
  }

  void onIconTapped(String iconString) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Use this icon for \n${projectBloc.currentProjectInstance.name}?'),
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
                  projectBloc.updateIcon(iconString);
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
