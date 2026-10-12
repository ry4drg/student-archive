/*
— Eleves(num eleve, nom, prenom, date naissance, poids, annee, sexe)
— Cours(num cours, nom, nbheures, annee)
— Professeurs(num prof, nom, specialite, date entree, der prom, salaire base, salaire actuel) — Activites(niveau, nom, equipe)
— Resultats(#num eleve, #num cours, points)
— Charge(#num prof, #num cours)
— Activites pratiquees(#num eleve, #(niveau, nom))
*/
/* Question 1 : Ecrire une procédure stockée qui prend en paramètre le nom d'un cours et augente de 10% le salaire actuel du ou des professeurs en charge de ce cours, avec un plafond à 3000€. */

CREATE OR REPLACE PROCEDURE AugmenterSalaireCours(p_nom_cours VARCHAR2) IS
  v_salaire_max CONSTANT NUMBER := 3000;
BEGIN
  UPDATE Professeurs
  SET salaire_actuel = LEAST(salaire_actuel * 1.1, v_salaire_max)
  WHERE num_prof IN (SELECT DISTINCT c.num_prof
                     FROM Charge c
                     JOIN Cours co ON c.num_cours = co.num_cours
                     WHERE co.nom = p_nom_cours);
END AugmenterSalaireCours;


/* Question 2 : Est-ce-que le code écrit pour la question précédente peut déclencher des exceptions système ?
Si oui, en faire la liste ci-dessous, en indiquant ce qui déclenche l'exception.
*/
/*
Oui, le code peut déclencher des exceptions système. Les principales exceptions qui pourraient être déclenchées incluent :

NO_DATA_FOUND : Si la sous-requête dans la clause WHERE ne renvoie aucun résultat.
TOO_MANY_ROWS : Si la sous-requête dans la clause WHERE renvoie plus d'une ligne, ce qui ne devrait pas arriver si chaque professeur est en charge d'au plus un cours.
VALUE_ERROR : Si le calcul du nouveau salaire dépasse la limite définie par v_salaire_max.
*/

/* Question 3 : Ecrire un déclencheur qui vérifie que le salaire actuel d'un professeur est supérieur à son salaire de base : dans le cas contraire, le déclencheur modifie le salaire pour être égal à son salaire de base. */

CREATE OR REPLACE TRIGGER VerifSalaireProf
BEFORE INSERT OR UPDATE ON Professeurs
FOR EACH ROW
BEGIN
  IF :NEW.salaire_actuel < :NEW.salaire_base THEN
    :NEW.salaire_actuel := :NEW.salaire_base;
  END IF;
END VerifSalaireProf;


/* Question 4 : Ecrire un déclencheur qui, lors de l'insertion ou la mise à jour d'une activité, vérifie s'il existe déjà une activité avec ce nom et ce niveau : dans ce cas, le déclencheur modifie le niveau de la nouvelle activité pour éviter tout conflit de clé primaire. */

CREATE OR REPLACE TRIGGER VerifActiviteExistante
BEFORE INSERT OR UPDATE ON Activites
FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM Activites
  WHERE niveau = :NEW.niveau AND nom = :NEW.nom;

  IF v_count > 0 THEN
    -- Éviter le conflit de clé primaire en ajustant le niveau
    :NEW.niveau := :NEW.niveau || '_2';
  END IF;
END VerifActiviteExistante;
