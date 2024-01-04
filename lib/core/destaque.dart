import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:neo/core/stock.dart';

import 'calculator.dart';
import 'money.dart';
import 'news.dart';

class HighlightsPage extends StatefulWidget {
  @override
  _HighlightsPageState createState() => _HighlightsPageState();
}

class _HighlightsPageState extends State<HighlightsPage> {
  int _currentIndex = 0;
  final CollectionReference newsCollection = FirebaseFirestore.instance.collection('news');
  List<Map<String, dynamic>> newsData = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  void fetchDataFromFirebase() async {
    try {
      QuerySnapshot querySnapshot = await newsCollection.get();
      if (querySnapshot.size > 0) {
        List<Map<String, dynamic>> data = querySnapshot.docs
            .map((doc) => Map<String, dynamic>.from(doc.data() as Map))
            .toList();
        setState(() {
          newsData = data;
        });
      } else {
        print("No data available");
      }
    } catch (error) {
      print("Error fetching data from Firestore: $error");
    }
  }

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
          'Destaques',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView.builder(
          itemCount: newsData.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: Image.network(
                  newsData[index]['image'],
                  width: 60.0,
                  height: 60.0,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  newsData[index]['description'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Autor: ${newsData[index]['author']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                onTap: () => _showNewsDetailsDialog(context, index),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: [
          Icons.compare_arrows_sharp,
          Icons.candlestick_chart_sharp,
          Icons.calculate,
          Icons.article
        ],
        activeIndex: 3,
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

  void _showNewsDetailsDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Image.network(
                      newsData[index]['image'],
                      width: 200.0,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    newsData[index]['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    newsData[index]['content'],
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Autor: ${newsData[index]['author']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Fechar',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StockInfoPage()),
        );
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
