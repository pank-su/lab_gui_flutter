import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/my_app_state.dart';
import 'package:lab_gui_flutter/repository.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

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

  var isLoadingNow = false;

  String? jwt;

  Future<void> authNow(MyAppState appState) async {
    setState(() {
      isLoadingNow = true;
    });
    try {
      await appState.auth(loginController.text, passwordController.text);
    } on Exception {
      isLoadingNow = false;
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Ошибка входа"),
              content: const Text("Неверный логин или пароль"),
              actions: [
                FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Понятно"))
              ],
            );
          });
    }
    setState(() {
      isLoadingNow = false;
    });
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final loginComponent = LoginComponent(
        theme: widget.theme,
        loginController: loginController,
        passwordController: passwordController,
        authNow: authNow);
    if (isLoadingNow) {
      return const CircularProgressIndicator();
    }
    if (!appState.isAuth) {
      return loginComponent;
    }
    return ProfileInfoComponent(
      appState: appState,
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
  final Future<void> Function(MyAppState) authNow;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
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
          decoration: const InputDecoration(
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
                authNow(appState);
              },
              child: const Text("Войти в аккаунт")),
        ),
      ]),
    );
  }
}

class ProfileInfoComponent extends StatefulWidget {
  const ProfileInfoComponent({super.key, required this.appState});

  final MyAppState appState;

  @override
  State<ProfileInfoComponent> createState() => _ProfileInfoComponentState();
}

class _ProfileInfoComponentState extends State<ProfileInfoComponent> {
  User? user;

  var isLoading = true;

  Future<void> getUserInfo(String token) async {
    try{
      user = await getUserInfoByToken(token);
    }on Exception{
      widget.appState.logout();
    }
    
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getUserInfo(widget.appState.token!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    if (isLoading == true) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
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
                      image: NetworkImage(user?.avatarUrl ??
                          "https://sun9-3.userapi.com/impg/GhqbifLL9RXukQi9AJ6SObwsLr-rQ2rDfYWLkg/qyxTl5xOlYU.jpg?size=188x188&quality=96&sign=1749242e0d43b4eaf90e28a74cec3cd9&type=album"))),
            ),
            Text(
              user?.login ?? "Unknown",
              style: theme.textTheme.headlineLarge,
            ),
            // Text("Имя", style: theme.textTheme.headlineLarge),
            Text(
              user?.role ?? "Unknown",
              style: theme.textTheme.labelLarge
                  ?.apply(color: theme.colorScheme.surfaceTint),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                  onPressed: () async {
                    appState.logout();
                  },
                  child: const Text("Выйти из аккаунта")),
            )
          ]),
    );
  }
}
