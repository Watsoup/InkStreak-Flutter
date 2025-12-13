# Cahier des charges - InkStreak
Application pour le cours de AdMoApp en Master HES-SO, réalisé par Gabriel Marino Jarrin et Jad Tayan

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
- [ ] Génération automatique d'un nouveau thème chaque jour à minuit (Zurich)
- [ ] Affichage du thème du jour dès l'ouverture de l'application
- [ ] Notification push pour annoncer le nouveau thème
- [ ] Thème défini aléatoirement parmi une immense liste
- [ ] Langue des thèmes / de l'app : Anglais par défaut

### 2.2 Import de dessin

**Description :** Les utilisateurs peuvent uploader leur dessin jusqu'à minuit.

**Spécifications :**
- [ ] Deux méthodes d'import :
  - [ ] Photo depuis l'appareil photo (capture directe)
  - [ ] Import depuis la galerie de l'appareil
- [ ] Formats acceptés : JPEG, PNG, HEIC
- [ ] Taille maximale du fichier : 10-20 MB, compresser si besoin
- [ ] Un seul dessin par utilisateur par jour
- [ ] Deadline : minuit (Zurich)

### 2.3 Feed principal

**Description :** Affichage des dessins de la journée, triés par popularité.

**Spécifications :**
- [ ] Tri par défaut : Posts les plus récents
- [ ] Affichage : Liste façon Instagram
- [ ] Informations visibles : pseudo de l'artiste, nombre de "Yeah", description, commentaires
- [ ] Possibilité de trier par :
  - [ ] Plus populaires
  - [ ] Aléatoire (découverte)
- [ ] Rafraîchissement manuel (onLoad ou scrollUp)
- [ ] Scroll infini
- [ ] Il faut avoir publié une image aujourd'hui pour pouvoir mettre des "Yeah" (à voir si c'est gardé)

### 2.4 Système de "Yeah"

**Description :** Mécanisme de vote/like pour les dessins.

**Spécifications :**
- [ ] Un "Yeah" = un vote positif
- [ ] Limite : un "Yeah" par utilisateur par dessin, disponible si l'utilisateur a fait un dessin aujourd'hui
- [ ] Compteur visible en temps réel
- [ ] Possibilité de retirer son "Yeah"
- [ ] Historique des "Yeah" reçus pour chaque utilisateur
- [ ] Statistiques globales (total de "Yeah" reçus)

### 2.5 Profil utilisateur

**Description :** Page personnelle de chaque utilisateur avec calendrier des participations.

**Spécifications :**
- [ ] Informations du profil :
  - [ ] Pseudo
  - [ ] Photo de profil
  - [ ] Bio (description courte)
  - [ ] Date d'inscription
  - [ ] Statistiques (série actuelle, série maximale, total de dessins, total de Yeah)
- [ ] Calendrier visuel :
  - [ ] Vue mensuelle avec miniatures des dessins
  - [ ] Chaque case : miniature du dessin, jour (date),
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
- [ ] Android
- [ ] Linux
- [ ] Version web PWA
- [ ] iOS

### 3.2 Architecture technique
- **Backend :** API RESTful (Hono)
- **Base de données :** PostgreSQL (Neon)
- **Stockage des images :** Bucket R2 Cloudflare
- **Notifications push :** Firebase Cloud Messaging
- **Authentification :**
  - [ ] Username / mot de passe
  - [ ] Discord OAuth

### 3.3 Sécurité
- [ ] Chiffrement des données en transit (HTTPS)
- [ ] Aucune donnée sensible (mot de passe chiffré SHA256)
- [ ] Authentification sécurisée (token, refresh token)

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
- [ ] Système de thème quotidien
- [ ] Upload de dessin (photo/galerie)
- [ ] Feed avec tri par "Yeah"
- [ ] Système de "Yeah"
- [ ] Profil avec calendrier basique
- [ ] Authentification simple

### Phase 2 - Enrichissement
- [ ] Notifications enrichies
- [ ] Commentaires
- [ ] Système de suivi utilisateurs
- [ ] Partage externe

### Phase 3 - Communauté avancée
- [ ] Classements
- [ ] Section Explorer

## 7. Fonctionnalités bonus et améliorations futures

### 7.1 Gamification avancée

**Badges et achievements :**
- [ ] Modération avancée
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
- [ ] Affichage journalier sur Discord

### 7.2 Découverte et inspiration

**Section Explorer :**
- [ ] Dessins les plus populaires de tous les temps
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
- [ ] Notifications sociales :
  - [ ] Nouveau follower
  - [ ] Commentaire sur votre dessin
  - [ ] Mention dans un commentaire
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

### 7.7 Ordre de priorité suggéré (post-MVP)

**Priorité haute** (améliore significativement l'expérience) :
1. Commentaires sur les dessins
2. Badges de participation de base (7, 30, 100 jours)
3. Section "Explorer" avec meilleurs dessins
4. Système de suivi (following/followers)
5. Notifications sociales basiques

**Priorité moyenne** (enrichit la plateforme) :
6. Recherche avancée
7. Archives des thèmes passés
8. Partage externe vers réseaux sociaux
9. Classement mensuel/annuel

**Priorité basse** (fonctionnalités "nice to have") :
10. Défis spéciaux hebdomadaires
11. Forum communautaire
12. Système de modération avancé
13. Statistiques avancées du profil

---

*Document mis à jour le 2025-10-27*
