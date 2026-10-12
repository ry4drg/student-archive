--types

--char(20) chaîne de longueur fixe (20 caractères)
--varchar2(20) chaîne de longueur variable (au plus 20)
--date date/heure
--number(n, p) nombres de n chiffres au total dont p après la virgule
--ex: number(4, 2) : 10,25 ok, 100,5 pas ok

--creation de tables

CREATE TABLE Film (
	idFilm number(3),
	titre VARCHAR2 (50),
	datesortie date,
	genre VARCHAR2 (20),
	duree number(3),
	paysfilm VARCHAR (20),
	entree number(8)
);

-- contraintes de colonne

drop table film;

CREATE TABLE Film (
	idFilm number(3) PRIMARY KEY ,
	titre VARCHAR2 (50) NOT NULL,
	datesortie date,
	genre VARCHAR2 (20) check (genre in ('comédie', 'drame', 'policier')),
	duree number(3) check (duree between 0 and 500),
	paysfilm VARCHAR (20),
	entree number(8) check (entree >= 0)
);

CREATE TABLE Acteur (
	idActeur number(3) PRIMARY KEY,
	nom VARCHAR2 (30),
	prenom VARCHAR2 (30),
	datenaiss date
);

--cle etrangere
--ON DELETE CASCADE : les suppressions dans acteur entraînent les suppressions dans jouer des lignes correspondantes
CREATE TABLE Jouer (
	idFilm number(3) REFERENCES Film (idfilm),
	idActeur number(3) REFERENCES Acteur (idActeur) ON DELETE CASCADE);

CREATE TABLE Internaute (
	email VARCHAR2 (50) PRIMARY KEY,
	nomint VARCHAR2 (20),
	prenomint VARCHAR2 (20),
	paysint VARCHAR2(20));

CREATE TABLE Notation (
	email VARCHAR2 (50) REFERENCES Internaute (email),
	idFilm number(3)  REFERENCES Film (idfilm),
	note number(2),
	datenote DATE);

-- contraintes de table

drop table jouer;
drop table notation;

CREATE TABLE Jouer (
	idFilm number(3) REFERENCES Film (idfilm),
	idActeur number(3) REFERENCES Acteur (idActeur) ON DELETE CASCADE,
	PRIMARY KEY (idfilm, idacteur)
);

CREATE TABLE Notation (
	email VARCHAR2 (50),
	idFilm number(3) REFERENCES Film (idfilm),
	note number(2),
	datenote DATE,
	PRIMARY KEY (email, idfilm),
	FOREIGN KEY (email) REFERENCES Internaute (email),
	CHECK (note BETWEEN 0 AND 10)
);

CREATE TABLE Commentaire(
    idcomm NUMBER(3) PRIMARY KEY,
    email VARCHAR2 (50) REFERENCES Internaute(email),
    idparent NUMBER(3) REFERENCES Commentaire(idcomm),
    idfilm NUMBER(3),
    texte VARCHAR2 (100),
    datecomm DATE,
    FOREIGN KEY (email, idfilm) REFERENCES Notation(email, idfilm)
);

-- nommer les contraintes
-- pour des messages d'erreur plus compréhensibles
-- pour la maintenance : activer/desactiver contraintes, supprimer une contrainte

drop table commentaire;

CREATE TABLE Commentaire(
    idcomm NUMBER(3) CONSTRAINT pk_comm PRIMARY KEY,
    email VARCHAR2 (50) CONSTRAINT fk_internaute REFERENCES Internaute(email),
    idparent NUMBER(3) CONSTRAINT fk_comm REFERENCES Commentaire(idcomm),
    idfilm NUMBER(3),
    texte VARCHAR2 (100),
    datecomm DATE CONSTRAINT c_datecomm NOT NULL,
    CONSTRAINT fk_notation FOREIGN KEY (email, idfilm) REFERENCES Notation(email, idfilm),
    CONSTRAINT c_idfilm CHECK (idfilm >= 0)
);

-- CREATE combiné à un SELECT
-- copie les données mais pas les contraintes

CREATE TABLE test AS SELECT * FROM dual;

SELECT * FROM test;

-- modifier une table

-- pour ajouter/supprimer des colonnes
ALTER TABLE test ADD(
    coucou VARCHAR2(50),
    idfilm NUMBER(3) REFERENCES film(idfilm)
);
SELECT * FROM test;
ALTER TABLE test DROP COLUMN coucou;

--pour modifier le type d'une colonne, si les données respectent le nouveau type
ALTER TABLE test MODIFY idfilm NUMBER(4);

--pour ajouter/supprimer ou activer/desactiver des contraintes
ALTER TABLE test ADD(
  CONSTRAINT pk_dummy PRIMARY KEY(dummy),
  CONSTRAINT c_idfilm_test CHECK (idfilm >= 1)
);

ALTER TABLE test ADD CONSTRAINT c_bla CHECK (dummy IS NOT NULL);

ALTER TABLE test DISABLE CONSTRAINT c_idfilm_test;
ALTER TABLE test ENABLE CONSTRAINT c_idfilm_test;

--rollback/commit

--pour enregistrer des modifications (insertions/suppressions/MAJ)
COMMIT;

INSERT INTO film(idfilm) VALUES(1);
SELECT * FROM film;

COMMIT;

INSERT INTO film(idfilm) VALUES(2);
SELECT * FROM film;

ROLLBACK;

SELECT * FROM film;
DELETE FROM film;

COMMIT;

--insertion/suppression/MAJ

insert into film values (1, 'toto à la plage', sysdate, 'comédie', 100, 'France', 10000);
insert into film values (2, 'toto à la montagne', to_date('20/12/2010'), 'policier', 110, 'Monaco', null);
insert into film(idfilm, titre) values (3, 'toto à la ville');

select * from film;
commit;

--insert avec un select, si même colonnes entre la table/la requête
insert into film(idfilm, titre, duree) select idfilm+3, titre, duree+10 from film;

select * from film;

--sequence: suite automatique d'entiers
CREATE SEQUENCE seqfilm INCREMENT BY 1 START WITH 7;
INSERT INTO film(idfilm, titre) VALUES(seqfilm.nextval, 'toto à la campagne');
--pour afficher la valeur courante : seqfilm.currval

select * from film;
commit;

--mises à jour
UPDATE film SET entree = 50000 WHERE idfilm = 1;
UPDATE film SET entree = 100000 WHERE entree is null;

select * from film;
UPDATE film SET entree = entree+100;
select * from film;

--update + select, met toutes les lignes à jour
UPDATE film f1 SET entree = (select entree+duree from film f2 where f1.idfilm = f2.idfilm);
commit;

-- suppressions
DELETE FROM film where idfilm = 1;
DELETE FROM film where entree is null;

select * from film;

DELETE FROM film where idfilm in (select idfilm from film where genre is null);

select * from film;

DELETE FROM film;

select * from film;

commit;
