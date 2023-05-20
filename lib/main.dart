import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:lab_gui_flutter/repository.dart';
import 'package:lab_gui_flutter/screens/auth.dart';
import 'package:lab_gui_flutter/screens/collection_page.dart';
import 'package:lab_gui_flutter/screens/collectors.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet_material3/side_sheet_material3.dart';

import 'color_schemes.g.dart';
import 'models/jwt.dart';
import 'screens/add_item_collection_dialog.dart';
import 'screens/topology_page.dart';

void main() {
  runApp(const MainApp());
}

class MyAppState extends ChangeNotifier {
  var isAuth = false;
  String? token;

  Future<void> checkToken() async {
    token = await SessionManager().get("token");
    if (token != null) {
      try {
        testRequest(token!);
        isAuth = true;
      } on Exception {
        SessionManager().set("token", null);
        isAuth = false;
      }
    }
    notifyListeners();
  }

  Future<void> auth(String login_, String password) async {
    Jwt jwt = await login(login_, password);
    token = jwt.token;
    await SessionManager().set("token", token);
    isAuth = true;
    notifyListeners();
  }

  Future<void> logout() async{
    token = null;
    isAuth = false;
    notifyListeners();
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = MyAppState();
    appState.checkToken();
    return ChangeNotifierProvider(
      create: (context) => appState,
      child: MaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          restorationScopeId: 'app',
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
    var appState = context.watch<MyAppState>();
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
                      leading: appState.isAuth
                          ? FloatingActionButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const AddCollectionItemDialog();
                                    });
                              },
                              child: const Icon(Icons.add),
                            )
                          : Container(),
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
