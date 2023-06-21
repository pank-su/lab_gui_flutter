import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/models/collector.dart';
import 'package:lab_gui_flutter/screens/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../my_app_state.dart';
import 'error_indicator.dart';

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
      maximumWidth: 100,
      label: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerRight,
        child: const Text('ID'),
      ),
    ),
    GridColumn(
      columnName: 'lastName',
      label: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text('Фамилия'),
      ),
    ),
    GridColumn(
      columnName: 'firstName',
      label: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text('Имя'),
      ),
    ),
    GridColumn(
      columnName: 'secondName',
      label: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text('Отчетство'),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    appState.collectorDataSource.context = context;
    switch (appState.state) {
      case Error():
        return Center(child: ErrorIndicator(
          buttonFNC: () {
            appState.restartNow();
          },
        ));
      case Loading():
        return const LoadingIndicator();
      default:
        break;
    }

    return Stack(children: [
      LayoutBuilder(builder: (context, constraints) {
        return ContextMenuOverlay(
            child: SfDataGridTheme(
                data: SfDataGridThemeData(
                    headerColor: theme.colorScheme.primaryContainer,
                    selectionColor: theme.colorScheme.secondaryContainer),
                child: SfDataGrid(
                    columnWidthMode: ColumnWidthMode.fill,
                    allowFiltering: true,
                    allowSorting: true,
                    allowMultiColumnSorting: true,
                    controller: appState.collectorController,
                    selectionMode: SelectionMode.multiple,
                    source: appState.collectorDataSource,
                    columns: columns)));
      }),
      widget.selectableMode
          ? Container(
              margin: const EdgeInsets.all(70),
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: FilledButton(
                      onPressed: true
                          ? () {
                              appState.setSelectedCollectors(
                                  appState.collectorController.selectedRows);
                              Navigator.pop(context);
                            }
                          : null,
                      child: const Text("Подтвердить"))))
          : const Text("")
    ]);
  }
}
