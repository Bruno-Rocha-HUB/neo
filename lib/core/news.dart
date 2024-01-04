import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:neo/core/calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
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
  int _currentIndex = 2; // Defina o índice inicial como 2 para a página de notícias

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<List<Article>> getCachedNews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('cachedNews')) {
      String cachedData = prefs.getString('cachedNews') ?? '';
      List<dynamic> cachedNewsData = json.decode(cachedData);
      return cachedNewsData.map((article) => Article.fromJson(article)).toList();
    }

    return [];
  }

  Future<void> saveToCache(List<Article> articles) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dataToCache = json.encode(articles.map((article) => article.toJson()).toList());
    prefs.setString('cachedNews', dataToCache);
  }

  Future<void> fetchNews() async {
    String url =
        'https://newsapi.org/v2/top-headlines?country=br&category=$selectedCategory&apiKey=$apiKey';

    try {
      List<Article> cachedNews = await getCachedNews();
      if (cachedNews.isNotEmpty) {
        setState(() {
          articles = cachedNews;
        });
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'ok') {
          List<dynamic> articlesData = data['articles'];
          setState(() {
            articles = articlesData.map((article) => Article.fromJson(article)).toList();
          });

          saveToCache(articles);
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
          'Noticias',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
        ),
        centerTitle: true,
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
                      padding: const EdgeInsets.all(8),
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
                      padding: const EdgeInsets.all(8),
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
            child: const SizedBox(
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
                  margin: const EdgeInsets.all(8),
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
      // Não é necessário navegar para a própria página de notícias
        break;
    }
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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
    };
  }
}

List<String> categories = ['business', 'technology', 'science', 'health', 'sports', 'entertainment'];
