import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lab_gui_flutter/repository.dart';
import 'package:lab_gui_flutter/screens/auth.dart';
import 'package:lab_gui_flutter/screens/collection_page.dart';
import 'package:lab_gui_flutter/screens/collectors.dart';
import 'package:provider/provider.dart';
import 'package:side_sheet_material3/side_sheet_material3.dart';

import 'color_schemes.g.dart';
import 'models/jwt.dart';
import 'screens/topology_page.dart';

void main() {
  runApp(const MainApp());
}

class MyAppState extends ChangeNotifier {
  final box = GetStorage();
  var isAuth = false;
  String? token;

  Future<void> checkToken() async {
    token = await SessionManager().get("token");
    print(token);
    if (token != null) {
      isAuth = true;
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

class AddCollectionItemDialog extends StatefulWidget {
  const AddCollectionItemDialog({super.key});

  @override
  State<AddCollectionItemDialog> createState() =>
      _AddCollectionItemDialogState();
}

enum Gender { Unknown, Male, Female }

enum Age { adult, subadult, juvenil, Unknown }

class _AddCollectionItemDialogState extends State<AddCollectionItemDialog> {
  var _gender = Gender.Unknown;
  var _age = Age.Unknown;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var titleTextStyle =
        TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 22);
    return Dialog(
        insetPadding:
            const EdgeInsets.only(left: 92, right: 92, top: 133, bottom: 133),
        child: Container(
          margin: const EdgeInsets.all(14),
          child: Column(children: [
            Center(
              child: Text(
                "Добавление новой записи",
                style: titleTextStyle,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
                margin: const EdgeInsets.only(right: 74, left: 74),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(children: [
                        const TextField(
                          enabled: false,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), labelText: 'ID'),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Container(
                            margin: const EdgeInsets.only(left: 16, right: 16),
                            child: Text("Число генерируется самостоятельно",
                                style: theme.textTheme.bodySmall
                                    ?.apply(color: theme.colorScheme.outline))),
                        const SizedBox(
                          height: 26,
                        ),
                        const TextField(
                          enabled: false,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Номер в каталоге'),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Container(
                            margin: const EdgeInsets.only(left: 16, right: 16),
                            child: Text(
                                "Число генерируется самостоятельно по ID",
                                style: theme.textTheme.bodySmall
                                    ?.apply(color: theme.colorScheme.outline))),
                        const SizedBox(
                          height: 26,
                        ),
                        const TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Collect ID'),
                        ),
                        const SizedBox(
                          height: 26,
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                                onPressed: () {},
                                child: const Text(
                                  "Выбрать топологию",
                                ))),
                        const SizedBox(
                          height: 73,
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                                onPressed: () {},
                                child: const Text("Выбрать коллекторов"))),
                        const SizedBox(
                          height: 92,
                        )
                      ]),
                    ),
                    const SizedBox(
                      width: 57,
                    ),
                    Expanded(
                        child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Дата сбора',
                              suffixIcon: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.today))),
                        ),
                        const SizedBox(
                          height: 22,
                        ),
                        TextField(
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Вауч. инст',
                              suffixIcon: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.keyboard_arrow_down))),
                        ),
                        const SizedBox(
                          height: 22,
                        ),
                        const TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Вауч. код')),
                        const SizedBox(
                          height: 22,
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Пол",
                              style: theme.textTheme.titleSmall
                                  ?.apply(fontWeightDelta: 2),
                              textAlign: TextAlign.left,
                            )),
                        Column(
                          children: [
                            // Если можно обойтись без лишних циклов, то обойдёмся
                            ListTile(
                              title: const Text("Неизвестный"),
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -3),
                              leading: Radio(
                                value: Gender.Unknown,
                                groupValue: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("Мужской"),
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -3),
                              leading: Radio(
                                value: Gender.Male,
                                groupValue: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("Женский"),
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -3),
                              leading: Radio(
                                value: Gender.Female,
                                groupValue: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Возраст",
                              style: theme.textTheme.titleSmall
                                  ?.apply(fontWeightDelta: 2),
                              textAlign: TextAlign.left,
                            )),
                        Column(
                          children: [
                            ListTile(
                              title: const Text("Неизвестный"),
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -3),
                              leading: Radio(
                                value: Age.Unknown,
                                groupValue: _age,
                                onChanged: (value) {
                                  setState(() {
                                    _age = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("adult"),
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -3),
                              leading: Radio(
                                value: Age.adult,
                                groupValue: _age,
                                onChanged: (value) {
                                  setState(() {
                                    _age = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("subadult"),
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -3),
                              leading: Radio(
                                value: Age.subadult,
                                groupValue: _age,
                                onChanged: (value) {
                                  setState(() {
                                    _age = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text("juvenil"),
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -3),
                              leading: Radio(
                                value: Age.juvenil,
                                groupValue: _age,
                                onChanged: (value) {
                                  setState(() {
                                    _age = value!;
                                  });
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    )),
                    const SizedBox(
                      width: 57,
                    ),
                    Expanded(
                        flex: 2,
                        child: Column(children: [
                          AspectRatio(
                              aspectRatio: 5 / 3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: FlutterMap(
                                    options: MapOptions(),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName: 'com.example.app',
                                      ),
                                    ]),
                              )),
                          const SizedBox(
                            height: 19,
                          ),
                          const Row(
                            children: [
                              Expanded(
                                  child: TextField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Широта'))),
                              SizedBox(
                                width: 22,
                              ),
                              Expanded(
                                  child: TextField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Долгота')))
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const Row(
                            children: [
                              Expanded(
                                  child: TextField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Страна'))),
                              SizedBox(
                                width: 22,
                              ),
                              Expanded(
                                  child: TextField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Регион'))),
                              SizedBox(
                                width: 22,
                              ),
                              Expanded(
                                  child: TextField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Субрегион')))
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const TextField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Комментарий к геопозиции'))
                        ]))
                  ],
                )),
          ]),
        ));
  }
}
