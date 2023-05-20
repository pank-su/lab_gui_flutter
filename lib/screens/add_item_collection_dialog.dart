import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lab_gui_flutter/repository.dart';
import 'package:intl/intl.dart';
import 'package:lab_gui_flutter/screens/topology_page.dart';

import '../models/voucher_institute.dart';

class AddCollectionItemDialog extends StatefulWidget {
  const AddCollectionItemDialog({super.key});

  @override
  State<AddCollectionItemDialog> createState() =>
      _AddCollectionItemDialogState();
}

enum Gender { Unknown, Male, Female }

enum Age { adult, subadult, juvenil, Unknown }

class _AddCollectionItemDialogState extends State<AddCollectionItemDialog> {
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

  final _textFieldKey = GlobalKey(); // FLUTTER багу два года, что за дела

  static String _displayStringForOption(VoucherInstitute option) => option.name;

  Future<void> getInfo() async {
    // Получение идентифакторов и другой посредственной информации
    var id = await getLastIdCollection() + 1;
    idController.text = id.toString();
    numberController.text = "ZIN-TER-M-${id + 4}";
    vauchInstitutes = await getVoucherInstitute();
  }

  Future<void> addNewItem() async {}

  @override
  void initState() {
    getInfo();
    dateController.text = dateFormat.format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var titleTextStyle =
        TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 22);
    return Dialog(
        insetPadding:
            const EdgeInsets.only(left: 92, right: 92, top: 80, bottom: 80),
        child: Container(
          margin: const EdgeInsets.all(14),
          child: Column(children: [
            Center(
              child: Text(
                "Добавление новой записи",
                style: titleTextStyle,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
                margin: const EdgeInsets.only(right: 74, left: 74),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(children: [
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
                            child: Text(
                                "Число генерируется самостоятельно по ID",
                                style: theme.textTheme.bodySmall
                                    ?.apply(color: theme.colorScheme.outline))),
                        const SizedBox(
                          height: 26,
                        ),
                        TextField(
                          controller: collectIdController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Collect ID'),
                        ),
                        const SizedBox(
                          height: 26,
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                                onPressed: () {showDialog(context: context, builder: (context){
                                  return Dialog(child: TopologyPage(selectableMode: true,));
                                });},
                                child: const Text(
                                  "Выбрать топологию",
                                ))),
                        const SizedBox(
                          height: 73,
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                                onPressed: () {},
                                child: const Text("Выбрать коллекторов"))),
                        const SizedBox(
                          height: 92,
                        )
                      ]),
                    ),
                    const SizedBox(
                      width: 57,
                    ),
                    Expanded(
                        child: Column(
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
                                        initialEntryMode:
                                            DatePickerEntryMode.input);
                                    if (date != null) {
                                      dateController.text =
                                          dateFormat.format(date);
                                    }
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
                                return vauchInstitutes.where((element) =>
                                    element.name
                                        .toLowerCase()
                                        .contains(value.text.toLowerCase()));
                              }
                              return vauchInstitutes;
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController
                                    fieldTextEditingController,
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
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down))),
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              final textFieldBox = _textFieldKey.currentContext!
                                  .findRenderObject() as RenderBox;
                              final textFieldWidth = textFieldBox.size.width;
                              return Material(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(4.0)),
                                  ),
                                  // Баг флаттера
                                  child: SizedBox(
                                      width: 200,
                                      child: ListView(
                                        padding: const EdgeInsets.all(8.0),
                                        children: options
                                            .map((VoucherInstitute option) =>
                                                GestureDetector(
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
                                border: OutlineInputBorder(),
                                labelText: 'Вауч. код')),
                        const SizedBox(
                          height: 22,
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Пол",
                              style: theme.textTheme.titleSmall
                                  ?.apply(fontWeightDelta: 2),
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
                              style: theme.textTheme.titleSmall
                                  ?.apply(fontWeightDelta: 2),
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
                    )),
                    const SizedBox(
                      width: 57,
                    ),
                    Expanded(
                        flex: 2,
                        child: Column(children: [
                          AspectRatio(
                              aspectRatio: 5 / 3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: FlutterMap(
                                    options: MapOptions(maxZoom: 15),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName: 'su.pank.su',
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
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'(^-?\d*\.?\d*)'))
                                      ],
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Широта'))),
                              const SizedBox(
                                width: 22,
                              ),
                              Expanded(
                                  child: TextField(
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'(^-?\d*\.?\d*)'))
                                      ],
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Долгота')))
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const Row(
                            children: [
                              Expanded(
                                  child: TextField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Страна'))),
                              SizedBox(
                                width: 22,
                              ),
                              Expanded(
                                  child: TextField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Регион'))),
                              SizedBox(
                                width: 22,
                              ),
                              Expanded(
                                  child: TextField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Субрегион')))
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const TextField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Комментарий к геопозиции'))
                        ]))
                  ],
                )),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 74),
                        child: const TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Комментарий')))),
                SizedBox(
                    width: 120,
                    child: ListTile(
                      title: const Text("RNA"),
                      leading: Checkbox(
                          value: _isRna,
                          onChanged: (val) {
                            setState(() {
                              _isRna = val!;
                            });
                          }),
                    )),
                FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text("Добавить"))
              ],
            ))
          ]),
        ));
  }
}
