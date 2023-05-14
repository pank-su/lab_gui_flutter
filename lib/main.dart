import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:lab_gui_flutter/models/base_model.dart';
import 'package:lab_gui_flutter/repository.dart';
import 'package:lab_gui_flutter/screens/auth.dart';
import 'package:lab_gui_flutter/screens/collection_page.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet_material3/side_sheet_material3.dart';

import 'color_schemes.g.dart';

void main() {
  runApp(const MainApp());
}

class MyAppState extends ChangeNotifier {}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme:
              ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
          home: const MainPage()),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var selectedIndex = 0;
  static const defaultElavation = 1.0;
  var railVisible = true;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var surfaceContainer = ElevationOverlay.applySurfaceTint(
        theme.colorScheme.surface,
        theme.colorScheme.surfaceTint,
        defaultElavation);

    Widget page;

    switch (selectedIndex) {
      case 0:
        page = const CollectionPage();
        break;
      case 1:
        page = const TopologyPage();
        break;
      case 2:
        page = const CollectorsPage();
        break;
      default:
        throw UnimplementedError("page not found");
    }

    return Scaffold(
        appBar: AppBar(
            backgroundColor: surfaceContainer,
            leading: Container(
                margin: const EdgeInsets.only(left: 13),
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    setState(() {
                      railVisible = !railVisible;
                    });
                  },
                )),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                  onPressed: () {
                    showModalSideSheet(context,
                        body: AuthScreen(theme: theme),
                        header: "Авторизация",
                        addActions: false,
                        addDivider: false,
                        addBackIconButton: true,
                        addCloseIconButton: true);
                  },
                  icon: const Icon(Icons.account_circle))
            ],
            title: const Text("Лаборатория геномики и палеогеномики")),
        body: Row(
          children: [
            SafeArea(
                child: Visibility(
                    visible: railVisible,
                    child: NavigationRail(
                      leading: FloatingActionButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const Dialog(
                                  child: Text("data"),
                                );
                              });
                        },
                        child: const Icon(Icons.add),
                      ),
                      selectedIndex: selectedIndex,
                      backgroundColor: surfaceContainer,
                      onDestinationSelected: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                      extended: false,
                      labelType: NavigationRailLabelType.all,
                      groupAlignment: 0,
                      destinations: const [
                        NavigationRailDestination(
                            icon: Icon(Icons.table_rows_outlined),
                            label: Text("Коллекция")),
                        NavigationRailDestination(
                            icon: Icon(Icons.account_tree_outlined),
                            label: Text("Топология")),
                        NavigationRailDestination(
                            icon: Icon(Icons.person_4_outlined),
                            label: Text("Сборщики"))
                      ],
                    ))),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Container(child: page),
            )
          ],
        ));
  }
}

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
      return CircularProgressIndicator();
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
    } else if (baseModel.type != BaseModelsTypes.kind) {
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
              child: Row(children: [
                getLeading(entry.node),
                Text(entry.node.name ?? "")
              ]),
              entry: entry);
        });
    ;
  }
}

class CollectorsPage extends StatelessWidget {
  const CollectorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Сборщики");
  }
}
