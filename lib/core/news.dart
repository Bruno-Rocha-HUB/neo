import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'calculator.dart';
import 'destaque.dart';
import 'money.dart';
import 'stock.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  String apiKey = '12dea2fb07c94f81abea63fcc63b45c6';
  String selectedCategory = 'business';
  List<Article> articles = [];

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    String url =
        'https://newsapi.org/v2/top-headlines?country=br&category=$selectedCategory&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'ok') {
          List<dynamic> articlesData = data['articles'];
          setState(() {
            articles = articlesData
                .map((article) => Article.fromJson(article))
                .toList();
          });
        }
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error: $e');
    }
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
            Text('Notícias'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HighlightsPage()),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Destaques',
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedCategory == 'Destaques' ? Colors.blue : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                } else {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategory = categories[index];
                        fetchNews();
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedCategory == categories[index] ? Colors.blue : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HighlightsPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.lightBlueAccent,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.yellow),
                    SizedBox(width: 8),
                    Text(
                      'Destaques',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(articles[index].title),
                    subtitle: Text(articles[index].description),
                    onTap: () {
                      _launchURL(articles[index].url);
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
                // Lógica para navegar para a tela de notícias
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class Article {
  final String title;
  final String description;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

List<String> categories = ['business', 'technology', 'science', 'health', 'sports', 'entertainment'];
