import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lab_gui_flutter/my_app_state.dart';
import 'package:lab_gui_flutter/repository.dart';
import 'package:intl/intl.dart';
import 'package:lab_gui_flutter/screens/collectors_page.dart';
import 'package:lab_gui_flutter/screens/topology_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:osm_nominatim/osm_nominatim.dart';
import 'package:responsive_grid/responsive_grid.dart';

import '../models/voucher_institute.dart';

class AddCollectionItemDialog extends StatefulWidget {
  const AddCollectionItemDialog(
      {super.key, required this.isUpdate, this.updatableId});

  final bool isUpdate;
  final int? updatableId;

  @override
  State<AddCollectionItemDialog> createState() =>
      _AddCollectionItemDialogState();
}

enum Gender { Unknown, Male, Female }

enum Age { adult, subadult, juvenil, Unknown }

enum MapMode { point, polygon, notSet }

class _AddCollectionItemDialogState extends State<AddCollectionItemDialog> {
  bool isUpdate = false;

  var _gender = Gender.Unknown;
  var _age = Age.Unknown;
  var _isRna = false;
  List<VoucherInstitute> vauchInstitutes = [];
  var menuIsVisible = false;

  final idController = TextEditingController();
  final numberController = TextEditingController();
  final collectIdController = TextEditingController();
  final dateController = TextEditingController();
  final vauchController = TextEditingController();
  final vauchIDController = TextEditingController();
  final longtitudeController = TextEditingController();
  final latitudeController = TextEditingController();
  final countryController = TextEditingController();
  final regionController = TextEditingController();
  final subRegionController = TextEditingController();
  final geoCommentController = TextEditingController();
  final commentController = TextEditingController();
  final dateFormat = DateFormat("dd.MM.yyyy");

  // Работа с картой
  MapMode mapMode = MapMode.notSet;
  LatLng point = LatLng(59.938284, 30.302509);

  final _textFieldKey = GlobalKey(); // FLUTTER багу два года, что за дела

  static String _displayStringForOption(VoucherInstitute option) => option.name;

  Future<void> getInfo() async {
    // Получение идентифакторов и другой посредственной информации
    vauchInstitutes = await getVoucherInstitute();
    if (!widget.isUpdate) {
      var id = await getLastIdCollection() + 1;
      idController.text = id.toString();
      numberController.text = "ZIN-TER-M-$id";

      return;
    }
    var id = widget.updatableId!;
    idController.text = id.toString();
    var collectionItem = await getCollectionItemById(id);
    numberController.text = collectionItem.catalogueNumber ?? "";
    vauchController.text = collectionItem.scientificInstitute ?? "";
    vauchIDController.text = collectionItem.voucherId ?? "";
    latitudeController.text = collectionItem.latitude?.toString() ?? "";
    longtitudeController.text = collectionItem.longitude?.toString() ?? "";
    countryController.text = collectionItem.country ?? "";
    regionController.text = collectionItem.region ?? "";
    subRegionController.text = collectionItem.subregion ?? "";
    geoCommentController.text = collectionItem.geoComment ?? "";
    commentController.text = collectionItem.comment ?? "";
    _isRna = collectionItem.rna ?? false;
    setState(() {
      point = LatLng(collectionItem.latitude ?? point.latitude,
          collectionItem.longitude ?? point.longitude);
      if (collectionItem.latitude != null && collectionItem.longitude != null) {
        mapMode = MapMode.point;
        mapController.move(point, 10);
      }
    });

    var collectionDTO = await getCollectionDtoById(id);
    try {
      setState(() {
        _age = Age.values[collectionDTO.ageId ?? 0];
        _gender = Gender.values[collectionDTO.sexId ?? 0];
      });
    } on RangeError {
      // Если года неправильные
    }
  }

  final mapController = MapController();

  Future<void> setPointState() async {
    setState(() {
      mapMode = MapMode.point;
      point = LatLng(
        double.parse(latitudeController.text),
        double.parse(longtitudeController.text),
      );
    });
  }

  Future<void> getCountryInfo() async {
    final reverseSearchResult = await Nominatim.reverseSearch(
        lat: point.latitude, lon: point.longitude, language: "ru");
    countryController.text = reverseSearchResult.address?["country"];
    regionController.text = reverseSearchResult.address?["region"] ?? "";
    subRegionController.text = reverseSearchResult.address?["county"] ?? "";
  }

