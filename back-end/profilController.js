const express = require('express');
const router = express.Router();

// Exemple de données
let profil = {
  nom: "Ismaël",
  projet: "Madago",
  messages: []
};

// 🔹 Route GET profil
router.get('/profil/:id', (req, res) => {
  res.json(profil);
});

// 🔹 Route PUT profil
router.put('/profil/:id', (req, res) => {
  const { nom, projet } = req.body;
  profil.nom = nom || profil.nom;
  profil.projet = projet || profil.projet;
  res.json({ message: "Profil mis à jour", profil });
});

// 🔹 Route POST message
router.post('/message', (req, res) => {
  const { sender, text } = req.body;
  profil.messages.push({ sender, text, date: new Date() });
  res.json({ message: "Message ajouté", messages: profil.messages });
});

module.exports = router;
