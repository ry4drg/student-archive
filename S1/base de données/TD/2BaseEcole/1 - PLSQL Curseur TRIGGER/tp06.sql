/* Exercice 1 */
/* 1.
 Ecrire un bloc PL/SQL qui réalise une insertion dans “Activites pratiquees”,
 pour un nom d’élève et un couple nom d’activité/niveau quelconques.
 Traiter les cas d’erreurs en déclenchant des exceptions système.
 */

DECLARE
  vnom VARCHAR2(30) := 'Toto'; -- pseudo-entree au clavier
  vnum NUMBER(3);
  vactivite VARCHAR2(20) := 'ActiviteTest';
  vniveau NUMBER(1) := 1;

  -- Déclaration d'exceptions personnalisées
  eleve_non_trouve EXCEPTION;
  activite_non_trouvee EXCEPTION;

BEGIN
  -- Utilisation de vnom pour récupérer le numéro de l'élève
  BEGIN
    SELECT num_eleve INTO vnum FROM eleves WHERE nom = vnom;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE eleve_non_trouve;
    WHEN TOO_MANY_ROWS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Plus d\'un élève trouvé avec le nom ' || vnom);
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20002, 'Erreur inattendue lors de la récupération du numéro de l\'élève');
  END;

  -- Insertion dans la table Activites_pratiquees
  BEGIN
    INSERT INTO activites_pratiquees (num_eleve, niveau, nom)
    VALUES (vnum, vniveau, vactivite);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20003, 'Erreur lors de l\'insertion dans la table Activites_pratiquees');
  END;

  -- Commit pour valider les changements
  COMMIT;
  dbms_output.put_line('Insertion réussie pour ' || vnom || ' dans ' || vactivite || ' (niveau ' || vniveau || ')');

EXCEPTION
  WHEN eleve_non_trouve THEN
    dbms_output.put_line('Élève non trouvé avec le nom ' || vnom);
  WHEN activite_non_trouvee THEN
    dbms_output.put_line('Activité non trouvée avec le nom ' || vactivite || ' (niveau ' || vniveau || ')');
  WHEN OTHERS THEN
    dbms_output.put_line('Erreur inattendue : ' || SQLCODE || ' - ' || SQLERRM);
END;

/* 2.
Ecrire un bloc PL/SQL qui ins`ere un nouvel élève (nom, prenom, date naissance) dans la base.
Le num eleve doit être calculé par le programme.
Vérifier à l’aide d’une exception utilisateur que la date de naissance est entrée au format XX-XX-XXXX.
*/

DECLARE
  vnom VARCHAR2(30) := 'NouvelEleve'; -- pseudo-entree au clavier
  vprenom VARCHAR2(30) := 'PrenomEleve'; -- pseudo-entree au clavier
  vdate_naissance VARCHAR2(10) := '01-01-2000'; -- pseudo-entree au clavier

  vnum_eleve NUMBER(4);

  -- Déclaration d'une exception utilisateur pour la validation du format de la date
  date_naissance_format_invalide EXCEPTION;

BEGIN
  -- Vérification du format de la date de naissance
  BEGIN
    IF REGEXP_LIKE(vdate_naissance, '^\d{2}-\d{2}-\d{4}$') THEN
      dbms_output.put_line('Format de date valide.');
    ELSE
      RAISE date_naissance_format_invalide;
    END IF;
  EXCEPTION
    WHEN date_naissance_format_invalide THEN
      RAISE_APPLICATION_ERROR(-20001, 'Format de date de naissance invalide. Utilisez le format XX-XX-XXXX.');
  END;

  -- Calcul du nouveau numéro d'élève
  SELECT MAX(num_eleve) + 1 INTO vnum_eleve FROM eleves;

  -- Insertion du nouvel élève dans la table Eleves
  BEGIN
    INSERT INTO eleves (num_eleve, nom, prenom, date_naissance)
    VALUES (vnum_eleve, vnom, vprenom, TO_DATE(vdate_naissance, 'DD-MM-YYYY'));
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20002, 'Erreur lors de l\'insertion du nouvel élève.');
  END;

  -- Commit pour valider les changements
  COMMIT;
  dbms_output.put_line('Insertion réussie pour ' || vnom || ' ' || vprenom || ' (numéro ' || vnum_eleve || ')');

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erreur inattendue : ' || SQLCODE || ' - ' || SQLERRM);
END;


/* Exercice 2 */
/* 3.
Ecrire une fonction stockée qui prend en paramètre un num prof et retourne le nombre de cours dont ce professeur a la charge.
*/

