const express = require('express');
const app = express();
const profilRoutes = require('./profilController');
const authRoutes = require('./authController');

app.use(express.json());
app.use('/', profilRoutes);
app.use('/', authRoutes);

app.listen(3000, () => {
  console.log('🚀 Serveur lancé sur http://localhost:3000');
});
