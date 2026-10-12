/*
1) Nombre d'utilisateurs par ville, par ordre croissant sur le nombre.
*/
SELECT count(*), idVille FROM utilisateur
GROUP BY idVille
ORDER BY count(*);

/* BOF */
SELECT count(*), nomVille FROM utilisateur NATURAL JOIN ville
GROUP BY nomVille, idVille
ORDER BY count(*);
SELECT nomville, pays FROM ville;

/*
2) Publications postées sur une page le mois de la création de la page :
afficher le nom de page, l'id de la publication, ainsi que le mois en lettres.
*/
SELECT idpub, nompage, to_char(datecrea, 'month') FROM publication
INNER JOIN page
ON publication.idpage = page.idpage
AND to_char(publication.datepub, 'MM/YYYY')=to_char(pag.datecrea, 'MM/YYYY');

/*
3) Nom des utilisateurs qui ont aimé plus de pages que la moyenne des utilisateurs.
*/
SELECT nom FROM aimepub NATURAL JOIN utilisateur
GROUP BY pseudo, nom
HAVING count(*) >=
(SELECT avg(count(*)) FROM aimepub GROUP BY pseudo);

SELECT nom, count(*) FROM aimepub NATURAL JOIN utilisateur
GROUP BY pseudo, nom
HAVING count(*) >=
(SELECT avg(count(*)) FROM aimepub GROUP BY pseudo);

/*
4) Pays pour lesquels chaque ville a au moins un utilisateur qui y habite.
*/
SELECT pays FROM ville v1 NATURAL JOIN utilisateur
GROUP BY pays HAVING count(distinct idVille) =
(SELECT count(distinct idville) FROM ville v2 WHERE v1.pays = v2.pays);

SELECT pays FROM ville
MINUS
SELECT pays FROM ville LEFT JOIN utilisateur
ON ville.idville = utilisateur.idville
WHERE pseudo IS NULL;

/*
Utilisateur(pseudo, nom, prenom, mail, telephone, dateNaiss, sexe, #idVille)
Ville(idVille, nomVille, pays)
Page(idPage, nomPage, typePage, datecrea, #createur)
Publication(idPub, titrePub, datePub, textePub, #idParent, #pseudo, #idpage)
aimePage(#idPage, #pseudo)
aimePub(#idPub, #pseudo)
*/
