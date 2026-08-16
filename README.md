 Madago

Madago est une plateforme collaborative destinée à connecter les talents locaux, partager des projets innovants et transformer des idées en opportunités d'affaires.

Objectifs

- Créer un **réseau local** où les talents se trouvent facilement
- Favoriser la **coopération** plutôt que la compétition
- Donner de la **visibilité** aux projets innovants
- Offrir un espace pour transformer une idée en **projet d'affaires concret**

 Fonctionnalités

- Authentification: inscription, connexion, réinitialisation de mot de passe par email
- Profils utilisateurs: nom, projet, compétences, photo de profil, système de réputation (notation par étoiles)
- Publication de projets: titre, description, besoins recherchés, lien GitHub optionnel
- Intégration GitHub: affichage automatique des infos d'un repo lié à un projet (étoiles, langage, dernière mise à jour)
- Recherche par compétences : retrouver des profils selon leurs domaines
- Messagerie privée: contacter directement le créateur d'un projet
- Chat en temps réel : discussion publique instantanée (Socket.io)
- Événements et ateliers : calendrier pour meetups, formations, hackathons
- Filtres et tri des projets: par mot-clé, récence, ordre alphabétique

- Node.js et Express API REST
- Socket.io messagerie en temps réel
- bcryptjs hashage des mots de passe
- Nodemailer envoi d'email pour reset mot de passe
- Persistance des données en fichiers JSON
- Hébergé sur Render

CI/CD
  - `Node.js CI` — vérifie l'installation des dépendances backend
  - `Flutter CI` — compile l'APK Android à chaque modification du frontend
  
Le backend est déployé sur Render à la racine du repo, l'APK Android est généré par le workflow et disponible dans les Releases.
Développé sur https://github.com/marioharison51