  Future<void> updateItem(MyAppState appState) async {
    String? pointStr;
    if (longtitudeController.text.trim() != "" ||
        latitudeController.text.trim() != "") {
      pointStr = "Point(${point.latitude} ${point.longitude})";
    }

    final topology = appState.selectedBaseModel?.getFullTopology();
    String? order;
    String? family;
    String? genus;
    String? kind;

    try {
      order = topology?[0];
      family = topology?[1];
      genus = topology?[2];
      kind = topology?[3];
    } on RangeError {
      // cool block
    }

    List<List<String>> collectors = List.empty(growable: true);
    for (var collector in appState.selectedCollectors) {
      collectors.add([
        collector.lastName ?? "",
        collector.firstName ?? "",
        collector.secondName ?? ""
      ]);
    }
    await updateCollection(
        col_id: widget.updatableId!,
        collectId: collectIdController.text.trim().isEmpty
            ? null
            : collectIdController.text.trim(),
        order: order,
        family: family,
        genus: genus,
        kind: kind,
        age: _age.name,
        sex: _gender.name,
        vauchInst: vauchController.text,
        vauchId: vauchIDController.text,
        point: pointStr,
        country: countryController.text.trim().isEmpty
            ? null
            : countryController.text.trim(),
        region: regionController.text.trim().isEmpty
            ? null
            : regionController.text.trim(),
        subregion: subRegionController.text.trim().isEmpty
            ? null
            : subRegionController.text.trim(),
        geocomment: geoCommentController.text.trim().isEmpty
            ? null
            : geoCommentController.text.trim(),
        dateCollect: dateController.text,
        comment: commentController.text.trim().isEmpty
            ? null
            : commentController.text.trim(),
        collectors: collectors,
        token: appState.token!,
        rna: _isRna);
    appState.restartNow();
  }

  Future<void> addNewItem(MyAppState appState) async {
    String? pointStr;
    if (longtitudeController.text.trim() != "" ||
        latitudeController.text.trim() != "") {
      pointStr = "Point(${point.latitude} ${point.longitude})";
    }

    final topology = appState.selectedBaseModel?.getFullTopology();
    String? order;
    String? family;
    String? genus;
    String? kind;

    try {
      order = topology?[0];
      family = topology?[1];
      genus = topology?[2];
      kind = topology?[3];
    } on RangeError {
      // cool block
    }

    List<List<String>> collectors = List.empty(growable: true);
    for (var collector in appState.selectedCollectors) {
      collectors.add([
        collector.lastName ?? "",
        collector.firstName ?? "",
        collector.secondName ?? ""
      ]);
    }
    await addCollection(
        collectId: collectIdController.text.trim().isEmpty
            ? null
            : collectIdController.text.trim(),
        order: order,
        family: family,
        genus: genus,
        kind: kind,
        age: _age.name,
        sex: _gender.name,
        vauchInst: vauchController.text,
        vauchId: vauchIDController.text,
        point: pointStr,
        country: countryController.text.trim().isEmpty
            ? null
            : countryController.text.trim(),
        region: regionController.text.trim().isEmpty
            ? null
            : regionController.text.trim(),
        subregion: subRegionController.text.trim().isEmpty
            ? null
            : subRegionController.text.trim(),
        geocomment: geoCommentController.text.trim().isEmpty
            ? null
            : geoCommentController.text.trim(),
        dateCollect: dateController.text,
        comment: commentController.text.trim().isEmpty
            ? null
            : commentController.text.trim(),
        collectors: collectors,
        token: appState.token!,
        rna: _isRna);
    appState.restartNow();
  }

  @override
  void initState() {
    getInfo();
    dateController.text = dateFormat.format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var theme = Theme.of(context);
    final titleTextStyle =
        TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 22);

