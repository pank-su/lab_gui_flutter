import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/collector_data_source.dart';
import '../repository.dart';

class CollectorsPage extends StatefulWidget {
  const CollectorsPage({super.key});

  @override
  State<CollectorsPage> createState() => _CollectorsPageState();
}

class _CollectorsPageState extends State<CollectorsPage> {
  final List<GridColumn> columns = <GridColumn>[
    GridColumn(
      columnName: 'id',
      label: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerRight,
        child: const Text('ID'),
      ),
    ),
    GridColumn(
      columnName: 'last_name',
      width: 200,
      label: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text('Last Name'),
      ),
    ),
    GridColumn(
      columnName: 'first_name',
      width: 200,
      label: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text('First Name'),
      ),
    ),
    GridColumn(
      columnName: 'second_name',
      width: 200,
      label: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.centerLeft,
        child: const Text('Second Name'),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getCollectors(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SfDataGrid(
                source: CollectorDataSource(snapshot.data!), columns: columns);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
