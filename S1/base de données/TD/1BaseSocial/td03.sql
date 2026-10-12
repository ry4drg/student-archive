/* 1. Quelle est la liste des utilisateurs de la base ? */

SELECT pseudo, nom, prenom
FROM utilisateur;

/* 2. Quels sont les utilisateurs originaires du Brésil, triés par nom ? */

SELECT pseudo, nom, prenom
FROM utilisateur
WHERE idville IN (SELECT idville FROM ville WHERE pays = 'Brésil')
ORDER BY nom;

/* 3. Quels sont les membres du groupe “Flat earth society” ? */

SELECT u.pseudo, u.nom, u.prenom
FROM utilisateur u
JOIN estmembre em ON u.pseudo = em.pseudo
JOIN page p ON em.idpage = p.idpage
WHERE p.nompage = 'Flat earth society';

'''ou'''

SELECT pseudo
FROM estMembre
WHERE idPage = (SELECT idPage FROM Page WHERE nomPage = 'Flat earth society' AND typePage = 'groupe');

/* 4. Afficher les ids et dates des publications post ́ees en juillet 2022. */

SELECT idpub, datepub
FROM publication
WHERE TO_CHAR(datepub, 'MM/YYYY') = '07/2022';

/* 5. Afficher les noms des villes d’origine de chaque utilisateur. Si l’information n’est pas pr ́esente, afficher “pas d’info” (utiliser NVL). */

SELECT u.pseudo, NVL(v.nomville, 'pas d''info') AS ville_origine
FROM utilisateur u
LEFT JOIN ville v ON u.idville = v.idville;

/* 6. Afficher les pseudos des utilisateurs dont le numero de telephone n’est pas un portable franc ̧ais
(le numero ne commence pas par 06 ou 07 ou ne fait pas 10 caracteres). */

SELECT pseudo
FROM utilisateur
WHERE LENGTH(telephone) != 10 OR (SUBSTR(telephone, 1, 2) NOT IN ('06', '07'));

/* 7. Quels utilisateurs ont plus de 30 ans ? */

SELECT pseudo, nom, prenom
FROM utilisateur
WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, datenaiss) / 12) > 30;

/* 8. Afficher l’arborescence des publications qui r ́epondent a celles de “Kevin69”, pour les discussions ≥ 4 publications. */

SELECT p.idpub , p.titrepub, CONNECT_BY_ROOT p.titrepub AS titre_initial, LEVEL AS niveau
FROM publication p
CONNECT BY PRIOR p.idpub = p.idparent
START WITH p.pseudo = 'Kevin69'
AND LEVEL >= 4;

/* 9. Afficher le niveau de chaque publication et le titre de la publication initiale (utiliser connect by root). */

SELECT p.idpub, p.titrepub, CONNECT_BY_ROOT p.titrepub AS titre_initial, LEVEL AS niveau
FROM publication p
CONNECT BY PRIOR p.idpub = p.idparent
START WITH p.idparent IS NULL;


/* 10. Quels utilisateurs sont nés un lundi ? */

SELECT pseudo, nom, prenom
FROM utilisateur
WHERE TO_CHAR(datenaiss, 'D') = '2';

/* 11. Quels noms d’utilisateurs commencent par une minuscule ? On pourra utiliser SUBSTR et LOWER. */

SELECT pseudo, nom
FROM Utilisateur
WHERE LOWER(SUBSTR(nom, 1, 1)) = SUBSTR(nom, 1, 1);

/* 12. Afficher les noms et emails des utilisateurs dont l’email contient leur nom. */

SELECT pseudo, nom, prenom, email
FROM utilisateur
WHERE INSTR(email, nom) > 0;

'''ou'''

SELECT nom, prenom, email
FROM Utilisateur
WHERE LOWER(email) LIKE '%' || LOWER(nom) || '%';

/* 13. Afficher les ids et titres des publications qui ont été postées le même mois que le mois de naissance de l’utilisateur qui l’a écrite. */

SELECT p.idpub, p.titrepub
FROM publication p
JOIN utilisateur u ON p.pseudo = u.pseudo
WHERE TO_CHAR(p.datepub, 'MM/YYYY') = TO_CHAR(u.datenaiss, 'MM/YYYY');

/* 14. Quels utilisateurs sont amis et habitent dans la même ville ? */

SELECT e1.pseudoA, e1.pseudoB
FROM enLien e1
JOIN enLien e2 ON e1.pseudoA = e2.pseudoA AND e1.pseudoB = e2.pseudoB AND e1.datelien = e2.datelien
WHERE e1.typeLien = 'ami' AND e2.typeLien = 'ami'
AND e1.pseudoA < e1.pseudoB;

'''ou'''

SELECT e1.pseudoA AS ami1, e2.pseudoA AS ami2, v.nomVille AS ville
FROM enLien e1
JOIN enLien e2 ON e1.pseudoB = e2.pseudoB AND e1.pseudoA < e2.pseudoA
JOIN Utilisateur u1 ON e1.pseudoA = u1.pseudo
JOIN Utilisateur u2 ON e2.pseudoA = u2.pseudo
JOIN Ville v ON u1.idVille = v.idVille
WHERE e1.typeLien = 'ami' AND e2.typeLien = 'ami';

/* 15. Afficher les ids, titres et textes des publications qui ont reçu un “j’aime” d’un utilisateur du même pays que son auteur.*/

SELECT p.idpub, p.titrepub, p.textepub
FROM publication p
JOIN aimepub ap ON p.idpub = ap.idpub
JOIN utilisateur u ON ap.pseudo = u.pseudo
WHERE u.idville = p.idville;

/* 16. Quels sont les messages privés qui ont été envoyés le même jour que le début de la liaison d’amitié ?*/

SELECT m.idmessage, m.textemessage
FROM message m
JOIN enLien e ON m.auteur = e.pseudoA
WHERE TO_CHAR(m.datemessage, 'DD/MM/YYYY') = TO_CHAR(e.datelien, 'DD/MM/YYYY');

'''ou'''
SELECT m.idMessage, m.texteMessage
FROM Message m
JOIN enLien e ON m.pseudo = e.pseudoA
WHERE TRUNC(TO_DATE(m.dateMessage, 'DD/MM/YYYY')) = TRUNC(TO_DATE(e.dateLien, 'DD/MM/YYYY'));

/* 17. Quels utilisateurs ont aimé une page que “Kevin69” a aimé ?*/

SELECT DISTINCT u.pseudo, u.nom, u.prenom
FROM utilisateur u
JOIN aimePage ak ON u.pseudo = ak.pseudo
WHERE ak.idpage IN (SELECT idpage FROM aimePage WHERE pseudo = 'Kevin69');

/* 18. Quels utilisateurs n’ont jamais aim ́e une page ?*/

SELECT pseudo
FROM Utilisateur
WHERE pseudo NOT IN (SELECT DISTINCT pseudo FROM aimePage);

/* Quels utilisateurs ont particip ́e a des discutions de profondeur > 3 (utiliser sys connect by path) ? */

SELECT DISTINCT pseudo
FROM Publication
WHERE LENGTH(SYS_CONNECT_BY_PATH(idPub, '/')) - LENGTH(REPLACE(SYS_CONNECT_BY_PATH(idPub, '/'), '/')) > 3
START WITH idParent IS NULL
CONNECT BY PRIOR idPub = idParent;
