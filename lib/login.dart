import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isRegistering = true;

  void toggleForm() {
    setState(() {
      isRegistering = !isRegistering;
    });
  }

  Future<void> register() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Сохранение имени и email в Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
      });

      // Обновление профиля пользователя с именем
      await userCredential.user!.updateProfile(displayName: _nameController.text);

      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Пользователь ${userCredential.user!.displayName} успешно зарегистрирован'),
            duration: Duration(seconds: 2),
          ),
        );
        context.go('/cities');
      });
    } catch (e) {
      print('Ошибка при регистрации пользователя: $e');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при регистрации пользователя ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  Future<void> login() async {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        context.go('/cities');
        // print('Пользователь ${_auth.currentUser!.email} авторизировался успешно');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Пользователь ${_auth.currentUser!.email} авторизировался успешно'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        // print('Ошибка при авторизации пользователя ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при авторизации пользователя ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isRegistering ? 'Регистрация' : 'Вход'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isRegistering)
                TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    hintText: 'Имя',
                    hintStyle: TextStyle(color: Colors.grey),
                    labelText: 'Имя',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey),
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                ),),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(
                  hintText: 'Пароль',
                  hintStyle: TextStyle(color: Colors.grey),
                  labelText: 'Пароль',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isRegistering ? register : login,
                child: Text(isRegistering ? 'Зарегистрироваться' : 'Войти'),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: toggleForm,
                child: Text(isRegistering
                    ? 'Уже есть аккаунт? Войти'
                    : 'Нет аккаунта? Зарегистрироваться'),
              ),
            ],
          ),
        ),
      );
  }
}
