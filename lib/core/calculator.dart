import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'money.dart';
import 'news.dart';
import 'stock.dart';

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
        title: Row(
          children: [
            Image.asset(
              'assets/ic_launcher.png',
              height: 40,
            ),
            SizedBox(width: 8),
            Text('Calculadora'),
          ],
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
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: calculateResult,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Ajuste o valor conforme necessário
                ),
                primary: Colors.lightBlueAccent, // Cor de fundo do botão
              ),
              child: SizedBox(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StockInfoPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.calculate, color: Colors.blue),
              onPressed: () {
                // Already on the calculator page
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
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CalculatorButton(this.text, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(64, 64),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
