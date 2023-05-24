import 'package:flutter/material.dart';

class AddCollector extends StatelessWidget{
  const AddCollector({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(title: Text("Добавление нового коллектора"), icon: Icon(Icons.add), content: Column(children: []),);
  }

}