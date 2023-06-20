import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/screens/add_collector_dialog.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'collector.dart';

class CollectorDataSource extends DataGridSource {
  BuildContext context;
  List<Collector> collectors;

  CollectorDataSource(this.collectors, this.context);

  @override
  List<DataGridRow> get rows => collectors.map<DataGridRow>((collector) {
        return DataGridRow(
          cells: [
            DataGridCell<int>(columnName: 'id', value: collector.id),
            DataGridCell<String>(
                columnName: 'lastName', value: collector.lastName),
            DataGridCell<String>(
                columnName: 'firstName', value: collector.firstName),
            DataGridCell<String>(
                columnName: 'secondName', value: collector.secondName),
          ],
        );
      }).toList();

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    var collectorId = row.getCells().first.value as int;
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return ContextMenuRegion(
            contextMenu: GenericContextMenu(buttonConfigs: [
              ContextMenuButtonConfig("Изменить", onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AddCollector(
                          isUpdate: true, updatableId: collectorId);
                    });
              })
            ]),
            child: Container(
              alignment: (dataGridCell.columnName == 'id')
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              padding: const EdgeInsets.all(16.0),
              child: Text((dataGridCell.value ?? "").toString()),
            ));
      }).toList(),
    );
  }
}
