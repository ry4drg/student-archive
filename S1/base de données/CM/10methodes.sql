drop table commande;
drop table personnel;
drop table client;
drop type commandet;
drop type clientt;
drop type vendeurt;

--methode
CREATE OR REPLACE TYPE personnelT AS OBJECT (
    idpers NUMBER(2),
    nomPers VARCHAR2(30),
    prenomPers VARCHAR2(30),
    dateEmb DATE,
    salaire NUMBER(5),
    adressePers ADRESSE,
    telephonePers TELEPHONE,
    MEMBER FUNCTION anciennete RETURN number,
    MEMBER PROCEDURE majSalaire
);

CREATE TABLE personnel OF personnelT(
    CONSTRAINT pk_pers PRIMARY KEY (idpers),
    CONSTRAINT ck_pers CHECK (telephonePers.typet in ('perso', 'pro'))
);

INSERT INTO personnel VALUES (1, 'Dugenou', 'Marcel', '19/10/2020', 1200, null, null);
INSERT INTO personnel VALUES (2, 'Martin', 'Géraldine', '07/05/2010', 1200, null, null);


CREATE OR REPLACE TYPE BODY personnelT AS
    MEMBER FUNCTION anciennete RETURN NUMBER IS
    BEGIN
        RETURN (trunc((sysdate - dateEmb)/365));
    END;
    MEMBER PROCEDURE majSalaire IS
    BEGIN
        if anciennete() > 10 THEN
            salaire := salaire * 2;
        END IF;
    END;
END;


SELECT nomPers, p.anciennete() FROM personnel p;
SELECT p.majsalaire FROM personnel p; --impossible pour une procedure

DECLARE
    pers REF personnelt;
    CURSOR cpers IS SELECT idpers FROM personnel;
BEGIN
    FOR cpers_rec IN cpers LOOP
        SELECT ref(p) into pers FROM personnel p WHERE cpers_rec.idpers = idpers;
        pers.majsalaire(); --interdit en PL/SQL parce que ????
    END LOOP;
END;

DECLARE
    pers personnelt;
    CURSOR cpers IS SELECT idpers FROM personnel;
BEGIN
    FOR cpers_rec IN cpers LOOP
        --VALUE : pour récupérer l'objet "ligne"
        SELECT value(p) into pers FROM personnel p WHERE cpers_rec.idpers = idpers;
        --modification de l'objet par appel a la methode
        pers.majsalaire();
        -- mise a jour de l'objet dans la table
        UPDATE personnel p SET value(p) = pers WHERE cpers_rec.idpers = idpers;
    END LOOP;
END;


