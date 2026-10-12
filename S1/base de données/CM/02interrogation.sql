/*Sélection*/
SELECT * FROM film WHERE paysfilm='France';
SELECT * FROM film WHERE entree<=100000;
SELECT * FROM film WHERE entree<=100000 AND entree>=50000;
SELECT * FROM film WHERE entree BETWEEN 50000 AND 100000;
SELECT * FROM film WHERE entree IS NULL;

/*Projection*/
SELECT titre FROM film;
SELECT titre, genre FROM film;
SELECT genre FROM film;
SELECT DISTINCT genre FROM film;
SELECT titre||' est un(e) '||genre from film;
SELECT titre||' est un(e) '||genre titre_genre from film;

/*Combinaison*/
SELECT titre FROM film WHERE paysfilm = 'France';
SELECT titre FROM film WHERE paysfilm = 'France' AND genre = 'comédie';
SELECT titre, paysfilm, genre FROM film WHERE paysfilm = 'France' OR genre = 'policier';

--LIKE
select titre from film where titre like 'Le%'; --nombre de caractère qcque
select titre from film where titre like 'Av_tar'; --exactement 1 caractere


/*Tri*/
SELECT * FROM film ORDER BY entree;
SELECT * FROM film ORDER BY entree DESC;
SELECT * FROM film ORDER BY paysfilm, entree;
SELECT round(entree, -2) arrondi FROM film ORDER BY arrondi;

--jointure

SELECT idacteur FROM film INNER JOIN jouer ON film.idfilm = jouer.idfilm
WHERE titre = 'Le parrain';

SELECT idacteur, nom FROM film INNER JOIN jouer ON film.idfilm = jouer.idfilm
INNER JOIN acteur ON acteur.idacteur = jouer.idacteur
WHERE titre = 'Le parrain'; --erreur: colonne ambigue*/

SELECT jouer.idacteur, nom FROM film INNER JOIN jouer ON film.idfilm = jouer.idfilm
INNER JOIN acteur ON acteur.idacteur = jouer.idacteur
WHERE titre = 'Le parrain'; --OK

--syntaxe NATURAL JOIN

SELECT idacteur FROM film NATURAL JOIN Jouer WHERE titre = 'Le parrain';

SELECT idacteur FROM film NATURAL JOIN Jouer NATURAL JOIN acteur
WHERE titre = 'Le parrain';

--syntaxe produit cartésien

SELECT idacteur FROM film, jouer WHERE film.idfilm = jouer.idfilm
AND titre = 'Le parrain';

SELECT jouer.idacteur FROM film, jouer, acteur WHERE film.idfilm = jouer.idfilm
AND jouer.idacteur = acteur.idacteur AND titre = 'Le parrain';

--alias

SELECT f1.entree - f2.entree FROM film f1, film f2
WHERE f1.titre = 'Le parrain' AND f2.titre = 'Avatar';

SELECT n1.email, titre FROM film INNER JOIN notation n1 ON film.idfilm = n1.idfilm
INNER JOIN notation n2 ON n1.idfilm = n2.idfilm
WHERE n2.email = 'Isabelle.Pruvat@yahoo.fr'
AND n1.email != 'Isabelle.Pruvat@yahoo.fr';

--Jointure externe (LEFT JOIN, RIGHT JOIN)

SELECT nomint FROM internaute LEFT JOIN notation
ON internaute.email = notation.email WHERE note IS NULL;

/* exercices :
   - noms des acteurs et des internautes qui ont le même prénom
   - titres des films qui ont la même duree
   - films dont le titre contient les 3 premieres lettres d'un titre d'un autre film
 */



/*Formatter une date*/
SELECT To_Char (datesortie, 'DD/MM/YYYY') FROM film;
SELECT To_Char (datesortie, 'DD month YYYY') FROM film;

--les films sortis en octobre
SELECT titre FROM film WHERE To_Char (datesortie, 'MM') = '10';

/*créer une date selon un format*/
SELECT titre FROM film WHERE To_Date ('16/12/2009') = datesortie; -- si format par défaut
SELECT titre FROM film WHERE To_Date ('16-12-09', 'DD-MM-YY') = datesortie;
SELECT titre FROM film WHERE To_Date ('12/09', 'MM/YY') = datesortie; -- pas de resultat, date incomplète

/* exercices :
    - quel jour de la semaine était le 9 novembre 1989 ?
    - Pour chaque acteur et actrice, afficher l’annee elle ou il a passe le baccalaureat
    - Noms des internautes qui ont notes un film dans la semaine qui a suivi sa sortie.
    - noms des acteurs qui ont joué dans un film alors qu'ils avaient entre 30 et 40 ans
 */


--arbres

--cree l'arbre depuis la racine
SELECT idcomm, idparent, texte, email FROM commentaire
START WITH idparent IS NULL CONNECT BY idparent = PRIOR idcomm;
--remarque: jointure interdite dans le FROM

--level indique le niveau dans l'arbre
SELECT level, texte, email FROM commentaire
START WITH idparent IS NULL CONNECT BY idparent = PRIOR idcomm;

--pour indenter
SELECT idcomm, idparent, RPAD(' ', level-1) || texte, email as texte FROM commentaire
START WITH idparent IS NULL CONNECT BY idparent = PRIOR idcomm;

SELECT idcomm, idparent, RPAD(' ', level-1) || texte, email as texte FROM commentaire
START WITH idparent IS NULL and email ='Juliette.Luna@gmail.fr' CONNECT BY idparent = PRIOR idcomm;


--cree l'arbre depuis la racine
SELECT idcomm, idparent, texte, email FROM commentaire
START WITH idparent IS NULL CONNECT BY idparent = PRIOR idcomm;


--parcours une branche depuis une feuille
SELECT idcomm, idparent, texte, email FROM commentaire
START WITH idcomm=4 CONNECT BY PRIOR idparent = idcomm;
