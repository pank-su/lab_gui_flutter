import 'package:flutter/material.dart';

const List<String> topology = <String>['Отряд', 'Семейство', 'Род', 'Вид'];

class AddTopologyDialog extends StatefulWidget {
  const AddTopologyDialog({super.key});

  @override
  State<AddTopologyDialog> createState() => _AddTopologyDialogState();
}

class _AddTopologyDialogState extends State<AddTopologyDialog> {
  String topologySelected = topology.first;
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Добавление топологии"),
      icon: const Icon(Icons.add),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("Тип"),
        DropdownButton<String>(
            value: topologySelected,
            items: topology
                .map<DropdownMenuItem<String>>(
                    (e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              setState(() {
                topologySelected = value ?? " ";
              });
            }),
        Column(
          children: topologySelected == topology.first
              ? [
                  const Text("Отец:"),
                  DropdownButton<String>(
                      value: topologySelected,
                      items: topology
                          .map<DropdownMenuItem<String>>(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          topologySelected = value ?? " ";
                        });
                      })
                ]
              : [],
        ),
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(), label: Text("Имя")),
          controller: nameController,
        ),
      ]),
      actions: [FilledButton(onPressed: () {}, child: const Text("Добавить"))],
    );
  }
}
