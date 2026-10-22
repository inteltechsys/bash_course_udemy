# CLAUDE.md : bash_course

## Projet
Dossier d'apprentissage du scripting Bash (cours + exercices pentest).
Machine : Zorin OS, hostname linux1. Tout est local, rien ne doit toucher d'autres dossiers.
Les scripts sont à la racine. Chaque script X a son test test_X.
Doc du projet : @README.md

## Règles pour les scripts
- Shebang `#!/bin/bash`, jamais `sh`
- Passer `shellcheck` avant de dire que c'est fini
- Mettre les variables entre guillemets ("$var")
- Commenter chaque bloc non évident, en français

## Tests
- Lancer le test d'un script après toute modification de ce script
- Ne jamais sauter, supprimer ou affaiblir un test pour le faire passer
- Montrer la sortie des tests, pas seulement dire que ça passe

## Sécurité
- Ne jamais écrire de secret, mot de passe ou clé dans un fichier
- Aucune commande destructrice (rm -rf, etc.) sans me demander d'abord
- Ne pas installer de nouveau paquet sans me l'expliquer
