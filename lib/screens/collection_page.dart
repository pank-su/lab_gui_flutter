import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/collection_data_source.dart';
import '../repository.dart';

class CollectionPage extends StatefulWidget {
  CollectionPage({super.key});

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
  Widget build(BuildContext context) {
    final columns = [
      GridColumn(
        columnName: 'id',
        width: columnWidthsCollection['id']!,
        minimumWidth: 100,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerRight,
          child: Text('ID'),
        ),
      ),
      GridColumn(
        columnName: 'catalogueNumber',
        width: columnWidthsCollection['catalogueNumber']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Номер в каталоге'),
        ),
      ),
      GridColumn(
        columnName: 'collectId',
        width: columnWidthsCollection['collectId']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Collect ID'),
        ),
      ),
      GridColumn(
        columnName: 'order',
        width: columnWidthsCollection['order']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Отряд'),
        ),
      ),
      GridColumn(
        columnName: 'family',
        width: columnWidthsCollection['family']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Семейство'),
        ),
      ),
      GridColumn(
        columnName: 'genus',
        width: columnWidthsCollection['family']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Род'),
        ),
      ),
      GridColumn(
        columnName: 'species',
        width: columnWidthsCollection['species']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Вид'),
        ),
      ),
      GridColumn(
        columnName: 'age',
        width: columnWidthsCollection['age']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Возраст'),
        ),
      ),
      GridColumn(
        columnName: 'gender',
        width: columnWidthsCollection['gender']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Пол'),
        ),
      ),
      GridColumn(
        columnName: 'scientificInstitute',
        width: columnWidthsCollection['scientificInstitute']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Ваучерный институт'),
        ),
      ),
      GridColumn(
        columnName: 'voucherId',
        width: columnWidthsCollection['voucherId']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Вауч. ID'),
        ),
      ),
      GridColumn(
        columnName: 'latitude',
        width: columnWidthsCollection['latitude']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerRight,
          child: Text('Latitude'),
        ),
      ),
      GridColumn(
        columnName: 'longitude',
        width: columnWidthsCollection['longitude']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerRight,
          child: Text('Longitude'),
        ),
      ),
      GridColumn(
        columnName: 'country',
        width: columnWidthsCollection['country']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Страна'),
        ),
      ),
      GridColumn(
        columnName: 'region',
        width: columnWidthsCollection['region']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Регион'),
        ),
      ),
      GridColumn(
        columnName: 'subregion',
        width: columnWidthsCollection['subregion']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Суб. регион'),
        ),
      ),
      GridColumn(
        columnName: 'geoComment',
        width: columnWidthsCollection['geoComment']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Гео-комментарий'),
        ),
      ),
      GridColumn(
        columnName: 'date',
        width: columnWidthsCollection['date']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Дата'),
        ),
      ),
      GridColumn(
        columnName: 'rna',
        width: columnWidthsCollection['rna']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('RNA'),
        ),
      ),
      GridColumn(
        columnName: 'comment',
        width: columnWidthsCollection['comment']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Комментарий'),
        ),
      ),
      GridColumn(
        columnName: 'stringAgg',
        width: columnWidthsCollection['stringAgg']!,
        label: Container(
          padding: EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: Text('Авторы'),
        ),
      )
    ];

    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SfDataGrid(
              frozenColumnsCount: 1,
              columnWidthMode: ColumnWidthMode.auto,
              columnWidthCalculationRange:
                  ColumnWidthCalculationRange.visibleRows,
              selectionMode: SelectionMode.multiple,
              allowColumnsResizing: true,
              columnResizeMode: ColumnResizeMode.onResizeEnd,
              onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                if (details.width < 30) {
                  return false;
                }
                setState(() {
                  columnWidthsCollection[details.column.columnName] =
                      details.width;
                });
                return true;
              },
              source: CollectionDataSource(collectionItems: snapshot.data!),
              columns: columns);
        } else {
          return const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text("Подождите, происходит загрузка данных...")
              ]));
        }
      },
      future: getCollection(),
    );
  }
}
