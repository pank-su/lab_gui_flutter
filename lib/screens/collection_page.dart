import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/collection_data_source.dart';
import '../repository.dart';

class CollectionPage extends StatelessWidget {
  final columns = [
    GridColumn(
      columnName: 'id',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerRight,
        child: Text('ID'),
      ),
    ),
    GridColumn(
      columnName: 'catalogueNumber',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Catalogue Number'),
      ),
    ),
    GridColumn(
      columnName: 'collectId',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Collect ID'),
      ),
    ),
    GridColumn(
      columnName: 'order',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Order'),
      ),
    ),
    GridColumn(
      columnName: 'family',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Family'),
      ),
    ),
    GridColumn(
      columnName: 'genus',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Genus'),
      ),
    ),
    GridColumn(
      columnName: 'species',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Species'),
      ),
    ),
    GridColumn(
      columnName: 'age',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Age'),
      ),
    ),
    GridColumn(
      columnName: 'gender',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Gender'),
      ),
    ),
    GridColumn(
      columnName: 'scientificInstitute',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Scientific Institute'),
      ),
    ),
    GridColumn(
      columnName: 'voucherId',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Voucher ID'),
      ),
    ),
    GridColumn(
      columnName: 'latitude',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerRight,
        child: Text('Latitude'),
      ),
    ),
    GridColumn(
      columnName: 'longitude',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerRight,
        child: Text('Longitude'),
      ),
    ),
    GridColumn(
      columnName: 'country',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Country'),
      ),
    ),
    GridColumn(
      columnName: 'region',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Region'),
      ),
    ),
    GridColumn(
      columnName: 'subregion',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Subregion'),
      ),
    ),
    GridColumn(
      columnName: 'geoComment',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Geo Comment'),
      ),
    ),
    GridColumn(
      columnName: 'date',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Date'),
      ),
    ),
    GridColumn(
      columnName: 'rna',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Date'),
      ),
    ),
    GridColumn(
      columnName: 'comment',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Date'),
      ),
    ),
    GridColumn(
      columnName: 'stringAgg',
      label: Container(
        padding: EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: Text('Date'),
      ),
    )
  ];

  @override
  Widget build(BuildContext context) {
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
