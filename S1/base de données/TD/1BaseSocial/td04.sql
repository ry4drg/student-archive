/* 1. Les utilisateurs viennent de combien de pays differents ? */

SELECT COUNT(DISTINCT pays) AS pays_différents
FROM ville;


/* 2. Combien y a-t-il d’utilisateurs dans chaque ville fran ̧caise ? */

SELECT v.nomville, COUNT(u.pseudo) AS nombre_utilisateurs
FROM ville v
LEFT JOIN utilisateur u ON v.idville = u.idville
WHERE v.pays = 'France'
GROUP BY v.nomville;

/* 3. Combien de comptes ont  ́et ́e cr ́e ́es entre 2010 et 2017 ? */

SELECT COUNT(*) AS nombre_comptes_créés
FROM utilisateur
WHERE TO_CHAR(datecrea, 'YYYY') BETWEEN 2010 AND 2017;

/* 4. Quels sont les amis de “Kevin69” ? */

SELECT e.pseudoB AS ami
FROM enLien e
WHERE e.pseudoA = 'Kevin69' AND e.typeLien = 'ami';

/* 5. Quelles publications de moins de 10 caracteres ont obtenu plus de 3 “Jaime” ? */

SELECT p.idpub, p.titrepub, p.textepub
FROM publication p
JOIN aimePub ap ON p.idpub = ap.idpub
WHERE LENGTH(p.textepub) < 10
GROUP BY p.idpub, p.titrepub, p.textepub
HAVING COUNT(ap.pseudo) > 3;

/* 6. Quels sont les utilisateurs habitant a Londres, par nombre d’amis croissant. */

SELECT u.pseudo, u.nom, u.prenom, COUNT(e.pseudoB) AS nombre_amis
FROM utilisateur u
LEFT JOIN enLien e ON u.pseudo = e.pseudoA
WHERE u.idville = (SELECT idville FROM ville WHERE nomville = 'Londres')
GROUP BY u.pseudo, u.nom, u.prenom
ORDER BY COUNT(e.pseudoB);

/* 7. Quel groupe a le plus de membres ? */

SELECT nompage AS groupe, COUNT(pseudo) AS nombre_membres
FROM estMembre em
JOIN page p ON em.idpage = p.idpage
GROUP BY nompage
ORDER BY COUNT(pseudo) DESC
LIMIT 1;

/* 8. Quels utilisateurs n’ont jamais envoyé de messages privés? Ecrire deux requêtes : une avec une opération ensembliste, une avec une sous-requête. */

SELECT pseudo, nom, prenom
FROM utilisateur
MINUS
SELECT DISTINCT auteur AS pseudo
FROM message;

/* 9. Dans le groupe “Flat Earth Society”, y a-t-il plus d’hommes ou de femmes ? */

SELECT pseudo, nom, prenom
FROM utilisateur
WHERE pseudo NOT IN (SELECT DISTINCT auteur FROM message);

/* 10. Cr ́eer une colonne ”nbaime” dans la table Publication. La compl ́eter avec le nombre de “j’aime” pour chaque publication. */

SELECT p.nompage AS groupe, SUM(CASE WHEN u.sexe = 'M' THEN 1 ELSE 0 END) AS hommes, SUM(CASE WHEN u.sexe = 'F' THEN 1 ELSE 0 END) AS femmes
FROM page p
JOIN estMembre em ON p.idpage = em.idpage
JOIN utilisateur u ON em.pseudo = u.pseudo
WHERE p.nompage = 'Flat Earth Society'
GROUP BY p.nompage;

/* 11. Afficher les pages qui obtiennent en moyenne plus de 2 “J’aime” par publication, class ́ees par nombre de “J’aime” moyen. */

ALTER TABLE publication
ADD nbaime NUMBER(3);

SELECT p.idpage, p.nompage, AVG(pub.nbaime) AS nbmoyenaime
FROM page p
LEFT JOIN publication pub ON p.idpage = pub.idpage
GROUP BY p.idpage, p.nompage
HAVING AVG(pub.nbaime) > 2
ORDER BY AVG(pub.nbaime) DESC;

/* 12. Pour chaque page, afficher la publication avec le plus de “J’aime”. */

