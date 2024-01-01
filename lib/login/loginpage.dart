import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neo/login/restpassaword.dart';


import '../core/money.dart';
import 'signpppage.dart'; // Importe a página inicial

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningIn = false;

  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final user = await _authService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Se a autenticação for bem-sucedida, navegue para a página inicial
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CurrencyConversionPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle errors aqui, por exemplo, exibindo uma mensagem de erro ao usuário
      print('Erro de autenticação: $e');
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/ic_launcher.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: 30),

                // Campo de E-mail
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 12),

                // Campo de Senha
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock, color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 16),

                // Botão de Entrar ocupando linha inteira
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSigningIn ? null : _signInWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: Text(
                      'Entrar',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Texto para navegar para a página de cadastro
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  child: Text(
                    'Não tem uma conta? Cadastre-se',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(height: 8),

                // Esqueci a senha
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RestPasswordPage()),
                      );
                      print('Esqueci a senha pressionado');
                    },
                    child: Text(
                      'Esqueci a senha',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
