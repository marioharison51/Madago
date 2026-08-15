const express = require('express');
const router = express.Router();

// Stockage simple en mémoire (à remplacer par une vraie base de données plus tard)
let evenements = [];

// Route POST créer un événement
router.post('/evenements', (req, res) => {
  const { nom, date, lieu } = req.body;

  if (!nom || !date || !lieu) {
    return res.status(400).json({ message: "Nom, date et lieu requis" });
  }

  const evenement = {
    id: Date.now().toString(),
    nom,
    date,
    lieu,
    participants: [],
  };
  evenements.push(evenement);

  res.status(201).json({ message: "Événement créé", evenement });
});

// Route GET liste des événements
router.get('/evenements', (req, res) => {
  res.json(evenements);
});

// Route POST participer à un événement
router.post('/evenements/:id/participer', (req, res) => {
  const evenement = evenements.find((e) => e.id === req.params.id);
  if (!evenement) {
    return res.status(404).json({ message: "Événement introuvable" });
  }
  const { participant } = req.body;
  if (!evenement.participants.includes(participant)) {
    evenement.participants.push(participant);
  }
  res.json({ message: "Participation enregistrée", evenement });
});

module.exports = router;
