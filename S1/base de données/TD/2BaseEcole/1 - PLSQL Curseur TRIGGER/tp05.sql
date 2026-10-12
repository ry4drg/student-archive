/* Exercice 1 */
/* 1.
Ecrire un programme PL/SQL qui affiche le nombre d’activités pratiquées par un élève choisi arbitrairement.
Si l’élève ne pratique aucune activité, le programme doit afficher “aucune activité”.
*/

DECLARE
  NOMBRE_ACTIVITEES_ELEVE_CHOISI      NUMBER;
  ELEVE_NUM                           NUMBER := 1;

BEGIN
  SELECT COUNT(*) INTO NOMBRE_ACTIVITEES_ELEVE_CHOISI
  FROM ACTIVITES_PRATIQUEES
  WHERE num_eleve = ELEVE_NUM;

  IF NOMBRE_ACTIVITEES_ELEVE_CHOISI > 0 THEN
    dbms_output.put_line('Nombre activités pratiquées par étudiant ' || ELEVE_NUM || ' : ' || NOMBRE_ACTIVITEES_ELEVE_CHOISI);
  ELSE
    dbms_output.put_line('Etudiant ' || ELEVE_NUM || ' ne pratique pas actvités.');
  END IF;
END;

/* 2.
Modifier le programme précédent pour qu’il réalise cet affichage pour chaque élève de la base.
*/

DECLARE
  NOMBRE_ACTIVITEES_ELEVE_CHOISI      NUMBER;
  /* curseur de la colonne des numéros d'élèves */
  CURSOR curseur_eleve IS
  SELECT num_eleve FROM ELEVES;

BEGIN
  FOR i IN curseur_eleve LOOP
    SELECT COUNT(*) INTO NOMBRE_ACTIVITEES_ELEVE_CHOISI
    FROM ACTIVITES_PRATIQUEES
    WHERE num_eleve = i.num_eleve;

    IF NOMBRE_ACTIVITEES_ELEVE_CHOISI > 0 THEN
      dbms_output.put_line('Nombre activités pratiquées par étudiant ' || i.num_eleve|| ' : ' || NOMBRE_ACTIVITEES_ELEVE_CHOISI);
    ELSE
      dbms_output.put_line('Etudiant ' || i.num_eleve || ' ne pratique aucune actvité.');
    END IF;
  END LOOP;
END;

/* 3.
Ecrire un programme PL/SQL qui affiche pour chaque élève la liste des activités qu’il pratique.
Si un élève ne pratique aucune activité, afficher “aucune activité”.
 */

DECLARE
  ACTIVITES_LIST VARCHAR2(200);

  CURSOR EleveCursor IS
    SELECT NUM_ELEVE
    FROM ELEVES;

BEGIN
  FOR i IN EleveCursor LOOP
    ACTIVITES_LIST := NULL;

    -- Concatenate the names of activities practiced by the current student
    FOR j IN ( SELECT AP.NOM FROM ACTIVITES_PRATIQUEES AP WHERE AP.NUM_ELEVE = i.NUM_ELEVE) LOOP
      ACTIVITES_LIST := ACTIVITES_LIST || j.NOM || ', ';
    END LOOP;

    -- Display the result
    IF ACTIVITES_LIST IS NOT NULL THEN
      dbms_output.put_line('Activités pratiquées par étudiant ' || i.NUM_ELEVE || ' : ' || ACTIVITES_LIST);
    ELSE
      dbms_output.put_line('Etudiant ' || i.NUM_ELEVE || ' ne pratique aucune activité.');
    END IF;
  END LOOP;
END;

/* 4 : Pas complet */

DECLARE
  ACTIVITES_LIST VARCHAR2(200);
  CURSOR EleveCursor IS
    SELECT NUM_ELEVE, ANNEE
    FROM ELEVES
    ORDER BY ANNEE;

  CURRENT_YEAR NUMBER := NULL;
BEGIN
  FOR i IN EleveCursor LOOP
    IF CURRENT_YEAR IS NULL OR CURRENT_YEAR <> i.ANNEE THEN
      dbms_output.put_line(i.ANNEE);
      CURRENT_YEAR := i.ANNEE;
    END IF;

    ACTIVITES_LIST := NULL;

    FOR j IN (SELECT AP.NOM FROM ACTIVITES_PRATIQUEES AP WHERE AP.NUM_ELEVE = i.NUM_ELEVE) LOOP
      ACTIVITES_LIST := ACTIVITES_LIST || j.NOM || CHR(10) || '   ';
    END LOOP;

    IF ACTIVITES_LIST IS NOT NULL THEN
      dbms_output.put_line('   ' || ACTIVITES_LIST || j.NOM || CHR(10) || '   ');
    ELSE
      dbms_output.put_line('Etudiant ' || i.NUM_ELEVE || ' ne pratique aucune activité.');
    END IF;
  END LOOP;
END;

/* Exercice 2
Écrire un programme PL/SQL qui affiche pour chaque niveau puis chaque activité, les noms des élèves qui pratiquent cette activité.
*/

DECLARE
  ELEVES_LIST VARCHAR2(200);

BEGIN
  FOR n IN (SELECT DISTINCT NIVEAU FROM ACTIVITES ORDER BY NIVEAU) LOOP
    FOR a IN (SELECT NOM FROM ACTIVITES WHERE NIVEAU = n.NIVEAU) LOOP
      ELEVES_LIST := NULL;

      -- Concatenate the names of students practicing the current activity
      FOR i IN (SELECT E.NOM || ' ' || E.PRENOM AS NOM_COMPLET FROM ELEVES E JOIN ACTIVITES_PRATIQUEES AP ON E.NUM_ELEVE = AP.NUM_ELEVE WHERE AP.NIVEAU = n.NIVEAU AND AP.NOM = a.NOM) LOOP
        ELEVES_LIST := ELEVES_LIST || i.NOM_COMPLET || ', ';
      END LOOP;

      -- Display the result
      dbms_output.put_line(n.NIVEAU);
      dbms_output.put_line(' ' || a.NOM);
      dbms_output.put_line('  ' || ELEVES_LIST);
    END LOOP;
  END LOOP;
END;