SELECT p.idpage, p.nompage, pub.titrepub AS publication_aimée
FROM page p
JOIN publication pub ON p.idpage = pub.idpage
WHERE pub.nbaime = (SELECT MAX(nbaime) FROM publication WHERE idpage = p.idpage)
ORDER BY p.idpage;

/* 13. Quels utilisateurs sont dans l’ensemble des groupes cr ́e ́es par “Kevin69” ? */

SELECT em.pseudo
FROM estMembre em
JOIN page p ON em.idpage = p.idpage
WHERE NOT EXISTS (
    SELECT g.idpage
    FROM page g
    WHERE g.createur = 'Kevin69'
    AND g.idpage NOT IN (SELECT idpage FROM estMembre em2 WHERE em2.pseudo = em.pseudo)
);

/* 14. Quels “amis” de “Kevin69” ont aim ́e toutes ses publications ? */

SELECT e.pseudoB
FROM enLien e
JOIN publication p ON e.pseudoB = p.pseudo
WHERE e.pseudoA = 'Kevin69'
GROUP BY e.pseudoB
HAVING COUNT(DISTINCT p.idpub) = (SELECT COUNT(DISTINCT idpub) FROM publication WHERE pseudo = 'Kevin69');

/* 15. Quels utilisateurs ont 66% de leurs groupes en commun ? */

SELECT a.pseudo, b.pseudo
FROM (
    SELECT e1.pseudoA AS pseudo, COUNT(DISTINCT e1.idpage) AS groupes_a
    FROM enLien e1
    WHERE e1.typeLien = 'estMembre'
    GROUP BY e1.pseudoA
) a
JOIN (
    SELECT e2.pseudoA AS pseudo, COUNT(DISTINCT e2.idpage) AS groupes_b
    FROM enLien e2
    WHERE e2.typeLien = 'estMembre'
    GROUP BY e2.pseudoA
) b
ON a.pseudo = b.pseudo
WHERE a.groupes_a >= 0.66 * b.groupes_b;

/* 16. Quels utilisateurs sont amis avec tous les amis de “Kevin69” ? */

SELECT DISTINCT e1.pseudoA AS pseudo
FROM enLien e1
WHERE e1.typeLien = 'ami'
MINUS
SELECT DISTINCT e2.pseudoB AS pseudo
FROM enLien e2
WHERE e2.typeLien = 'ami'
AND e2.pseudoA = 'Kevin69';

/* 17. Afficher les groupes dont au moins la moiti ́e des membres ont plus de 2 “J’aime” en moyenne sur les publications de leurs pages. */

SELECT p.nompage AS groupe
FROM page p
JOIN estMembre em ON p.idpage = em.idpage
LEFT JOIN (
    SELECT idpage, AVG(nbaime) AS avg_nbaime
    FROM publication
    GROUP BY idpage
) avg_pub ON p.idpage = avg_pub.idpage
WHERE em.typeLien = 'estMembre'
GROUP BY p.nompage
HAVING SUM(CASE WHEN avg_pub.avg_nbaime > 2 THEN 1 ELSE 0 END) >= COUNT(p.idpage) / 2;

/* 18. Quels utilisateurs ont publi ́e sur toutes les pages de leurs amis ? */

SELECT DISTINCT e1.pseudoA AS pseudo
FROM enLien e1
WHERE e1.typeLien = 'ami'
MINUS
SELECT DISTINCT e2.pseudoB AS pseudo
FROM enLien e2
WHERE e2.typeLien = 'ami'
AND e2.pseudoA NOT IN (
    SELECT e3.pseudoA
    FROM enLien e3
    WHERE e3.typeLien = 'estMembre'
);

/* 19. Les publications initi ́ees par “Kevin69” generent combien de reponses en moyenne ? */

SELECT AVG(COUNT(p2.idpub)) AS nombre_moyen_de_réponses
FROM publication p1
JOIN publication p2 ON p1.idpub = p2.idparent
WHERE p1.pseudo = 'Kevin69'
GROUP BY p1.idpub;

/* 20. Afficher le nombre moyen de mots des publications contenant “Trump” (compter les espaces qui s ́eparent les mots). */

SELECT AVG(LENGTH(REGEXP_REPLACE(textepub, '[^ ]', '')) + 1) AS nombre_moyen_de_mots
FROM publication
WHERE UPPER(textepub) LIKE '%TRUMP%';
