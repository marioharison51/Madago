const express = require('express');
const router = express.Router();

// Stockage simple en mémoire (à remplacer par une vraie base de données plus tard)
let conversations = [];

// Route GET conversation entre deux utilisateurs
router.get('/messages/:userA/:userB', (req, res) => {
  const { userA, userB } = req.params;
  const historique = conversations.filter(
    (m) =>
      (m.expediteur === userA && m.destinataire === userB) ||
      (m.expediteur === userB && m.destinataire === userA)
  );
  res.json(historique);
});

// Route POST envoyer un message (fallback HTTP, en plus du temps réel)
router.post('/messages', (req, res) => {
  const { expediteur, destinataire, contenu } = req.body;
  if (!expediteur || !destinataire || !contenu) {
    return res.status(400).json({ message: "Expéditeur, destinataire et contenu requis" });
  }
  const message = { expediteur, destinataire, contenu, date: new Date() };
  conversations.push(message);
  res.status(201).json({ message: "Message envoyé", data: message });
});

module.exports = router;
