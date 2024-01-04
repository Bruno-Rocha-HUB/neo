import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'money.dart';
import 'news.dart';
import 'stock.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String input = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
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
        title: const Text(
          'Calculadora',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              input,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CalculatorButton('7', () => addToInput('7')),
                CalculatorButton('8', () => addToInput('8')),
                CalculatorButton('9', () => addToInput('9')),
                CalculatorButton('÷', () => addToInput('/')),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CalculatorButton('4', () => addToInput('4')),
                CalculatorButton('5', () => addToInput('5')),
                CalculatorButton('6', () => addToInput('6')),
                CalculatorButton('×', () => addToInput('*')),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CalculatorButton('1', () => addToInput('1')),
                CalculatorButton('2', () => addToInput('2')),
                CalculatorButton('3', () => addToInput('3')),
                CalculatorButton('-', () => addToInput('-')),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CalculatorButton('.', () => addToInput('.')),
                CalculatorButton('0', () => addToInput('0')),
                CalculatorButton('C', clearInput),
                CalculatorButton('+', () => addToInput('+')),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: calculateResult,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                primary: Colors.lightBlueAccent,
              ),
              child: const SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Calcular',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
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
        activeIndex: 2, // Defina o índice ativo como 2 para a Calculadora
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

  void addToInput(String value) {
    setState(() {
      input += value;
    });
  }

  void clearInput() {
    setState(() {
      input = '';
    });
  }

  void calculateResult() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(input);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        input = eval.toString();
      });
    } catch (e) {
      // If there is an error in evaluating the expression, do nothing
    }
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StockInfoPage()),
        );
        break;
      case 2:
      // Não é necessário navegar para a própria página
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

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CalculatorButton(this.text, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 64),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
