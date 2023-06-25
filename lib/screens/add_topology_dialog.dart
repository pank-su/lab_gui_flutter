import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/models/base_model.dart';
import 'package:lab_gui_flutter/repository.dart';
import 'package:lab_gui_flutter/screens/loading_indicator.dart';
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
  late BaseModel selectedBaseModel = widget.selectedBaseModel ?? FATHER;

  final topology = {
    BaseModelsTypes.order: getOrders,
    BaseModelsTypes.family: getFamiliesById,
    BaseModelsTypes.genus: getGenusesById,
  };

  final nameController = TextEditingController();

  @override
  void initState() {
    type =
        BaseModelsTypes.values[(widget.selectedBaseModel?.type.index ?? 0) + 1];
    super.initState();
  }

  // Нужно сделать так чтобы значение отсылались на переменную, которую мы можем перезагрузить, чтобы не вызвать ошибку
  Future<List<Widget>> getCurrentDropDowns() async {
    var children = <Widget>[];
    BaseModel? father = selectedBaseModel;
    while ((father?.type ?? BaseModelsTypes.father) != BaseModelsTypes.father) {
      List<BaseModel> models;
      if (father?.type == BaseModelsTypes.order) {
        models = await topology[father?.type]!();
      } else {
        models = await topology[father?.type]!(father!.parent);
      }
      children.add(DropdownButtonHideUnderline(
        child: DropdownButton2(
            isDense: true,
            value: father,
            onChanged: (value) async {
              BaseModel? father = selectedBaseModel;
              var structure = <BaseModel>[];
              while ((father?.type ?? BaseModelsTypes.father) !=
                  BaseModelsTypes.father) {
                structure.add(father!);
                father = father?.parent;
              }
              var newBaseModel = FATHER;
              for (BaseModel el in structure.reversed) {
                if ((father?.type.index ?? 0) < el.type.index - 1) {
                  var parent = newBaseModel;
                  newBaseModel = el;
                  newBaseModel.parent = parent;
                } else if (el.type.index - 1 == (father?.type.index ?? 0)) {
                  var parent = newBaseModel;
                  newBaseModel = value!;
                  newBaseModel.parent = parent;
                } else {
                  var parent = newBaseModel;
                  newBaseModel = (await topology[el.type]!())[0];
                  newBaseModel.parent = parent;
                }
              }

              // setState(() {
              //   selectedBaseModel = newBaseModel;
              // });
            },
            items: models
                .map((e) => DropdownMenuItem<BaseModel>(
                    value: e, child: Text(e?.name ?? "")))
                .toList()),
      ));
      father = father?.parent;
    }
    return children.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

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
        FutureBuilder(
            future: getCurrentDropDowns(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: snapshot.data!,
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return ErrorWidget(snapshot);
              } else {
                return LoadingIndicator();
              }
            }),
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
