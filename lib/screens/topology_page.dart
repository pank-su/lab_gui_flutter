import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../models/base_model.dart';
import '../repository.dart';

class TopologyPage extends StatefulWidget {
  const TopologyPage({super.key});

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

  Map<BaseModel, List<BaseModel>> childrenMap = {};
  BaseModel father =
      BaseModel(id: 0, name: "father", type: BaseModelsTypes.father);

  var loadingModels = <BaseModel>[];

  Future<void> loadOrders() async {
    var orders = await getOrders();
    setState(() {
      childrenMap[father] = orders;
      treeController.roots = childrenProvider(father);
    });
  }

  @override
  void initState() {
    childrenMap[father] = [];

    treeController = TreeController(
        roots: childrenProvider(father), childrenProvider: childrenProvider);

    loadOrders();

    super.initState();
  }

  Iterable<BaseModel> childrenProvider(BaseModel baseModel) {
    return childrenMap[baseModel] ?? const Iterable.empty();
  }

  Widget getLeading(BaseModel baseModel) {
    if (loadingModels.contains(baseModel)) {
      return const CircularProgressIndicator();
    }

    late final VoidCallback? onPressed;
    late final bool? isOpen;

    final List<BaseModel>? children = childrenMap[baseModel];

    if (baseModel.name != null &&
        baseModel.type != BaseModelsTypes.kind &&
        children == null) {
      isOpen = false;
      onPressed = () async {
        setState(() {
          loadingModels.add(baseModel);
        });
        final list = await topology[baseModel.type]!(baseModel);
        childrenMap[baseModel] = list;
        loadingModels.remove(baseModel);
        treeController.expand(baseModel);
      };
    } else if (baseModel.type == BaseModelsTypes.kind) {
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

  @override
  Widget build(BuildContext context) {
    return AnimatedTreeView(
        treeController: treeController,
        nodeBuilder: (context, entry) {
          return TreeIndentation(
              entry: entry,
              child: Row(children: [
                getLeading(entry.node),
                Text(entry.node.name ?? "")
              ]));
        });
  }
}