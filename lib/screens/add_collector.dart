import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/repository.dart';
import 'package:provider/provider.dart';

import '../my_app_state.dart';

class AddCollector extends StatefulWidget {
  const AddCollector({super.key});

  @override
  State<AddCollector> createState() => _AddCollectorState();
}

class _AddCollectorState extends State<AddCollector> {
  final idController = TextEditingController();
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final secondNameController = TextEditingController();

  var canAdd = false;

  Future<void> getInfo() async {
    idController.text = (await getLastCollectorId()).toString();
  }

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return AlertDialog(
      title: Text("Добавление нового коллектора"),
      icon: Icon(Icons.add),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          decoration:
              InputDecoration(border: OutlineInputBorder(), label: Text("ID")),
          enabled: false,
          controller: idController,
        ),
        SizedBox(
          height: 20,
        ),
        TextField(
          decoration: InputDecoration(
              border: OutlineInputBorder(), label: Text("Фамилия")),
          controller: lastNameController,
          onChanged: (value) {
            setState(() {
              canAdd = value.trim().isNotEmpty;
            });
          },
        ),
        SizedBox(
          height: 20,
        ),
        TextField(
          decoration:
              InputDecoration(border: OutlineInputBorder(), label: Text("Имя")),
          controller: firstNameController,
        ),
        SizedBox(
          height: 20,
        ),
        TextField(
          decoration: InputDecoration(
              border: OutlineInputBorder(), label: Text("Отчетство")),
          controller: secondNameController,
        )
      ]),
      actions: [
        FilledButton(
            onPressed: canAdd
                ? () async {
                    addCollector(
                        lastNameController.text,
                        firstNameController.text,
                        secondNameController.text,
                        appState.token!);
                  }
                : null,
            child: Text("Добавить"))
      ],
    );
  }
}
