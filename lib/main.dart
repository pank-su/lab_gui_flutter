import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/models/collection_data_source.dart';
import 'package:lab_gui_flutter/models/collector_data_source.dart';
import 'package:lab_gui_flutter/repository.dart';
import 'package:lab_gui_flutter/screens/auth.dart';
import 'package:lab_gui_flutter/screens/collection_page.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet_material3/side_sheet_material3.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'color_schemes.g.dart';
import 'screens/topology_page.dart';

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

class CollectorsPage extends StatefulWidget {
  const CollectorsPage({super.key});

  @override
  State<CollectorsPage> createState() => _CollectorsPageState();
}

class _CollectorsPageState extends State<CollectorsPage> {
  final List<GridColumn> columns = <GridColumn>[
  GridColumn(
    columnName: 'id',
    label: Container(
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.centerRight,
      child: Text('ID'),
    ),
  ),
  GridColumn(
    columnName: 'last_name',
    width: 200,
    label: Container(
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.centerLeft,
      child: Text('Last Name'),
    ),
  ),
  GridColumn(
    columnName: 'first_name',
    width: 200,
    label: Container(
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.centerLeft,
      child: Text('First Name'),
    ),
  ),
  GridColumn(
    columnName: 'second_name',
    width: 200,
    label: Container(
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.centerLeft,
      child: Text('Second Name'),
    ),
  ),
];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: getCollectors(), builder: (context, snapshot){
      if (snapshot.hasData){
        return SfDataGrid(source: CollectorDataSource(snapshot.data!), columns: columns);
      }else{
        return Center(child: CircularProgressIndicator());
      }
    });
  }
}
