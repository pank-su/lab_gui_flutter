import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'collector.dart';

class CollectorDataSource extends DataGridSource {
  final List<Collector> collectors;

  CollectorDataSource(this.collectors);

  @override
  List<DataGridRow> get rows => collectors.map<DataGridRow>((collector) {
        return DataGridRow(
          cells: [
            DataGridCell<int>(columnName: 'id', value: collector.id),
            DataGridCell<String>(
                columnName: 'lastName', value: collector.lastName),
            DataGridCell<dynamic>(
                columnName: 'firstName', value: collector.firstName),
            DataGridCell<dynamic>(
                columnName: 'secondName', value: collector.secondName),
          ],
        );
      }).toList();

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: (dataGridCell.columnName == 'id')
              ? Alignment.centerRight
              : Alignment.centerLeft,
          padding: const EdgeInsets.all(16.0),
          child: Text((dataGridCell.value ?? "").toString()),
        );
      }).toList(),
    );
  }
}
