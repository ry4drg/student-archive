/* Question 1
Créer un type etatCivil avec les attributs nom, prenom de type chaîne, dateNaiss de type date, sexe de type CHAR(1).
*/
CREATE TYPE etatCivil AS OBJECT (
    nom VARCHAR2(50),
    prenom VARCHAR2(50),
    dateNaiss DATE,
    sexe CHAR(1)
);

/* Question 2
Créer les types suivants, dans lequel identite est de type etatCivil.
Pour les autres attributs, reprendre les types de la base Ecole.
— eleveT(numEleve, identite, poids, annee)
— profT(numProf, identite, specialite, dateEntree, derProm, salaireBase, salaireActuel)
*/
CREATE TYPE eleveT AS OBJECT (
    Num_eleve NUMBER,
    identite etatCivil,
    poids NUMBER,
    annee NUMBER
);

CREATE TYPE profT AS OBJECT (
    Num_prof NUMBER,
    identite etatCivil,
    specialite VARCHAR2(50),
    dateEntree DATE,
    derProm DATE,
    salaireBase DECIMAL(10, 2),
    salaireActuel DECIMAL(10, 2)
);

/* Question 3
Créer les tables correspondantes, avec les contraintes de clés primaires et de valeur sur le sexe qui ne peut être que ’M’ ou ’F’.
*/
CREATE TABLE ELEVES OF eleveT (
    CONSTRAINT PK_ELEVES PRIMARY KEY(numEleve),
    CONSTRAINT chk_sexe_eleve CHECK (identite.sexe IN ('M','F'))
);

CREATE TABLE PROFESSEURS OF profT (
    CONSTRAINT PK_PROF PRIMARY KEY(numProf),
    CONSTRAINT chk_sexe_prof CHECK (identite.sexe IN ('M','F'))
);

/* Question 4 :
Insérer les 5 premiers élèves et les 3 premiers professeurs du fichier baseEcole.sql
*/
ALTER SESSION set NLS_date_format = 'DD-MM-YYYY';

Insert into Eleves Values (1, etatCivil('Brisefer', 'Benoit', '10-12-1978', 'M'), 35, 1);
Insert into Eleves Values (2, etatCivil('Génial', 'Olivier', '10-04-1978', 'M'), 42, 1);
Insert into Eleves Values (3, etatCivil('Jourdan', 'Gil', '28-06-1974', 'F'), 72, 2);
Insert into Eleves Values (4, etatCivil('Spring', 'Jerry', '16-02-1974', 'M'), 78, 2);
Insert into Eleves Values (5, etatCivil('Tsuno', 'Yoko', '29-10-1977', 'F'), 45, 1);

Insert into Professeurs Values(1, etatCivil('Bottle', 'Prenom1', '01-10-1950', 'M'), 'poésie', '01-10-1970', '01-10-1988', 2000000, 2600000);
Insert into Professeurs Values(2, etatCivil('Bolenov', 'Prenom2', '15-11-1948', 'F'), 'réseau', '15-11-1968', '01-10-1998', 1900000, 2468000);
Insert into Professeurs Values(3, etatCivil('Tonilaclasse', 'Prenom3', '01-10-1959', 'M'), 'poo', '01-10-1979', '01-01-1989', 1900000, 2360000);

/* Question 5 */
/* 1. Nombre d’élèves par sexe. */
SELECT e.identite.sexe, COUNT(*) AS nombre_eleves
FROM Eleves e
GROUP BY e.identite.sexe;


/* 2. Noms des élèves nés avant 1975. */
SELECT e.identite.nom, e.identite.dateNaiss
FROM Eleves e
WHERE EXTRACT(YEAR FROM e.identite.dateNaiss) < 1975;

/* 3. Noms des élèves qui sont nés la même année. */
/***** Pas trouvé : DISTINCT *****/

/* Question 6 :  L’élève ’Benoît Brisefer’ devient ’Bernadette Brisefer’ de sexe féminin. Ecrire requêtes de mise à jour nécessaires */
-- Mettre à jour le nom et le prénom de l'élève
UPDATE Eleves e
SET e.identite.nom = 'Brisefer', e.identite.prenom = 'Bernadette', e.identite.sexe = 'F'
WHERE e.identite.nom = 'Brisefer' AND e.identite.prenom = 'Benoit';

-- Afficher les résultats mis à jour
SELECT e.Num_eleve, e.identite.nom, e.identite.prenom, e.identite.dateNaiss, e.identite.sexe, e.poids, e.annee
FROM Eleves e;

/* Question 7 : Supprimer les professeurs dont le nom commence par B. */
DELETE From Professeurs p
WHERE SUBSTR(p.identite.nom, 1, 1) = 'B';
