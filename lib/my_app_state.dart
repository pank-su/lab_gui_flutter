import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:lab_gui_flutter/models/collection_data_source.dart';
import 'package:lab_gui_flutter/models/collector_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'models/base_model.dart';
import 'models/collection_item.dart';
import 'models/collector.dart';
import 'models/jwt.dart';
import 'repository.dart';

import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'dart:convert';
import 'dart:html';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

sealed class TableState {}

class Error extends TableState {}

class Loading extends TableState {}

class Loaded extends TableState {}

final BaseModel FATHER =
    BaseModel(id: 0, name: "father", type: BaseModelsTypes.father);

class MyAppState extends ChangeNotifier {
  // Авторизация
  var isAuth = false;
  String? token;

  final GlobalKey<SfDataGridState> collectionKey = GlobalKey<SfDataGridState>();

  final DataGridController collectionController = DataGridController();
  final DataGridController collectorController = DataGridController();
  List<CollectionItem> collection = List.empty(growable: true);
  List<Collector> collectors = List.empty(growable: true);
  late CollectionDataSource collectionDataSource;
  late CollectorDataSource collectorDataSource;

  Future<void> exportToExcel() async {
    final Workbook workbook = Workbook();
    final Worksheet worksheet = workbook.worksheets[0];
    collectionKey.currentState!.exportToExcelWorksheet(worksheet);
    final List<int> bytes = workbook.saveAsStream();
    AnchorElement(
        href:
            "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", "output.xlsx")
      ..click();
  }

  // Добавление изменение
  BaseModel? selectedBaseModel;
  List<Collector> selectedCollectors = List.empty(growable: true);

  void start({required BuildContext context}) {
    collectionDataSource =
        CollectionDataSource(collectionItems: collection, context: context);
    collectorDataSource = CollectorDataSource(collectors, context);
    autoUpdate();
    checkToken();
    childrenTopologyMap[FATHER] = [];
    treeController = TreeController(
        roots: childrenProvider(FATHER), childrenProvider: childrenProvider);
    loadOrders();
  }

  Future<void> resetSelected() async {
    selectedBaseModel = null;
    selectedCollectors = List.empty(growable: true);
  }

  /// Получение коллекторов по [id] записи коллекции
  Future<void> setSelectedCollectorsById(int id) async {
    selectedCollectors = await getCollectorsByColItemId(id);
    notifyListeners();
  }

  /// Получение топологии по [id] записи коллекции
  Future<void> setTopologyByColId(int id) async {
    var colItem = await getCollectionItemById(id);
    selectedBaseModel = await getBaseModelByNames(colItem.order ?? "",
        colItem.family ?? "", colItem.genus ?? "", colItem.species ?? "");
    notifyListeners();
  }

  /// Установка [selectedBaseModel]
  void setSelectedBaseModel(BaseModel? baseModel) {
    selectedBaseModel = baseModel;
    notifyListeners();
  }

  /// Передача выбранных строк ([collectorsRows]) из таблицы Коллекторы
  Future<void> setSelectedCollectors(List<DataGridRow> collectorsRows) async {
    var collectors = await getCollectors();
    selectedCollectors.clear();
    for (var el in collectorsRows) {
      selectedCollectors.add(collectors
          .firstWhere((element) => element.id == el.getCells().first.value));
    }
    notifyListeners();
  }

  /// Проверка токена на сервере
  Future<void> checkToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    if (token != null && token != "") {
      try {
        checkAuth(token!);
        isAuth = true;
      } on Exception {
        await logout();
      }
    }
    notifyListeners();
  }

  /// Авторизация пользователя по [login_] и [password]
  Future<void> auth(String login_, String password) async {
    Jwt jwt = await login(login_, password);
    token = jwt.token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token!);
    isAuth = true;
    notifyListeners();
    restartNow();
  }

  /// Выход пользователя
  // TODO добавить на сервер чёрный список токенов
  Future<void> logout() async {
    token = null;
    isAuth = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", "");
    notifyListeners();
    restartNow();
  }

  TableState state = Loading();

  // Для обновления всех таблиц
  bool get isRestart => state == Loading();

  Future<void> restartNow() async {
    state = Loading();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 20));
    resetSelected();
    try {
      collection = await getCollection();
      collectors = await getCollectors();
    } on Exception catch (e) {
      print(e);
      state = Error();
      notifyListeners();
      return;
    }

    collectorDataSource.collectors = collectors;
    collectionDataSource.updateCollectionItems(collection);
    collectionDataSource.notifyListeners();
    collectorDataSource.notifyListeners();
    finishRestart();
  }

  Future<void> finishRestart() async {
    state = Loaded();
    notifyListeners();
  }

  Future<void> autoUpdate() async {
    while (true) {
      restartNow();
      checkToken();
      await Future.delayed(const Duration(minutes: 15));
    }
  }

  Iterable<BaseModel> childrenProvider(BaseModel baseModel) {
    return childrenTopologyMap[baseModel] ?? const Iterable.empty();
  }

  late final TreeController<BaseModel> treeController;

  var loadingModels = <BaseModel>[];

  BaseModel? selectableBaseModel;

  Future<void> loadOrders() async {
    var orders = await getOrders();

    childrenTopologyMap[FATHER] = orders
        .where((element) =>
            element.name != null && element.name!.trim().isNotEmpty)
        .toList();
    treeController.roots = childrenProvider(FATHER);
  }

  Map<BaseModel, List<BaseModel>> childrenTopologyMap = {};
}
