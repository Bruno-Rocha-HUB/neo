import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyConversionPage extends StatefulWidget {
  const CurrencyConversionPage({Key? key}) : super(key: key);

  @override
  _CurrencyConversionPageState createState() => _CurrencyConversionPageState();
}

class _CurrencyConversionPageState extends State<CurrencyConversionPage> {
  late String _moedaOrigem;
  late String _moedaAlvo;
  late double _quantidade;
  late Map<String, double> _taxasDeCambio;
  bool _carregando = true;

  // Mapa de bandeiras diretamente no código
  Map<String, String> _bandeiras = {
    "USD": "assets/flags/united-states.png",
    "EUR": "assets/flags/european-union.png",
    "GBP": "assets/flags/united-kingdom.png",
    "JPY": "assets/flags/japan.png",
    "AUD": "assets/flags/australia.png",
    "CAD": "assets/flags/canada.png",
    "CNY": "assets/flags/china.png",
    "INR": "assets/flags/india.png",
    "BRL": "assets/flags/brazil.png",
    "RUB": "assets/flags/russia.png",
    "KRW": "assets/flags/south-korea.png",
    "ZAR": "assets/flags/south-africa.png",
    "NZD": "assets/flags/new-zealand.png",
    "SGD": "assets/flags/singapore.png",
    "SEK": "assets/flags/sweden.png",
    "CHF": "assets/flags/switzerland.png",
    "NOK": "assets/flags/norway.png",
    "MXN": "assets/flags/mexico.png",
    "HKD": "assets/flags/hong-kong.png",
    "TRY": "assets/flags/turkey.png",
    "IDR": "assets/flags/indonesia.png",
    "MYR": "assets/flags/malaysia.png",
    "THB": "assets/flags/thailand.png",
    "PHP": "assets/flags/philippines.png",
    "PLN": "assets/flags/poland.png",
    "HUF": "assets/flags/hungary.png",
    "CZK": "assets/flags/czech-republic.png",
    "ILS": "assets/flags/israel.png",
    "CLP": "assets/flags/chile.png",
    "ARS": "assets/flags/argentina.png",
    "AED": "assets/flags/united-arab-emirates.png",
    "EGP": "assets/flags/egypt.png",
    "KWD": "assets/flags/kuwait.png",
    "QAR": "assets/flags/qatar.png",
    "SAR": "assets/flags/saudi-arabia.png",
    "BHD": "assets/flags/bahrain.png",
    "OMR": "assets/flags/oman.png",
    "JOD": "assets/flags/jordan.png",
    "KZT": "assets/flags/kazakhstan.png",
    "VND": "assets/flags/vietnam.png",
    "NGN": "assets/flags/nigeria.png"
    // Adicione mais moedas conforme necessário
  };

  final TextEditingController _controladorQuantidade = TextEditingController();

  Future<void> _buscarTaxasDeCambio() async {
    const apiKey = 'e14de8f0940958c0b98ca863';
    const endpoint = 'https://v6.exchangerate-api.com/v6/$apiKey/latest/USD';

    try {
      final resposta = await http.get(Uri.parse(endpoint));

      if (resposta.statusCode == 200) {
        final Map<String, dynamic> dadosResposta = json.decode(resposta.body);
        Map<String, double> taxasDeCambio = {};

        dadosResposta['conversion_rates'].forEach((moeda, taxa) {
          taxasDeCambio[moeda] = taxa.toDouble();
        });

        setState(() {
          _taxasDeCambio = taxasDeCambio;
          _carregando = false;
        });
      } else {
        print('Erro ao buscar taxas de câmbio: ${resposta.body}');
        throw Exception('Erro ao buscar taxas de câmbio');
      }
    } catch (e) {
      print('Erro ao buscar taxas de câmbio: $e');
      throw Exception('Erro ao buscar taxas de câmbio');
    }
  }

  @override
  void initState() {
    super.initState();
    _moedaOrigem = 'USD';
    _moedaAlvo = 'USD';
    _quantidade = 1.0;

    _buscarTaxasDeCambio();
  }

  double _converterMoeda(double quantidade, String moedaOrigem, String moedaAlvo) {
    final taxaOrigem = _taxasDeCambio[moedaOrigem] ?? 1.0;
    final taxaAlvo = _taxasDeCambio[moedaAlvo] ?? 1.0;
    return quantidade * (taxaAlvo / taxaOrigem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversor de Moeda'),
      ),
      body: _carregando
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/ic_launcher.png',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _controladorQuantidade,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade em $_moedaOrigem',
                border: OutlineInputBorder(),
              ),
              onChanged: (valor) {
                setState(() {
                  _quantidade = double.tryParse(valor) ?? 0.0;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdownButtonWithFlag(_moedaOrigem, (String? valor) {
                  setState(() {
                    _moedaOrigem = valor!;
                  });
                }),
                Icon(Icons.compare_arrows, size: 30),
                _buildDropdownButtonWithFlag(_moedaAlvo, (String? valor) {
                  setState(() {
                    _moedaAlvo = valor!;
                  });
                }),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final quantidadeConvertida = _converterMoeda(
                  _quantidade,
                  _moedaOrigem,
                  _moedaAlvo,
                );
                final quantidadeFormatada = quantidadeConvertida.toStringAsFixed(2);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$_quantidade $_moedaOrigem = $quantidadeFormatada $_moedaAlvo',
                    ),
                  ),
                );
              },
              child: Text('Converter'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.attach_money),
              onPressed: () {
                // Adicione lógica para navegar para a tela de conversão de moeda
              },
            ),
            IconButton(
              icon: Icon(Icons.business),
              onPressed: () {
                // Adicione lógica para navegar para a tela de ações
              },
            ),
            IconButton(
              icon: Icon(Icons.article),
              onPressed: () {
                // Adicione lógica para navegar para a tela de notícias
              },
            ),
            IconButton(
              icon: Icon(Icons.calculate),
              onPressed: () {
                // Adicione lógica para navegar para a tela de calculadora
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDropdownButtonWithFlag(String value, void Function(String?) onChanged) {
    return Container(
      width: 120,
      child: DropdownButton<String>(
        value: value,
        items: _bandeiras.keys.map((String moeda) {
          return DropdownMenuItem<String>(
            value: moeda,
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                        _bandeiras[moeda]!,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Text(moeda),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}