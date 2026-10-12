-- la note est comprise entre 0 et 10
alter table notation add constraint ck_note check (note between 0 and 10);

-- l'email contient un @
alter table internaute add constraint ck_arobase check (email like '%@%');

-- seuls les internautes de la base peuvent noter les films
--clé étrangère dans notation -> internautes

-- le changement d'un idacteur ou la suppression d'un acteur entraine la MAJ de jouer
alter table jouer drop CONSTRAINT fkjoueracteur;
alter table jouer add (
    constraint fkjoueracteur FOREIGN KEY (idacteur) references acteur(idacteur)
    on delete cascade
);
-- on update cascade n'existe pas en Oracle, mais dans d'autres SGBD

create or replace trigger updatejouer
    after update of idacteur on acteur
    for each row
begin
    update jouer set idacteur = :new.idacteur where idacteur = :old.idacteur;
END;

update acteur set idacteur = 52 where idacteur = 1;
select * from jouer;
rollback;

-- le genre du film est en minuscule
alter table film add constraint ckmajgenre check (genre = upper(genre));
--impossible : les donnees deja dans la table doivent respecter la contrainte

alter table film add constraint ckmajgenre check (genre = lower(genre));

-- le film a été noté après sa sortie

create or replace trigger ckdatenote
    before insert or update of datenote on notation
    for each ROw
DECLARE
    dates date;
begin
    select datesortie into dates from film where idfilm = :new.idfilm;
    if :new.datenote < dates then
        raise_application_error(-20001, 'La date de la note doit être supérieure à la date de sortie du film');
    END IF;
END;

insert into notation Values('Amandine.Dahan@gmail.fr', 1, 3, to_date('01/01/1900', 'DD/MM/YYYY'));

-- l'id d'un commentaire est supérieur à son idparent

alter table commentaire add constraint ckid check(idcomm > idparent);

-- un film français fait au moins 1000 entrees

--A => B est equivalent à not(A) or B
alter table film add constraint ckfrance check (paysfilm <> 'France' or entree >= 1000);

insert into film(idfilm, titre, paysfilm, entree) values (50, 'Toto', 'France', 12);
insert into film(idfilm, titre, paysfilm, entree) values (50, 'Toto', 'France', 1200);
rollback;

--un commentaire qui commence un nouveau fil fait référence à une note

--idparent is null implique idfilm is not null
--A => B est equivalent à not(A) or B

alter table commentaire add constraint ckidparent check(idparent is not null or idfilm is not null);

--l'insertion n'une note est toujours à la date du jour

alter table notation add constraint ckdatenote check (datenote = sysdate);
--impossible: pas de sysdate dans un check

create or replace trigger insertnotedate
    before insert on notation
    for each row
begin
    if :new.datenote <> sysdate then
        raise_application_error(-20001, 'la date doit être celle d''aujourd''hui');
    END IF;
END;

alter trigger insertnotedate disable;

--un internaute ne peut changer sa note qu'avec une note supérieure

create or replace trigger majnote
    before update of note on notation
    for each row
begin
    if :new.note <= :old.note then
        raise_application_error(-20001, 'Meilleure note requise');
    END IF;
END;

select * from notation;
update notation set note = 5 where email = 'Isabelle.Pruvat@yahoo.fr' and idfilm =1;

alter trigger majnote disable;

--un internaute ne peut changer sa note qu'avec une note supérieure à la moyenne des notes du film

create or replace trigger majnotemoy
    before update of note on notation
    for each row
declare
    moy number (4, 2);
begin
    select avg(note) into moy from notation where idfilm = :new.idfilm;
    if :new.note <= moy then
        raise_application_error(-20001, 'Meilleure note requise');
    END IF;
END;

select * from notation;
update notation set note = 5 where email = 'Isabelle.Pruvat@yahoo.fr' and idfilm =1;
--déclencheur composite (compound trigger) nécessaire

