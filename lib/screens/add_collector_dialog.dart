import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/repository.dart';
import 'package:provider/provider.dart';

import '../my_app_state.dart';

class AddCollector extends StatefulWidget {
  final bool isUpdate;
  final int? updatableId;

  const AddCollector({super.key, required this.isUpdate, this.updatableId});

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
    if (!widget.isUpdate) {
      idController.text = (await getLastCollectorId()).toString();
      return;
    }
    idController.text = widget.updatableId?.toString() ?? " ";
    var collector = await getCollectorById(widget.updatableId ?? 0);
    lastNameController.text = collector.lastName ?? "";
    firstNameController.text = collector.firstName ?? "";
    secondNameController.text = collector.secondName ?? "";
    setState(() {
      canAdd = true;
    });
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
      title: const Text("Добавление нового коллектора"),
      icon: const Icon(Icons.add),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          decoration:
              const InputDecoration(border: OutlineInputBorder(), label: Text("ID")),
          enabled: false,
          controller: idController,
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(), label: Text("Фамилия")),
          controller: lastNameController,
          onChanged: (value) {
            setState(() {
              canAdd = value.trim().isNotEmpty;
            });
          },
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          decoration:
              const InputDecoration(border: OutlineInputBorder(), label: Text("Имя")),
          controller: firstNameController,
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(), label: Text("Отчетство")),
          controller: secondNameController,
        )
      ]),
      actions: [
        FilledButton(
            onPressed: canAdd
                ? () async {if (!widget.isUpdate) {
                  addCollector(
                        lastNameController.text,
                        firstNameController.text,
                        secondNameController.text,
                        appState.token!);
                } else{
                  updateCollector(
                        lastNameController.text,
                        firstNameController.text,
                        secondNameController.text,
                        appState.token!, widget.updatableId ?? -1);
                }
                Navigator.pop(context);
                  }
                  
                : null,
            child: Text(widget.isUpdate ? "Изменить" : "Добавить"))
      ],
    );
  }
}
