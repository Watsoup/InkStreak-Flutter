# Cahier des charges - InkStreak

## 1. Présentation du projet

### 1.1 Contexte
InkStreak est un réseau social mobile dédié au dessin quotidien, inspiré du concept du Inktober. L'application encourage la pratique régulière du dessin à travers des défis quotidiens thématiques et une dynamique communautaire.

### 1.2 Objectifs
- Encourager la pratique quotidienne du dessin
- Créer une communauté d'artistes amateurs et confirmés
- Gamifier l'expérience de création artistique
- Offrir une vitrine pour les créations quotidiennes

### 1.3 Cible
- Artistes amateurs et professionnels
- Personnes souhaitant développer une pratique de dessin régulière
- Communauté créative cherchant l'inspiration et le challenge
- Tranche d'âge : 13-45 ans principalement

## 2. Fonctionnalités principales

### 2.1 Système de thème quotidien

**Description :** Un thème de dessin est imposé chaque jour à tous les utilisateurs.

**Spécifications :**
- [x] Génération automatique d'un nouveau thème chaque jour à minuit (Zurich)
- [x] Affichage du thème du jour dès l'ouverture de l'application
- [ ] Notification push pour annoncer le nouveau thème
- [x] Thème définit aléatoirement parmi une immense liste
- [x] Langue des thèmes / de l'app : Anglais par défaut

### 2.2 Import de dessin

**Description :** Les utilisateurs peuvent uploader leur dessin jusqu'à minuit.

**Spécifications :**
- [x] Deux méthodes d'import :
  - [x] Photo depuis l'appareil photo (capture directe)
  - [x] Import depuis la galerie de l'appareil
- [x] Formats acceptés : JPEG, PNG, HEIC
- [x] Taille maximale du fichier : 10-20 MB, compresser si besoin
- [x] Un seul dessin par utilisateur par jour
- [x] Deadline : minuit (Zurich)
- [ ] Option de recadrage/rotation avant publication (bonus)

### 2.3 Feed principal

**Description :** Affichage des dessins de la journée, triés par popularité.

**Spécifications :**
- [x] Tri par défaut : Post les plus récents
- [x] Affichage : Liste façon Instagram
- [x] Informations visibles : pseudo de l'artiste, nombre de "Yeah",  description, commentaires
- [x] Possibilité de trier par :
  - [x] Plus populaires
  - [x] Aléatoire (découverte)
- [ ] Rafraîchissement manuel (onLoad ou scrollUp)
- [x] Scroll infini
- [ ] Possibilité de zoomer sur ine image (comme Instagram, encore)
- [ ] Il faut avoir publié une image aujourd'hui pour pouvoir mettre des "Yeah"
- [ ] Filtre par niveau (débutant/confirmé) ? (Bonus)

### 2.4 Système de "Yeah"

**Description :** Mécanisme de vote/like pour les dessins.

**Spécifications :**
- Un "Yeah" = un vote positif
- Limite : un "Yeah" par utilisateur par dessin, disponible si l'utilisateur a fait un dessin aujourd'hui
- Compteur visible en temps réel
- Possibilité de retirer son "Yeah"
- Historique des "Yeah" reçus pour chaque utilisateur
- Statistiques globales (total de "Yeah" reçus)
- Système de points/récompenses basé sur les "Yeah" (Bonus -> badges ou achievement)

### 2.5 Profil utilisateur

**Description :** Page personnelle de chaque utilisateur avec calendrier des participations.

**Spécifications :**
- [x] Informations du profil :
  - [x] Pseudo
  - [x] Photo de profil
  - [x] Bio (description courte)
  - [x] Date d'inscription
  - [x] Statistiques (série actuelle, série maximale, total de dessins, total de Yeah)
- [ ] Calendrier visuel :
  - [ ] Vue mensuelle avec miniatures des dessins
  - [ ] Chaque case -> Miniature du dessin, Jour (date), nb de Yeah
  - [ ] Jours manqués clairement identifiables -> Miniature grisée, impossible d'aggrandir
  - [ ] Possibilité de naviguer entre les mois
- [ ] Clic sur un jour = affichage du dessin en grand
- [ ] Possibilité de suivre d'autres utilisateurs
- [x] Système de bio/description/pdp personnalisable ?

### 2.6 Misc
- [ ] Commentaires sur les dessins
- [ ] Messages privés
- [ ] Système de suivi (following/followers)

## 3. Fonctionnalités secondaires

### 3.2 Gamification avancée
- [ ] Badges de participation (7 jours, 30 jours, 100 jours, etc.)
- [ ] Achievements spéciaux (premier "Yeah", 100 "Yeah" sur un dessin, etc.)
- [ ] Classement mensuel/annuel
- [ ] Défis spéciaux hebdomadaires
- [x] Affichage journalier sur Discord

### 3.3 Découverte et inspiration
- [x] Section "Explorer" avec dessins populaires de tous les temps
- [ ] Archives des thèmes passés avec galeries
- [ ] Recherche par thème, utilisateur, date

## 4. Spécifications techniques

### 4.1 Plateformes
- [x] Android
- [x] Linux
- [x] Version web PWA
- [x] iOS (Bonus)

### 4.2 Architecture technique
- Backend : API RESTful (Hono)
- Base de données : PostgreSQL (Neon)
- Stockage des images : Bucket R2 Cloudflare
- Notifications push : Firebase Cloud Messaging
- Authentification : 
  - [x] Username / mot de passe
  - [x] Discord
  - [ ] (OAuth en bonus)

