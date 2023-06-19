import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/screens/add_item_collection_dialog.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../my_app_state.dart';
import 'collection_item.dart';

/// Источник данных для таблицы
class CollectionDataSource extends DataGridSource {
  BuildContext context;
  final List<CollectionItem> collectionItems;

  void updateCollectionItems(List<CollectionItem> collectionItems) {
    context = context;
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
                  columnName: 'collectrors', value: item.collectors),
            ]))
        .toList();
  }

  CollectionDataSource({required this.collectionItems, required this.context}) {
    updateCollectionItems(collectionItems);
  }

  List<DataGridRow> _collectionItems = [];

  @override
  List<DataGridRow> get rows => _collectionItems;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    var appState = Provider.of<MyAppState>(context,
        listen: false); // Проcлушивание не нужно
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return ContextMenuRegion(
          contextMenu: GenericContextMenu(buttonConfigs: [
            ContextMenuButtonConfig("Изменить",
                onPressed: !appState.isAuth
                    ? null
                    : () {
                        var id = row.getCells().first.value as int;
                        appState.setSelectedCollectorsById(id);
                        appState.setTopologyByColId(id);
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AddCollectionItemDialog(
                                isUpdate: true,
                                updatableId: id,
                              );
                            });
                      })
          ]),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (dataGridCell.columnName == 'rna') {
                return Container(
                  alignment: Alignment.center,
                  child: Checkbox(
                    value: dataGridCell.value,
                    onChanged: null,
                  ),
                );
              }
              if (dataGridCell.columnName == 'id') {
                if (appState.collection
                        .firstWhere(
                            (element) => element.id == dataGridCell.value)
                        .hasFile ??
                    false) {
                  return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16.0),
                      child: Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.file_present),
                            Text(dataGridCell.value?.toString() ?? '')
                          ],
                        ),
                      ));
                } else {
                  return Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(dataGridCell.value?.toString() ?? ''),
                  );
                }
              }
              return Container(
                alignment: (dataGridCell.columnName == 'latitude' ||
                        dataGridCell.columnName == 'longitude')
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                padding: const EdgeInsets.all(16.0),
                child: Text(dataGridCell.value?.toString() ?? ''),
              );
            },
          ));
    }).toList());
  }
}
