const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const { charger, sauvegarder } = require('./storage');

let utilisateurs = charger('utilisateurs.json', []);

router.post('/register', async (req, res) => {
  const { nom, email, motDePasse } = req.body;

  if (!nom || !email || !motDePasse) {
    return res.status(400).json({ message: "Nom, email et mot de passe requis" });
  }

  const existe = utilisateurs.find((u) => u.email === email);
  if (existe) {
    return res.status(409).json({ message: "Un compte existe déjà avec cet email" });
  }

  const motDePasseHash = await bcrypt.hash(motDePasse, 10);
  const utilisateur = { id: Date.now().toString(), nom, email, motDePasseHash };
  utilisateurs.push(utilisateur);
  sauvegarder('utilisateurs.json', utilisateurs);

  res.status(201).json({ message: "Compte créé", id: utilisateur.id, nom, email });
});

router.post('/login', async (req, res) => {
  const { email, motDePasse } = req.body;

  const utilisateur = utilisateurs.find((u) => u.email === email);
  if (!utilisateur) {
    return res.status(401).json({ message: "Email ou mot de passe incorrect" });
  }

  const motDePasseValide = await bcrypt.compare(motDePasse, utilisateur.motDePasseHash);
  if (!motDePasseValide) {
    return res.status(401).json({ message: "Email ou mot de passe incorrect" });
  }

  res.json({ message: "Connexion réussie", id: utilisateur.id, nom: utilisateur.nom, email: utilisateur.email });
});

module.exports = router;
