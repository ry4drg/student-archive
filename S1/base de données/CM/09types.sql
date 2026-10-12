/*
drop table commande;
drop table client;
drop table personnel;
drop type commandeT;
drop type clientT;
drop type personnelT;
drop type adresse;
drop type telephone;
*/


--creation de type = declaration de classe
CREATE TYPE adresse AS OBJECT (
    numero NUMBER(3),
    rue VARCHAR2(50),
    cp CHAR(5),
    ville VARCHAR2(40)
);

--pas de contraintes dans les declarations de types
CREATE TYPE telephone AS OBJECT (
    typet VARCHAR2(50), --perso ou pro
    numero CHAR(10)
);

--on peut utiliser des types pour creer d'autres types
CREATE TYPE clientT AS OBJECT (
    nomClient VARCHAR2(30),
    prenomClient VARCHAR2(30),
    points NUMBER(3),
    adresseClient ADRESSE,
    telephoneClient TELEPHONE
);

CREATE TYPE personnelT AS OBJECT (
    nomPers VARCHAR2(30),
    prenomPers VARCHAR2(30),
    dateEmb DATE,
    salaire NUMBER(5),
    adressePers ADRESSE,
    telephonePers TELEPHONE
);
--Avantage vs relationnel ?


--creation de table: contient les contraintes
CREATE TABLE client OF CLIENTT (
    CONSTRAINT ck_tel CHECK (telephoneClient.typet in ('perso', 'pro'))
);

CREATE TABLE personnel OF PERSONNELT (
    CONSTRAINT ck_tel_pers CHECK (telephonePers.typet in ('perso', 'pro'))
);

--insertion d'objets
INSERT INTO client VALUES(
    clientt('Dugenou', 'Marcel', 0,
        adresse(12, 'rue du canard', '93430', 'Villetaneuse'),
        telephone('perso', '0112345678')
    )
);

--verification des contraintes
INSERT INTO client VALUES(
    clientt('Dupond', 'Gertrude', 0,
        adresse(28, 'rue du poulet', '93430', 'Villetaneuse'),
        telephone('bla', '0187654321')
    )
);

INSERT INTO client VALUES(
    clientt('Dupond', 'Gertrude', 0,
        adresse(28, 'rue du poulet', '93430', 'Villetaneuse'),
        telephone('pro', '0187654321')
    )
);

--pour l'instant, pas de clé primaire
INSERT INTO client VALUES(
    clientt('Dupond', 'Gertrude', 0,
        adresse(12, 'rue du poulet', '93430', 'Villetaneuse'),
        telephone('pro', '0187654321')
    )
);

--type clientt facultatif
INSERT INTO client VALUES(
    'Durand', 'Bob', 0, adresse(17, 'rue du faisan', '93430', 'Villetaneuse'), telephone('pro', '0187654312')
);

INSERT INTO personnel VALUES(
    'Martin', 'Ingrid', to_date('01/09/2020', 'DD/MM/YYYY'), 1500,
        adresse(30, 'rue du colibri', '93430', 'Villetaneuse'),
        telephone('pro', '0187645312')
);

commit;

SELECT * FROM client;
SElECT * FROM client WHERE nomclient = 'Dupond';
SELECT nomclient, prenomclient, c.telephoneclient FROM client c;
SELECT nomclient, prenomclient, c.telephoneclient.numero FROM client c;
SELECT * FROM client c WHERE c.telephoneclient.typet = 'pro';

UPDATE client SET points = 50 WHERE nomclient = 'Durand';
UPDATE client c SET points = points+10 WHERE c.adresseclient.ville = 'Villetaneuse';

commit;

DELETE FROM client WHERE nomclient = 'Durand';
DELETE FROM client c WHERE c.adresseclient.rue LIKE '%canard%';

ROLLBACK;

--Object IDentifier (OID) vs clés primaires/étrangères

SELECT REF(c), nomclient, prenomclient FROM client c;

CREATE TYPE commandeT AS OBJECT (
    numCom NUMBER(3),
    livreur REF personnelt,
    clientcom REF clientt
);


CREATE TABLE commande OF commandet (
    CONSTRAINT pk_commande PRIMARY KEY (numcom)
);

INSERT INTO commande VALUES (
    1, (SELECT ref(l) FROM personnel l WHERE nompers = 'Martin'), (SELECT ref(c) FROM client c WHERE nomclient = 'Dugenou')
);

select numcom, c.livreur.nompers, c.clientcom.nomclient from commande c;

INSERT INTO commande VALUES (
    1, (SELECT ref(l) FROM personnel l WHERE nompers = 'Martin'), (SELECT ref(c) FROM client c WHERE nomclient = 'Dupond')
);

select * from client;

INSERT INTO commande VALUES (
    2, (SELECT ref(l) FROM personnel l WHERE nompers = 'Martin'), (SELECT ref(c) FROM client c WHERE nomclient = 'Dupond' and c.adresseclient.numero = 12)
);

drop table client;
select numcom, c.clientcom.nomclient from commande c;

DROP TYPE clientt;

DROP TABLE commande;
DROP TYPE commandet;
DROP TYPE clientt;

CREATE TYPE clientT AS OBJECT (
    numclient NUMBER(2),
    nomClient VARCHAR2(30),
    prenomClient VARCHAR2(30),
    points NUMBER(3),
    adresseClient ADRESSE,
    telephoneClient TELEPHONE
);

CREATE TABLE client OF CLIENTT (
    CONSTRAINT ck_tel CHECK (telephoneClient.typet in ('perso', 'pro')),
    CONSTRAINT pk_client PRIMARY KEY (numclient)
);

INSERT INTO client VALUES(
    1, 'Dugenou', 'Marcel', 0, adresse(12, 'rue du canard', '93430', 'Villetaneuse'),
        telephone('perso', '0112345678')
);

INSERT INTO client VALUES(
    2, 'Dupond', 'Gertrude', 0,
        adresse(28, 'rue du poulet', '93430', 'Villetaneuse'),
        telephone('pro', '0187654321')
);

INSERT INTO client VALUES(
    3, 'Dupond', 'Gertrude', 0,
        adresse(12, 'rue du poulet', '93430', 'Villetaneuse'),
        telephone('pro', '0187654321')
);

INSERT INTO client VALUES(
    4, 'Durand', 'Bob', 0,
        adresse(17, 'rue du faisan', '93430', 'Villetaneuse'),
        telephone('pro', '0187654312')
);

SELECT * FROM client;

COMMIT;

CREATE TYPE commandeT AS OBJECT (
    numCom NUMBER(3),
    livreur REF personnelt,
    clientcom REF clientt
);

CREATE TABLE commande OF commandet (
    CONSTRAINT pk_commande PRIMARY KEY (numcom)
);


INSERT INTO commande VALUES (
    1, (SELECT ref(l) FROM personnel l WHERE nompers = 'Martin'), (SELECT ref(c) FROM client c WHERE c.numclient = 1)
);

INSERT INTO commande VALUES (
    2, (SELECT ref(l) FROM personnel l WHERE nompers = 'Martin'), (SELECT ref(c) FROM client c WHERE c.numclient = 2)
);

INSERT INTO commande VALUES (
    3, (SELECT ref(l) FROM personnel l WHERE nompers = 'Martin'), (SELECT ref(c) FROM client c WHERE c.numclient = 2)
);

COMMIT;

SELECT numcom, c.livreur.nompers, c.clientcom.nomclient FROM commande c;
SELECT numcom FROM commande c WHERE c.clientcom.nomclient = 'Dupond';

--avantages/inconvénients OID vs cle primaires/etrangeres ?