import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/models/base_model.dart';
import 'package:lab_gui_flutter/repository.dart';
import 'package:provider/provider.dart';

import '../my_app_state.dart';

// Смещение так как отправляется отец
const List<String> topology = <String>['Отряд', 'Семейство', 'Род', 'Вид'];
const Map<String, BaseModelsTypes> topologyNameToBaseModel = {
  "Отряд": BaseModelsTypes.order,
  "Семейство": BaseModelsTypes.family,
  "Род": BaseModelsTypes.genus,
  "Вид": BaseModelsTypes.kind
};

const Map<BaseModelsTypes, String> baseModelToTopologyName = {
  BaseModelsTypes.order: "Отряд",
  BaseModelsTypes.family: "Семейств",
  BaseModelsTypes.genus: 'Род',
  BaseModelsTypes.kind: 'Вид'
};

class AddTopologyDialog extends StatefulWidget {
  final BaseModel? selectedBaseModel;
  const AddTopologyDialog({super.key, this.selectedBaseModel});

  @override
  State<AddTopologyDialog> createState() => _AddTopologyDialogState();
}

// ПЕРЕДЕЛАТЬ ЛОГИКУ ВЫБОРА, ЛУЧШЕ ИСПОЛЬЗОВАТЬ ТО ЧТО В ЭКРАНЕ ТОПОЛОГИИ
class _AddTopologyDialogState extends State<AddTopologyDialog> {
  BaseModelsTypes type = BaseModelsTypes.order;

  final nameController = TextEditingController();

  @override
  void initState() {
    type =
        BaseModelsTypes.values[(widget.selectedBaseModel?.type.index ?? 0) + 1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<MyAppState>(context, listen: false);
    String title = baseModelToTopologyName[type]?.toLowerCase() ?? "";
    return AlertDialog(
      title: Text("Добавление нового ${title}а"),
      icon: const Icon(Icons.add),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("Вид:"),
        DropdownButtonHideUnderline(
            child: DropdownButton2<BaseModelsTypes>(
          value: type,
          onChanged: (BaseModelsTypes? value) {
            setState(() {
              type = value ?? BaseModelsTypes.order;
            });
          },
          items: baseModelToTopologyName.keys
              .map((e) => DropdownMenuItem<BaseModelsTypes>(
                    value: e,
                    child: Text(e == BaseModelsTypes.family
                        ? "${baseModelToTopologyName[e]!}о"
                        : baseModelToTopologyName[e]!),
                  ))
              .toList(),
        )),
        TextField(
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              label: Text("Название ${title}а")),
          controller: nameController,
        ),
      ]),
      actions: [FilledButton(onPressed: () {}, child: const Text("Добавить"))],
    );
  }
}
