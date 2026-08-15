const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, 'data');

if (!fs.existsSync(DATA_DIR)) {
  fs.mkdirSync(DATA_DIR);
}

function charger(nomFichier, valeurParDefaut) {
  const chemin = path.join(DATA_DIR, nomFichier);
  if (!fs.existsSync(chemin)) {
    return valeurParDefaut;
  }
  try {
    const contenu = fs.readFileSync(chemin, 'utf-8');
    return JSON.parse(contenu);
  } catch (err) {
    return valeurParDefaut;
  }
}

function sauvegarder(nomFichier, donnees) {
  const chemin = path.join(DATA_DIR, nomFichier);
  fs.writeFileSync(chemin, JSON.stringify(donnees, null, 2), 'utf-8');
}

module.exports = { charger, sauvegarder };
