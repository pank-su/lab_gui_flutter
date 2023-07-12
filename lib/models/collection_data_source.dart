import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/screens/add_item_collection_dialog.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../my_app_state.dart';
import 'collection_item.dart';
import 'package:intl/intl.dart';

class SearchedText extends StatelessWidget {
  final String defaultText;
  final String searchedText;

  const SearchedText({
    Key? key,
    required this.defaultText,
    required this.searchedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    if (searchedText.isEmpty) return Text(defaultText);
    var indices = <Match>[];
    int lastIndex = 0;
    while (lastIndex <= defaultText.length - searchedText.length) {
      int index = defaultText.indexOf(searchedText, lastIndex);
      if (index == -1) {
        break;
      }
      lastIndex = index + searchedText.length;
      indices.add(Match(index, lastIndex));
    }
    if (indices.isEmpty) return Text(defaultText);
    List<TextSpan> textSpans = [];
    if (indices.first.start > 0) {
      textSpans
          .add(TextSpan(text: defaultText.substring(0, indices.first.start)));
    }
    for (var i = 0; i < indices.length; i++) {
      textSpans.add(
        TextSpan(
          text: defaultText.substring(indices[i].start, indices[i].end),
          style: TextStyle(
              backgroundColor: theme.colorScheme.tertiaryContainer,
              color: theme.colorScheme.onTertiaryContainer),
        ),
      );
      if (i < indices.length - 1) {
        textSpans.add(
          TextSpan(
              text:
                  defaultText.substring(indices[i].end, indices[i + 1].start)),
        );
      }
    }
    if (indices.last.end < defaultText.length) {
      textSpans.add(TextSpan(text: defaultText.substring(indices.last.end)));
    }
    return RichText(
      text: TextSpan(children: textSpans),
    );
  }
}

class Match {
  final int start;
  final int end;

  Match(this.start, this.end);
}

/// Источник данных для таблицы
class CollectionDataSource extends DataGridSource {
  BuildContext context;
  List<CollectionItem> collectionItems;
  final DateFormat formatter = DateFormat('dd.MM.yyyy');

  void updateCollectionItems(List<CollectionItem> collectionItems) {
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
    buildFilter(filter);
  }

  CollectionDataSource({required this.collectionItems, required this.context}) {
    updateCollectionItems(collectionItems);
  }

  List<DataGridRow> _collectionItems = [];
  List<DataGridRow> _filteredCollectionItems = [];
  String filter = "";

  @override
  List<DataGridRow> get rows {
    return _filteredCollectionItems;
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    var appState = Provider.of<MyAppState>(context,
        listen: false); // Проcлушивание не нужно
    var collectionItem = collectionItems
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
                  child: SearchedText(
                    defaultText: formattedString,
                    searchedText: filter,
                  ),
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
                            SearchedText(
                              defaultText: dataGridCell.value?.toString() ?? '',
                              searchedText: filter,
                            )
                          ],
                        ),
                      ));
                } else {
                  return Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.all(16.0),
                    child: SearchedText(
                      defaultText: dataGridCell.value?.toString() ?? '',
                      searchedText: filter,
                    ),
                  );
                }
              }
              return Container(
                alignment: (dataGridCell.columnName == 'latitude' ||
                        dataGridCell.columnName == 'longitude')
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                padding: const EdgeInsets.all(16.0),
                child: SearchedText(
                  defaultText: dataGridCell.value?.toString() ?? '',
                  searchedText: filter,
                ),
              );
            },
          ));
    }).toList());
  }

  void buildFilter(String text) {
    filter = text;
    if (text.trim().isNotEmpty) {
      _filteredCollectionItems = _collectionItems
          .where((item) => collectionItems[_collectionItems.indexOf(item)]
              .toString()
              .contains(text))
          .toList();
      notifyListeners();
    } else {
      _filteredCollectionItems = _collectionItems;
      return;
    }
  }
}
