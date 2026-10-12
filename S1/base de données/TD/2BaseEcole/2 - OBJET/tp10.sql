DROP TABLE personnet;
DROP type elevet;
DROP type proft;

/* Question 1
Créer les types du diagramme d’héritage ci-dessous.
Reprendre les types des attributs de la base Ecole.
La classe PersonneT est abstraite (elle ne peut pas être instanciée).
*/
create or replace type personnet as object (
    num number(4),
    nom varchar2(25),
    prenom varchar2(25),
    datenaiss date,
    sexe char(1),
    member function affichage return varchar2
) not final not instantiable;

create or replace type elevet under personnet (
    poids number,
    annee number
);

create or replace type proft under personnet (
    specialite VARCHAR2(20),
    dateentree date,
    derprom date,
    salairebase number,
    salaireactuel number,
    member procedure promotion
);


/* Question 2
Ecrire le corps de la méthode affichage, qui retourne une chaêne ’M Nom Prenom’ ou ’Mme Nom Prenom’ selon le sexe.
*/
create or replace type body personnet as
    member function affichage return varchar2 is
    message varchar2(50);
    begin
       if (sexe = 'F') then
           message := 'Mme ' || nom || ' ' || prenom;
       else
           message := 'M ' || nom || ' ' || prenom;
       end if;
       return message;
    end;
end;

/* Question 3
Ecrire le corps de la méthode promotion : si la dernière promotion date de plus de 3 ans, augmenter le salaire actuel de 5% et mettre à jour la date de dernière promotion à la date du jour.
*/
CREATE OR REPLACE TYPE BODY proft AS
    MEMBER PROCEDURE promotion IS
    BEGIN
        if (trunc((sysdate - DERPROM)/365)) > 3 THEN
            SALAIREACTUEL := SALAIREACTUEL * 1.05;
            derprom := sysdate;
        END IF;
    END;
END;

/* Question 4
Créer les tables eleve et professeur avec les contraintes de clés primaires et de valeur sur le sexe qui ne peut être que ’M’ ou ’F’.
*/
create table eleve of elevet (
    constraint pk_eleve primary key (num),
    constraint ck_sexe check (sexe in ('M','F'))
);

create table prof of proft (
    constraint pk_prof primary key (num),
    constraint ck_s check (sexe in ('M','F'))
);

/* Question 5
Ecrire des déclencheurs sur les tables eleve et professeur qui v ́erifie la contrainte de partition : un élève et un professeur ne peuvent avoir le même num.
*/
-- Déclencheur pour la table eleve
CREATE OR REPLACE TRIGGER check_eleve_num
BEFORE INSERT ON eleve
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM prof WHERE num = :new.num;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Le numéro est déjà utilisé par un professeur.');
    END IF;
END;


-- Déclencheur pour la table prof
CREATE OR REPLACE TRIGGER check_prof_num
BEFORE INSERT ON prof
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM eleve WHERE num = :new.num;
    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Le numéro est déjà utilisé par un élève.');
    END IF;
END;

/* Question 6 : Ins ́erer les 5 premiers élèves et les 3 premiers professeurs du fichier baseEcole.sql.*/
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY' ;

Insert into eleve (Num, nom, prenom, datenaiss, Poids, annee, sexe)
Values (1, 'Brisefer', 'Benoit', '10-12-1978', 35, 1, 'M') ;

Insert into eleve (Num, nom, prenom, datenaiss, Poids, annee, sexe)
Values (2, 'Génial', 'Olivier', '10-04-1978', 42, 1, 'M') ;

Insert into eleve (num, nom, prenom, datenaiss, Poids, annee, sexe)
Values (3, 'Jourdan', 'Gil', '28-06-1974', 72, 2, 'F') ;

Insert into eleve (num, nom, prenom, datenaiss, Poids, annee, sexe)
Values (4, 'Spring', 'Jerry', '16-02-1974', 78, 2, 'M') ;

Insert into eleve (num, nom, prenom, datenaiss, Poids, annee, sexe)
Values (5, 'Tsuno', 'Yoko', '29-10-1977', 45, 1, 'F') ;

Insert into PROF (Num, nom , specialite, Dateentree, Derprom, Salairebase, Salaireactuel)
Values(8, 'Bottle', 'poésie', '01-10-1970', '01-10-1988', 2000000, 2600000) ;

Insert into PROF (Num, nom , specialite, Dateentree, Derprom, Salairebase, Salaireactuel)
Values(9, 'Bolenov', 'réseau', '15-11-1968', '01-10-1998', 1900000, 2468000) ;

Insert into PROF (Num, nom , specialite, Dateentree, Derprom, Salairebase, Salaireactuel)
Values(7, 'Tonilaclasse', 'poo', '01-10-1979', '01-01-1989', 1900000, 2360000) ;

/* Question 7 : Dans une seule requête SQL, faire appel à la méthode affichage pour toutes les personnes de la base. */
SELECT c.affichage() FROM eleve c
UNION
SELECT d.affichage() FROM prof d;

/* Question 8 : Ecrire un bloc PL/SQL qui fait appel à la méthode promotion pour tous les professeurs de la base.*/
declare
    m proft;
    cursor cur is select num from prof;
  begin
    for c in cur loop
        select value(p) into m from prof p where num = c.num;
        m.promotion();
        UPDATE prof p SET value(p) = m WHERE c.num = num;
    end loop;
end;
