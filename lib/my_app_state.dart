import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:lab_gui_flutter/models/collection_data_source.dart';
import 'package:lab_gui_flutter/models/collector_data_source.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'models/base_model.dart';
import 'models/collection_item.dart';
import 'models/collector.dart';
import 'models/jwt.dart';
import 'repository.dart';

sealed class TableState {}

class Error extends TableState {}

class Loading extends TableState {}

class Loaded extends TableState {}

class MyAppState extends ChangeNotifier {
  // Авторизация
  var isAuth = false;
  String? token;

  final DataGridController collectionController = DataGridController();
  final DataGridController collectorController = DataGridController();
  List<CollectionItem> collection = List.empty(growable: true);
  List<Collector> collectors = List.empty(growable: true);
  late CollectionDataSource collectionDataSource;
  late CollectorDataSource collectorDataSource;

  // Добавление изменение
  BaseModel? selectedBaseModel;
  List<Collector> selectedCollectors = List.empty(growable: true);

  void start({required BuildContext context}) {
    collectionDataSource =
        CollectionDataSource(collectionItems: collection, context: context);
    collectorDataSource = CollectorDataSource(collectors, context);
    autoUpdate();
    checkToken();
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
  // TODO сделать isolate
  Future<void> checkToken() async {
    token = await SessionManager().get("token");
    if (token != null && token != "") {
      try {
        testRequest(token!);
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
    await SessionManager().set("token", token);
    isAuth = true;
    notifyListeners();
  }

  /// Выход пользователя
  // TODO добавить на сервер чёрный список токенов
  Future<void> logout() async {
    token = null;
    isAuth = false;
    await SessionManager().set("token", "");
    notifyListeners();
  }

  TableState state = Loading();

  // Для обновления всех таблиц
  bool get isRestart => state == Loading();

  Future<void> restartNow() async {
    state = Loading();
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
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
      await Future.delayed(const Duration(minutes: 15));
    }
  }
}
