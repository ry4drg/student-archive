--procedures et fonctions stockees

--types des parametres: NUMBER, VARCHAR2 (sans précision), tous les autres types PL/SQL
CREATE OR REPLACE PROCEDURE maxentreepays (ppays VARCHAR2) IS
	vmax film.entree%type;
BEGIN
	SELECT max(entree) INTO vmax FROM film WHERE paysfilm=ppays;
	--SELECT max(nvl(entree, 0)) INTO vmax FROM film WHERE paysfilm=ppays;
	dbms_output.put_line(vmax);
END;


--appel d'une procédure: dans un autre bloc PL/SQL
DECLARE
	vpays film.paysfilm%type := :pays;
BEGIN
	maxentreepays(vpays);
END;

DECLARE
	CURSOR cpays IS SELECT DISTINCT paysfilm FROM film;
BEGIN
	FOR cpays_rec IN cpays LOOP
	    dbms_output.put(cpays_rec.paysfilm||' ');
	    maxentreepays(cpays_rec.paysfilm);
	END LOOP;
END;

--fonction: retourne un résultat
CREATE OR REPLACE FUNCTION fmaxentreepays (ppays VARCHAR2) RETURN NUMBER IS
	zero_film exception;
	max_null exception;
	vnb number(2);
	vmax film.entree%type;
BEGIN
	select count(*) into vnb from film where paysfilm = ppays;
	if vnb = 0 then
        	raise zero_film;
	end if;
	SELECT max(entree) INTO vmax FROM film WHERE paysfilm=ppays;
	if vmax is null then
            raise max_null;
    end if;
	RETURN(vmax);
exception
    when zero_film then
	RETURN(-1);
	when max_null then
    return(0);
end;

--appel d'une fonction : dans une requête ou un bloc PL/SQL
SELECT DISTINCT paysfilm, fmaxentreepays(paysfilm) FROM film;
SELECT DISTINCT paysfilm FROM film WHERE fmaxentreepays(paysfilm) > 1000000;

DECLARE
	vpays film.paysfilm%type := :pays;
BEGIN
	dbms_output.put_line (fmaxentreepays(vpays));
END;

DECLare
    vpays film.paysfilm%type := :pays;
    vmax film.entree%type;
begin
    vmax := fmaxentreepays(vpays);
    if vmax < 0 then
        dbms_output.put_line ('Pays sans film');
    elsif vmax = 0 then
        dbms_output.put_line ('données inconnues');
    else
        dbms_output.put_line (vmax);
    end if;
end;

--procedure/fonction avec parametres out, qui sont modifiés par la procédure
create or replace procedure iomaxentreepays(ppays varchar2, pmin out number, pmax out number) is
begin
    select min(entree), max(entree) into pmin, pmax from film where paysfilm = ppays;
end;

--appel d'une procédure in/out
DECLARE
	vpays film.paysfilm%type := :pays;
	vmin film.entree%type;
	vmax film.entree%type;
BEGIN
	iomaxentreepays(vpays, vmin, vmax);
	dbms_output.put_line('Max : '||vmax||' Min : '||vmin);
END;

--packages: regroupe plusieurs objets
create or replace package packminmax is
    cursor cpays is select distinct paysfilm from film;
    procedure max(ppays varchar2);
    function min(ppays varchar2) return number;
end;

create or replace package body packminmax is
    PROCEDURE max (ppays VARCHAR2) IS
	    vmax film.entree%type;
    BEGIN
	    SELECT max(entree) INTO vmax FROM film WHERE paysfilm=ppays;
    	dbms_output.put_line(vmax);
    END;

    function min (ppays VARCHAR2) return number IS
	    vmin film.entree%type;
    BEGIN
	    SELECT min(entree) INTO vmin FROM film WHERE paysfilm=ppays;
    	return vmin;
    END;
end;

--appel d'une procedure/fonction d'un package
DECLARE
BEGIN
	for cpays_rec in packminmax.cpays loop
	    dbms_output.put(cpays_rec.paysfilm||' ');
        packminmax.max(cpays_rec.paysfilm);
    end loop;
END;

SELECT distinct paysfilm, packminmax.min(paysfilm) from film;

