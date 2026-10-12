DROP TABLE pizza;
DROP table commande;
DROP TABLE recette;

/*************************
    Nested tables
***************************/

CREATE OR REPLACE TYPE ingredientT AS OBJECT
(
    noming VARCHAR2(40)
);

CREATE OR REPLACE TYPE ingredientsT AS TABLE OF ingredientt;

CREATE OR REPLACE TYPE pizzaT AS OBJECT
(
    nompizza VARCHAR2(40),
    prix NUMBER(4, 2),
    ingr ingredientst
);

CREATE TABLE pizza OF pizzat
(
    CONSTRAINT pk_piz PRIMARY KEY (nompizza)
)
NESTED TABLE ingr STORE AS tabingr;

INSERT INTO pizza VALUES ('Reine', 12.5,
    ingredientst(ingredientt('Sauce tomate'),
                 ingredientt('Champignon'),
                 ingredientt('Jambon'),
                 ingredientt('Mozarella')));

INSERT INTO pizza VALUES ('Margherita', 9.5,
    ingredientst(ingredientt('Sauce tomate'),
                 ingredientt('Basilic'),
                 ingredientt('Mozarella')));

INSERT INTO pizza VALUES ('Hawaienne', 13.5,
    ingredientst(ingredientt('Sauce tomate'),
                 ingredientt('Jambon'),
                 ingredientt('Mozarella'),
                 ingredientt('Ananas')));



commit;

SELECT * FROM pizza;
--pour recuperer une sous-table : mot-cle TABLE
SELECT nompizza, t.* FROM pizza p, TABLE(p.ingr) t; --joiture implicite
SELECT nompizza FROM pizza p, TABLE(p.ingr) t WHERE t.noming = 'Jambon';
SELECT count(*) FROM pizza p, TABLE(p.ingr) WHERE nompizza = 'Reine';
SELECT nompizza, count(*) FROM pizza p, TABLE(p.ingr) group by nompizza;
-- pas de table ingredients, elle doit etre creee par un SELECT
SELECT DISTINCT t.noming FROM pizza p, TABLE(p.ingr) t;
SELECT t.noming, count(*) FROM pizza p, TABLE(p.ingr) t GROUP BY t.noming;
select * from pizza;
INSERT INTO TABLE (SELECT p.ingr FROM pizza p WHERE nompizza = 'Margherita')
            VALUES ('Huile d''olive');
UPDATE pizza p SET prix = prix * 1.05
    WHERE EXISTS (SELECT * FROM TABLE (p.ingr) t WHERE t.noming = 'Jambon');
UPDATE TABLE (SELECT p.ingr FROM pizza p WHERE nompizza = 'Reine') ti
    SET ti.noming = 'Gruyère' WHERE ti.noming = 'Mozarella';
UPDATE TABLE (SELECT p.ingr FROM pizza p WHERE prix > 10) ti
    SET ti.noming = 'Jambon sec' WHERE ti.noming = 'Jambon';
--ne fonctionne pas, on ne peut pas update plusieurs tables en meme temps

DELETE FROM pizza p
       WHERE EXISTS (SELECT * FROM TABLE (p.ingr) t WHERE t.noming = 'Basilic');
DELETE FROM TABLE(SELECT p.ingr FROM pizza p WHERE nompizza ='Reine') ti
       WHERE ti.noming = 'Jambon';

/*ingredients qui apparaissent dans toutes les pizzas*/
select distinct t.noming from pizza p, table(p.ingr) t
group by t.noming having count(*) = (select count(*) from pizza);

/*prix moyen des pizzas par ingredients*/
SELECT t.noming, avg(p.prix) from pizza p, table(p.ingr) t group by t.noming;


/*************************
    VARRAY Varrying Array
***************************/

--sous-table dont la taille max est connue, par exemple 2 tailles de pizza max

DROP TABLE pizza;

--on ne cree pas un type specifique pour les tailles, on utilise des chaines
CREATE OR REPLACE TYPE taillesT as VARRAY (2) OF VARCHAR2(10);

CREATE OR REPLACE TYPE pizzaT AS OBJECT
(
    nompizza VARCHAR2(40),
    prix NUMBER(4, 2),
    ingr ingredientst,
    tailles taillest
);

CREATE TABLE pizza OF pizzat
(
    CONSTRAINT pk_piz PRIMARY KEY (nompizza)
)
NESTED TABLE ingr STORE AS tabingr;

--pas de contrainte possible sur les NESTED TABLE ou les VARRAY, declencheur necessaire
--on verifie que les tailles petite ou grande, et qu'il y en a au minimum 1
CREATE OR REPLACE TRIGGER trig_taille
BEFORE INSERT OR UPDATE OF tailles ON pizza
FOR EACH ROW
DECLARE
    ttailles taillest;