    return Dialog(
        child: Container(
            margin: const EdgeInsets.only(top: 14),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child:
                        Text("Добавление новой записи", style: titleTextStyle),
                  ),
                  ResponsiveGridRow(
                    children: [
                      ResponsiveGridCol(
                        lg: 3,
                        md: 6,
                        sm: 12,
                        child: firstColumnInput(theme, context, appState),
                      ),
                      ResponsiveGridCol(
                          lg: 3,
                          md: 6,
                          sm: 12,
                          child: secondColumnInput(context, theme)),
                      ResponsiveGridCol(lg: 6, md: 12, child: inputGeo()),
                      ResponsiveGridCol(
                          lg: 12, child: addButton(appState, context))
                    ],
                  ),
                ],
              ),
            )));
  }

  Container addButton(MyAppState appState, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
            onPressed: () {
              if (widget.isUpdate) {
                updateItem(appState);
                Navigator.pop(context);
                return;
              }
              addNewItem(appState);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add),
            label: Text(widget.isUpdate ? "Обновить" : "Добавить")),
      ),
    );
  }

  Container inputGeo() {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: ListView(
        shrinkWrap: true,
        children: [
          AspectRatio(
              aspectRatio: 5 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: FlutterMap(
                    options: MapOptions(
                      initialCenter: point,
                      maxZoom: 15,
                      onSecondaryTap: (tapPosition, point) {
                        latitudeController.text = point.latitude.toString();
                        longtitudeController.text = point.longitude.toString();
                        setPointState();
                        getCountryInfo();
                      },
                    ),
                    mapController: mapController,
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'su.pank.su',
                      ),
                      MarkerLayer(
                        markers: mapMode == MapMode.point
                            ? [
                                Marker(
                                    point: point,
                                    child: const FlutterLogo())
                              ]
                            : [],
                      ),
                    ]),
              )),
          const SizedBox(
            height: 19,
          ),
          Row(
            children: [
              Expanded(
                  child: TextField(
                      keyboardType: TextInputType.number,
                      controller: latitudeController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'(^-?\d*\.?\d*)'))
                      ],
                      onEditingComplete: () {
                        if (countryController.text.isNotEmpty ||
                            regionController.text.isNotEmpty ||
                            subRegionController.text.isNotEmpty ||
                            latitudeController.text.isEmpty) {
                          return;
                        }
                        getCountryInfo();
                      },
                      onChanged: (value) {
                        if (countryController.text.isNotEmpty ||
                            regionController.text.isNotEmpty ||
                            subRegionController.text.isNotEmpty ||
                            longtitudeController.text.isEmpty) {
                          return;
                        }
                        setPointState();
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Широта'))),
              const SizedBox(
                width: 22,
              ),
              Expanded(
                  child: TextField(
                      keyboardType: TextInputType.number,
                      controller: longtitudeController,
                      onEditingComplete: () {
                        if (countryController.text.isNotEmpty ||
                            regionController.text.isNotEmpty ||
                            subRegionController.text.isNotEmpty ||
                            latitudeController.text.isEmpty) {
                          return;
                        }
                        getCountryInfo();
                      },
                      onChanged: (val) {
                        if (countryController.text.isNotEmpty ||
                            regionController.text.isNotEmpty ||
                            subRegionController.text.isNotEmpty ||
                            latitudeController.text.isEmpty) {
                          return;
                        }
                        setPointState();
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'(^-?\d*\.?\d*)'))
                      ],
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Долгота')))
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Expanded(
                  child: TextField(
                      controller: countryController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Страна'))),
              const SizedBox(
                width: 22,
              ),
              Expanded(
                  child: TextField(
                      controller: regionController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Регион'))),
              const SizedBox(
                width: 22,
              ),
              Expanded(
                  child: TextField(
                      controller: subRegionController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Субрегион')))
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          TextField(
              controller: geoCommentController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Комментарий к геопозиции'))
        ],
      ),
    );
  }

  // Нужно чуть-чуть исправить, некритично (ListView и сам по себе Column)
  Container firstColumnInput(
      ThemeData theme, BuildContext context, MyAppState appState) {
    return Container(
        padding: const EdgeInsets.only(left: 14, right: 14),
        child: ListView(shrinkWrap: true, children: [
          Column(
            children: [
              TextField(
                controller: idController,
                enabled: false,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'ID'),
              ),
              const SizedBox(
                height: 4,
              ),
              Container(
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  child: Text("Число генерируется самостоятельно",
                      style: theme.textTheme.bodySmall
                          ?.apply(color: theme.colorScheme.outline))),
              const SizedBox(
                height: 26,
              ),
              TextField(
                controller: numberController,
                enabled: false,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Номер в каталоге'),
              ),
              const SizedBox(
                height: 4,
              ),
              Container(
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  child: Text("Число генерируется самостоятельно по ID",
                      style: theme.textTheme.bodySmall
                          ?.apply(color: theme.colorScheme.outline))),
              const SizedBox(
                height: 26,
              ),
              TextField(
                controller: collectIdController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Collect ID'),
              ),
              const SizedBox(
                height: 26,
              ),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Dialog(
                                  child: TopologyPage(
                                selectableMode: true,
                              ));
                            });
                      },
                      child: const Text(
                        "Выбрать топологию",
                      ))),
              SizedBox(
                  height: 73,
                  child: Text(
                      appState.selectedBaseModel?.getFullTopology().join(" ") ??
                          "")),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return const Dialog(
                                child: CollectorsPage(
                                  selectableMode: true,
                                ),
                              );
                            }));
                      },
                      child: const Text("Выбрать коллекторов"))),
              SizedBox(
                  height: 92,
                  child: Text(appState.selectedCollectors
                      .map((e) => e.lastName)
                      .join(", ")))
            ],
          ),
        ]));
  }

  Container secondColumnInput(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: ListView(
        shrinkWrap: true,
        children: [
          TextField(
            controller: dateController,
            readOnly: true,
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Дата сбора',
                suffixIcon: IconButton(
                    onPressed: () async {
                      DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1700),
                          lastDate: DateTime.now(),
                          locale: const Locale('ru'),
                          initialEntryMode: DatePickerEntryMode.input);
                      dateController.text = dateFormat.format(date!);
                                        },
                    icon: const Icon(Icons.today))),
          ),
          const SizedBox(
            height: 22,
          ),
          RawAutocomplete<VoucherInstitute>(
              displayStringForOption: _displayStringForOption,
              optionsBuilder: (value) {
                if (!menuIsVisible) {
                  return const Iterable.empty();
                }
                if (value.text.isNotEmpty) {
                  return vauchInstitutes.where((element) => element.name
                      .toLowerCase()
                      .contains(value.text.toLowerCase()));
                }
                return vauchInstitutes;
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                return TextField(
                  key: _textFieldKey,
                  focusNode: fieldFocusNode,
                  controller: fieldTextEditingController,
                  onChanged: (value) {
                    setState(() {
                      menuIsVisible = value.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Вауч. инст',
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              menuIsVisible = !menuIsVisible;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_down))),
                );
              },
              // Существует баг с размером autocomplete, это попытка его исправить
              optionsViewBuilder: (context, onSelected, options) {
                final textFieldBox = _textFieldKey.currentContext!
                    .findRenderObject() as RenderBox;
                final textFieldWidth = textFieldBox.size.width;
                return Material(
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(4.0)),
                    ),
                    // Баг флаттера
                    child: SizedBox(
                        width: 200,
                        child: ListView(
                          padding: const EdgeInsets.all(8.0),
                          children: options
                              .map((VoucherInstitute option) => GestureDetector(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: ListTile(
                                      title: Text(option.name),
                                    ),
                                  ))
                              .toList(),
                        )));
              }),
          const SizedBox(
            height: 22,
          ),
          TextField(
              controller: vauchIDController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Вауч. код')),
          const SizedBox(
            height: 22,
          ),
          SizedBox(
              width: double.infinity,
              child: Text(
                "Пол",
                style: theme.textTheme.titleSmall?.apply(fontWeightDelta: 2),
                textAlign: TextAlign.left,
              )),
          Column(
            children: [
              // Если можно обойтись без лишних циклов, то обойдёмся
              ListTile(
                title: const Text("Неизвестный"),
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                leading: Radio(
                  value: Gender.Unknown,
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("Мужской"),
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                leading: Radio(
                  value: Gender.Male,
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("Женский"),
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                leading: Radio(
                  value: Gender.Female,
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
              )
            ],
          ),
          SizedBox(
              width: double.infinity,
              child: Text(
                "Возраст",
                style: theme.textTheme.titleSmall?.apply(fontWeightDelta: 2),
                textAlign: TextAlign.left,
              )),
          Column(
            children: [
              ListTile(
                title: const Text("Неизвестный"),
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                leading: Radio(
                  value: Age.Unknown,
                  groupValue: _age,
                  onChanged: (value) {
                    setState(() {
                      _age = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("adult"),
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                leading: Radio(
                  value: Age.adult,
                  groupValue: _age,
                  onChanged: (value) {
                    setState(() {
                      _age = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("subadult"),
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                leading: Radio(
                  value: Age.subadult,
                  groupValue: _age,
                  onChanged: (value) {
                    setState(() {
                      _age = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text("juvenil"),
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                leading: Radio(
                  value: Age.juvenil,
                  groupValue: _age,
                  onChanged: (value) {
                    setState(() {
                      _age = value!;
                    });
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
