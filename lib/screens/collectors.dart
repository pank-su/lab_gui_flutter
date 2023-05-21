import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/models/collector.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../main.dart';
import '../models/collector_data_source.dart';
import '../repository.dart';

class CollectorsPage extends StatefulWidget {
  const CollectorsPage({super.key, required this.selectableMode});

  final bool selectableMode;

  @override
  State<CollectorsPage> createState() => _CollectorsPageState();
}

class _CollectorsPageState extends State<CollectorsPage> {
  List<Collector> selectedCollectors = List.empty(growable: true);

  final List<GridColumn> columns = <GridColumn>[
    GridColumn(
      columnName: 'id',
      label: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerRight,
        child: const Text('ID'),
      ),
    ),
    GridColumn(
      columnName: 'last_name',
      width: 200,
      label: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text('Last Name'),
      ),
    ),
    GridColumn(
      columnName: 'first_name',
      width: 200,
      label: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text('First Name'),
      ),
    ),
    GridColumn(
      columnName: 'second_name',
      width: 200,
      label: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text('Second Name'),
      ),
    ),
  ];

  final DataGridController _dataGridController = DataGridController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Stack(children: [
      FutureBuilder(
          future: getCollectors(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SfDataGrid(
                  controller: _dataGridController,
                  selectionMode: SelectionMode.multiple,
                  source: CollectorDataSource(snapshot.data!),
                  columns: columns);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
      widget.selectableMode
          ? Container(
              margin: const EdgeInsets.all(70),
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: FilledButton(
                      onPressed: true
                          ? () {
                              appState
                                  .setSelectedCollectors(_dataGridController.selectedRows);
                              Navigator.pop(context);
                            }
                          : null,
                      child: const Text("Подтвердить"))))
          : const Text("")
    ]);
  }
}
