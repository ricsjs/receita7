import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;

class DataService {
  final ValueNotifier<List> tableStateNotifier = new ValueNotifier([]);
  var chaves = ["chave", "chave", "chave"];
  var colunas = ["Coluna", "Coluna", "Coluna"];

  void carregar(index) {
    var funcoes = [
      carregarCafe,
      carregarCervejas,
      carregarNacoes,
    ];

    funcoes[index]();
  }

  void PropCafe() {
    chaves = ["blend_name", "origin", "intensifier"];
    colunas = ["Nome", "Nacionalidade", "Intensidade"];
  }

  void PropCerveja() {
    chaves = ["name", "style", "ibu"];
    colunas = ["Nome", "Estilo", "IBU"];
  }

  void PropNacoes() {
    chaves = ["nationality", "language", "capital"];
    colunas = ["Nacionalidade", "Idioma", "Capital"];
  }

  Future<void> carregarCafe() async {
    PropCafe();

    var coffeeUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: 'api/coffee/random_coffee',
        queryParameters: {'size': '5'});

    print('carregarCafe #1 - antes do await');

    var jsonString = await http.read(coffeeUri);

    print('carregarCafe #2 - depois do await');

    var coffeeJson = jsonDecode(jsonString);

    tableStateNotifier.value = coffeeJson;
  }

  Future<void> carregarCervejas() async {
    PropCerveja();

    var beersUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: 'api/beer/random_beer',
        queryParameters: {'size': '5'});

    print('carregarCervejas #1 - antes do await');

    var jsonString = await http.read(beersUri);

    print('carregarCervejas #2 - depois do await');

    var beersJson = jsonDecode(jsonString);

    tableStateNotifier.value = beersJson;
  }

  Future<void> carregarNacoes() async {
    PropNacoes();

    var nationUri = Uri(
        scheme: 'https',
        host: 'random-data-api.com',
        path: 'api/nation/random_nation',
        queryParameters: {'size': '5'});

    print('carregarNacoes #1 - antes do await');

    var jsonString = await http.read(nationUri);

    print('carregarNacoes #2 - depois do await');

    var nationJson = jsonDecode(jsonString);

    tableStateNotifier.value = nationJson;
  }
}

final dataService = DataService();

void main() {
  MyApp app = MyApp();

  runApp(app);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Dicas"),
          ),
          body: ValueListenableBuilder(
              valueListenable: dataService.tableStateNotifier,
              builder: (_, value, __) {
                return DataTableWidget(
                  jsonObjects: value,
                  propertyNames: dataService.chaves,
                  columnNames: dataService.colunas,
                );
              }),
          bottomNavigationBar:
              NewNavBar(itemSelectedCallback: dataService.carregar),
        ));
  }
}

class NewNavBar extends HookWidget {
  var itemSelectedCallback; //esse atributo será uma função

  NewNavBar({this.itemSelectedCallback}) {
    itemSelectedCallback ??= (_) {};
  }

  @override
  Widget build(BuildContext context) {
    var state = useState(0);
    return BottomNavigationBar(
        onTap: (index) {
          state.value = index;
          print(state.value);
          itemSelectedCallback(index);
        },
        currentIndex: state.value,
        items: const [
          BottomNavigationBarItem(
            label: "Cafés",
            icon: Icon(Icons.coffee_outlined),
          ),
          BottomNavigationBarItem(
              label: "Cervejas", icon: Icon(Icons.local_drink_outlined)),
          BottomNavigationBarItem(
              label: "Nações", icon: Icon(Icons.flag_outlined))
        ]);
  }
}

class DataTableWidget extends StatelessWidget {
  final List jsonObjects;

  final List<String> columnNames;

  final List<String> propertyNames;

  DataTableWidget(
      {this.jsonObjects = const [],
      this.columnNames = const ["Coluna", "Coluna", "Coluna"],
      this.propertyNames = const ["name", "style", "ibu"]});

  @override
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: columnNames
          .map(
            (name) => DataColumn(
              label: Expanded(
                child: Text(
                  name,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          )
          .toList(),
      rows: jsonObjects
          .map(
            (obj) => DataRow(
              cells: propertyNames
                  .map(
                    (propName) => DataCell(
                      Text(obj[propName] ??
                          'Conteúdo vazio'), // Verificar e fornecer valor padrão para propriedades nulas
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
