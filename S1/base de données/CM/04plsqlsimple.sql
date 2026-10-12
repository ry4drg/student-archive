--set serveroutput on;

--exemple de programme simple
DECLARE
    vidfilm number(3); --types possibles : tous les types de SQL Varchar2(20), Date, number(P,q) + Boolean
    vpays film.paysfilm%type; --vpays a le même type que paysfilm
    vfilm film%rowtype; --vfilm a autant de colonnes que film
    nbnotes number(3) := 0; --variable déclarée et initialisée
    moy number(4, 2);

Begin
    -- := affectation
    -- : lecture au clavier, sous SQLplus symbole &
    vidfilm := :cequevousvoulez;
    select * into vfilm from film where idfilm = vidfilm;
    --select into ne fonctionne que si la requête ne retourne qu'une seule ligne
    select count(*), avg(note) into nbnotes, moy from notation where idfilm = vidfilm;
    vpays := vfilm.paysfilm;
    if vpays = 'France' then
        dbms_output.put_line(vfilm.titre||' est français, cocorico');
    elsif vpays = 'USA' then
        dbms_output.put_line(vfilm.titre||' est americain, pas cocorico');
    else
        dbms_output.put_line(vfilm.titre||' n''est pas français, pas cocorico');
    end if;
    dbms_output.put_line('Moyenne :'||moy||' nb de notes : '||nbnotes);
end;

--boucles FOR i IN [REVERSE] 1..N LOOP ... END LOOP;
-- WHILE condition LOOP ... END LOOP;

--curseur

DECLARE
    vidfilm number(3) := 10;
    vtitre film.titre%type;
    CURSOR cnotes IS SELECT nomint, prenomint, note from
        notation natural join internaute where idfilm = vidfilm;
BEGIN
    select titre into vtitre from film where idfilm = vidfilm;
    dbms_output.put_line('Notes de '||vtitre);
	FOR cnotes_rec IN cnotes LOOP
		dbms_output.put_line(cnotes_rec.prenomint||' '||cnotes_rec.nomint||' a noté '||cnotes_rec.note);
	END LOOP;
END;

DECLARE
    vidfilm number(3) := 10;
    vtitre film.titre%type;
    CURSOR cnotes IS SELECT nomint, prenomint, note from
        notation natural join internaute where idfilm = vidfilm order by note desc;
    cnotes_rec cnotes%rowtype;
BEGIN
    select titre into vtitre from film where idfilm = vidfilm;
    dbms_output.put_line('Notes de '||vtitre);
    open cnotes;
    --nb de lignes du curseur
    fetch cnotes into cnotes_rec;
	while cnotes%found and cnotes_rec.note >= 5 LOOP
		dbms_output.put_line(cnotes_rec.prenomint||' '||cnotes_rec.nomint||' a noté '||cnotes_rec.note);
		fetch cnotes into cnotes_rec;
	END LOOP;
    dbms_output.put_line('Nb total de notes : '||cnotes%rowcount);
	close cnotes;
END;

--boucle imbriquée : curseur parametree
--types des paramaètres : VARCHAR2, NUMBER (sans précision), film.idfilm%type ...

DECLARE
    cursor cfilm is select idfilm, titre from film;
    CURSOR cnotes(pidfilm number) IS SELECT nomint, prenomint, note from
        notation natural join internaute where idfilm = pidfilm;
BEGIN
    for cfilm_rec in cfilm loop
        dbms_output.put_line('Notes de '||cfilm_rec.titre);
	    FOR cnotes_rec IN cnotes(cfilm_rec.idfilm) LOOP
		    dbms_output.put_line('  '||cnotes_rec.prenomint||' '||cnotes_rec.nomint||' a noté '||cnotes_rec.note);
	    END LOOP;
    end loop;
END;
