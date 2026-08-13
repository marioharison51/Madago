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
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProjetsPage()),
                      );
                    },
                    child: const Text('Voir les projets'),
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

class ProjetsPage extends StatefulWidget {
  const ProjetsPage({super.key});

  @override
  State<ProjetsPage> createState() => _ProjetsPageState();
}

class _ProjetsPageState extends State<ProjetsPage> {
  List<dynamic> projets = [];
  final titreController = TextEditingController();
  final descriptionController = TextEditingController();
  final besoinsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProjets();
  }

  Future<void> fetchProjets() async {
    final response = await http.get(Uri.parse('http://localhost:3000/projets'));
    if (response.statusCode == 200) {
      setState(() {
        projets = json.decode(response.body);
      });
    }
  }

  Future<void> publierProjet() async {
    if (titreController.text.isEmpty || descriptionController.text.isEmpty) return;

    await http.post(
      Uri.parse('http://localhost:3000/projets'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "titre": titreController.text,
        "description": descriptionController.text,
        "besoins": besoinsController.text.split(',').map((b) => b.trim()).toList(),
        "createur": "Ismaël",
      }),
    );

    titreController.clear();
    descriptionController.clear();
    besoinsController.clear();
    fetchProjets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projets')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: titreController,
                  decoration: const InputDecoration(labelText: "Titre du projet"),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: besoinsController,
                  decoration: const InputDecoration(labelText: "Besoins (séparés par des virgules)"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: publierProjet,
                  child: const Text("Publier le projet"),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: projets.length,
              itemBuilder: (context, index) {
                final projet = projets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(projet['titre']),
                    subtitle: Text(
                      "${projet['description']}\nBesoins : ${(projet['besoins'] as List).join(', ')}\nPar : ${projet['createur']}",
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
