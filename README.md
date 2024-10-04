# Compilateur Langage MyC

## Aperçu

Ce document présente un aperçu du compilateur développé pour le langage MyC, couvrant **les phases I à VI**. Ce compilateur est conçu pour traiter divers aspects de la programmation, de la gestion des expressions arithmétiques simples aux appels de fonctions complexes.

## Phases de Développement

### Phase I: Gestion des Expressions Arithmétiques

- Support des expressions arithmétiques entières et flottantes.
- Invariant : Le PCode généré empile uniquement la valeur résultante de l'expression arithmétique.

### Phase II: Gestion et Vérification des Types

- Gestion des expressions mixtes (entiers et flottants).
- Conversion explicite d'entiers en flottants et détection d'erreurs de type (conversion implicite de flottants en entiers interdite).
- Invariant : Identique à la Phase I.

### Phase III: Gestion des Variables Globales

- Déclaration et utilisation de variables globales.
- Stockage et accès aux valeurs via un offset relatif à la base de la pile.

### Phase IV: Gestion des Branchements

- Implémentation des structures conditionnelles (if, if-else) et de boucles (while).

### Phase V: Gestion des Sous-blocs

- Gestion de la portée et de la visibilité des variables locales.
- Accès aux variables selon leur portée et le pointeur de bloc courant.
- Invariant : Le PCode gère la valeur de retour des sous-blocs et les effets de bord.

### Phase VI: Gestion des Appels de Fonctions

- Compilation des définitions et appels de fonctions pour des types entiers.
- Invariant : Le PCode généré empile la valeur de retour de la fonction appelée.
- La gestion des types dans les fonctions générales (arguments, type de retour) n'est pas encore completement opérationelle.

### Phase VII (Non Implémentée)

La phase VII, qui concerne l'ajout de type tableau et structure , n'a pas été implémentée dans cette version du compilateur.

# Contributeurs

Théophane Loloum, Théo Facen
