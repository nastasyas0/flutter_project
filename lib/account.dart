import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_flutter_app/edit_acc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("Пользователь вышел из аккаунта");
    } catch (e) {
      print("Ошибка при выходе из аккаунта: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Center(child: Text('Пользователь не аутентифицирован'));
    }

    // Получаем ссылку на документ пользователя в Firestore
    DocumentReference userDoc = _firestore.collection('users').doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Аккаунт'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: userDoc.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка загрузки данных'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Пользователь не найден'));
            }
            // Получаем данные пользователя
            var userData = snapshot.data!.data() as Map<String, dynamic>;

            return Stack(
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
                            Text('${userData['name'] ?? 'Не указано'}',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)
                            ),
                            const SizedBox(height: 5),
                            Text('${user.email ?? 'Не указано'}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey)
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
                    icon: Icon(Icons.logout),
                    onPressed: () async {
                      await _auth.signOut();
                      context.go('/');
                    },
                  ),
                ),
                Positioned(
                  bottom: 25.0,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EditAccountPage())),
                      child: const Text('Редактировать'),
                    ),
                  ),
                ),
              ],
            );
          }
          ),
    );
  }
}
