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
- [x] Thème défini aléatoirement parmi une immense liste
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

### 2.3 Feed principal

**Description :** Affichage des dessins de la journée, triés par popularité.

**Spécifications :**
- [x] Tri par défaut : Posts les plus récents
- [x] Affichage : Liste façon Instagram
- [x] Informations visibles : pseudo de l'artiste, nombre de "Yeah", description, commentaires
- [x] Possibilité de trier par :
  - [x] Plus populaires
  - [x] Aléatoire (découverte)
- [ ] Rafraîchissement manuel (onLoad ou scrollUp)
- [x] Scroll infini
- [ ] Il faut avoir publié une image aujourd'hui pour pouvoir mettre des "Yeah"

### 2.4 Système de "Yeah"

**Description :** Mécanisme de vote/like pour les dessins.

**Spécifications :**
- [x] Un "Yeah" = un vote positif
- [ ] Limite : un "Yeah" par utilisateur par dessin, disponible si l'utilisateur a fait un dessin aujourd'hui
- [x] Compteur visible en temps réel
- [x] Possibilité de retirer son "Yeah"
- [x] Historique des "Yeah" reçus pour chaque utilisateur
- [x] Statistiques globales (total de "Yeah" reçus)

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
  - [ ] Chaque case : miniature du dessin, jour (date), nb de Yeah
  - [ ] Jours manqués clairement identifiables (miniature grisée, impossible d'agrandir)
  - [ ] Possibilité de naviguer entre les mois
- [ ] Clic sur un jour = affichage du dessin en grand

### 2.6 Interactions sociales

**Spécifications :**
- [ ] Commentaires sur les dessins
- [ ] Système de suivi (following/followers)
- [ ] Possibilité de suivre d'autres utilisateurs

## 3. Spécifications techniques

### 3.1 Plateformes
- [x] Android
- [x] Linux
- [x] Version web PWA
- [x] iOS

### 3.2 Architecture technique
- **Backend :** API RESTful (Hono)
- **Base de données :** PostgreSQL (Neon)
- **Stockage des images :** Bucket R2 Cloudflare
- **Notifications push :** Firebase Cloud Messaging
- **Authentification :**
  - [x] Username / mot de passe
  - [x] Discord OAuth

### 3.3 Sécurité
- [x] Chiffrement des données en transit (HTTPS)
- [x] Aucune donnée sensible (mot de passe chiffré SHA256)
- [x] Authentification sécurisée (token, refresh token)

## 4. Contraintes et règles métier

### 4.1 Règles de participation
- Un dessin par jour maximum
- Deadline stricte à minuit (Zurich)
- Le dessin doit correspondre au thème du jour
- Formats acceptés uniquement : images (pas de vidéos / gif / psd / autre)

### 4.2 Règles de contenu
- Contenu approprié uniquement (pas de nudité, violence, haine, etc.)
- Propriété intellectuelle respectée (pas de plagiat)
- Dessins originaux uniquement (pas de copies)
- Pas d'images générées par IA

## 5. Design et expérience utilisateur

### 5.1 Écrans principaux
- **Écran de Login :** Création ou connexion du compte
- **Écran d'accueil :** Thème du jour + bouton d'upload + feed
- **Feed :** Liste des dessins du jour
- **Profil :** Calendrier personnel + statistiques
- **Upload :** Interface de capture/import de dessin
- **Détail dessin :** Vue complète + "Yeah" + infos artiste

## 6. Planning et phases

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

## 7. Fonctionnalités bonus et améliorations futures

### 7.1 Gamification avancée

**Badges et achievements :**
- [ ] Badges de participation (7 jours, 30 jours, 100 jours, 365 jours)
- [ ] Achievements spéciaux :
  - [ ] Premier "Yeah" reçu
  - [ ] 10, 50, 100, 500, 1000 "Yeah" sur un dessin
  - [ ] 100, 500, 1000 dessins totaux
  - [ ] Participation pendant événements spéciaux (style Duolingo)
- [ ] Système de niveaux/rangs basé sur l'activité

**Compétitions :**
- [ ] Classement mensuel/annuel avec podium
- [ ] Défis spéciaux hebdomadaires ou thématiques
- [x] Affichage journalier sur Discord

### 7.2 Découverte et inspiration

**Section Explorer :**
- [x] Dessins les plus populaires de tous les temps
- [ ] Sélection de la rédaction

**Archives et recherche :**
- [ ] Archives des thèmes passés avec galeries filtrables
- [ ] Recherche avancée par :
  - [ ] Thème spécifique
  - [ ] Utilisateur
  - [ ] Date/période
  - [ ] Tags
- [ ] Page de statistiques globales de la plateforme

### 7.3 Communauté et social avancé

**Interactions enrichies :**
- [ ] Messages privés entre utilisateurs
- [ ] Notifications sociales :
  - [ ] Nouveau follower
  - [ ] Commentaire sur votre dessin
  - [ ] Mention dans un commentaire
  - [ ] Message privé reçu
- [ ] Partage externe vers autres réseaux sociaux (Instagram, Twitter, etc.)
- [ ] Création de collections/favoris personnels
- [ ] Système de tags personnalisés pour organiser ses dessins

**Outils communautaires :**
- [ ] Guidelines de la communauté visibles
- [ ] Espace FAQ interactif
- [ ] Section tutoriels/tips pour améliorer son dessin
- [ ] Forum ou espace discussion
- [ ] Événements communautaires spéciaux (contests, collaborations)
- [ ] Système de mentorat (artistes confirmés / débutants)

### 7.4 Améliorations du profil

**Confidentialité et personnalisation :**
- [ ] Profils privés (option de confidentialité)
- [ ] Bio enrichie (liens externes, réseaux sociaux)

**Statistiques avancées :**
- [ ] Graphiques d'évolution (moyenne de Yeah, etc.)
- [ ] Meilleurs thèmes par "Yeah"
- [ ] Taux de participation mensuel
- [ ] Temps moyen de dessin (si tracking implémenté)
- [ ] Export de son calendrier/portfolio en PDF ou image

**Fonctionnalités premium :**
- [ ] Thèmes personnalisés
- [ ] Badge premium visible
- [ ] Stockage illimité/qualité maximale des images
- [ ] Accès anticipé aux nouvelles fonctionnalités

### 7.5 Améliorations de l'expérience utilisateur

**Upload et édition :**
- [ ] Option de recadrage/rotation avant publication
- [ ] Possibilité de zoomer sur une image (comme Instagram)
- [ ] Filtre par niveau (débutant/confirmé)

### 7.6 Modération

**Système de modération :**
- [ ] Système de report par les utilisateurs
- [ ] Modération automatique (IA) pour détecter contenu inapproprié
- [ ] Modération manuelle pour les cas ambigus
- [ ] Sanctions graduées (avertissement, suspension, bannissement)

### 7.7 Ordre de priorité suggéré (post-MVP)

**Priorité haute** (améliore significativement l'expérience) :
1. Commentaires sur les dessins
2. Badges de participation de base (7, 30, 100 jours)
3. Section "Explorer" avec meilleurs dessins
4. Système de suivi (following/followers)
5. Notifications sociales basiques

**Priorité moyenne** (enrichit la plateforme) :
6. Messages privés
7. Recherche avancée
8. Archives des thèmes passés
9. Partage externe vers réseaux sociaux
10. Classement mensuel/annuel

**Priorité basse** (fonctionnalités "nice to have") :
11. Défis spéciaux hebdomadaires
12. Forum communautaire
13. Système de modération avancé
14. Statistiques avancées du profil

---

*Document mis à jour le 2025-10-20*
