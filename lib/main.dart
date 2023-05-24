import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/my_app_state.dart';
import 'package:lab_gui_flutter/screens/auth.dart';
import 'package:lab_gui_flutter/screens/collection_page.dart';
import 'package:lab_gui_flutter/screens/collectors.dart';
//import 'package:lab_gui_flutter/web_settings.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet_material3/side_sheet_material3.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'color_schemes.g.dart';

import 'screens/add_item_collection_dialog.dart';
import 'screens/topology_page.dart';

void main() {
  if (kIsWeb){
    //webSet();
  }
  runApp(const MainApp());

}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = MyAppState();
    appState.autoUpdate();
    appState.checkToken();
    return ChangeNotifierProvider(
      create: (context) => appState,
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        restorationScopeId: 'app',
        darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
        home: const MainPage(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ru')],
      ),
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
    Widget dialog = const Dialog();
    

    switch (selectedIndex) {
      case 0:
        page = const CollectionPage();
        dialog = const AddCollectionItemDialog(isUpdate: false,);
        break;
      case 1:
        page = const TopologyPage(selectableMode: false,);
        break;
      case 2:
        page = const CollectorsPage(selectableMode: false);
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
                                      return dialog;
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
                            label: Text("Коллекторы"))
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
