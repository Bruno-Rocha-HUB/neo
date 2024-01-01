import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'calculator.dart';
import 'money.dart';
import 'news.dart';

class StockInfoPage extends StatefulWidget {
  const StockInfoPage({Key? key}) : super(key: key);

  @override
  _StockInfoPageState createState() => _StockInfoPageState();
}

class _StockInfoPageState extends State<StockInfoPage> {
  late String _acao;
  double? _precoAberto;
  double? _precoFechado;
  double? _precoSemana;
  String? _informacoesEmpresa;
  String? _classificacao;
  String? _setor;
  bool _carregando = false;

  final TextEditingController _controladorAcao = TextEditingController();

  Future<void> _buscarDadosAcao() async {
    setState(() {
      _carregando = true;
    });

    final apiKey = '5ZwgcSVeTZuV1IIeaWpK3bnOh0HpJJxc';
    final endpoint = 'https://financialmodelingprep.com/api/v3/profile/$_acao?apikey=$apiKey';

    try {
      final resposta = await http.get(Uri.parse(endpoint));

      if (resposta.statusCode == 200) {
        final List<dynamic> dadosResposta = json.decode(resposta.body);
        if (dadosResposta.isNotEmpty) {
          final empresa = dadosResposta.first;
          setState(() {
            _precoAberto = empresa['price'] ?? 0.0;
            _precoFechado = empresa['changes'] ?? 0.0;
            _precoSemana = empresa['changesPercentage'] ?? 0.0;
            _informacoesEmpresa = empresa['description'] ?? '';
            _setor = empresa['sector'] ?? 'Não disponível';
            _calcularClassificacao();
            _carregando = false;
          });
        } else {
          _exibirSnackBar('Ação não encontrada. Tente novamente.');
        }
      } else {
        _exibirSnackBar('Erro ao buscar dados da ação: ${resposta.body}');
      }
    } catch (e) {
      _exibirSnackBar('Erro ao buscar dados da ação: $e');
    }
  }

  void _calcularClassificacao() {
    if (_precoAberto! > 1000) {
      _classificacao = 'AAA (triple A): Alta qualidade';
    } else if (_precoAberto! > 500) {
      _classificacao = 'AA: Qualidade muito alta';
    } else if (_precoAberto! > 100) {
      _classificacao = 'A: Qualidade alta';
    } else if (_precoAberto! > 50) {
      _classificacao = 'BBB: Boa qualidade';
    } else if (_precoAberto! > 20) {
      _classificacao = 'BB: Especulativo';
    } else if (_precoAberto! > 10) {
      _classificacao = 'B: Altamente especulativo';
    } else if (_precoAberto! > 5) {
      _classificacao = 'CCC: Risco substancial';
    } else if (_precoAberto! > 1) {
      _classificacao = 'CC: Risco muito alto';
    } else if (_precoAberto! > 0.1) {
      _classificacao = 'C: Risco excepcionalmente alto';
    } else {
      _classificacao = 'D: Inadimplente';
    }
  }

  void _exibirSnackBar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/ic_launcher.png',
              height: 40,
            ),
            SizedBox(width: 8),
            Text('Informações de Ações'),
          ],
        ),
        centerTitle: true,
      ),
      body: _carregando
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Logo.gif',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _controladorAcao,
              decoration: InputDecoration(
                labelText: 'Buscar Ação',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _acao = _controladorAcao.text.toUpperCase();
                });
                _buscarDadosAcao();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Ajuste o valor conforme necessário
                ),
                //primary: Colors.blue, // Cor de fundo do botão
              ),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Buscar',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_precoAberto != null)
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preço de Mercado Aberto: USD\$${_precoAberto!.toStringAsFixed(2)}'),
                      SizedBox(height: 8),
                      Text('Variação desde o Fechamento: USD\$${_precoFechado!.toStringAsFixed(2)}'),
                      SizedBox(height: 8),
                      Text('Variação durante a Semana: $_precoSemana%'),
                      SizedBox(height: 16),
                      Text('Informações da Empresa (em inglês):'),
                      SizedBox(height: 8),
                      Text(_informacoesEmpresa!),
                      SizedBox(height: 16),
                      Text('Setor: $_setor'),
                      SizedBox(height: 16),
                      Text('Classificação: $_classificacao'),
                    ],
                  ),
                ),
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
              icon: Icon(Icons.compare_arrows_sharp, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CurrencyConversionPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.candlestick_chart_sharp, color: Colors.blue),
              onPressed: () {
              },
            ),
            IconButton(
              icon: Icon(Icons.calculate, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalculatorPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.article, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewsPage()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
