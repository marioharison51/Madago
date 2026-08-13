const express = require('express');
const router = express.Router();

// Stockage simple en mémoire (à remplacer par une vraie base de données plus tard)
let profils = {
  ismael: { nom: "Ismaël", projet: "Madago", messages: [] },
};

// Route GET profil
router.get('/profil/:id', (req, res) => {
  const profil = profils[req.params.id];
  if (!profil) {
    return res.status(404).json({ message: "Profil introuvable" });
  }
  res.json(profil);
});

// Route PUT profil
router.put('/profil/:id', (req, res) => {
  const profil = profils[req.params.id];
  if (!profil) {
    return res.status(404).json({ message: "Profil introuvable" });
  }
  const { nom, projet } = req.body;
  profil.nom = nom || profil.nom;
  profil.projet = projet || profil.projet;
  res.json({ message: "Profil mis à jour", profil });
});

// Route POST message
router.post('/profil/:id/message', (req, res) => {
  const profil = profils[req.params.id];
  if (!profil) {
    return res.status(404).json({ message: "Profil introuvable" });
  }
  const { sender, text } = req.body;
  profil.messages.push({ sender, text, date: new Date() });
  res.json({ message: "Message ajouté", messages: profil.messages });
});

module.exports = router;
