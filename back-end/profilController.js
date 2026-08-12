const express = require('express');
const router = express.Router();

// Exemple de données (à remplacer par MongoDB plus tard)
const profil = {
  nom: "Ismaël",
  projet: "Madago"
};

// Route GET pour récupérer le profil
router.get('/profil/:id', (req, res) => {
  res.json(profil);
});

// Route PUT pour modifier le profil
router.put('/profil/:id', (req, res) => {
  const { nom, projet } = req.body;
  profil.nom = nom || profil.nom;
  profil.projet = projet || profil.projet;
  res.json({ message: "Profil mis à jour", profil });
});

module.exports = router;
