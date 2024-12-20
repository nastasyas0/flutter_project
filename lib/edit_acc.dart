import 'package:flutter/material.dart';
import 'package:test_flutter_app/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? displayName;
  String password = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Получаем данные пользователя из Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          displayName = userDoc['name'];
          _nameController.text = displayName ?? '';
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Обновляем пароль в Firebase Authentication
        if (_passwordController.text.isNotEmpty) {
          await user.updatePassword(_passwordController.text);
          await user.reload();
        }
        await user.reload();  // Перезагружаем пользователя для получения обновленной информации
        user = _auth.currentUser;

        // Обновляем имя в Firestore
        await _firestore.collection('users').doc(user!.uid).update({
          'name': _nameController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Данные успешно обновлены')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка обновления данных: $e')));
      }
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Пользователь не аутентифицирован')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: const Text('Редактировать аккаунт'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 50.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextField(
                        controller: _nameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            hintText: _nameController.text,
                            hintStyle: TextStyle(color: Colors.grey),
                            labelText: 'Имя',
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            hintText: 'Пароль',
                            hintStyle: TextStyle(color: Colors.grey),
                            labelText: 'Пароль',
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage())),
            ),
          ),
          Positioned(
            bottom: 25.0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  _updateUserData();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage()));
                  },
                child: const Text('Сохранить'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
