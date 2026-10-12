DROP TABLE eleves;

/* Question 1 : Compléter le bloc PL/SQL fourni pour remplir les sous-tables resultat de chaque étudiant. */
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
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY' ;
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
    TYPE courst IS TABLE OF VARCHAR2(20);
    tabcours courst := courst('Réseau', 'SGBD', 'Programmation', 'Analyse');
    CURSOR celeves IS SELECT num_eleve FROM eleves;
BEGIN
    FOR eleve_rec IN celeves LOOP
        FOR i IN 1..4 LOOP
            INSERT INTO TABLE (SELECT resultat FROM eleves WHERE num_eleve = eleve_rec.num_eleve)
            VALUES (resultatT(tabcours(i), TRUNC(dbms_random.value(0, 20), 2)));
        END LOOP;
    END LOOP;
END;

/* Question 2 */
-- 1. Noms des élèves qui ont eu la moyenne au cours de r ́eseau.
select e.num_eleve from eleves e, table(e.resultat) r where r.nom_cours = 'Réseau' and r.points >= 10;

-- 2. Moyenne de classe pour chaque cours.
select r.nom_cours, avg(r.points) from eleves e, table(e.resultat) r group by r.nom_cours;

-- 3. Nom de l’élève qui a obtenu la meilleure note en programmation.
select e.num_eleve from eleves e, table(e.resultat) r where r.nom_cours = 'Programmation' and r.points = (select max(t.points) from eleves s, table(s.resultat) t where t.nom_cours = 'Programmation');

-- 4. Moyenne sur les 4 cours pour chaque élève.
select e.num_eleve, avg(r.points) from eleves e, table(e.resultat) r group by e.num_eleve;

/* Question 3 : Ecrire un bloc PL/SQL qui rajoute un point à chaque étudiant dans le cours d’analyse, sans dépasser la note maximale de 20 (utiliser LEAST). */
DECLARE
    v_max NUMBER := 20;
    CURSOR m IS SELECT e.num_eleve FROM eleves e;
BEGIN
    FOR i IN m LOOP
        UPDATE table (select e.resultat from eleves e where e.num_eleve = i.num_eleve) z
        SET z.points = LEAST(z.points + 1, v_max)
        WHERE z.nom_cours = 'Analyse';
    END LOOP;
end;

select r.* from eleves e, table(e.resultat) r where r.nom_cours='Analyse';

/* Question 4 : A ́ l’aide d’une seule requête UPDATE, mettre à jour l’attribut admis `a ’O’ pour les  ́etudiants qui ont une moyenne globale (sur les 4 cours) supérieure à 10 */
update eleves s
set admis = 'O'
where (select avg(r.points) from eleves e, table(e.resultat) r where s.num_eleve = e.num_eleve group by e.num_eleve) >= 10;

/* Question 5 : Pour l’élève n°1, supprimer de sa table r ́esultat le cours pour lequel il a eu la note la plus faible. */
delete table(select e.resultat from eleves e where num_eleve=1 )t where t.points<10;

/* Question 6 : Supprimer le ou les élève(s) qui a/ont eu la note la plus faible dans le cours de SGBD.*/
delete eleves e where exists(select 1 from table(e.resultat) r where r.nom_cours ='Réseau' and r.points=(select min(r2.points) from eleves e2, table(e2.resultat)r2 where r2.nom_cours='Réseau'));
