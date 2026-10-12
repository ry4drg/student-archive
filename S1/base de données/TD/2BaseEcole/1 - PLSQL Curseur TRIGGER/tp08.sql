/* Exercice 1 */
/* 1. Les points sont compris entre 0 et 20. */
CREATE TABLE Resultats (
    num_eleve INT,
    num_cours INT,
    points INT CHECK (points >= 0 AND points looçà<= 20),
    PRIMARY KEY (num_eleve, num_cours),
    FOREIGN KEY (num_eleve) REFERENCES Eleves(num_eleve),
    FOREIGN KEY (num_cours) REFERENCES Cours(num_cours)
);

/*
2. Le salaire actuel d’un professeur ne peut pas être inférieur à son salaire de base.
3. Le sexe peut prendre les valeurs ’F’, ’M’, ou NULL .
5. La dernière promotion d’un professeur a lieu au moins 3 ans après la date d’entrée.
*/
CREATE TABLE Professeurs (
    num_prof INT PRIMARY KEY,
    nom VARCHAR2(50),
    specialite VARCHAR2(50),
    date_entree DATE,
    der_prom DATE CHECK (der_prom IS NULL OR der_prom >= date_entree + INTERVAL '3' YEAR), /* date de la dernière promotion */
    salaire_base DECIMAL(10, 2),
    salaire_actuel DECIMAL(10, 2) CHECK (salaire_actuel >= salaire_base),
    sexe CHAR(1) CHECK (sexe IN ('F', 'M') OR sexe IS NULL)
);


/* 6. Les élèves qui pratiquent une activité ”Volley ball” font au moins 45kg s’ils sont de sexe masculin et au moins 35kg sinon. */
CREATE TABLE Activites_pratiquees (
    num_eleve INT,
    niveau INT,
    nom VARCHAR(50),
    PRIMARY KEY (num_eleve, niveau, nom),looçà
    FOREIGN KEY (num_eleve) REFERENCES Eleves(num_eleve),
    FOREIGN KEY (niveau, nom) REFERENCES Activites(niveau, nom),
    CHECK (
        (sexe = 'M' AND poids >= 45 AND nom = 'Volley ball') OR
        (sexe = 'F' AND poids >= 35 AND nom = 'Volley ball') OR
        (nom != 'Volley ball')
    )
);

/* Exercice 2
Ecrire un déclencheur à l’insertion d’un élève qui passe le sexe en majuscule (pour respecter la contrainte 3 de l’exercice précédent).
*/

CREATE OR REPLACE FUNCTION before_insert_eleve()
RETURNS TRIGGER AS $$
BEGIN
    NEW.sexe = UPPER(NEW.sexe);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_before_insert_eleve
BEFORE INSERT ON Eleves
FOR EACH ROW
EXECUTE FUNCTION before_insert_eleve();


/* ou */

CREATE OR REPLACE TRIGGER tr_insert_eleve
BEFORE INSERT ON Eleves
FOR EACH ROW
BEGIN
    :NEW.sexe := UPPER(:NEW.sexe);
END;

/* Exercice 3 */
/* 2.
Créer un déclencheur qui met à jour la table audit resultats à chaque modification de la table resultat.
Il faut donner l’utilisateur qui a fait la modification (USER), la date de la modification et une description de la modification (‘INSERT’, ‘DELETE’, ‘NOUVEAU’, ‘ANCIEN’)
*/

CREATE OR REPLACE TRIGGER tr_audit_resultats
AFTER INSERT OR UPDATE OR DELETE ON resultats
FOR EACH ROW
DECLARE
    v_desc_maj VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        v_desc_maj := 'INSERT';
    ELSIF UPDATING THEN
        v_desc_maj := 'UPDATE';
    ELSIF DELETING THEN
        v_desc_maj := 'DELETE';
    END IF;

    INSERT INTO audit_resultats (utilisateur, date_maj, desc_maj, num_eleve, num_cours, points)
    VALUES (USER, SYSDATE, v_desc_maj, :OLD.num_eleve, :OLD.num_cours, :OLD.points);
END;

/* Exercice 4
On souhaite que seul l’utilisateur ’GrandChef’ puisse augmenter les salaires des professeurs de plus de 20%.
Ecrire un déclencheur qui fait respecter cette contrainte, et retourne une erreur (n° -20002) avec le message ’Modification interdite’ sinon.
*/

CREATE OR REPLACE TRIGGER tr_controle_salaire
BEFORE UPDATE ON professeurs
FOR EACH ROW
DECLARE
    v_augmentation_pct NUMBER(5,2);
BEGIN
    -- Spécifiez ici le pourcentage d'augmentation autorisé
    v_augmentation_pct := 20.00;

    -- Vérifie si l'utilisateur est 'GrandChef' et si le salaire augmente de plus de 20%
    IF USER = 'GrandChef' AND :NEW.salaire_actuel > :OLD.salaire_actuel * (1 + v_augmentation_pct/100) THEN
        -- Autoriser la modification
        NULL;
    ELSE
        -- Annuler la modification avec une erreur personnalisée
        RAISE_APPLICATION_ERROR(-20002, 'Modification interdite');
    END IF;
END;

/* Exercice 5
Ecrire un déclencheur qui vérifie que si un élève veut pratiquer une activité de niveau n > 1, il la pratique
déjà pour tous les niveaux strictement inférieurs à n existants pour cette activité.
*/

CREATE OR REPLACE TRIGGER tr_verif_activites
BEFORE INSERT ON ACTIVITES_PRATIQUEES
FOR EACH ROW
DECLARE
    v_activite_exist NUMBER;
BEGIN
    -- Vérifie si l'élève pratique déjà cette activité pour des niveaux inférieurs
    SELECT COUNT(*)
    INTO v_activite_exist
    FROM ACTIVITES_PRATIQUEES
    WHERE num_eleve = :NEW.num_eleve
      AND niveau < :NEW.niveau
      AND nom = :NEW.nom;

    IF v_activite_exist > 0 THEN
        -- L'élève pratique déjà cette activité pour des niveaux inférieurs
        NULL;
    ELSE
        -- L'élève ne pratique pas l'activité pour tous les niveaux inférieurs
        RAISE_APPLICATION_ERROR(-20001, 'L''élève doit pratiquer l''activité pour tous les niveaux inférieurs avant de pratiquer pour le niveau spécifié.');
    END IF;
END;
