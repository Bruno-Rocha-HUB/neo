import 'dart:convert';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neo/core/calculator.dart';
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
          'Informações da Ação',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
        ),
        centerTitle: true,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _controladorAcao,
              decoration: const InputDecoration(
                labelText: 'Buscar Ação',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _acao = _controladorAcao.text.toUpperCase();
                });
                _buscarDadosAcao();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Ajuste o valor conforme necessário
                ),
                //primary: Colors.blue, // Cor de fundo do botão
              ),
              child: const SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Buscar',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_precoAberto != null)
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preço de Mercado Aberto: USD\$${_precoAberto!.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      Text('Variação desde o Fechamento: USD\$${_precoFechado!.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      Text('Variação durante a Semana: $_precoSemana%'),
                      const SizedBox(height: 16),
                      const Text('Informações da Empresa (em inglês):'),
                      const SizedBox(height: 8),
                      Text(_informacoesEmpresa!),
                      const SizedBox(height: 16),
                      Text('Setor: $_setor'),
                      const SizedBox(height: 16),
                      Text('Classificação: $_classificacao'),
                    ],
                  ),
                ),
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
        activeIndex: 1, // Defina o índice ativo como 2 para a Calculadora
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        backgroundColor: Colors.blue, // Cor de fundo da AppBar inferior
        activeColor: Colors.white, // Cor do ícone ativo
        inactiveColor: Colors.white.withOpacity(0.6), // Cor dos ícones inativos
        onTap: (index) {
          _navigateToScreen(index, context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _navigateToScreen(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CurrencyConversionPage()),
        );
        break;
      case 1:
      // Não é necessário navegar para a própria página
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalculatorPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsPage()),
        );
        break;
    }
  }
}
