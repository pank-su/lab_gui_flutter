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
  BaseModelsTypes.order: "Семейство",
  BaseModelsTypes.family: "Род",
  BaseModelsTypes.genus: 'Вид',
  // BaseModelsTypes.kind: 'Вид'
};

class AddTopologyDialog extends StatefulWidget {
  final BaseModel? selectedBaseModel;
  const AddTopologyDialog({super.key, this.selectedBaseModel});

  @override
  State<AddTopologyDialog> createState() => _AddTopologyDialogState();
}

// TODO ПЕРЕДЕЛАТЬ ЛОГИКУ ВЫБОРА, ЛУЧШЕ ИСПОЛЬЗОВАТЬ ТО ЧТО В ЭКРАНЕ ТОПОЛОГИИ
class _AddTopologyDialogState extends State<AddTopologyDialog> {
  String selectedTopology = topology.first;
  TextEditingController nameController = TextEditingController();
  var orders = <BaseModel>[];
  BaseModel? order;
  var families = <BaseModel>[];
  BaseModel? family;
  var genuses = <BaseModel>[];
  BaseModel? genus;
  // var kinds = <BaseModel>[];
  // BaseModel? kind;

  Future<void> getInfo() async {
    selectedTopology =
        baseModelToTopologyName[widget.selectedBaseModel?.type] ??
            topology.first;

    if (widget.selectedBaseModel?.type == BaseModelsTypes.order) {
      order = widget.selectedBaseModel;
    }
    if (widget.selectedBaseModel?.type == BaseModelsTypes.family) {
      family = widget.selectedBaseModel;
      order = family?.parent;
      return;
    }
    if (widget.selectedBaseModel?.type == BaseModelsTypes.genus) {
      genus = widget.selectedBaseModel;
      family = genus?.parent;
      order = family?.parent;
      return;
    }
    setState(() {
      order = order;
    });
  }

  Future<void> loadFathers() async {
    orders = await getOrders();
    if (order != null) {
      families = await getFamiliesById(order!);
      if (family != null) {
        genuses = await getGenusesById(family!);
        genus = genuses[0];
      } else {
        family = families[0];
      }
    } else {
      order = orders[0];
    }
    setState(() {
      orders = orders.toList();
    });
  }

  @override
  void initState() {
    getInfo();
    loadFathers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<MyAppState>(context, listen: false);
    return AlertDialog(
      title: Text("Добавление ${selectedTopology.toLowerCase()}а"),
      icon: const Icon(Icons.add),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("Тип"),
        DropdownButton<String>(
            value: selectedTopology,
            items: topology
                .map<DropdownMenuItem<String>>(
                    (e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) async {
              loadFathers();
              setState(() {
                selectedTopology = value ?? " ";
              });
            }),
        getFatherEditors(),
        TextField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(), label: Text("Имя")),
          controller: nameController,
        ),
      ]),
      actions: [
        FilledButton(
            onPressed: () {
              var parentId = -1;
              parentId = genus?.id ?? -1;
              parentId = family?.id ?? -1;
              parentId = order?.id ?? -1;
              addBaseModel(topologyNameToBaseModel[selectedTopology]!, parentId,
                  nameController.text, appState.token ?? "");
            },
            child: const Text("Добавить"))
      ],
    );
  }

  Widget getFatherEditors() {
    if (selectedTopology == topology.first) {
      return Container();
    }
    var children = [
      Column(
        children: [
          const Text("Отряд"),
          DropdownButton<BaseModel>(
              value: order ?? orders[0],
              items: orders
                  .where((element) => element.name != null)
                  .map<DropdownMenuItem<BaseModel>>(
                      (e) => DropdownMenuItem(value: e, child: Text(e.name!)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    order = value;
                  });
                  //loadFathers();
                }
              })
        ],
      )
    ];
    if (topology.indexOf(selectedTopology) >= 2) {
      children.add(Column(
        children: [
          const Text("Семейство"),
          DropdownButton<BaseModel>(
              value: family!,
              items: families
                  .where((element) => element.name != null)
                  .map<DropdownMenuItem<BaseModel>>(
                      (e) => DropdownMenuItem(value: e, child: Text(e.name!)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    family = value;
                  });
                  //loadFathers();
                }
              })
        ],
      ));
    }
    if (topology.indexOf(selectedTopology) == 3) {
      children.add(Column(
        children: [
          const Text("Род"),
          DropdownButton<BaseModel>(
              value: genus!,
              items: genuses
                  .where((element) => element.name != null)
                  .map<DropdownMenuItem<BaseModel>>(
                      (e) => DropdownMenuItem(value: e, child: Text(e.name!)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    genus = value;
                  });
                  //loadFathers();
                }
              })
        ],
      ));
    }
    return Column(
      children: children,
    );
  }
}
