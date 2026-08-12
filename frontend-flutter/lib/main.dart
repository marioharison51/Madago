Future<void> fetchProfil() async {
  final response = await http.get(Uri.parse('http://localhost:3000/profil/ismael'));
  if (response.statusCode == 200) {
    setState(() {
      profil = json.decode(response.body);
    });
  }
}

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
                Text('Nom : ${profil['nom']}'),
                Text('Projet : ${profil['projet']}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // action pour modifier le profil
                  },
                  child: Text('Modifier le profil'),
                ),
                SizedBox(height: 20),
                Text('Messages :'),
                ...profil['messages'].map<Widget>((msg) => Text('${msg['sender']}: ${msg['text']}')).toList(),
              ],
            ),
          ),
  );
}
