import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/screens/add_item_collection_dialog.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../my_app_state.dart';
import 'collection_item.dart';
import 'package:intl/intl.dart';

/// Источник данных для таблицы
class CollectionDataSource extends DataGridSource {
  BuildContext context;
  List<CollectionItem> collectionItems;
  final DateFormat formatter = DateFormat('dd.MM.yyyy');
  String filter = "";

  void updateCollectionItems(List<CollectionItem> collectionItems) {
    context = context;
    this.collectionItems = collectionItems;
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
              DataGridCell<DateTime?>(columnName: 'date', value: item.date),
              DataGridCell<bool?>(columnName: 'rna', value: item.rna),
              DataGridCell<String?>(columnName: 'comment', value: item.comment),
              DataGridCell<String?>(
                  columnName: 'collectors', value: item.collectors),
            ]))
        .toList();
  }

  CollectionDataSource({required this.collectionItems, required this.context}) {
    updateCollectionItems(collectionItems);
  }

  List<DataGridRow> _collectionItems = [];

  @override
  List<DataGridRow> get rows {
    if (filter.trim().isEmpty) {
      return _collectionItems;
    } else {
      return _collectionItems
          .where((element) => collectionItems[_collectionItems.indexOf(element)]
              .toString()
              .contains(filter))
          .toList();
    }
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    var appState = Provider.of<MyAppState>(context,
        listen: false); // Проcлушивание не нужно
    var collectionItem = appState.collection
        .firstWhere((element) => element.id == row.getCells().first.value);
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return ContextMenuRegion(
          contextMenu: GenericContextMenu(buttonConfigs: [
            ContextMenuButtonConfig("Изменить",
                onPressed: !appState.isAuth
                    ? null
                    : () {
                        appState.setSelectedCollectorsById(collectionItem.id);
                        appState.setTopologyByColId(collectionItem.id);
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AddCollectionItemDialog(
                                isUpdate: true,
                                updatableId: collectionItem.id,
                              );
                            });
                      }),
            ContextMenuButtonConfig("Экспортировать", onPressed: () {
              appState.exportToExcel();
            }),
            ContextMenuButtonConfig("Экспортировать выделенное", onPressed: () {
              appState.exportSelectedToExcel();
            })
          ]),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (dataGridCell.columnName == 'date') {
                if (dataGridCell.value == null) return Container();
                String formattedString;
                switch (collectionItem.dateType) {
                  case DateType.all:
                    formattedString = formatter.format(dataGridCell.value);
                    break;
                  case DateType.mounthAndYear:
                    formattedString =
                        DateFormat("MM.yyyy").format(dataGridCell.value);
                  case DateType.year:
                    formattedString =
                        DateFormat("yyyy").format(dataGridCell.value);
                }
                return Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.all(16.0),
                  child: Text(formattedString),
                );
              }
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
                if (collectionItem.hasFile ?? false) {
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
