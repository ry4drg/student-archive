
--tp12
--q1
/* Traduire le modèle ci-dessous en types SQL objet, en utilisant le moins de types possible. */
drop type livre;
drop type roman;

create type livre as object(
    isbn varchar2(50),
    titre varchar2(50),
    auteur REF personne
)not final;


create type chapitre as object(
    titre varchar2(50),
    nbpages number
);

create or replace type chapitress as table of chapitre;

create type roman under livre(
    chapitres chapitress,
    member function totalpages return number
);

create type personne as object(
    nom varchar2(50),
    prenom varchar2(50)
);

create type bd under livre(
    dessinateur ref personne
);

--q2
/* Ecrire le corps de la méthode totalpages qui retourne le nombre de pages au total du roman. */
CREATE OR REPLACE TYPE BODY roman AS
    MEMBER FUNCTION totalpages RETURN NUMBER IS
        s NUMBER;
    BEGIN
        SELECT SUM(r.nbpages) INTO s FROM TABLE (self.chapitres) r;
        RETURN s;
    END;
END;

--q3
/* Créer les tables et objets nécessaires pour qu’à la fin, la base contienne 2 romans avec des auteurs différents. */
create table pers of personne;

insert into pers values('victor','hugo');
insert into pers values('albert','camus');

create table chap of chapitre;

insert into chap values('chapitre 1',20);

create table book of roman(
    constraint pk_roman primary key (isbn)
)NESTED TABLE chapitres STORE AS tabchap;


insert into book(isbn,titre,auteur,chapitres) values('N-10','Les Misérables',(select ref(l) from pers l where nom='victor'),chapitress(chapitre('chapitre 1',60)));

insert into book(isbn,titre,auteur,chapitres) values('N-11','L''Étranger',(select ref(l) from pers l where nom='albert'),chapitress(chapitre('chapitre 1',20)));

--q4
/* 1. Titres, noms des auteurs et total de pages des romans de la base. */
SELECT e.isbn, e.titre, e.totalpages() as nb FROM book e;

/* 2. Titres des romans dont un des chapitres fait plus de 50 pages. */
SELECT e.isbn, e.titre FROM book e, table (e.chapitres) t where t.nbpages > 50;
