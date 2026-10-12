DROP TABLE eleves;

CREATE OR REPLACE TYPE resultatT AS OBJECT
(
    nom_cours VARCHAR2(20),
    points NUMBER(4, 2)
);

CREATE OR REPLACE TYPE resultatsT AS TABLE OF resultatt;

CREATE OR REPLACE TYPE eleveT AS OBJECT
(
    num_eleve      NUMBER(4),
    nom            VARCHAR2(25),
    prenom         VARCHAR2(25),
    date_naissance DATE,
    poids          NUMBER,
    annee          NUMBER,
    sexe           CHAR(1),
    admis CHAR(1),
    resultat resultatsT
);

CREATE TABLE eleves OF eleveT(
    CONSTRAINT pk_eleve PRIMARY KEY (num_eleve),
    CONSTRAINT ck_sexe CHECK (sexe in ('M', 'F')),
    CONSTRAINT ck_admis CHECK (admis in ('N', 'O'))
)
NESTED TABLE resultat STORE AS tabresultat;

Insert into eleves
Values (1, 'Brisefer', 'Benoit', '10-12-1978', 35, 1, 'M', 'N', resultatst());

Insert into eleves
Values (2, 'Génial', 'Olivier', '10-04-1978', 42, 1, 'M', 'N', resultatst()) ;

Insert into eleves
Values (3, 'Jourdan', 'Gil', '28-06-1974',  72, 2, 'F', 'N', resultatst()) ;

Insert into eleves
Values (4, 'Spring', 'Jerry', '16-02-1974', 78, 2, 'M', 'N', resultatst()) ;

Insert into eleves
Values (5, 'Tsuno', 'Yoko', '29-10-1977', 45, 1, 'F', 'N', resultatst()) ;

SELECT TRUNC(dbms_random.value(0, 20), 2) FROM DUAL;

DECLARE
    TYPE courst IS --A COMPLETER
    tabcours courst := courst('Réseau', 'SGBD', 'Programmation', 'Analyse');
    CURSOR celeves IS SELECT num_eleve FROM eleves;
BEGIN
    FOR --A COMPLETER
        FOR i in 1..4 LOOP
	  --A COMPLETER
        END LOOP;
    END LOOP;
END;

