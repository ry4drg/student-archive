/***************************************
  heritage de types
******************/

DROP TABLE personnel;

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
) NOT FINAL; --peut inclure des sous-classes

--les types vendeurT et livreurT heritent de personnelT
--remarque : heritage multiple impossible
CREATE OR REPLACE TYPE vendeurT UNDER personnelT () FINAL;

CREATE OR REPLACE TYPE livreurT UNDER personnelT (
    permis CHAR(1)
); --'FINAL' facultatif (par defaut)

CREATE TABLE personnel OF personnelT (
    CONSTRAINT pk_pers PRIMARY KEY (idpers),
    CONSTRAINT ck_pers CHECK (telephonePers.typet in ('perso', 'pro'))
);

CREATE TABLE vendeur OF vendeurT (
    CONSTRAINT pk_vendeur PRIMARY KEY (idpers),
    CONSTRAINT ck_vendeur CHECK (telephonePers.typet in ('perso', 'pro'))
);

CREATE TABLE livreur OF livreurT (
    CONSTRAINT pk_livreur PRIMARY KEY (idpers),
    CONSTRAINT ck_livreur CHECK (telephonePers.typet in ('perso', 'pro')),
    CONSTRAINT ck_permis CHECK(permis in ('A', 'B'))
);

INSERT INTO personnel(idpers, nompers) VALUES(1, 'Martin');
INSERT INTO livreur(idpers, nompers) VALUES(1, 'Dugenou');
--les cles primaires ne sont pas partagees entre les tables


/***************************************
  heritage de types, classe abstraite
******************/


--contrainte : on veut qu'un personnel soit un vendeur ou un livreur, et rien d'autre

DROP TABLE personnel;
DROP TABLE livreur;
DROP TABLE vendeur;
DROP TYPE vendeurt;
DROP TYPE livreurt;

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
) NOT INSTANTIABLE NOT FINAL; -- equivalent d'une classe abstraite

CREATE OR REPLACE TYPE vendeurT UNDER personnelT (); --INSTANTIABLE par defaut

CREATE OR REPLACE TYPE livreurT UNDER personnelT (
    permis CHAR(1)
); --INSTANTIABLE par defaut

CREATE TABLE personnel OF personnelT (
    CONSTRAINT pk_pers PRIMARY KEY (idpers),
    CONSTRAINT ck_pers CHECK (telephonePers.typet in ('perso', 'pro'))
);

INSERT INTO personnel(idpers, nompers) VALUES(1, 'Martin');
--on peut creer une table personnel mais on ne peut pas inserer dedans ...


CREATE TABLE vendeur OF vendeurT (
    CONSTRAINT pk_vendeur PRIMARY KEY (idpers),
    CONSTRAINT ck_vendeur CHECK (telephonePers.typet in ('perso', 'pro'))
);

CREATE TABLE livreur OF livreurT (
    CONSTRAINT pk_livreur PRIMARY KEY (idpers),
    CONSTRAINT ck_livreur CHECK (telephonePers.typet in ('perso', 'pro')),
    CONSTRAINT ck_permis CHECK(permis in ('A', 'B'))
);

INSERT INTO vendeur(idpers, nompers) VALUES(1, 'Martin');
INSERT INTO livreur(idpers, nompers) VALUES(1, 'Dugenou');
--les 2 tables sont toujours completement independantes

/***************************************
  heritage en relationnel pur
******************/

DROP TABLE personnel;
DROP TABLE livreur;
DROP TABLE vendeur;
DROP TYPE vendeurt;
DROP TYPE livreurt;

-- avec des cles etrangeres

CREATE TABLE personnel (
    idpers NUMBER(2),
    nomPers VARCHAR2(30),
    prenomPers VARCHAR2(30),
    dateEmb DATE,
    salaire NUMBER(5),
    adressePers ADRESSE,
    telephonePers TELEPHONE,
    CONSTRAINT pk_pers PRIMARY KEY (idpers),
    CONSTRAINT ck_pers CHECK (telephonePers.typet in ('perso', 'pro'))
);

CREATE TABLE vendeur (
    idpers NUMBER(2) PRIMARY KEY REFERENCES personnel(idpers)
);

CREATE TABLE livreur (
    idpers NUMBER(2) PRIMARY KEY REFERENCES personnel(idpers),
    permis CHAR(1) CHECK (permis in ('A', 'B'))
);

--une seule table

DROP TABLE personnel;
DROP TABLE livreur;
DROP TABLE vendeur;

CREATE TABLE personnel (
    idpers NUMBER(2),
    nomPers VARCHAR2(30),
    prenomPers VARCHAR2(30),
    dateEmb DATE,
    salaire NUMBER(5),
    adressePers ADRESSE,
    telephonePers TELEPHONE,
    permis CHAR(1) CHECK (permis in ('A', 'B')),
    CONSTRAINT pk_pers PRIMARY KEY (idpers),
    CONSTRAINT ck_pers CHECK (telephonePers.typet in ('perso', 'pro'))
);
--si permis est à null, c'est un vendeur
--si arbre d'heritage plus complique, rajouter des contraintes