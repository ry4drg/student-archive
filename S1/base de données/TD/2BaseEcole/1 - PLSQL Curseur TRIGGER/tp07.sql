/************ Procédures et fonctions stockées ************/
/* 1.
Ecrire une fonction stockée qui prend en paramètre un num prof et retourne le nombre de cours dont ce professeur a la charge.
*/
CREATE OR REPLACE FUNCTION NbCoursCharge(NUM_PROFESSEUR NUMBER) RETURN NUMBER IS
    NB number;

BEGIN
	SELECT count(*) INTO NB FROM charge WHERE num_prof = NUM_PROFESSEUR;
	return NB;
END;

/* 2.
Utiliser la fonction de la question précédente dans une requête SQL pour afficher la liste des professeurs qui n’ont en charge aucun cours.
*/
SELECT num_prof, nom FROM professeurs WHERE NbCoursCharge(num_prof) = 0;

/* 3.
Ecrire une fonction stockée qui prend en paramètre un nom d’élève et qui retourne son num eleve.
En cas d’erreur, retourner 0. Utiliser des exceptions.
*/
CREATE OR REPLACE FUNCTION GetNumEleveBynom(NOM_ELEVE VARCHAR2) RETURN NUMBER IS
  NUM NUMBER;

BEGIN
  BEGIN
      SELECT num_eleve INTO NUM FROM eleves WHERE nom = NOM_ELEVE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NUM := 0;
  END;
  return NUM;
END;

/* 4
E ́crire une proc ́edure stockée qui prend en paramètres un nom d’élève, un nom de cours et une note et qui insère ou mets à jour cette note pour ce cours pour cet élève.
Utiliser la fonction précédente.
La procédure prend en plus un paramètre de sortie de type entier qui décrit le résultat de l’exécution de la procédure :
il contiendra 1 si la note a été insérée,
2 si la note a été mise à jour,
3 en cas d’erreur sur le nom de l’élève ou du cours (pas/trop d’élèves/de cours avec ce nom),
4 en cas d’autre erreur.
*/

CREATE OR REPLACE PROCEDURE InsererOuMaj(
  NOM_ELEVE VARCHAR2,
  NOM_COURS VARCHAR2,
  NOTE NUMBER,
  SORTIE_RESULT_PROC NUMBER

RETURN

/************ Déclencheurs ************/

/* 5.
Ecrire un déclencheur qui vérifie que le salaire d’un professeur ne diminue pas.
*/

CREATE OR REPLACE TRIGGER verif_salaire_prof
BEFORE UPDATE ON professeurs
FOR EACH ROW
DECLARE
BEGIN
  -- Vérification que le nouveau salaire n'est pas inférieur à l'ancien salaire
  IF :NEW.salaire_actuel < :OLD.salaire_actuel THEN
    RAISE_APPLICATION_ERROR(-20001, 'Erreur : Le salaire d''un professeur ne peut pas diminuer.');
  END IF;
END;


/* 6.
A l’aide d’un CREATE combiné à un SELECT, créer une table Prof specialite qui contient le nombre de professeurs par spécialité.
Ajouter sa clé primaire.
*/

CREATE TABLE Prof_Specialite AS
SELECT specialite, COUNT(*) AS nombre_professeurs
FROM professeurs
GROUP BY specialite;

-- Ajout de la clé primaire
ALTER TABLE Prof_Specialite
ADD CONSTRAINT PK_Prof_Specialite PRIMARY KEY (specialite);

/* 7.
Ecrire un déclencheur qui met à jour la table Prof specialite lorsqu’on ajoute ou supprime un professeur, ou met à jour la spécialité d’un professeur.
*/

CREATE OR REPLACE TRIGGER maj_specialite_prof
AFTER INSERT OR UPDATE OR DELETE ON professeurs
FOR EACH ROW
DECLARE
BEGIN
  -- Suppression de l'entrée correspondante dans Prof_Specialite
  IF DELETING THEN
    DELETE FROM prof_specialite
    WHERE num_prof = :OLD.num_prof;

  -- Insertion ou mise à jour dans Prof_Specialite
  ELSIF INSERTING OR UPDATING THEN
    INSERT INTO prof_specialite (num_prof, specialite)
    VALUES (:NEW.num_prof, :NEW.specialite)
    ON DUPLICATE KEY UPDATE specialite = :NEW.specialite;
  END IF;
END;

/* 8.
Ecrire un déclencheur qui met à jour la table Charge lorsqu’on met à jour le num prof d’un professeur ou lorsqu’un professeur est supprimé.
*/

CREATE OR REPLACE TRIGGER maj_charge_prof
AFTER UPDATE OR DELETE ON professeurs
FOR EACH ROW
DECLARE
BEGIN
  -- Mise à jour de la table Charge lorsqu'on modifie le num_prof
  IF UPDATING('num_prof') THEN
    UPDATE charge
    SET num_prof = :NEW.num_prof
    WHERE num_prof = :OLD.num_prof;

  -- Suppression des entrées correspondantes dans Charge lorsqu'on supprime un professeur
  ELSIF DELETING THEN
    DELETE FROM charge
    WHERE num_prof = :OLD.num_prof;
  END IF;
END;
