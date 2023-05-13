import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../jwt.dart';
import '../repository.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final loginController = TextEditingController();

  final passwordController = TextEditingController();

  final box = GetStorage();

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  _future() async {
    return _memoizer
        .runOnce(() async => await (!isAuth ? testRequest(jwt!) : auth()));
  }

  var isAuth = false;

  String? jwt;

  void authNow() {
    setState(() {
      isAuth = true;
    });
  }

  Future<String> auth() async {
    Jwt jwt = await login(loginController.text, passwordController.text);
    print(jwt.token);
    box.write("jwt", jwt.token);
    setState(() {
      this.jwt = jwt.token;
    });
    await box.save();
    return "ok";
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      jwt = box.read("jwt");
    });

    final loginComponent = LoginComponent(
        theme: widget.theme,
        loginController: loginController,
        passwordController: passwordController,
        authNow: authNow);
    if (jwt == null && !isAuth) {
      return loginComponent;
    }
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return loginComponent;
        } else if (snapshot.hasData) {
          return ProfileInfoComponent();
        } else {
          return const Center(
            child: Column(children: [
              CircularProgressIndicator.adaptive(),
              SizedBox(
                height: 10,
              ),
              Text("Загрузка информации")
            ]),
          );
        }
      },
      future: _future(),
    );
  }
}

class LoginComponent extends StatelessWidget {
  const LoginComponent({
    super.key,
    required this.theme,
    required this.loginController,
    required this.passwordController,
    required this.authNow,
  });

  final ThemeData theme;
  final TextEditingController loginController;
  final TextEditingController passwordController;
  final void Function() authNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 75, right: 75),
      child: Column(children: [
        const Text("Введите ваш логин и пароль для входа в систему"),
        const SizedBox(
          height: 23,
        ),
        TextField(
          controller: loginController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Логин',
          ),
        ),
        const SizedBox(
          height: 23,
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
              border: OutlineInputBorder(), labelText: 'Пароль'),
        ),
        const SizedBox(
          height: 4,
        ),
        Container(
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
                "Пароль, от вашего аккаунта вам может поменять или выдать администратор",
                style: theme.textTheme.bodySmall
                    ?.apply(color: theme.colorScheme.onSurfaceVariant))),
        const SizedBox(
          height: 24,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
              onPressed: () {
                authNow();
              },
              child: Text("Войти в аккаунт")),
        ),
      ]),
    );
  }
}

class ProfileInfoComponent extends StatelessWidget {
  const ProfileInfoComponent({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(left: 40, right: 28),
      width: double.infinity,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.topCenter,
              width: 188,
              height: 188,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(1000),
                  child: Image(
                      image: NetworkImage(
                          "https://sun1.beeline-yaroslavl.userapi.com/s/v1/ig2/PrqTddqVrLQuv_zazUPZPnDeZ4H781yPMhpy67QzOY1-x_7xs1vCIs6goqEKfrloxQu_7iqONtMiF_7z-1bsMZKH.jpg?size=400x400&quality=95&crop=23,90,1266,1266&ava=1"))),
            ),
            Text(
              "Фамилия",
              style: theme.textTheme.headlineLarge,
            ),
            Text("Имя", style: theme.textTheme.headlineLarge),
            Text(
              "Должность",
              style: theme.textTheme.labelLarge
                  ?.apply(color: theme.colorScheme.surfaceTint),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                  onPressed: () {}, child: Text("Выйти из аккаунта")),
            )
          ]),
    );
  }
}
