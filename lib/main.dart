import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lab_gui_flutter/jwt.dart';
import 'package:lab_gui_flutter/repository.dart';
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
          home: MainPage()),
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
        page = CollectionPage();
        break;
      case 1:
        page = TopologyPage();
        break;
      case 2:
        page = CollectorsPage();
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
                  icon: Icon(Icons.menu),
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
                  icon: Icon(Icons.account_circle))
            ],
            title: const Text("Лаборатория геномики и палеогеномики")),
        body: Row(
          children: [
            SafeArea(
                child: Visibility(
                    visible: railVisible,
                    child: NavigationRail(
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

class AuthScreen extends StatelessWidget {
  const AuthScreen({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final jwt = box.read("jwt");
    if (jwt != null) {
      return LoginComponent(theme: theme);
    }else{
      return ProfileInfoComponent();
    }
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LoginComponent(theme: theme);
        } else {
          return Center(
            child: Column(children: [
              CircularProgressIndicator.adaptive(),
              Text("Загрузка информации")
            ]),
          );
        }
      },
      future: testRequest(jwt),
    );
  }
}

class LoginComponent extends StatelessWidget {
  const LoginComponent({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 75, right: 75),
      child: Column(children: [
        const Text("Введите ваш логин и пароль для входа в систему"),
        const SizedBox(
          height: 23,
        ),
        const TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Логин',
          ),
        ),
        const SizedBox(
          height: 23,
        ),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(
              border: OutlineInputBorder(), labelText: 'Пароль'),
        ),
        const SizedBox(
          height: 4,
        ),
        Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            child: Text(
                "Пароль, от вашего аккаунта вам может поменять или выдать администратор",
                style: theme.textTheme.bodySmall
                    ?.apply(color: theme.colorScheme.onSurfaceVariant))),
        const SizedBox(
          height: 24,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(onPressed: () {}, child: Text("Войти в аккаунт")),
        ),
      ]),
    );
  }
}

class ProfileInfoComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 40, right: 28),
      child: Column(children: [
        Container(alignment: Alignment.topCenter,
          width: 188,
          height: 188,
          child: ClipRRect(borderRadius: BorderRadius.circular(1000),
              child: Image(
                  image: NetworkImage(
                      "https://sun1.beeline-yaroslavl.userapi.com/s/v1/ig2/PrqTddqVrLQuv_zazUPZPnDeZ4H781yPMhpy67QzOY1-x_7xs1vCIs6goqEKfrloxQu_7iqONtMiF_7z-1bsMZKH.jpg?size=400x400&quality=95&crop=23,90,1266,1266&ava=1"))),
        )
      ]),
    );
  }
}

class CollectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("Коллекция");
  }
}

class TopologyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("Топология");
  }
}

class CollectorsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("Сборщики");
  }
}
