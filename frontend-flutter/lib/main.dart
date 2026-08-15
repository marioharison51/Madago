import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

void main() => runApp(const MadagoApp());

class MadagoApp extends StatelessWidget {
  const MadagoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madago',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4F46E5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF374151)),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final motDePasseController = TextEditingController();
  String? erreur;
  bool chargement = false;
  bool motDePasseVisible = false;

  Future<void> seConnecter() async {
    if (emailController.text.isEmpty || motDePasseController.text.isEmpty) return;
    setState(() {
      chargement = true;
      erreur = null;
    });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": emailController.text.trim(),
          "motDePasse": motDePasseController.text,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen(userId: data['id'])),
        );
      } else {
        final data = json.decode(response.body);
        setState(() {
          erreur = data['message'] ?? "Erreur de connexion";
          chargement = false;
        });
      }
    } catch (e) {
      setState(() {
        erreur = "Erreur de connexion : $e";
        chargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Madago', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motDePasseController,
              decoration: InputDecoration(
                labelText: "Mot de passe",
                suffixIcon: IconButton(
                  icon: Icon(motDePasseVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => motDePasseVisible = !motDePasseVisible),
                ),
              ),
              obscureText: !motDePasseVisible,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                  );
                },
                child: const Text("Mot de passe oublié ?"),
              ),
            ),
            const SizedBox(height: 12),
            if (erreur != null)
              Text(erreur!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            chargement
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: seConnecter,
                    child: const Text("Se connecter"),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text("Pas encore de compte ? S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  String? message;
  String? nouveauMotDePasse;
  bool chargement = false;
  bool succes = false;

  Future<void> reinitialiser() async {
    if (emailController.text.isEmpty) return;
    setState(() {
      chargement = true;
      message = null;
      nouveauMotDePasse = null;
    });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/mot-de-passe-oublie'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": emailController.text.trim()}),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          succes = true;
          nouveauMotDePasse = data['nouveauMotDePasse'];
          chargement = false;
        });
      } else {
        setState(() {
          message = data['message'] ?? "Erreur";
          chargement = false;
        });
      }
    } catch (e) {
      setState(() {
        message = "Erreur de connexion : $e";
        chargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Entre ton email, un nouveau mot de passe temporaire te sera affiché ici.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
            ),
            const SizedBox(height: 20),
            if (message != null)
              Text(message!, style: const TextStyle(color: Colors.red)),
            if (succes && nouveauMotDePasse != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  "Nouveau mot de passe : $nouveauMotDePasse\nConnecte-toi avec celui-ci.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 10),
            chargement
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: reinitialiser,
                    child: const Text("Réinitialiser"),
                  ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nomController = TextEditingController();
  final emailController = TextEditingController();
  final motDePasseController = TextEditingController();
  String? erreur;
  bool chargement = false;
  bool motDePasseVisible = false;

  Future<void> sInscrire() async {
    if (nomController.text.isEmpty || emailController.text.isEmpty || motDePasseController.text.isEmpty) return;
    setState(() {
      chargement = true;
      erreur = null;
    });
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/register'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nom": nomController.text,
          "email": emailController.text.trim(),
          "motDePasse": motDePasseController.text,
        }),
      );
      if (response.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte créé, tu peux te connecter")),
        );
      } else {
        final data = json.decode(response.body);
        setState(() {
          erreur = data['message'] ?? "Erreur lors de l'inscription";
          chargement = false;
        });
      }
    } catch (e) {
      setState(() {
        erreur = "Erreur de connexion : $e";
        chargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nomController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motDePasseController,
              decoration: InputDecoration(
                labelText: "Mot de passe",
                suffixIcon: IconButton(
                  icon: Icon(motDePasseVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => motDePasseVisible = !motDePasseVisible),
                ),
              ),
              obscureText: !motDePasseVisible,
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: 20),
            if (erreur != null)
              Text(erreur!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            chargement
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: sInscrire,
                    child: const Text("S'inscrire"),
                  ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String userId;
  const MainScreen({super.key, required this.userId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  static const titres = ['Profil', 'Projets', 'Recherche', 'Événements', 'Chat'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titres[selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          ProfilTab(userId: widget.userId),
          const ProjetsTab(),
          const RechercheTab(),
          const EvenementsTab(),
          const ChatTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
          NavigationDestination(icon: Icon(Icons.work), label: 'Projets'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Recherche'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Événements'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }
}

class ProfilTab extends StatefulWidget {
  final String userId;
  const ProfilTab({super.key, required this.userId});

  @override
  State<ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> {
  Map<String, dynamic>? profil;
  String? erreur;

  @override
  void initState() {
    super.initState();
    fetchProfil();
  }

  Future<void> fetchProfil() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/profil/${widget.userId}'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        setState(() {
          profil = json.decode(response.body);
          erreur = null;
        });
      } else {
        setState(() {
          erreur = "Erreur serveur : ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        erreur = "Erreur de connexion : $e";
      });
    }
  }

  Future<void> noterProfil(int note) async {
    await http.post(
      Uri.parse('http://localhost:3000/profil/${widget.userId}/noter'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"note": note}),
    );
    fetchProfil();
  }

  @override
  Widget build(BuildContext context) {
    final moyenne = profil?['moyenneNotes'];
    if (erreur != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(erreur!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: fetchProfil, child: const Text("Réessayer")),
            ],
          ),
        ),
      );
    }
    if (profil == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Colors.blueAccent),
            const SizedBox(height: 20),
            Text('Nom : ${profil!['nom']}'),
            Text('Projet : ${(profil!['projet'] as String).isEmpty ? "Pas encore renseigné" : profil!['projet']}'),
            const SizedBox(height: 10),
            Text(
              moyenne == null
                  ? 'Pas encore de note'
                  : 'Note moyenne : ${moyenne.toStringAsFixed(1)} / 5 (${(profil!['notes'] as List).length} avis)',
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return IconButton(
                  icon: const Icon(Icons.star, color: Colors.amber),
                  onPressed: () => noterProfil(i + 1),
                );
              }),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final resultat = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ModifierProfilPage(userId: widget.userId, profilActuel: profil!),
                  ),
                );
                if (resultat == true) {
                  fetchProfil();
                }
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

class ModifierProfilPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> profilActuel;
  const ModifierProfilPage({super.key, required this.userId, required this.profilActuel});

  @override
  State<ModifierProfilPage> createState() => _ModifierProfilPageState();
}

class _ModifierProfilPageState extends State<ModifierProfilPage> {
  late TextEditingController nomController;
  late TextEditingController projetController;
  late TextEditingController competencesController;
  String? erreur;
  bool chargement = false;

  @override
  void initState() {
    super.initState();
    nomController = TextEditingController(text: widget.profilActuel['nom'] ?? '');
    projetController = TextEditingController(text: widget.profilActuel['projet'] ?? '');
    competencesController = TextEditingController(
      text: (widget.profilActuel['competences'] as List?)?.join(', ') ?? '',
    );
  }

  Future<void> enregistrer() async {
    setState(() {
      chargement = true;
      erreur = null;
    });
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/profil/${widget.userId}'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nom": nomController.text,
          "projet": projetController.text,
          "competences": competencesController.text
              .split(',')
              .map((c) => c.trim())
              .where((c) => c.isNotEmpty)
              .toList(),
        }),
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        setState(() {
          erreur = "Erreur lors de la mise à jour";
          chargement = false;
        });
      }
    } catch (e) {
      setState(() {
        erreur = "Erreur de connexion : $e";
        chargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: projetController,
              decoration: const InputDecoration(labelText: "Projet"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: competencesController,
              decoration: const InputDecoration(labelText: "Compétences (séparées par des virgules)"),
            ),
            const SizedBox(height: 20),
            if (erreur != null)
              Text(erreur!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            chargement
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: enregistrer,
                    child: const Text("Enregistrer"),
                  ),
          ],
        ),
      ),
    );
  }
}

class ProjetsTab extends StatefulWidget {
  const ProjetsTab({super.key});

  @override
  State<ProjetsTab> createState() => _ProjetsTabState();
}

class _ProjetsTabState extends State<ProjetsTab> {
  List<dynamic> projets = [];
  final titreController = TextEditingController();
  final descriptionController = TextEditingController();
  final besoinsController = TextEditingController();
  final githubController = TextEditingController();

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
        "githubUrl": githubController.text.isEmpty ? null : githubController.text,
      }),
    );

    titreController.clear();
    descriptionController.clear();
    besoinsController.clear();
    githubController.clear();
    fetchProjets();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              TextField(
                controller: githubController,
                decoration: const InputDecoration(labelText: "Lien GitHub (optionnel)"),
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
              return ProjetCard(projet: projet);
            },
          ),
        ),
      ],
    );
  }
}

class ProjetCard extends StatefulWidget {
  final dynamic projet;
  const ProjetCard({super.key, required this.projet});

  @override
  State<ProjetCard> createState() => _ProjetCardState();
}

