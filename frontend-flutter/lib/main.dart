import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MadagoApp());
}

class MadagoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madago',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProfilPage(),
    );
  }
}

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? profil;

  @override
  void initState() {
    super.initState();
    fetchProfil();
  }

  Future<void> fetchProfil() async {
    final response = await http.get(Uri.parse('http://localhost:3000/profil/ismael'));
    if (response.statusCode == 200) {
      setState(() {
        profil = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil utilisateur')),
      body: profil == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(radius: 50, backgroundColor: Colors.blueAccent),
                  SizedBox(height: 20),
                  Text('Nom : ${profil!['nom']}', style: TextStyle(fontSize: 18)),
                  Text('Projet : ${profil!['projet']}', style: TextStyle(fontSize: 16)),
                  ElevatedButton(
                    onPressed: () {
                      // action pour modifier le profil
                    },
                    child: Text('Modifier le profil'),
                  ),
                ],
              ),
            ),
    );
  }
}
