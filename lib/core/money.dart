import 'dart:convert';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'calculator.dart';
import 'news.dart';
import 'stock.dart';

class CurrencyConversionPage extends StatefulWidget {
  const CurrencyConversionPage({Key? key}) : super(key: key);

  @override
  _CurrencyConversionPageState createState() => _CurrencyConversionPageState();
}

class _CurrencyConversionPageState extends State<CurrencyConversionPage> {
  late String _moedaOrigem;
  late String _moedaAlvo;
  late double _quantidade;
  late Map<String, double> _taxasDeCambio = {};
  List<String> _historicoConversoes = [];
  final TextEditingController _controladorQuantidade = TextEditingController();
  int _currentIndex = 0;

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

  @override
  void initState() {
    super.initState();
    _moedaOrigem = 'USD';
    _moedaAlvo = 'USD';
    _quantidade = 1.0;

    _buscarTaxasDeCambio(); // Inicia a busca, mas não aguarda o carregamento
  }

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

  double _converterMoeda(double quantidade, String moedaOrigem, String moedaAlvo) {
    final taxaOrigem = _taxasDeCambio[moedaOrigem] ?? 1.0;
    final taxaAlvo = _taxasDeCambio[moedaAlvo] ?? 1.0;
    return quantidade * (taxaAlvo / taxaOrigem);
  }

  void _adicionarConversaoAoHistorico(String mensagem) {
    setState(() {
      if (_historicoConversoes.length >= 5) {
        _historicoConversoes.removeAt(0); // Remove a conversão mais antiga
      }
      _historicoConversoes.add(mensagem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),

          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/ic_launcher.png',
              width: 40,
              height: 40,
            ),
          ),
          title: Text(
            'Conversor de Moedas',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
          ),
          centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Image.asset(
              'assets/Logo.gif',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controladorQuantidade,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Valor em $_moedaOrigem',
                border: const OutlineInputBorder(),
              ),
              onChanged: (valor) {
                setState(() {
                  _quantidade = double.tryParse(valor) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdownButtonWithFlag(_moedaOrigem, (String? valor) {
                  setState(() {
                    _moedaOrigem = valor!;
                  });
                }),
                const Icon(Icons.compare_arrows, size: 30, color: Colors.blue),
                _buildDropdownButtonWithFlag(_moedaAlvo, (String? valor) {
                  setState(() {
                    _moedaAlvo = valor!;
                  });
                }),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final quantidadeConvertida = _converterMoeda(
                  _quantidade,
                  _moedaOrigem,
                  _moedaAlvo,
                );
                final quantidadeFormatada = quantidadeConvertida.toStringAsFixed(2);
                final mensagem =
                    '$_quantidade $_moedaOrigem = $quantidadeFormatada $_moedaAlvo';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(mensagem),
                  ),
                );
                _adicionarConversaoAoHistorico(mensagem);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Converter',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_historicoConversoes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Histórico de Conversões:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _historicoConversoes.reversed.map((conversao) {
                      return Container(
                        alignment: Alignment.center,
                        child: Text(conversao),
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: [
          Icons.compare_arrows_sharp,
          Icons.candlestick_chart_sharp,
          Icons.calculate,
          Icons.article
        ],
        activeIndex: 0, // Defina o índice ativo
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        backgroundColor: Colors.blue, // Cor de fundo da AppBar inferior
        activeColor: Colors.white, // Cor do ícone ativo
        inactiveColor: Colors.white.withOpacity(0.6), // Cor dos ícones inativos
        onTap: (index) {
          _navigateToScreen(index, context);
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Widget _buildDropdownButtonWithFlag(String value, void Function(String?) onChanged) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: Container(),
        icon: const Icon(Icons.arrow_drop_down),
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
                const SizedBox(width: 5),
                Text(moeda),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _navigateToScreen(int index, BuildContext context) {
    switch (index) {
      case 0:
      // Não é necessário navegar para a própria página
        break;
      case 1:
      // Navegar para a tela de informações de ações
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StockInfoPage()),
        );
        break;
      case 2:
      // Navegar para a calculadora
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalculatorPage()),
        );
        break;
      case 3:
      // Navegar para a tela de notícias
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsPage()),
        );
        break;
    }
  }
}