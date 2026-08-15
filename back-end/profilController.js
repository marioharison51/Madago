const express = require('express');
const router = express.Router();
const { charger, sauvegarder } = require('./storage');

let profils = charger('profils.json', {
  ismael: {
    nom: "Ismaël",
    projet: "Madago",
    competences: ["JavaScript", "Flutter", "Node.js"],
    messages: [],
    notes: [],
  },
});

router.get('/profil/:id', (req, res) => {
  const profil = profils[req.params.id];
  if (!profil) {
    return res.status(404).json({ message: "Profil introuvable" });
  }
  const moyenne = profil.notes.length
    ? profil.notes.reduce((a, b) => a + b, 0) / profil.notes.length
    : null;
  res.json({ ...profil, moyenneNotes: moyenne });
});

router.put('/profil/:id', (req, res) => {
  const profil = profils[req.params.id];
  if (!profil) {
    return res.status(404).json({ message: "Profil introuvable" });
  }
  const { nom, projet, competences } = req.body;
  profil.nom = nom || profil.nom;
  profil.projet = projet || profil.projet;
  profil.competences = competences || profil.competences;
  sauvegarder('profils.json', profils);
  res.json({ message: "Profil mis à jour", profil });
});

router.get('/profils/recherche', (req, res) => {
  const { competence } = req.query;
  if (!competence) {
    return res.status(400).json({ message: "Paramètre 'competence' requis" });
  }
  const resultats = Object.entries(profils)
    .filter(([id, profil]) =>
      profil.competences.some((c) => c.toLowerCase().includes(competence.toLowerCase()))
    )
    .map(([id, profil]) => ({ id, nom: profil.nom, competences: profil.competences }));
  res.json(resultats);
});

router.post('/profil/:id/message', (req, res) => {
  const profil = profils[req.params.id];
  if (!profil) {
    return res.status(404).json({ message: "Profil introuvable" });
  }
  const { sender, text } = req.body;
  profil.messages.push({ sender, text, date: new Date() });
  sauvegarder('profils.json', profils);
  res.json({ message: "Message ajouté", messages: profil.messages });
});

router.post('/profil/:id/noter', (req, res) => {
  const profil = profils[req.params.id];
  if (!profil) {
    return res.status(404).json({ message: "Profil introuvable" });
  }
  const { note } = req.body;
  if (typeof note !== 'number' || note < 1 || note > 5) {
    return res.status(400).json({ message: "La note doit être un nombre entre 1 et 5" });
  }
  profil.notes.push(note);
  sauvegarder('profils.json', profils);
  const moyenne = profil.notes.reduce((a, b) => a + b, 0) / profil.notes.length;
  res.json({ message: "Note ajoutée", moyenneNotes: moyenne, totalNotes: profil.notes.length });
});

module.exports = router;
