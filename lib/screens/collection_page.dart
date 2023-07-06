import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:lab_gui_flutter/screens/error_indicator.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../my_app_state.dart';
import 'loading_indicator.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late Map<String, double> columnWidthsCollection = {
    'id': double.nan,
    'catalogueNumber': 140,
    'collectId': 70,
    'order': 100,
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
    'date': 100,
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
          child: const Text(
            'ID',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      GridColumn(
        columnName: 'catalogueNumber',
        width: columnWidthsCollection['catalogueNumber']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Номер в каталоге',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      GridColumn(
        columnName: 'collectId',
        width: columnWidthsCollection['collectId']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Collect ID', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'order',
        width: columnWidthsCollection['order']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Отряд', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'family',
        width: columnWidthsCollection['family']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Семейство', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'genus',
        width: columnWidthsCollection['family']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Род', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'species',
        width: columnWidthsCollection['species']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Вид', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'age',
        width: columnWidthsCollection['age']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Возраст', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'gender',
        width: columnWidthsCollection['gender']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Пол', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'scientificInstitute',
        width: columnWidthsCollection['scientificInstitute']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child:
              const Text('Ваучерный институт', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'voucherId',
        width: columnWidthsCollection['voucherId']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Вауч. ID', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'latitude',
        width: columnWidthsCollection['latitude']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerRight,
          child: const Text('Latitude', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'longitude',
        width: columnWidthsCollection['longitude']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerRight,
          child: const Text('Longitude', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'country',
        width: columnWidthsCollection['country']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Страна', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'region',
        width: columnWidthsCollection['region']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Регион', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'subregion',
        width: columnWidthsCollection['subregion']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Суб. регион', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'geoComment',
        width: columnWidthsCollection['geoComment']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Гео-комментарий', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'date',
        width: columnWidthsCollection['date']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Дата', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'rna',
        width: columnWidthsCollection['rna']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('RNA', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'comment',
        width: columnWidthsCollection['comment']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Комментарий', overflow: TextOverflow.ellipsis),
        ),
      ),
      GridColumn(
        columnName: 'collectors',
        width: columnWidthsCollection['stringAgg']!,
        label: Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerLeft,
          child: const Text('Коллекторы', overflow: TextOverflow.ellipsis),
        ),
      )
    ];

    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    appState.collectionDataSource.context = context;

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
    // Здесь необходим LayoutBuilder,
    // потому что иначе flutter не видит обновлений и не хочет обновлять таблицу
    // при изменении размеров окна
    return LayoutBuilder(builder: (context, constraints) {
      return ContextMenuOverlay(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: SfDataGridTheme(
                  data: SfDataGridThemeData(
                      headerColor: theme.colorScheme.primaryContainer,
                      selectionColor: theme.colorScheme.secondaryContainer),
                  child: SfDataGrid(
                    key: appState.collectionKey,
                    controller: appState.collectionController,
                    frozenColumnsCount: 1,
                    columnWidthMode: ColumnWidthMode.auto,
                    columnWidthCalculationRange:
                        ColumnWidthCalculationRange.visibleRows,
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
                        columnWidthsCollection[details.column.columnName] =
                            details.width;
                      });
                      return true;
                    },
                    source: appState.collectionDataSource,
                  ))));
    });
  }
}
