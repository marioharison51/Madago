const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: '*' } });

const profilRoutes = require('./profilController');
const authRoutes = require('./authController');
const projetRoutes = require('./projetController');
const messageRoutes = require('./messageController');

app.use(express.json());
app.use('/', profilRoutes);
app.use('/', authRoutes);
app.use('/', projetRoutes);
app.use('/', messageRoutes);

io.on('connection', (socket) => {
  console.log('Utilisateur connecté :', socket.id);

  socket.on('envoyerMessage', (data) => {
    io.emit('nouveauMessage', data);
  });

  socket.on('disconnect', () => {
    console.log('Utilisateur déconnecté :', socket.id);
  });
});

server.listen(3000, () => {
  console.log('🚀 Serveur lancé sur http://localhost:3000');
});
