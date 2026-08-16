const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const { charger, sauvegarder } = require('./storage');

let utilisateurs = charger('utilisateurs.json', []);
let profils = charger('profils.json', {});

const transporteur = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

router.post('/register', async (req, res) => {
  const { nom, email, motDePasse } = req.body;

  if (!nom || !email || !motDePasse) {
    return res.status(400).json({ message: "Nom, email et mot de passe requis" });
  }

  const emailNormalise = email.trim().toLowerCase();
  const existe = utilisateurs.find((u) => u.email === emailNormalise);
  if (existe) {
    return res.status(409).json({ message: "Un compte existe déjà avec cet email" });
  }

  const motDePasseHash = await bcrypt.hash(motDePasse, 10);
  const id = Date.now().toString();
  const utilisateur = { id, nom, email: emailNormalise, motDePasseHash };
  utilisateurs.push(utilisateur);
  sauvegarder('utilisateurs.json', utilisateurs);

  profils[id] = {
    nom,
    projet: "",
    competences: [],
    photoUrl: "",
    messages: [],
    notes: [],
  };
  sauvegarder('profils.json', profils);

  res.status(201).json({ message: "Compte créé", id, nom, email: emailNormalise });
});

router.post('/login', async (req, res) => {
  const { email, motDePasse } = req.body;

  const emailNormalise = (email || '').trim().toLowerCase();
  const utilisateur = utilisateurs.find((u) => u.email === emailNormalise);
  if (!utilisateur) {
    return res.status(401).json({ message: "Email ou mot de passe incorrect" });
  }

  const motDePasseValide = await bcrypt.compare(motDePasse, utilisateur.motDePasseHash);
  if (!motDePasseValide) {
    return res.status(401).json({ message: "Email ou mot de passe incorrect" });
  }

  res.json({
    message: "Connexion réussie",
    id: utilisateur.id,
    nom: utilisateur.nom,
    email: utilisateur.email,
  });
});

router.post('/mot-de-passe-oublie', async (req, res) => {
  const { email } = req.body;
  const emailNormalise = (email || '').trim().toLowerCase();
  const utilisateur = utilisateurs.find((u) => u.email === emailNormalise);
  if (!utilisateur) {
    return res.status(404).json({ message: "Aucun compte trouvé avec cet email" });
  }

  const nouveauMotDePasse = Math.random().toString(36).slice(-8);
  utilisateur.motDePasseHash = await bcrypt.hash(nouveauMotDePasse, 10);
  sauvegarder('utilisateurs.json', utilisateurs);

  try {
    await transporteur.sendMail({
      from: `"Madago" <${process.env.EMAIL_USER}>`,
      to: utilisateur.email,
      subject: "Réinitialisation de ton mot de passe Madago",
      text: `Bonjour ${utilisateur.nom},\n\nTon nouveau mot de passe temporaire est : ${nouveauMotDePasse}\n\nConnecte-toi avec celui-ci, tu pourras le changer ensuite depuis ton profil.\n\nL'équipe Madago`,
    });
    res.json({ message: "Un email avec ton nouveau mot de passe a été envoyé" });
  } catch (err) {
    res.status(500).json({ message: "Erreur lors de l'envoi de l'email" });
  }
});

module.exports = router;
