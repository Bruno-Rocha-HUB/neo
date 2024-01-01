import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calculator.dart';
import 'money.dart';
import 'news.dart';
import 'stock.dart';

class HighlightsPage extends StatefulWidget {
  @override
  _HighlightsPageState createState() => _HighlightsPageState();
}

class _HighlightsPageState extends State<HighlightsPage> {
  final CollectionReference newsCollection =
  FirebaseFirestore.instance.collection('news');

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

  List<Map<String, dynamic>> newsData = [];

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
            Text('Destaques'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView.separated(
          itemCount: newsData.length,
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                leading: Image.network(
                  newsData[index]['image'],
                  width: 60.0,
                  height: 60.0,
                  fit: BoxFit.cover,
                ),
                title: Text(newsData[index]['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(newsData[index]['description']
                    ),
                    SizedBox(height: 4),
                    Text('Autor: ${newsData[index]['author']}'),
                  ],
                ),
                onTap: () => _showNewsDetailsDialog(context, index),
              ),
            );
          },
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

  void _showNewsDetailsDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
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
                SizedBox(height: 12),
                Text(
                  newsData[index]['title'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  newsData[index]['content'],
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 12),
                Text(
                  "Autor: ${newsData[index]['author']}",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
