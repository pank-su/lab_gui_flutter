import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/collection_data_source.dart';
import '../my_app_state.dart';
import '../repository.dart';
import 'loading_indicator.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late Map<String, double> columnWidthsCollection = {
    'id': double.nan,
    'catalogueNumber': double.nan,
    'collectId': double.nan,
    'order': double.nan,
    'family': double.nan,
    'genus': double.nan,
    'species': double.nan,
    'age': double.nan,
    'gender': double.nan,
    'scientificInstitute': double.nan,
    'voucherId': double.nan,
    'latitude': double.nan,
    'longitude': double.nan,
    'country': double.nan,
    'region': double.nan,
    'subregion': double.nan,
    'geoComment': double.nan,
    'date': double.nan,
    'rna': double.nan,
    'comment': double.nan,
    'stringAgg': double.nan,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final columns = [
      GridColumn(
        columnName: 'id',
        width: columnWidthsCollection['id']!,
        minimumWidth: 100,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerRight,
          child: const Text('ID'),
        ),
      ),
      GridColumn(
        columnName: 'catalogueNumber',
        width: columnWidthsCollection['catalogueNumber']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Номер в каталоге'),
        ),
      ),
      GridColumn(
        columnName: 'collectId',
        width: columnWidthsCollection['collectId']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Collect ID'),
        ),
      ),
      GridColumn(
        columnName: 'order',
        width: columnWidthsCollection['order']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Отряд'),
        ),
      ),
      GridColumn(
        columnName: 'family',
        width: columnWidthsCollection['family']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Семейство'),
        ),
      ),
      GridColumn(
        columnName: 'genus',
        width: columnWidthsCollection['family']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Род'),
        ),
      ),
      GridColumn(
        columnName: 'species',
        width: columnWidthsCollection['species']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Вид'),
        ),
      ),
      GridColumn(
        columnName: 'age',
        width: columnWidthsCollection['age']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Возраст'),
        ),
      ),
      GridColumn(
        columnName: 'gender',
        width: columnWidthsCollection['gender']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Пол'),
        ),
      ),
      GridColumn(
        columnName: 'scientificInstitute',
        width: columnWidthsCollection['scientificInstitute']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Ваучерный институт'),
        ),
      ),
      GridColumn(
        columnName: 'voucherId',
        width: columnWidthsCollection['voucherId']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Вауч. ID'),
        ),
      ),
      GridColumn(
        columnName: 'latitude',
        width: columnWidthsCollection['latitude']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerRight,
          child: const Text('Latitude'),
        ),
      ),
      GridColumn(
        columnName: 'longitude',
        width: columnWidthsCollection['longitude']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerRight,
          child: const Text('Longitude'),
        ),
      ),
      GridColumn(
        columnName: 'country',
        width: columnWidthsCollection['country']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Страна'),
        ),
      ),
      GridColumn(
        columnName: 'region',
        width: columnWidthsCollection['region']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Регион'),
        ),
      ),
      GridColumn(
        columnName: 'subregion',
        width: columnWidthsCollection['subregion']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Суб. регион'),
        ),
      ),
      GridColumn(
        columnName: 'geoComment',
        width: columnWidthsCollection['geoComment']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Гео-комментарий'),
        ),
      ),
      GridColumn(
        columnName: 'date',
        width: columnWidthsCollection['date']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Дата'),
        ),
      ),
      GridColumn(
        columnName: 'rna',
        width: columnWidthsCollection['rna']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('RNA'),
        ),
      ),
      GridColumn(
        columnName: 'comment',
        width: columnWidthsCollection['comment']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Комментарий'),
        ),
      ),
      GridColumn(
        columnName: 'stringAgg',
        width: columnWidthsCollection['stringAgg']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Авторы'),
        ),
      )
    ];

    var appState = context.watch<MyAppState>();
    appState.collectionDataSource.context = context;

    if (appState.isRestart || appState.collection.isEmpty) {
      return const LoadingIndicator();
    }

    return ContextMenuOverlay(
        child: SfDataGrid(
      controller: appState.collectionController,
      //allowFiltering: true,
      frozenColumnsCount: 1,
      columnWidthMode: ColumnWidthMode.auto,
      columnWidthCalculationRange: ColumnWidthCalculationRange.visibleRows,
      selectionMode: SelectionMode.multiple,
      allowColumnsResizing: true,
      allowFiltering: true,
      allowSorting: true,
      allowMultiColumnSorting: true,
      columnResizeMode: ColumnResizeMode.onResizeEnd,
      isScrollbarAlwaysShown: true,
      columns: columns,
      onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
        if (details.width < 30) {
          return false;
        }
        setState(() {
          columnWidthsCollection[details.column.columnName] = details.width;
        });
        return true;
      },
      source: appState.collectionDataSource,
    ));
  }
}
