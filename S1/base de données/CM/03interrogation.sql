--opérations ensemblistes
SELECT titre FROM film
WHERE paysfilm = 'France'
UNION
SELECT titre FROM film
WHERE paysfilm = 'USA';

select titre, genre from film where paysfilm = 'France'
union
select titre from film where paysfilm = 'USA';
-- ne fonctionne pas parce que nb de colonnes différent, même type nécessaire

SELECT paysfilm pays FROM film
UNION
SELECT paysint pays FROM internaute;

SELECT paysfilm pays FROM film
UNION ALL
SELECT paysint pays FROM internaute;

select titre from film where paysfilm = 'France'
intersect
select titre from film where genre = 'comédie';

select titre from film where paysfilm = 'France'
minus
select titre from film where genre = 'comédie';

--fonctions d'agrégationL
select max(entree) from film;
select min(entree) from film;
select sum(entree) from film; --somme
select avg(entree) from film;
select count(*) from film; --compte toutes les lignes
select count(entree) from film; --compte toutes les lignes pour lequel entree est not null
select count(distinct genre) from film;

select count(*) from film where paysfilm = 'France';
select max(entree) from film where paysfilm = 'France';

select paysfilm, count(*) from film group by paysfilm;
select genre, count(*) from film where paysfilm = 'France' group by genre;

select paysfilm, genre, count(*) from film group by paysfilm, genre;
--toutes les attributs dans le select qui ne sont pas des fonctions count, max ...
--doivent être dans le group by

select nom, count(*) from acteur natural join jouer group by nom, idacteur;
-- on peut mettre plus d'arguments dans le group by que dans le select

select titre, count(*) from acteur natural join jouer natural join film group by titre, idfilm;

select paysfilm, sum(entree*10) CA from film group by paysfilm order by CA;

select max(avg(note)) from notation group by idfilm;

--Condition sur le groupe : HAVING
SELECT paysfilm, COUNT(*) FROM film
GROUP BY paysfilm
HAVING COUNT(*)>2;

SELECT titre from film natural join notation group by idfilm, titre having avg(note) > 5;

--Ordre des mots-clés
SELECT ...
FROM ... [INNER JOIN ... ON ...]
WHERE ... GROUP BY ... HAVING ... ORDER BY ...;


/*exercice
- Afficher le nombre de notes pour les annees comprises entre 2000 et 2010.
- Afficher le nombres d'entrees cumulees pour le genre qui en totalise le plus
 */


--sous requetes

-- Films francais sortis la même année que "Une vie de chat"
SELECT titre FROM film
WHERE paysfilm = 'France' and TO_CHAR(datesortie, 'YYYY')
	= (SELECT TO_CHAR(datesortie, 'YYYY') FROM film
	   WHERE titre = 'Une vie de chat');

-- Acteur le plus vieux
SELECT nom FROM acteur WHERE datenaiss = (SELECT min(datenaiss) FROM acteur);

select idfilm, titre from film natural join notation group by idfilm, titre
having avg(note) = (select max(avg(note)) from notation group by idfilm);

select nom from acteur where datenaiss <=
  (select datenaiss from acteur);
--ne fonctionne pas, parce que la sous-requête retourne plusieurs lignes
SELECT nom FROM acteur
WHERE datenaiss <= ALL (SELECT datenaiss FROM acteur);

-- Email des internautes ayant noté les mêmes films qu'Amandine Dahan
SELECT titre, email FROM film NATURAL JOIN notation
WHERE idfilm IN
(SELECT idfilm FROM notation WHERE email='Amandine.Dahan@gmail.fr');
-- NOT IN possible

--internaute qui a noté tous les films
SELECT email from notation group by email
having count(*) = (select count(*) from film);

-- Titre des films qui ont été noté par un internaute
-- de la même nationalité que le film
SELECT titre FROM film
WHERE EXISTS (SELECT * FROM internaute NATURAL JOIN notation
WHERE paysfilm = paysint AND idfilm = notation.idfilm);

--noms des acteurs qui ont joué avec un acteur plus jeune
select distinct nom from acteur a1 inner join jouer j1 on a1.idacteur = j1.idacteur where exists
(select * from acteur a2 inner join jouer j2 on a2.idacteur = j2.idacteur
          where j1.idfilm = j2.idfilm and a1.datenaiss < a2.datenaiss);

--jointure avec une table temporaire

---nb de notes par internaute
select internaute.email, count(*)
    from internaute inner join notation on internaute.email = notation.email
    group by internaute.email;

select internaute.email, count(note)
    from internaute left join notation on internaute.email = notation.email
    group by internaute.email;

---nb de notes moyen par paysint

--avec jointure (table nommée)
select paysint, round(avg(nbnotes), 2)
    from internaute inner join
    (select internaute.email, count(note) nbnotes
    from internaute left join notation on internaute.email = notation.email
    group by internaute.email) temp
    on internaute.email = temp.email
group by paysint;

--sans jointure
select paysint, round(avg(nbnotes), 2)
    from
    (select internaute.email, internaute.paysint, count(note) nbnotes
    from internaute left join notation on internaute.email = notation.email
    group by internaute.email, internaute.paysint)
group by paysint;


--vues

create or replace view filmFrancais as select * from film where paysfilm = 'France';

select * from filmfrancais natural join jouer natural join acteur where genre = 'comédie';

create or replace view casting as select titre, nom, prenom, datesortie
    from acteur natural join jouer natural join film;

select * from casting where to_char(datesortie, 'YYYY') = '2010';

--nommage des colonnes
create or replace view filmsPays as select paysfilm, count(*) as nbfilms
    from film group by paysfilm;

select * from filmspays;

select * from filmfrancais;

insert into film(idfilm, titre, paysfilm) values(50, 'Toto à la plage', 'France');

select * from filmfrancais;

rollback;

--insertions/modifications/suppressions à travers une vue

insert into casting values ('Toto à la plage', 'Dujardin', 'Jean', sysdate);
--impossible d'insérer dans une table sous-jacente : il manque idfilm, idacteur ...

--la vue ne doit pas contenir
--de jointure, d'union etc
--de  DISTINCT, fonctions d'agrégation SUM .. fonctions SQRT ...
--de GRP BY, ORDER BY

insert into filmfrancais(idfilm, titre, paysfilm) values(50, 'Toto à la plage', 'France');

rollback;

insert into filmfrancais(idfilm, titre, paysfilm) values(50, 'Toto à la plage', 'USA');

create or replace view filmFrancais as select * from film where paysfilm = 'France' with check option;