class _ProjetCardState extends State<ProjetCard> {
  Map<String, dynamic>? infosGithub;
  bool chargement = false;
  String? erreur;

  Future<void> chargerInfosGithub() async {
    setState(() {
      chargement = true;
      erreur = null;
    });
    final response = await http.get(
      Uri.parse('http://localhost:3000/projets/${widget.projet['id']}/github'),
    );
    if (response.statusCode == 200) {
      setState(() {
        infosGithub = json.decode(response.body);
        chargement = false;
      });
    } else {
      setState(() {
        erreur = "Impossible de récupérer les infos GitHub";
        chargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projet = widget.projet;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(projet['titre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(projet['description']),
            Text("Besoins : ${(projet['besoins'] as List).join(', ')}"),
            Text("Par : ${projet['createur']}"),
            if (projet['githubUrl'] != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.code),
                label: const Text("Voir les infos GitHub"),
                onPressed: chargement ? null : chargerInfosGithub,
              ),
              if (chargement) const CircularProgressIndicator(),
              if (erreur != null) Text(erreur!, style: const TextStyle(color: Colors.red)),
              if (infosGithub != null) ...[
                Text("⭐ ${infosGithub!['etoiles']} — ${infosGithub!['langagePrincipal'] ?? 'N/A'}"),
                Text("Dernière mise à jour : ${infosGithub!['derniereMaj']}"),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class RechercheTab extends StatefulWidget {
  const RechercheTab({super.key});

  @override
  State<RechercheTab> createState() => _RechercheTabState();
}

class _RechercheTabState extends State<RechercheTab> {
  List<dynamic> resultats = [];
  final competenceController = TextEditingController();

  Future<void> rechercher() async {
    if (competenceController.text.isEmpty) return;
    final response = await http.get(
      Uri.parse('http://localhost:3000/profils/recherche?competence=${competenceController.text}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        resultats = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: competenceController,
                  decoration: const InputDecoration(labelText: "Compétence (ex: Flutter)"),
                ),
              ),
              IconButton(icon: const Icon(Icons.search), onPressed: rechercher),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: resultats.length,
            itemBuilder: (context, index) {
              final profil = resultats[index];
              return ListTile(
                title: Text(profil['nom']),
                subtitle: Text((profil['competences'] as List).join(', ')),
              );
            },
          ),
        ),
      ],
    );
  }
}

class EvenementsTab extends StatefulWidget {
  const EvenementsTab({super.key});

  @override
  State<EvenementsTab> createState() => _EvenementsTabState();
}

class _EvenementsTabState extends State<EvenementsTab> {
  List<dynamic> evenements = [];
  final nomController = TextEditingController();
  final dateController = TextEditingController();
  final lieuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEvenements();
  }

  Future<void> fetchEvenements() async {
    final response = await http.get(Uri.parse('http://localhost:3000/evenements'));
    if (response.statusCode == 200) {
      setState(() {
        evenements = json.decode(response.body);
      });
    }
  }

  Future<void> creerEvenement() async {
    if (nomController.text.isEmpty || dateController.text.isEmpty || lieuController.text.isEmpty) return;

    await http.post(
      Uri.parse('http://localhost:3000/evenements'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "nom": nomController.text,
        "date": dateController.text,
        "lieu": lieuController.text,
      }),
    );

    nomController.clear();
    dateController.clear();
    lieuController.clear();
    fetchEvenements();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(labelText: "Nom de l'événement"),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Date (jj/mm/aaaa)"),
              ),
              TextField(
                controller: lieuController,
                decoration: const InputDecoration(labelText: "Lieu"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: creerEvenement,
                child: const Text("Créer l'événement"),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: evenements.length,
            itemBuilder: (context, index) {
              final evenement = evenements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(evenement['nom']),
                  subtitle: Text(
                    "${evenement['date']} — ${evenement['lieu']}\nParticipants : ${(evenement['participants'] as List).length}",
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  late IO.Socket socket;
  final List<String> messages = [];
  final messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    connecterSocket();
  }

  void connecterSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Connecté au serveur de chat');
    });

    socket.on('nouveauMessage', (data) {
      setState(() {
        messages.add(data['contenu']);
      });
    });
  }

  void envoyerMessage() {
    if (messageController.text.isEmpty) return;
    socket.emit('envoyerMessage', {'contenu': messageController.text});
    messageController.clear();
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(messages[index]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: "Ton message"),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: envoyerMessage),
            ],
          ),
        ),
      ],
    );
  }
}
