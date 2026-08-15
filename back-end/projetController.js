const express = require('express');
const router = express.Router();

// Stockage simple en mémoire (à remplacer par une vraie base de données plus tard)
let projets = [];

// Route POST publier un projet
router.post('/projets', (req, res) => {
  const { titre, description, besoins, createur, githubUrl } = req.body;

  if (!titre || !description || !createur) {
    return res.status(400).json({ message: "Titre, description et créateur requis" });
  }

  const projet = {
    id: Date.now().toString(),
    titre,
    description,
    besoins: besoins || [],
    createur,
    githubUrl: githubUrl || null,
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

// Route GET infos GitHub d'un projet (via l'API publique GitHub)
router.get('/projets/:id/github', async (req, res) => {
  const projet = projets.find((p) => p.id === req.params.id);
  if (!projet) {
    return res.status(404).json({ message: "Projet introuvable" });
  }
  if (!projet.githubUrl) {
    return res.status(400).json({ message: "Aucun lien GitHub associé à ce projet" });
  }

  const match = projet.githubUrl.match(/github\.com\/([^/]+)\/([^/]+)/);
  if (!match) {
    return res.status(400).json({ message: "URL GitHub invalide" });
  }
  const [, owner, repo] = match;

  try {
    const response = await fetch(`https://api.github.com/repos/${owner}/${repo.replace('.git', '')}`);
    if (!response.ok) {
      return res.status(response.status).json({ message: "Impossible de récupérer les infos GitHub" });
    }
    const data = await response.json();
    res.json({
      nom: data.name,
      description: data.description,
      etoiles: data.stargazers_count,
      langagePrincipal: data.language,
      derniereMaj: data.updated_at,
      url: data.html_url,
    });
  } catch (err) {
    res.status(500).json({ message: "Erreur lors de la récupération des infos GitHub" });
  }
});

module.exports = router;
