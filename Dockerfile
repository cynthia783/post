# Utilise l'image officielle de Postiz comme base
FROM ghcr.io/gitroomhq/postiz-app:latest

# Copie ton fichier .env dans le conteneur
COPY .env /app/.env

# Définis le répertoire de travail
WORKDIR /app

# Installe les dépendances si nécessaire
RUN npm install

# Expose les ports nécessaires
EXPOSE 5000 3000

# Démarre l'application
CMD ["npm", "start"]
