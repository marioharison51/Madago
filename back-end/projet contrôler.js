const express = require('express');
const router = express.Router();

// Stockage simple en mémoire (à remplacer par une vraie base de données plus tard)
let projets = [];

// Route POST publier un projet
router.post('/projets', (req, res) => {
  const { titre, description, besoins, createur } = req.body;

  if (!titre || !description || !createur) {
    return res.status(400).json({ message: "Titre, description et créateur requis" });
  }

  const projet = {
    id: Date.now().toString(),
    titre,
    description,
    besoins: besoins || [],
    createur,
    dateCreation: new Date(),
  };
  projets.push(projet);

  res.status(201).json({ message: "Projet publié", projet });
});

// Route GET liste des projets
router.get('/projets', (req, res) => {
  res.json(projets);
});

// Route GET un projet précis
router.get('/projets/:id', (req, res) => {
  const projet = projets.find((p) => p.id === req.params.id);
  if (!projet) {
    return res.status(404).json({ message: "Projet introuvable" });
  }
  res.json(projet);
});

module.exports = router;
