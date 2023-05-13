import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'collection_item.dart';

class CollectionDataSource extends DataGridSource {
  CollectionDataSource({required List<CollectionItem> collectionItems}) {
    _collectionItems = collectionItems
        .map<DataGridRow>((item) => DataGridRow(cells: [
              DataGridCell<int?>(columnName: 'id', value: item.id),
              DataGridCell<String?>(
                  columnName: 'catalogueNumber', value: item.catalogueNumber),
              DataGridCell<String?>(
                  columnName: 'collectId', value: item.collectId),
              DataGridCell<String?>(columnName: 'order', value: item.order),
              DataGridCell<String?>(columnName: 'family', value: item.family),
              DataGridCell<String?>(columnName: 'genus', value: item.genus),
              DataGridCell<String?>(columnName: 'species', value: item.species),
              DataGridCell<String?>(columnName: 'age', value: item.age),
              DataGridCell<String?>(columnName: 'gender', value: item.gender),
              DataGridCell<String?>(
                  columnName: 'scientificInstitute',
                  value: item.scientificInstitute),
              DataGridCell<String?>(
                  columnName: 'voucherId', value: item.voucherId),
              DataGridCell<double?>(
                  columnName: 'latitude', value: item.latitude),
              DataGridCell<double?>(
                  columnName: 'longitude', value: item.longitude),
              DataGridCell<String?>(columnName: 'country', value: item.country),
              DataGridCell<String?>(columnName: 'region', value: item.region),
              DataGridCell<String?>(
                  columnName: 'subregion', value: item.subregion),
              DataGridCell<String?>(
                  columnName: 'geoComment', value: item.geoComment),
              DataGridCell<String?>(columnName: 'date', value: item.date),
              DataGridCell<bool?>(columnName: 'rna', value: item.rna),
              DataGridCell<String?>(columnName: 'comment', value: item.comment),
              DataGridCell<String?>(
                  columnName: 'stringAgg', value: item.stringAgg),
            ]))
        .toList();
  }

  List<DataGridRow> _collectionItems = [];

  @override
  List<DataGridRow> get rows => _collectionItems;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: (dataGridCell.columnName == 'id' ||
                dataGridCell.columnName == 'latitude' ||
                dataGridCell.columnName == 'longitude')
            ? Alignment.centerRight
            : Alignment.centerLeft,
        padding: EdgeInsets.all(16.0),
        child: Text(dataGridCell.value?.toString() ?? ''),
      );
    }).toList());
  }
}
