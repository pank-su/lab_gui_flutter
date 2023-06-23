import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:lab_gui_flutter/my_app_state.dart';
import 'package:lab_gui_flutter/screens/add_topology_dialog.dart';
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
  late final TreeController<BaseModel> treeController;

  Map<BaseModel, List<BaseModel>> childrenTopologyMap = {};
  BaseModel father =
      BaseModel(id: 0, name: "father", type: BaseModelsTypes.father);

  var loadingModels = <BaseModel>[];

  BaseModel? selectableBaseModel;

  Future<void> loadOrders() async {
    var orders = await getOrders();
    setState(() {
      childrenTopologyMap[father] = orders
          .where((element) =>
              element.name != null && element.name!.trim().isNotEmpty)
          .toList();
      treeController.roots = childrenProvider(father);
    });
  }

  @override
  void initState() {
    childrenTopologyMap[father] = [];

    treeController = TreeController(
        roots: childrenProvider(father), childrenProvider: childrenProvider);

    loadOrders();

    super.initState();
  }

  Iterable<BaseModel> childrenProvider(BaseModel baseModel) {
    return childrenTopologyMap[baseModel] ?? const Iterable.empty();
  }

  Widget getLeading(BaseModel baseModel) {
    if (loadingModels.contains(baseModel)) {
      return const CircularProgressIndicator();
    }

    late final VoidCallback? onPressed;
    late final bool? isOpen;

    final List<BaseModel>? children = childrenTopologyMap[baseModel];

    if (baseModel.name != null &&
        baseModel.type != BaseModelsTypes.kind &&
        children == null) {
      isOpen = false;
      onPressed = () async {
        setState(() {
          loadingModels.add(baseModel);
        });
        var list = await topology[baseModel.type]!(baseModel);

        childrenTopologyMap[baseModel] = list
            .where((element) =>
                element.name != null && element.name!.trim().isNotEmpty)
            .toList();
        loadingModels.remove(baseModel);
        treeController.expand(baseModel);
      };
    } else if (baseModel.type == BaseModelsTypes.kind ||
        baseModel.name == null ||
        children!.isEmpty) {
      isOpen = null;
      onPressed = null;
    } else {
      isOpen = treeController.getExpansionState(baseModel);
      onPressed = () => treeController.toggleExpansion(baseModel);
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
        selectableBaseModel = appState.selectedBaseModel;
        firstSelect = true;
      });
    }

    return Stack(children: [
      AnimatedTreeView(
          treeController: treeController,
          nodeBuilder: (context, entry) {
            var parent = entry.node.type == BaseModelsTypes.order
                ? father
                : entry.node.parent;

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
                                color: selectableBaseModel != null &&
                                        selectableBaseModel! == entry.node
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : Colors.transparent,
                                child: GestureDetector(
                                  child: Text(entry.node.name ?? ""),
                                  onTap: () {
                                    setState(() {
                                      selectableBaseModel = entry.node;
                                    });
                                  },
                                ))
                            : Text(entry.node.name ?? "")
                      ],
                    )),
                appState.isAuth &&
                        childrenTopologyMap[parent]!.indexOf(entry.node) ==
                            childrenTopologyMap[parent]!.length - 1
                    ? Row(children: [
                        SizedBox(
                          width: entry.level * 40,
                        ),
                        IconButton(
                          iconSize: 24,
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AddTopologyDialog(
                                    selectedBaseModel: parent,
                                  );
                                });
                          },
                          icon: const Icon(Icons.add),
                          alignment: Alignment.topLeft,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        LayoutBuilder(builder: (context, constraints) {
                          switch (entry.node.type) {
                            case BaseModelsTypes.order:
                              return const Text("Добавить новый отряд");
                            case BaseModelsTypes.family:
                              return const Text("Добавить новое семейство");
                            case BaseModelsTypes.genus:
                              return const Text("Добавить новый род");
                            case BaseModelsTypes.kind:
                              return const Text("Добавить новый вид");
                            case BaseModelsTypes.father:
                              return const Text(
                                  "Вы программист?"); // Этот пункт никогда не должен быть использован
                          }
                        })
                      ])
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
                      onPressed: selectableBaseModel != null
                          ? () {
                              appState
                                  .setSelectedBaseModel(selectableBaseModel);
                              Navigator.pop(context);
                            }
                          : null,
                      child: const Text("Подтвердить"))))
          : const Text("")
    ]);
  }
}
