import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MadagoApp());

class MadagoApp extends StatelessWidget {
  const MadagoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madago',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const ProfilPage(),
    );
  }
}

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
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
      appBar: AppBar(title: const Text('Profil utilisateur')),
      body: profil == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Colors.blueAccent),
                  const SizedBox(height: 20),
                  Text('Nom : ${profil!['nom']}'),
                  Text('Projet : ${profil!['projet']}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // action pour modifier le profil
                    },
                    child: const Text('Modifier le profil'),
                  ),
                  const SizedBox(height: 20),
                  const Text('Messages :'),
                  ...profil!['messages'].map<Widget>((msg) => Text('${msg['sender']}: ${msg['text']}')).toList(),
                ],
              ),
            ),
    );
  }
}