CREATE OR REPLACE FUNCTION getNombreCoursCharge(p_num_prof IN NUMBER) RETURN NUMBER IS
  v_nombre_cours NUMBER;
BEGIN
  -- Utilisation de la fonction agrégée COUNT pour compter le nombre de cours
  SELECT COUNT(*) INTO v_nombre_cours
  FROM charge
  WHERE num_prof = p_num_prof;

  -- Retour du résultat
  RETURN v_nombre_cours;
END getNombreCoursCharge;



DECLARE
  v_num_prof NUMBER := 1; -- Remplacez par le numéro de professeur souhaité
  v_result NUMBER;
BEGIN
  -- Appel de la fonction
  v_result := getNombreCoursCharge(v_num_prof);

  -- Affichage du résultat
  dbms_output.put_line('Le professeur ' || v_num_prof || ' a la charge de ' || v_result || ' cours.');
END;

/* 4.
Utiliser la fonction de la question précédente dans une requˆete SQL pour afficher la liste des professeurs qui n’ont en charge aucun cours.
*/

SELECT *
FROM professeurs
WHERE getNombreCoursCharge(num_prof) = 0;

/* 5.
Ecrire une fonction stockée qui prend en param`etre un nom d’élève et qui retourne son num eleve.
En cas d’erreur, retourner 0. Utiliser des exceptions.
*/

CREATE OR REPLACE FUNCTION getNumeroEleve(p_nom_eleve IN VARCHAR2) RETURN NUMBER IS
  v_num_eleve NUMBER;
  -- Déclaration d'une exception personnalisée
  eleve_non_trouve EXCEPTION;
BEGIN
  -- Utilisation de la clause INTO pour récupérer le numéro d'élève
  SELECT num_eleve INTO v_num_eleve
  FROM eleves
  WHERE nom = p_nom_eleve;

  -- Retour du résultat
  RETURN v_num_eleve;

EXCEPTION
  -- Gestion de l'exception si l'élève n'est pas trouvé
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
END getNumeroEleve;

/* 6.
Ecrire une procédure stockée qui prend en paramètres un nom d’élève, un nom de cours et une note et qui insère ou mets à jour cette note pour ce cours pour cet élève. 
Utiliser la fonction pr ́ec ́edente.
*/

CREATE OR REPLACE PROCEDURE insererMajNote(p_nom_eleve IN VARCHAR2, p_nom_cours IN VARCHAR2, p_note IN NUMBER) IS
  v_num_eleve NUMBER;
  v_num_cours NUMBER;

  -- Déclaration d'une exception utilisateur
  eleve_non_trouve EXCEPTION;

BEGIN
  -- Utilisation de la fonction pour obtenir le numéro de l'élève
  v_num_eleve := getNumeroEleve(p_nom_eleve);

  -- Vérification si l'élève a été trouvé
  IF v_num_eleve = 0 THEN
    RAISE eleve_non_trouve;
  END IF;

  -- Utilisation de la fonction pour obtenir le numéro du cours
  SELECT num_cours INTO v_num_cours
  FROM cours
  WHERE nom = p_nom_cours;

  -- Insertion ou mise à jour de la note
  BEGIN
    INSERT INTO resultats (num_eleve, num_cours, points)
    VALUES (v_num_eleve, v_num_cours, p_note);
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      UPDATE resultats
      SET points = p_note
      WHERE num_eleve = v_num_eleve AND num_cours = v_num_cours;
  END;

  -- Commit pour valider les changements
  COMMIT;
  dbms_output.put_line('Note pour ' || p_nom_eleve || ' pour le cours ' || p_nom_cours || ' : ' || p_note);

EXCEPTION
  -- Gestion de l'exception utilisateur
  WHEN eleve_non_trouve THEN
    dbms_output.put_line('Erreur : élève ' || p_nom_eleve || ' non trouvé.');
  -- Gestion de toutes les autres exceptions
  WHEN OTHERS THEN
    dbms_output.put_line('Erreur inattendue : ' || SQLCODE || ' - ' || SQLERRM);
END insererMajNote;


DECLARE
  v_nom_eleve VARCHAR2(30) := 'NomEleve'; -- Remplacez par le nom de l'élève souhaité
  v_nom_cours VARCHAR2(30) := 'NomCours'; -- Remplacez par le nom du cours souhaité
  v_note NUMBER := 15; -- Remplacez par la note souhaitée

BEGIN
  -- Appel de la procédure
  insererMajNote(v_nom_eleve, v_nom_cours, v_note);
END;
