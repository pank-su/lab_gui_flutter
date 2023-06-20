import 'package:flutter/material.dart';

class ErrorIndicator extends StatefulWidget {
  // Действие при нажатии на кнопку повторения попытки
  final void Function() buttonFNC;

  const ErrorIndicator({super.key, required this.buttonFNC});
  @override
  State<ErrorIndicator> createState() => _ErrorIndicatorState();
}

class _ErrorIndicatorState extends State<ErrorIndicator> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
            width: 300,
            child: Text(
              "Подключение к серверу отсутствует, проверьте ваше подключение и повторите попытку.",
              textAlign: TextAlign.center,
            )),
        const SizedBox(
          height: 10,
        ),
        FilledButton(
            onPressed: widget.buttonFNC, child: const Text("Повторить попытку"))
      ],
    );
  }
}