### 4.4 Sécurité
- [x] Chiffrement des données en transit (HTTPS)
- [x] Aucune donnée sensible (mot de passe chiffré SHA256)
- [x] Authentification sécurisée (token, refresh token)

## 5. Contraintes et règles métier

### 5.1 Règles de participation
- Un dessin par jour maximum
- Deadline stricte à minuit
- Le dessin doit correspondre au thème du jour
- Formats acceptés uniquement : images (pas de vidéos / gif / psd / autre)

### 5.2 Règles de contenu
- Contenu approprié uniquement (pas de nudité, violence, haine, etc.)
- Propriété intellectuelle respectée (pas de plagiat)
- Dessins originaux uniquement (pas de copies)
- Pas d'images générées par IA

### 5.3 Modération (BONUS)
- Système de report par les utilisateurs
- Modération automatique (IA) pour détecter contenu inapproprié
- Modération manuelle pour les cas ambigus
- Sanctions graduées (avertissement, suspension, bannissement)

## 6. Design et expérience utilisateur

### 6.3 Écrans principaux
- **Écran de Login**: Création ou connexion du compte
- **Écran d'accueil :** Thème du jour + bouton d'upload + feed
- **Feed :** Liste des dessins du jour
- **Profil :** Calendrier personnel + statistiques
- **Upload :** Interface de capture/import de dessin
- **Détail dessin :** Vue complète + "Yeah" + infos artiste

## 7. Planning et phases

### Phase 1 - MVP (Minimum Viable Product)
- [x] Système de thème quotidien
- [x] Upload de dessin (photo/galerie)
- [x] Feed avec tri par "Yeah"
- [x] Système de "Yeah"
- [ ] Profil avec calendrier basique
- [x] Authentification simple

### Phase 2 - Enrichissement
- [ ] Système de suivi utilisateurs
- [ ] Commentaires
- [ ] Badges et achievements
- [ ] Notifications enrichies
- [ ] Partage externe

### Phase 3 - Communauté avancée
- [ ] Messagerie privée
- [ ] Défis spéciaux
- [x] Classements
- [ ] Section Explorer
- [ ] Modération avancée


---

## 11.1 Fonctionnalités secondaires (post-v1)

### Gamification avancée

- Badges de participation multiples (7 jours, 30 jours, 100 jours, 365 jours, etc.)
- Achievements spéciaux :
    - Premier "Yeah" reçu
    - 10, 50, 100, 500, 1000 "Yeah" sur un dessin
    - 100, 500, 1000 dessins totaux
    - Participation pendant événements spéciaux (duolingo style)

- Classement mensuel/annuel avec podium
- Défis spéciaux hebdomadaires ou thématiques
- Système de niveaux/rangs basé sur l'activité

### Découverte et inspiration

- [x] Section "Explorer" avec :
    - [x] Dessins les plus populaires de tous les temps
    - [ ] Sélection de la rédaction

- [ ] Archives des thèmes passés avec galeries filtrables
- [ ] Recherche avancée par :
    - [ ] Thème spécifique
    - [ ] Utilisateur
    - [ ] Date/période
    - [ ] Tags

- [ ] Page de statistiques globales de la plateforme (bonus)

### Communauté et social

- Commentaires sur les dessins
- Messages privés entre utilisateurs
- Système de suivi avancé (following/followers)
- Notifications sociales :
    - Nouveau follower
    - Commentaire sur votre dessin
    - Mention dans un commentaire
    - Message privé reçu

- Partage externe vers autres réseaux sociaux (Instagram, Twitter, etc.)
- Création de collections/favoris personnels
- Système de tags personnalisés pour organiser ses dessins

### Fonctionnalités communautaires

- Guidelines de la communauté visibles
- Espace FAQ interactif
- Section tutoriels/tips pour améliorer son dessin
- Forum ou espace discussion (optionnel)
- Événements communautaires spéciaux (contests, collaborations)
- Système de mentorat (artistes confirmés / débutants)

### Améliorations du profil

- Profils privés (option de confidentialité)
- Bio enrichie (liens externes, réseaux sociaux)
- Statistiques détaillées :
    - Graphiques d'évolution (Yeah average...)
    - Meilleurs thèmes par "Yeah"
    - Taux de participation mensuel
    - Temps moyen de dessin (si tracking implémenté)
- Export de son calendrier/portfolio en PDF ou image

- Thèmes personnalisés pour soi-même
- Statistiques avancées
- Badge premium visible
- Stockage illimité/qualité maximale des images
- Accès anticipé aux nouvelles fonctionnalités

## 11.3 Ordre de priorité suggéré (post-v1)
### Priorité haute (améliore significativement l'expérience)

1. Commentaires sur les dessins
2. Badges de participation de base (7, 30, 100 jours)
3. Section "Explorer" avec meilleurs dessins
4. Système de suivi (following/followers)
5. Notifications sociales basiques

### Priorité moyenne (enrichit la plateforme)
6. Messages privés
7. Recherche avancée
8. Archives des thèmes passés
9. Partage externe vers réseaux sociaux
10. Classement mensuel/annuel

### Priorité basse (fonctionnalités "nice to have")
11. Défis spéciaux hebdomadaires
14. Forum communautaire

- Système de report de contenu inapproprié
- Modération (automatique et manuelle)
- Guidelines de la communauté
- Espace FAQ/tutoriels