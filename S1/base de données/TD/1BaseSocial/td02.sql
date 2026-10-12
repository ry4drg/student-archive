/* Question 1 –
Type de l’attribut “sexe”, sachant qu’il est représenté par ’F’ ou ’M’ ? : CHAR(1)
Quel type utiliser pour “téléphone” ? : VARCHAR ou CHAR
*/

/*
Question 3 –
Créer les tables avec leurs clés primaires, étrangères, et contraintes de valeurs de la question précédente.
Nommer les contraintes. Les “id” sont des entiers.
*/

CREATE TABLE Utilisateur (
    pseudo VARCHAR(50) PRIMARY KEY,
    nom VARCHAR(50),
    prenom VARCHAR(50),
    email VARCHAR(100) CHECK (email LIKE '%@%'),
    telephone VARCHAR(20),
    dateNaiss DATE,
    sexe CHAR(1) CHECK (sexe IN ('F', 'M')),
    idVille INT,
    datecrea DATE,
    datecloture DATE,
    FOREIGN KEY (idVille) REFERENCES Ville(idVille)
);

CREATE TABLE Ville (
    idVille INT PRIMARY KEY,
    nomVille VARCHAR(50),
    pays VARCHAR(50)
);

CREATE TABLE Page (
    idPage INT PRIMARY KEY,
    nomPage VARCHAR(50),
    typePage VARCHAR(50),
    createur VARCHAR(50),
    FOREIGN KEY (createur) REFERENCES Utilisateur(pseudo)
);

CREATE TABLE Publication (
    idPub INT PRIMARY KEY,
    titrePub VARCHAR(100),
    datePub DATE,
    textePub TEXT,
    idParent INT,
    pseudo VARCHAR(50),
    idpage INT,
    FOREIGN KEY (idParent) REFERENCES Publication(idPub),
    FOREIGN KEY (pseudo) REFERENCES Utilisateur(pseudo),
    FOREIGN KEY (idpage) REFERENCES Page(idPage)
);

CREATE TABLE Message (
    idMessage INT PRIMARY KEY,
    texteMessage TEXT,
    dateMessage DATE,
    auteur VARCHAR(50),
    FOREIGN KEY (auteur) REFERENCES Utilisateur(pseudo)
);

CREATE TABLE estMembre (
    pseudo VARCHAR(50),
    idPage INT,
    PRIMARY KEY (pseudo, idPage),
    FOREIGN KEY (pseudo) REFERENCES Utilisateur(pseudo),
    FOREIGN KEY (idPage) REFERENCES Page(idPage)
);

CREATE TABLE enLien (
    pseudoA VARCHAR(50),
    pseudoB VARCHAR(50),
    typeLien VARCHAR(50),
    dateLien DATE,
    PRIMARY KEY (pseudoA, pseudoB),
    FOREIGN KEY (pseudoA) REFERENCES Utilisateur(pseudo),
    FOREIGN KEY (pseudoB) REFERENCES Utilisateur(pseudo)
);

CREATE TABLE aimePage (
    idPage INT,
    pseudo VARCHAR(50),
    PRIMARY KEY (idPage, pseudo),
    FOREIGN KEY (idPage) REFERENCES Page(idPage),
    FOREIGN KEY (pseudo) REFERENCES Utilisateur(pseudo)
);

CREATE TABLE aimePub (
    idPub INT,
    pseudo VARCHAR(50),
    PRIMARY KEY (idPub, pseudo),
    FOREIGN KEY (idPub) REFERENCES Publication(idPub),
    FOREIGN KEY (pseudo) REFERENCES Utilisateur(pseudo)
);

CREATE TABLE cibles (
    idMessage INT,
    pseudo VARCHAR(50),
    PRIMARY KEY (idMessage, pseudo),
    FOREIGN KEY (idMessage) REFERENCES Message(idMessage),
    FOREIGN KEY (pseudo) REFERENCES Utilisateur(pseudo)
);

/*
Question 4 –
A l’aide d’une requête ALTER TABLE, ajouter une contrainte
de valeur pour vérifier que l’email contient une arobase @.
Utiliser LIKE.
*/
ALTER TABLE Utilisateur
ADD CONSTRAINT check_email_format CHECK (email LIKE '%@%');


/*
Question 6 – Insérer un nouvel utilisateur, en donnant seulement son pseudo, nom, prénom.
Ajouter un “J’aime” de cet internaute sur une page existante.
*/
-- Insérer un nouvel utilisateur
INSERT INTO Utilisateur (pseudo, nom, prenom) VALUES ('NouveauUtilisateur', 'Nom', 'Prenom');

-- Ajouter un "J'aime" sur une page existante (remplacez idPage et NouveauUtilisateur par les valeurs appropriées)
INSERT INTO aimePage (idPage, pseudo) VALUES (idPage, 'NouveauUtilisateur');

-- Effectuez une COMMIT après chaque question.
COMMIT;

/*
Question 7 – Supprimer ce nouvel utilisateur.
*/

-- Supprimer le nouvel utilisateur
DELETE FROM Utilisateur WHERE pseudo = 'NouveauUtilisateur';

-- Effectuez une COMMIT après chaque question.
COMMIT;

/*
Question 8 – Supprimer les messages privés d’un utilisateur de votre choix.
*/

-- Remplacez 'UtilisateurChoisi' par le pseudo de l'utilisateur dont vous voulez supprimer les messages privés
DELETE FROM Message WHERE auteur = 'UtilisateurChoisi';

-- Effectuez une COMMIT après chaque question.
COMMIT;

/*
Question 9 – Ajouter 10 jours à toutes les dates de publications.
*/

-- Ajouter 10 jours à toutes les dates de publications
UPDATE Publication SET datePub = datePub + INTERVAL '10' DAY;

-- Effectuez une COMMIT après chaque question.
COMMIT;

/*
Question 10 – Echanger les sexes : tous les ’M’ deviennent ’F’ et toutes les ’F’ deviennent ’M’.
*/

-- Échanger les sexes (tous les 'M' deviennent 'F' et vice versa)
UPDATE Utilisateur SET sexe = CASE WHEN sexe = 'M' THEN 'F' ELSE 'M' END;

-- Effectuez une COMMIT après chaque question.
COMMIT;

/*
Question 11 – Ajouter une colonne “nbAime” à la table “Page”.
Remplir cette colonne : pour chaque page, calculer le nombre de “J’aime” qu’a reçu cette page.
*/

-- Ajouter une colonne "nbAime" à la table "Page"
ALTER TABLE Page ADD COLUMN nbAime INT;

-- Mettre à jour la colonne "nbAime" avec le nombre de "J'aime" pour chaque page
UPDATE Page p
SET nbAime = (SELECT COUNT(*) FROM aimePage a WHERE a.idPage = p.idPage);

-- Effectuez une COMMIT après chaque question.
COMMIT;
