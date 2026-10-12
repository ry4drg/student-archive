--exceptions prédéfinies

DECLARE
    vtitre film.titre%type := :titre;
    vidfilm film.idfilm%type;
    CURSOR cnotes(pidfilm number) IS SELECT nomint, prenomint, note from
        notation natural join internaute where idfilm = pidfilm;
BEGIN
    select idfilm into vidfilm from film where titre = vtitre;
    dbms_output.put_line('Notes de '||vtitre);
	FOR cnotes_rec IN cnotes(vidfilm) LOOP
		dbms_output.put_line(cnotes_rec.prenomint||' '||cnotes_rec.nomint||' a noté '||cnotes_rec.note);
	END LOOP;
exception
    -- si le select ...into ne retourne aucun résultat
    when no_data_found then
        dbms_output.put_line('Ce film n''est pas dans la base');
    -- si le select ... into retourne plusieurs résultats
    when too_many_rows then
        dbms_output.put_line('Plusieurs films avec ce titre dans la base');
END;

--autres exceptions prédéfinies
--zero_divide
--dup_val_on_index : insert into avec une cle deja existante
--OTHERS : cas par défaut

DECLARE
    vtitre film.titre%type := :titre;
    vidfilm film.idfilm%type := :idfilm;
BEGIN
    insert into film(idfilm, titre) values (vidfilm, vtitre);
exception
    when dup_val_on_index then
        dbms_output.put_line('idfilm déjà dans la base');
end;


DECLARE
    vtitre film.titre%type := :titre;
    vidfilm film.idfilm%type;
    pasdenotes EXCEPTIOn;
    nbnotes number(3);
    CURSOR cnotes(pidfilm number) IS SELECT nomint, prenomint, note from
        notation natural join internaute where idfilm = pidfilm;
BEGIN
    select idfilm into vidfilm from film where titre = vtitre;
    select count(*) into nbnotes from notation where idfilm = vidfilm;
    if nbnotes = 0 then
        raise pasdenotes;
    end if;
    dbms_output.put_line('Notes de '||vtitre);
	FOR cnotes_rec IN cnotes(vidfilm) LOOP
		dbms_output.put_line(cnotes_rec.prenomint||' '||cnotes_rec.nomint||' a noté '||cnotes_rec.note);
	END LOOP;
exception
    when pasdenotes then
        dbms_output.put_line('Films sans note');
    when others then --cas par défaut
        --affiche le code et le message de l'erreur
        dbms_output.put_line('Erreur : '||sqlcode||' '||sqlerrm);
 END;


insert into film(idfilm, titre) values (43, 'Toto');
rollback;


--raise_application_error: interrompt l'execution comme une exception classique
DECLARE
    vtitre film.titre%type := :titre;
    vidfilm film.idfilm%type;
    nbnotes number(3);
    CURSOR cnotes(pidfilm number) IS SELECT nomint, prenomint, note from
        notation natural join internaute where idfilm = pidfilm;
BEGIN
    select idfilm into vidfilm from film where titre = vtitre;
    select count(*) into nbnotes from notation where idfilm = vidfilm;
    if nbnotes = 0 then
        raise_application_error(-20001, 'film sans note');
        --le code doit être compris entre -20000 et -20999
    end if;
    dbms_output.put_line('Notes de '||vtitre);
	FOR cnotes_rec IN cnotes(vidfilm) LOOP
		dbms_output.put_line(cnotes_rec.prenomint||' '||cnotes_rec.nomint||' a noté '||cnotes_rec.note);
	END LOOP;
exception
    when others then --cas par défaut
        --affiche le code et le message de l'erreur
        dbms_output.put_line('Erreur : '||sqlcode||' '||sqlerrm);
 END;



