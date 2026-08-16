import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

const String baseUrl = 'https://madago-backend.onrender.com';

void main() => runApp(const MadagoApp());

class MadagoApp extends StatelessWidget {
  const MadagoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madago',
      debugShowCheckedModeBanner: false,
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
          fillColor: const Color(0xFFF3F4F6),
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
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black26,
          indicatorColor: const Color(0xFFEEF2FF),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF374151)),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
      ),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool modeConnexion = true;

  final emailController = TextEditingController();
  final motDePasseController = TextEditingController();
  bool motDePasseVisible = false;

  final nomController = TextEditingController();
  final emailInscriptionController = TextEditingController();
  final motDePasseInscriptionController = TextEditingController();
  bool motDePasseInscriptionVisible = false;

  String? erreur;
  bool chargement = false;

  Future<void> seConnecter() async {
    if (emailController.text.isEmpty || motDePasseController.text.isEmpty) return;
    setState(() {
      chargement = true;
      erreur = null;
    });
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "email": emailController.text.trim(),
              "motDePasse": motDePasseController.text,
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, animation, __) => MainScreen(userId: data['id'], userNom: data['nom']),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
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

  Future<void> sInscrire() async {
    if (nomController.text.isEmpty ||
        emailInscriptionController.text.isEmpty ||
        motDePasseInscriptionController.text.isEmpty) return;
    setState(() {
      chargement = true;
      erreur = null;
    });
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "nom": nomController.text,
              "email": emailInscriptionController.text.trim(),
              "motDePasse": motDePasseInscriptionController.text,
            }),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 201) {
        setState(() {
          modeConnexion = true;
          chargement = false;
          emailController.text = emailInscriptionController.text.trim();
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte créé ! Connecte-toi.")),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4F46E5), Color(0xFFF7F7FB)],
            stops: [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)],
                    ),
                    child: const Icon(Icons.groups_rounded, size: 48, color: Color(0xFF4F46E5)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Madago',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Connecte les talents, fais grandir tes idées',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    modeConnexion = true;
                                    erreur = null;
                                  }),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: modeConnexion ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: modeConnexion
                                          ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]
                                          : [],
                                    ),
                                    child: Text(
                                      'Se connecter',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: modeConnexion ? const Color(0xFF4F46E5) : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    modeConnexion = false;
                                    erreur = null;
                                  }),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: !modeConnexion ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: !modeConnexion
                                          ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]
                                          : [],
                                    ),
                                    child: Text(
                                      'S\'inscrire',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: !modeConnexion ? const Color(0xFF4F46E5) : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: modeConnexion
                              ? Column(
                                  key: const ValueKey('connexion'),
                                  children: [
                                    TextField(
                                      controller: emailController,
                                      decoration: const InputDecoration(
                                        labelText: "Email",
                                        prefixIcon: Icon(Icons.email_outlined),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      textCapitalization: TextCapitalization.none,
                                      autocorrect: false,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: motDePasseController,
                                      decoration: InputDecoration(
                                        labelText: "Mot de passe",
                                        prefixIcon: const Icon(Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          icon: Icon(motDePasseVisible ? Icons.visibility_off : Icons.visibility),
                                          onPressed: () => setState(() => motDePasseVisible = !motDePasseVisible),
                                        ),
                                      ),
                                      obscureText: !motDePasseVisible,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                    ),
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
                                    const SizedBox(height: 8),
                                    if (erreur != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Text(erreur!, style: const TextStyle(color: Colors.red)),
                                      ),
                                    chargement
                                        ? const CircularProgressIndicator()
                                        : SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: seConnecter,
                                              icon: const Icon(Icons.login),
                                              label: const Text("Se connecter"),
                                            ),
                                          ),
                                  ],
                                )
                              : Column(
                                  key: const ValueKey('inscription'),
                                  children: [
                                    TextField(
                                      controller: nomController,
                                      decoration: const InputDecoration(
                                        labelText: "Nom",
                                        prefixIcon: Icon(Icons.person_outline),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: emailInscriptionController,
                                      decoration: const InputDecoration(
                                        labelText: "Email",
                                        prefixIcon: Icon(Icons.email_outlined),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      textCapitalization: TextCapitalization.none,
                                      autocorrect: false,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: motDePasseInscriptionController,
                                      decoration: InputDecoration(
                                        labelText: "Mot de passe",
                                        prefixIcon: const Icon(Icons.lock_outline),
                                        suffixIcon: IconButton(
                                          icon: Icon(motDePasseInscriptionVisible ? Icons.visibility_off : Icons.visibility),
                                          onPressed: () => setState(
                                              () => motDePasseInscriptionVisible = !motDePasseInscriptionVisible),
                                        ),
                                      ),
                                      obscureText: !motDePasseInscriptionVisible,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                    ),
                                    const SizedBox(height: 20),
                                    if (erreur != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Text(erreur!, style: const TextStyle(color: Colors.red)),
                                      ),
                                    chargement
                                        ? const CircularProgressIndicator()
                                        : SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: sInscrire,
                                              icon: const Icon(Icons.check),
                                              label: const Text("S'inscrire"),
                                            ),
                                          ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
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
  bool chargement = false;
  bool succes = false;

  Future<void> reinitialiser() async {
    if (emailController.text.isEmpty) return;
    setState(() {
      chargement = true;
      message = null;
    });
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/mot-de-passe-oublie'),
            headers: {"Content-Type": "application/json"},
            body: json.encode({"email": emailController.text.trim()}),
          )
          .timeout(const Duration(seconds: 20));
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          succes = true;
          message = data['message'];
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
            const Icon(Icons.lock_reset, size: 48, color: Color(0xFF4F46E5)),
            const SizedBox(height: 16),
            const Text(
              "Entre ton email, un nouveau mot de passe temporaire te sera envoyé par email.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
            ),
            const SizedBox(height: 20),
            if (message != null)
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: succes ? Colors.green : Colors.red),
              ),
            const SizedBox(height: 16),
            chargement
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: reinitialiser,
                      icon: const Icon(Icons.send),
                      label: const Text("Envoyer"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String userId;
  final String userNom;
  const MainScreen({super.key, required this.userId, required this.userNom});

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
            tooltip: 'Se déconnecter',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: IndexedStack(
          key: ValueKey(selectedIndex),
          index: selectedIndex,
          children: [
            ProfilTab(userId: widget.userId),
            ProjetsTab(userId: widget.userId, userNom: widget.userNom),
            const RechercheTab(),
            const EvenementsTab(),
            const ChatTab(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Projets'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Recherche'),
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Événements'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
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
          .get(Uri.parse('$baseUrl/profil/${widget.userId}'))
          .timeout(const Duration(seconds: 20));
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
      Uri.parse('$baseUrl/profil/${widget.userId}/noter'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"note": note}),
    );
    fetchProfil();
  }

  @override
  Widget build(BuildContext context) {
    final moyenne = profil?['moyenneNotes'];
    final photoUrl = profil?['photoUrl'] as String?;
    if (erreur != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(erreur!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              Text(
                "Le serveur peut mettre jusqu'à une minute à démarrer.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: fetchProfil,
                icon: const Icon(Icons.refresh),
                label: const Text("Réessayer"),
              ),
            ],
          ),
        ),
      );
    }
    if (profil == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF4F46E5),
            backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
            child: (photoUrl == null || photoUrl.isEmpty)
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 16),
          Text(profil!['nom'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            (profil!['projet'] as String).isEmpty ? "Pas encore de projet renseigné" : profil!['projet'],
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    moyenne == null
                        ? 'Pas encore de note'
                        : '${moyenne.toStringAsFixed(1)} / 5 (${(profil!['notes'] as List).length} avis)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                        onPressed: () => noterProfil(i + 1),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
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
              icon: const Icon(Icons.edit),
              label: const Text('Modifier le profil'),
            ),
          ),
          const SizedBox(height: 20),
          if ((profil!['messages'] as List).isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Messages', style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            ...profil!['messages'].map<Widget>((msg) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.message_outlined),
                    title: Text(msg['sender']),
                    subtitle: Text(msg['text']),
                  ),
                )),
          ],
        ],
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
  late TextEditingController photoUrlController;
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
    photoUrlController = TextEditingController(text: widget.profilActuel['photoUrl'] ?? '');
  }

  Future<void> enregistrer() async {
    setState(() {
      chargement = true;
      erreur = null;
    });
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profil/${widget.userId}'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nom": nomController.text,
          "projet": projetController.text,
          "competences": competencesController.text
              .split(',')
              .map((c) => c.trim())
              .where((c) => c.isNotEmpty)
              .toList(),
          "photoUrl": photoUrlController.text.trim(),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (photoUrlController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(photoUrlController.text),
                ),
              ),
            TextField(
              controller: photoUrlController,
              decoration: const InputDecoration(
                labelText: "Lien de la photo de profil (URL)",
                prefixIcon: Icon(Icons.image_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: "Nom",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: projetController,
              decoration: const InputDecoration(
                labelText: "Projet",
                prefixIcon: Icon(Icons.work_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: competencesController,
              decoration: const InputDecoration(
                labelText: "Compétences (séparées par des virgules)",
                prefixIcon: Icon(Icons.star_outline),
              ),
            ),
            const SizedBox(height: 20),
            if (erreur != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(erreur!, style: const TextStyle(color: Colors.red)),
              ),
            chargement
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: enregistrer,
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class ProjetsTab extends StatefulWidget {
  final String userId;
  final String userNom;
  const ProjetsTab({super.key, required this.userId, required this.userNom});

  @override
  State<ProjetsTab> createState() => _ProjetsTabState();
}

enum TriProjets { recent, ancien, alphabetique }

class _ProjetsTabState extends State<ProjetsTab> {
  List<dynamic> projets = [];
  final titreController = TextEditingController();
  final descriptionController = TextEditingController();
  final besoinsController = TextEditingController();
  final githubController = TextEditingController();
  final filtreController = TextEditingController();
  TriProjets tri = TriProjets.recent;

  @override
  void initState() {
    super.initState();
    fetchProjets();
  }

  Future<void> fetchProjets() async {
    final response = await http.get(Uri.parse('$baseUrl/projets'));
    if (response.statusCode == 200) {
      setState(() {
        projets = json.decode(response.body);
      });
    }
  }

  Future<void> publierProjet() async {
    if (titreController.text.isEmpty || descriptionController.text.isEmpty) return;

    await http.post(
      Uri.parse('$baseUrl/projets'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "titre": titreController.text,
        "description": descriptionController.text,
        "besoins": besoinsController.text.split(',').map((b) => b.trim()).toList(),
        "createur": widget.userNom,
        "createurId": widget.userId,
        "githubUrl": githubController.text.isEmpty ? null : githubController.text,
      }),
    );

    titreController.clear();
    descriptionController.clear();
    besoinsController.clear();
    githubController.clear();
    fetchProjets();
  }

  List<dynamic> get projetsFiltres {
    var liste = List<dynamic>.from(projets);
    if (filtreController.text.isNotEmpty) {
      final motCle = filtreController.text.toLowerCase();
      liste = liste.where((p) {
        final besoins = (p['besoins'] as List).join(' ').toLowerCase();
        return besoins.contains(motCle) || (p['titre'] as String).toLowerCase().contains(motCle);
      }).toList();
    }
    switch (tri) {
      case TriProjets.recent:
        liste.sort((a, b) => (b['dateCreation'] ?? '').compareTo(a['dateCreation'] ?? ''));
        break;
      case TriProjets.ancien:
        liste.sort((a, b) => (a['dateCreation'] ?? '').compareTo(b['dateCreation'] ?? ''));
        break;
      case TriProjets.alphabetique:
        liste.sort((a, b) => (a['titre'] as String).compareTo(b['titre'] as String));
        break;
    }
    return liste;
  }

  @override
  Widget build(BuildContext context) {
    final liste = projetsFiltres;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: titreController,
                    decoration: const InputDecoration(
                      labelText: "Titre du projet",
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: besoinsController,
                    decoration: const InputDecoration(
                      labelText: "Besoins (séparés par des virgules)",
                      prefixIcon: Icon(Icons.handyman_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: githubController,
                    decoration: const InputDecoration(
                      labelText: "Lien GitHub (optionnel)",
                      prefixIcon: Icon(Icons.code),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: publierProjet,
                      icon: const Icon(Icons.publish),
                      label: const Text("Publier le projet"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: filtreController,
            decoration: const InputDecoration(
              labelText: "Filtrer par mot-clé ou besoin",
              prefixIcon: Icon(Icons.filter_alt_outlined),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<TriProjets>(
              segments: const [
                ButtonSegment(value: TriProjets.recent, label: Text('Récents'), icon: Icon(Icons.south)),
                ButtonSegment(value: TriProjets.ancien, label: Text('Anciens'), icon: Icon(Icons.north)),
                ButtonSegment(value: TriProjets.alphabetique, label: Text('A-Z'), icon: Icon(Icons.sort_by_alpha)),
              ],
              selected: {tri},
              onSelectionChanged: (nouveau) => setState(() => tri = nouveau.first),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: liste.isEmpty
              ? Center(
                  child: Text("Aucun projet trouvé", style: TextStyle(color: Colors.grey.shade600)),
                )
              : ListView.builder(
                  itemCount: liste.length,
                  itemBuilder: (context, index) {
                    final projet = liste[index];
                    return ProjetCard(projet: projet, currentUserId: widget.userId, currentUserNom: widget.userNom);
                  },
                ),
        ),
      ],
    );
  }
}

class ProjetCard extends StatefulWidget {
  final dynamic projet;
  final String currentUserId;
  final String currentUserNom;
  const ProjetCard({super.key, required this.projet, required this.currentUserId, required this.currentUserNom});

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
      Uri.parse('$baseUrl/projets/${widget.projet['id']}/github'),
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
    final createurId = projet['createurId'] as String?;
    final peutContacter = createurId != null && createurId != widget.currentUserId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rocket_launch_outlined, color: Color(0xFF4F46E5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(projet['titre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(projet['description']),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (projet['besoins'] as List)
                  .map<Widget>((b) => Chip(label: Text(b), visualDensity: VisualDensity.compact))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(projet['createur'], style: TextStyle(color: Colors.grey.shade600)),
                if (peutContacter) ...[
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.mail_outline, size: 18),
                    label: const Text("Contacter"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MessagePriveTab(
                            userId: widget.currentUserId,
                            userNom: widget.currentUserNom,
                            autreId: createurId,
                            autreNom: projet['createur'],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            if (projet['githubUrl'] != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.code),
                label: const Text("Voir les infos GitHub"),
                onPressed: chargement ? null : chargerInfosGithub,
              ),
              if (chargement) const LinearProgressIndicator(),
              if (erreur != null) Text(erreur!, style: const TextStyle(color: Colors.red)),
              if (infosGithub != null) ...[
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(" ${infosGithub!['etoiles']} — ${infosGithub!['langagePrincipal'] ?? 'N/A'}"),
                  ],
                ),
                Text("Dernière mise à jour : ${infosGithub!['derniereMaj']}", style: const TextStyle(fontSize: 12)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class MessagePriveTab extends StatefulWidget {
  final String userId;
  final String userNom;
  final String autreId;
  final String autreNom;
  const MessagePriveTab({
    super.key,
    required this.userId,
    required this.userNom,
    required this.autreId,
    required this.autreNom,
  });

  @override
  State<MessagePriveTab> createState() => _MessagePriveTabState();
}

class _MessagePriveTabState extends State<MessagePriveTab> {
  List<dynamic> messages = [];
  final messageController = TextEditingController();
  bool chargement = true;

  @override
  void initState() {
    super.initState();
    chargerMessages();
  }

  Future<void> chargerMessages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/${widget.userId}/${widget.autreId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        messages = json.decode(response.body);
        chargement = false;
      });
    } else {
      setState(() => chargement = false);
    }
  }

  Future<void> envoyer() async {
    if (messageController.text.isEmpty) return;
    await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "expediteur": widget.userId,
        "destinataire": widget.autreId,
        "contenu": messageController.text,
      }),
    );
    messageController.clear();
    chargerMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Discussion avec ${widget.autreNom}")),
      body: Column(
        children: [
          Expanded(
            child: chargement
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? Center(
                        child: Text("Aucun message, lance la discussion", style: TextStyle(color: Colors.grey.shade600)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final estMoi = msg['expediteur'] == widget.userId;
                          return Align(
                            alignment: estMoi ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                              decoration: BoxDecoration(
                                color: estMoi ? const Color(0xFF4F46E5) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                              ),
                              child: Text(
                                msg['contenu'],
                                style: TextStyle(color: estMoi ? Colors.white : Colors.black87),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: "Ton message",
                      prefixIcon: Icon(Icons.chat_bubble_outline),
                    ),
                    onSubmitted: (_) => envoyer(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(icon: const Icon(Icons.send), onPressed: envoyer),
              ],
            ),
          ),
        ],
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
      Uri.parse('$baseUrl/profils/recherche?competence=${competenceController.text}'),
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
                  decoration: const InputDecoration(
                    labelText: "Compétence (ex: Flutter)",
                    prefixIcon: Icon(Icons.psychology_outlined),
                  ),
                  onSubmitted: (_) => rechercher(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(icon: const Icon(Icons.search), onPressed: rechercher),
            ],
          ),
        ),
        Expanded(
          child: resultats.isEmpty
              ? Center(
                  child: Text("Recherche un profil par compétence", style: TextStyle(color: Colors.grey.shade600)),
                )
              : ListView.builder(
                  itemCount: resultats.length,
                  itemBuilder: (context, index) {
                    final profil = resultats[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFF4F46E5), child: Icon(Icons.person, color: Colors.white)),
                        title: Text(profil['nom']),
                        subtitle: Text((profil['competences'] as List).join(', ')),
                      ),
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
    final response = await http.get(Uri.parse('$baseUrl/evenements'));
    if (response.statusCode == 200) {
      setState(() {
        evenements = json.decode(response.body);
      });
    }
  }

  Future<void> creerEvenement() async {
    if (nomController.text.isEmpty || dateController.text.isEmpty || lieuController.text.isEmpty) return;

    await http.post(
      Uri.parse('$baseUrl/evenements'),
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
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nomController,
                    decoration: const InputDecoration(
                      labelText: "Nom de l'événement",
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: "Date (jj/mm/aaaa)",
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: lieuController,
                    decoration: const InputDecoration(
                      labelText: "Lieu",
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: creerEvenement,
                      icon: const Icon(Icons.add),
                      label: const Text("Créer l'événement"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: evenements.isEmpty
              ? Center(
                  child: Text("Aucun événement pour l'instant", style: TextStyle(color: Colors.grey.shade600)),
                )
              : ListView.builder(
                  itemCount: evenements.length,
                  itemBuilder: (context, index) {
                    final evenement = evenements[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.event, color: Color(0xFF4F46E5)),
                        title: Text(evenement['nom']),
                        subtitle: Text(
                          "${evenement['date']} — ${evenement['lieu']}\n${(evenement['participants'] as List).length} participant(s)",
                        ),
                        isThreeLine: true,
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
    socket = IO.io(baseUrl, <String, dynamic>{
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
          child: messages.isEmpty
              ? Center(
                  child: Text("Aucun message pour l'instant", style: TextStyle(color: Colors.grey.shade600)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                      ),
                      child: Text(messages[index]),
                    ),
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
                  decoration: const InputDecoration(
                    labelText: "Ton message",
                    prefixIcon: Icon(Icons.chat_bubble_outline),
                  ),
                  onSubmitted: (_) => envoyerMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(icon: const Icon(Icons.send), onPressed: envoyerMessage),
            ],
          ),
        ),
      ],
    );
  }
}
