import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() async {
  runApp(
    MaterialApp(
        home: Home(),
        theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white)),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final coinController = TextEditingController();
  Map currencies;
  Map coin;
  Map values = {'BTC': 1, 'ETH': 1, 'LTC': 1};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                    icon: ImageIcon(
                      AssetImage('assets/bitcoin.png'),
                      size: 30,
                      color: Colors.white,
                    ),
                    child: Text('Bitcoin')),
                Tab(
                    icon: ImageIcon(
                      AssetImage('assets/ethereum.png'),
                      size: 30,
                      color: Colors.white,
                    ),
                    child: Text('Ethereum')),
                Tab(
                    icon: ImageIcon(
                      AssetImage('assets/litecoin.png'),
                      size: 30,
                      color: Colors.white,
                    ),
                    child: Text('Litecoin')),
              ],
            ),
            title: Text('Cotação de Coins'),
          ),
          body: TabBarView(
            children: [
              new Container(
                // color: Colors.blueGrey,
                child: new Center(
                  child: projectWidget('BitCoin', 'BTC'),
                ),
              ),
              new Container(
                // color: Colors.blueGrey,
                child: new Center(
                  child: projectWidget('Ethereum', 'ETH'),
                ),
              ),
              new Container(
                // color: Colors.teal,
                child: new Center(
                  child: projectWidget('Litecoin', 'LTC'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map> getCurrency(String currency) async {
    var request_currency =
        "https://hibots.com.br/hgbrasil/currencies.json?format=json&key=bd2c8b49";
    http.Response response_currency = await http.get(request_currency);

    var request_coin =
        "https://www.mercadobitcoin.net/api/" + currency + "/ticker/";
    http.Response response_coin = await http.get(request_coin);

    return {
      'coin': json.decode(response_coin.body)['ticker'],
      'currencies': json.decode(response_currency.body)['results']['currencies']
    };
  }

  Widget buildWaitingScreen() {
    return Center(
      child: Text(
        "Carregando Dados!",
        style: TextStyle(
          color: Colors.amber,
          fontSize: 25,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildErrorScreen() {
    return Center(
      child: Text(
        "Erro =(",
        style: TextStyle(
          color: Colors.amber,
          fontSize: 25,
        ),
      ),
    );
  }

  Widget buildFinalScreen(textfields) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: textfields,
        ));
  }

  Widget projectWidget(String name, String currency) {
    return FutureBuilder(
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return buildWaitingScreen();
          case ConnectionState.done:
            coin = snapshot.data['coin'];
            currencies = snapshot.data['currencies'];
            currencies.remove('source');
            currencies.remove('BTC');
            List<String> keys = currencies.keys.toList();
            // print(keys[0]);
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  TextField(
                    controller: coinController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Valor'),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          values[currency] = double.parse(coinController.text);
                          _listView(currencies, keys,
                              double.parse(coinController.text), currency);
                          print(coinController.text);
                          _dispose();
                        });
                      },
                      child: Text('OK')),
                  _listView(currencies, keys, 1.0, currency),
                ],
              ),
            );
        }
      },
      future: getCurrency(currency),
    );
  }

  Widget _listView(currencies, keys, value, currency) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: currencies.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            _buildRow(
                currencies[keys[index]]['name'],
                keys[index],
                currencies[keys[index]]['buy'],
                double.parse(coin['low']),
                currency)
          ],
        );
      },
    );
  }

  void _dispose() {
    // FUNÇÃO PARA LIMPAR DADOS DOS CONTROLLERS
    coinController.clear();
  }

  Widget _buildRow(
      String name, String symbol, double value, double coin, currency) {
    var calc = (coin / value) * values[currency];
    print(values[currency].toString());
    return ListTile(
      title: Text(name),
      subtitle: Text(symbol + " " + calc.toString()),
    );
  }
}
