import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:lab_gui_flutter/my_app_state.dart';
import 'package:lab_gui_flutter/screens/add_topology_dialog_old.dart';
import 'package:provider/provider.dart';

import '../models/base_model.dart';
import '../repository.dart';

class TopologyPage extends StatefulWidget {
  const TopologyPage({super.key, required this.selectableMode});

  final bool selectableMode;

  @override
  State<TopologyPage> createState() => _TopologyPageState();
}

class _TopologyPageState extends State<TopologyPage> {
  final topology = {
    BaseModelsTypes.order: getFamiliesById,
    BaseModelsTypes.family: getGenusesById,
    BaseModelsTypes.genus: getKindsById,
  };

  @override
  void initState() {
    super.initState();
  }

  bool isAdding = false;
  BaseModel? addedParent;

  bool isEditing = false;
  late BaseModel editedBaseModel;

  TextEditingController _textEditingController = TextEditingController();

  Widget getLeading(BaseModel baseModel) {
    var appState = context.watch<MyAppState>();

    if (appState.loadingModels.contains(baseModel)) {
      return const CircularProgressIndicator();
    }

    late final VoidCallback? onPressed;
    late final bool? isOpen;

    final List<BaseModel>? children = appState.childrenTopologyMap[baseModel];

    if (baseModel.name != null &&
        baseModel.type != BaseModelsTypes.kind &&
        children == null) {
      isOpen = false;
      onPressed = () async {
        appState.loadingModels.add(baseModel);
        appState.notifyListeners();

        var list = await topology[baseModel.type]!(baseModel);

        appState.childrenTopologyMap[baseModel] = list
            .where((element) =>
                element.name != null && element.name!.trim().isNotEmpty)
            .toList();
        appState.loadingModels.remove(baseModel);
        appState.treeController.expand(baseModel);
      };
    } else if (baseModel.type == BaseModelsTypes.kind ||
        baseModel.name == null ||
        children!.isEmpty) {
      isOpen = null;
      onPressed = null;
    } else {
      isOpen = appState.treeController.getExpansionState(baseModel);
      onPressed = () => appState.treeController.toggleExpansion(baseModel);
    }

    return FolderButton(
      isOpen: isOpen,
      onPressed: onPressed,
    );
  }

  bool firstSelect = false;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (widget.selectableMode && !firstSelect) {
      setState(() {
        appState.selectableBaseModel = appState.selectedBaseModel;
        firstSelect = true;
      });
    }

    return Stack(children: [
      AnimatedTreeView(
          treeController: appState.treeController,
          nodeBuilder: (context, entry) {
            var parent = entry.node.type == BaseModelsTypes.order
                ? FATHER
                : entry.node.parent;

            String title =
                baseModelToTopologyName[entry.node.type]?.toLowerCase() ?? "";

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TreeIndentation(
                    entry: entry,
                    child: Row(
                      children: [
                        getLeading(entry.node),
                        widget.selectableMode
                            ? Container(
                                color: appState.selectableBaseModel != null &&
                                        appState.selectableBaseModel! ==
                                            entry.node
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : Colors.transparent,
                                child: GestureDetector(
                                  child: Text(entry.node.name ?? ""),
                                  onTap: () {
                                    setState(() {
                                      appState.selectableBaseModel = entry.node;
                                    });
                                  },
                                ))
                            : Text(entry.node.name ?? "")
                      ],
                    )),
                appState.isAuth &&
                        appState.childrenTopologyMap[parent]!
                                .indexOf(entry.node) ==
                            appState.childrenTopologyMap[parent]!.length - 1
                    ? addingButton(entry, parent, title, context, appState)
                    : const SizedBox()
              ],
            );
          }),
      widget.selectableMode
          ? Container(
              margin: const EdgeInsets.all(70),
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: FilledButton(
                      onPressed: appState.selectableBaseModel != null
                          ? () {
                              appState.setSelectedBaseModel(
                                  appState.selectableBaseModel);
                              Navigator.pop(context);
                            }
                          : null,
                      child: const Text("Подтвердить"))))
          : const Text("")
    ]);
  }

  Column addingButton(TreeEntry<BaseModel> entry, BaseModel? parent,
      String title, BuildContext context, MyAppState appState) {
    return Column(children: [
      Row(children: [
        SizedBox(
          width: entry.level * 40,
        ),
        IconButton(
          iconSize: 24,
          onPressed: () {
            setState(() {
              isAdding = true;
              addedParent = parent;
            });
          },
          icon: const Icon(Icons.add),
          alignment: Alignment.topLeft,
        ),
        const SizedBox(
          width: 10,
        ),
        LayoutBuilder(builder: (context, constraints) {
          if (title == "семейств") {
            return Text("Добавить новое ${title}о");
          } else {
            return Text("Добавить новый ${title}");
          }
        })
      ]),
      isAdding && addedParent == parent
          ? Row(children: [
              SizedBox(
                width: entry.level * 40,
              ),
              SizedBox(
                width: 250,
                child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        label: Text("Название ${title}а"))),
              ),
              IconButton(
                  onPressed: () async {
                    if (_textEditingController.text.trim() == "") {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const AlertDialog(
                              title: Text('Ошибка'),
                              content: Text(
                                  "Поле пустое, пожалуйста, внимательно вводите даннные."),
                            );
                          });
                      return;
                    }
                    await addBaseModel(parent ?? FATHER,
                        _textEditingController.text, appState.token!);
                    appState.treeController.collapse(parent!);
                    appState.loadingModels.add(parent);
                    appState.notifyListeners();
                    var list = await topology[parent.type]!(parent);

                    appState.childrenTopologyMap[parent] = list
                        .where((element) =>
                            element.name != null &&
                            element.name!.trim().isNotEmpty)
                        .toList();
                    appState.loadingModels.remove(parent);
                    appState.treeController.expand(parent);
                    _textEditingController.text = "";
                  },
                  icon: const Icon(Icons.done))
            ])
          : const SizedBox()
    ]);
  }
}
