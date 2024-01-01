import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  bool _isResettingPassword = false;

  Future<void> _resetPassword() async {
    if (_isResettingPassword) return;

    try {
      _isResettingPassword = true;
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // Adicione lógica adicional, por exemplo, exibindo uma mensagem de sucesso
      print('E-mail de redefinição de senha enviado para ${_emailController.text.trim()}');
    } on FirebaseAuthException catch (e) {
      print('Erro ao redefinir senha: $e');
    } finally {
      _isResettingPassword = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Esqueci a Senha'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sua logo aqui
                Image.asset('assets/Cadeado.gif', height: 120, width: 120),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isResettingPassword ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: Text(
                      'Redefinir Senha',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Voltar à tela de login
                  },
                  child: Text(
                    'Voltar ao Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
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
