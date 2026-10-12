--rappel : contraintes de valeur

/*
	genre VARCHAR2 (20) check (genre in ('comédie', 'drame', 'policier')),
	duree number(3) check (duree between 0 and 500),
	entree number(8) check (entree >= 0)
*/

--clés étrangères

--integrité des valeurs entre plusieurs tables : déclencheurs (triggers)

--drop table statbase;

create table statbase (
    nomtable varchar2(20) primary key,
    nbinsert number(3)
);

CREATE OR REPLACE TRIGGER statnotation
    AFTER INSERT ON film
    FOR EACH ROW
DECLARE
    VNbInsert Number(3);
BEGIN
    SELECT NbInsert INTO VNbInsert
    FROM statbase
    WHERE NomTable='film';
    UPDATE statbase
    SET NbInsert = VNbInsert+1
    WHERE NomTable='film' ;
EXCEPTION
    WHEN No_Data_Found THEN
    INSERT INTO statbase VALUES ('film', 1);
END ;

insert into film(idfilm, titre) Values(40, 'Toto à la plage');
select * from statbase;
insert into film(idfilm, titre) Values(41, 'Toto à la montagne');
select * from statbase;
rollback;

--syntaxe
/*
CREATE [OR REPLACE] TRIGGER <Nom_Trigger>
[BEFORE | AFTER] [INSERT [OR] DELETE [OR] UPDATE [OF <Attribut>]]
ON <Nom_Table>
[FOR EACH ROW][WHEN <Condition>]
DECLARE
BEGIN
[EXCEPTION]
END
*/

-- :Old et :New

ALTER TABLE film ADD nbnotes number(3);
UPDATE film set nbnotes = (select count(*) from notation where idfilm = film.idfilm);
select * from film;

CREATE OR REPLACE TRIGGER MajNbNotes
    AFTER INSERT ON notation
    FOR EACH ROW
BEGIN
    UPDATE film
    SET nbnotes = nbnotes+1
    WHERE idfilm = :new.idfilm;
END ;

select * from film;
insert into notation values ('Amandine.Dahan@gmail.fr', 2, 8, sysdate);
insert into notation values ('Isabelle.Pruvat@yahoo.fr', 2, 4, sysdate);


CREATE OR REPLACE TRIGGER MajNbNotes
    AFTER UPDATE ON notation
    FOR EACH ROW
BEGIN
    if :old.note <> :new.note then
        UPDATE film
        SET nbnotes = nbnotes+1
        WHERE idfilm = :new.idfilm;
    end if;
END ;

select * from film;
update notation set note = 8 where email = 'Amandine.Dahan@gmail.fr' and idfilm = 2;
update notation set note = 7 where email = 'Amandine.Dahan@gmail.fr' and idfilm = 2;

delete from notation where email = 'Amandine.Dahan@gmail.fr' and idfilm = 2;
delete from notation where email = 'Isabelle.Pruvat@yahoo.fr' and idfilm = 2;
UPDATE film set nbnotes = (select count(*) from notation where idfilm = film.idfilm);

CREATE OR REPLACE TRIGGER MajNbNotes
    AFTER INSERT ON notation
    FOR EACH ROW WHEN (new.note > 5) --Attention !!! pas de ":" avant new/old
BEGIN
     UPDATE film
     SET nbnotes = nbnotes+1
     WHERE idfilm = :new.idfilm;  -- ":" avant new/old dans le begin
END ;

select * from film;
insert into notation values ('Amandine.Dahan@gmail.fr', 2, 8, sysdate);
insert into notation values ('Isabelle.Pruvat@yahoo.fr', 2, 4, sysdate);

CREATE OR REPLACE TRIGGER MajNbNotes
    AFTER UPDATE of note ON notation
    FOR EACH ROW when (old.note <> new.note)
BEGIN
     UPDATE film
     SET nbnotes = nbnotes+1
     WHERE idfilm = :new.idfilm;
END ;

select * from film;
update notation set note = 8 where email = 'Amandine.Dahan@gmail.fr' and idfilm = 2;
update notation set note = 7 where email = 'Amandine.Dahan@gmail.fr' and idfilm = 2;

delete from notation where email = 'Amandine.Dahan@gmail.fr' and idfilm = 2;
delete from notation where email = 'Isabelle.Pruvat@yahoo.fr' and idfilm = 2;
UPDATE film set nbnotes = (select count(*) from notation where idfilm = film.idfilm);

create or replace trigger insertIdfilm
    before insert on film
    for each row when (new.idfilm = 0)
begin
    --modif de la nouvelle valeur par le declencheur
    select max(idfilm)+1 into :new.idfilm from film;
END;

insert into film(idfilm, titre) values (0, 'Toto à la plage');
select * from film;
rollback;
--inserting, updating, deleting

CREATE OR REPLACE TRIGGER MajNbNotes
    AFTER INSERT OR DELETE ON notation
    FOR EACH ROW
BEGIN
    IF Inserting THEN
        UPDATE film
        SET nbnotes = nbnotes+1
        WHERE idfilm = :new.idfilm;
    END IF ;
    IF Deleting THEN
        UPDATE film
        SET nbnotes = nbnotes-1
        WHERE idfilm = :old.idfilm;
    END IF ;
END ;

select * from film;
insert into notation values ('Amandine.Dahan@gmail.fr', 2, 8, sysdate);
delete from notation where email = 'Amandine.Dahan@gmail.fr' and idfilm = 2;

alter table film drop column nbnotes;

commit;

--activer/desactiver un déclencheur
--ALTER TRIGGER majnbnotes ENABLE/DISABLE
--supprimer un déclencheur
--DROP TRIGGER majnbnotes
