import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

const request = "https://api.hgbrasil.com/finance?key=91f097e0";

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
          color: Colors.white,
        )))),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final usdController = TextEditingController();
  final eurController = TextEditingController();
  double usd, eur;

  void _clearAll() {
    realController.text = '';
    usdController.text = '';
    eurController.text = '';
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    usdController.text = (real / usd).toStringAsFixed(2);
    eurController.text = (real / eur).toStringAsFixed(2);
  }

  void _usdChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double usd = double.parse(text);
    realController.text = (this.usd * usd).toStringAsFixed(2);
    eurController.text = (usd * this.usd / eur).toStringAsFixed(2);
  }

  void _eurChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double eur = double.parse(text);
    realController.text = (eur * this.eur).toStringAsFixed(2);
    usdController.text = (eur * this.eur / usd).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
            ),
            onPressed: _clearAll,
          )
        ],
        title: Text('\$Conversor\$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    'Carregando dados',
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar dados',
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  usd = snapshot.data['results']['currencies']['USD']['buy'];
                  eur = snapshot.data['results']['currencies']['EUR']['buy'];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.attach_money,
                          size: 150,
                          color: Colors.amber,
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                        ),
                        buildTextField(
                            'Reais', 'R\$ ', realController, _realChanged),
                        Divider(
                          height: 30.0,
                        ),
                        buildTextField(
                            'Dólares', 'US\$ ', usdController, _usdChanged),
                        Divider(
                          height: 30.0,
                        ),
                        buildTextField(
                            'Euros', 'EUR ', eurController, _eurChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25),
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