BEGIN
    ttailles := :new.tailles;
    --count: nb d'element dans le tableau
    IF ttailles.count = 0 then
        raise_application_error(-20001, 'au moins une taille requise');
    END IF;
    FOR i IN 1..ttailles.count LOOP
        IF ttailles(i) NOT IN ('petite', 'grande') THEN
            raise_application_error(-20001, 'taille invalide');
        END IF;
    END LOOP;
END;
--possible aussi avec une NESTED TABLE

INSERT INTO pizza VALUES ('Reine', 12.5,
    ingredientst(ingredientt('Sauce tomate'),
                 ingredientt('Champignon'),
                 ingredientt('Jambon'),
                 ingredientt('Mozarella')),
    taillest('grande', 'petite')
);

INSERT INTO pizza VALUES ('Margherita', 9.5,
    ingredientst(ingredientt('Sauce tomate'),
                 ingredientt('Basilic'),
                 ingredientt('Mozarella')),
    taillest('grande')
);

INSERT INTO pizza VALUES ('Hawaienne', 13.5,
    ingredientst(ingredientt('Sauce tomate'),
                 ingredientt('Jambon'),
                 ingredientt('Mozarella'),
                 ingredientt('Ananas')),
    taillest()
);

INSERT INTO pizza VALUES ('Hawaienne', 13.5,
    ingredientst(ingredientt('Sauce tomate'),
                 ingredientt('Jambon'),
                 ingredientt('Mozarella'),
                 ingredientt('Ananas')),
    taillest('bla')
);

INSERT INTO pizza VALUES ('Hawaienne', 13.5,
    ingredientst(ingredientt('Sauce tomate'),
                 ingredientt('Jambon'),
                 ingredientt('Mozarella'),
                 ingredientt('Ananas')),
    taillest('petite')
);


commit;

SELECT * FROM pizza;
SELECT nompizza, t.* FROM pizza p, TABLE(p.tailles) t;
--column_value pour acceder pour une colonne d'un VARRAY ou NESTED TABLE sans nom
SELECT nompizza FROM pizza p, TABLE(p.tailles) t WHERE t.column_value = 'grande';
SELECT count(*) FROM pizza p, TABLE(p.tailles) WHERE nompizza = 'Reine';
SELECT nompizza, count(*) FROM pizza p, TABLE(p.tailles) group by nompizza;

SELECT p.tailles FROM pizza p WHERE nompizza = 'Margherita';
INSERT INTO TABLE (SELECT p.tailles FROM pizza p WHERE nompizza = 'Margherita')
            VALUES ('petite');
--impossible: un varray n'est pas une table
UPDATE TABLE (SELECT p.tailles FROM pizza p WHERE nompizza = 'Margherita') t
    SET t.column_value = 'petite' WHERE t.column_value = 'grande';
--impossible aussi
DELETE FROM TABLE (SELECT p.tailles FROM pizza p WHERE nompizza = 'Margherita') t
    WHERE t.column_value = 'grande';
--impossible aussi
--la manipulation des VARRAY se fait en PL/SQL (comme dans le declencheur ci-dessus)

UPDATE pizza p SET p.tailles = taillest('petite', 'grande') WHERE nompizza = 'Margherita';
--possible

select * from pizza;

DELETE FROM pizza p
       WHERE EXISTS (SELECT * FROM TABLE (p.tailles) t WHERE t.column_value = 'grande');
--possible

SELECT * FROM pizza;

--a comparer avec le relationnel

/* noms des pizzas avec 2 tailles différentes*/
select p.nompizza from pizza p, table(p.tailles) t group by p.nompizza
having count(distinct t.column_value) = 2;
select p.nompizza from pizza p, table(p.tailles) t where t.count = 2; --ne fonctionne pas
select p.nompizza from pizza p where p.tailles.count = 2; --ne fonctionne pas

/* paires de noms de pizzas avec des tailles différentes*/
select p1.nompizza, p2.nompizza from pizza p1, pizza p2, table(p1.tailles) t1,
table(p2.tailles) t2 where t1.column_value != t2.column_value
and p1.nompizza < p2.nompizza;

select p1.nompizza, p2.nompizza from pizza p1, pizza p2, table(p1.tailles) t1,
table(p2.tailles) t2 where t1.column_value != t2.column_value
and p1.nompizza < p2.nompizza
and p1.nompizza in (select p.nompizza from pizza p, table(p.tailles) t
group by p.nompizza having count(distinct t.column_value) =1)
and p2.nompizza in (select p.nompizza from pizza p, table(p.tailles) t
group by p.nompizza having count(distinct t.column_value) =1)
;
