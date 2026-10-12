drop table cibles;
drop table aimePub;
drop table aimePage;
drop table enLien;
drop table estMembre;
drop table message;
drop table publication cascade constraints;
drop table page;
drop table utilisateur cascade constraints;
drop table ville;



create table ville(
    idville number(3) constraint pkville primary key,
    nomville varchar2(30),
    pays varchar2(30)
);

create table utilisateur(
    pseudo varchar2(30) constraint pkutil primary key,
    nom varchar2(30),
    prenom varchar2(30),
    email varchar2(30),
    telephone varchar2(30),
    datenaiss date,
    sexe char(1) constraint csexe check (sexe in ('M', 'F')),
    idville number(3) constraint fkutil references ville(idville),
    datecrea date,
    datecloture date
);

create table page
(
    idpage   number(3) constraint pkpage primary key,
    nompage  varchar2(30),
    typepage varchar2(30) constraint ctypep check (typepage in ('publique', 'privée', 'groupe')),
    createur varchar2(30) constraint fkpage references utilisateur (pseudo)
);

create table publication (
    idpub number(3) constraint pkpub primary key,
    titrepub varchar2(30),
    datepub date,
    textepub varchar2(50),
    idparent number(3) constraint fkparent references publication(idpub),
    pseudo varchar2(30) constraint fkpseudo references utilisateur(pseudo),
    idpage number(3) constraint fkpagepub references page(idpage)
);

create table message (
    idmessage number(3) constraint pkmessage primary key,
    textemessage varchar2(30),
    datemessage date,
    auteur varchar2(30) constraint fkmessage references utilisateur(pseudo)
);

create table estMembre(
    pseudo varchar2(30) constraint fkpmembre references utilisateur(pseudo),
    idpage number(3) constraint fkpagemembre references page(idpage),
    constraint pkmembre primary key (pseudo, idpage)
);

create table enLien(
    pseudoA varchar2(30) constraint fkpA references utilisateur(pseudo),
    pseudoB varchar2(30) constraint fkpB references utilisateur(pseudo),
    typeLien varchar2(30) constraint ctypelien check (typeLien in ('ami', 'en couple')),
    datelien date,
    constraint pklien primary key (pseudoA, pseudoB)
);

create table aimePage(
    pseudo varchar2(30) constraint fkpaime references utilisateur(pseudo),
    idpage number(3) constraint fkaimepage references page(idpage),
    constraint pkaimepage primary key (pseudo, idpage)
);

create table aimePub(
    pseudo varchar2(30) constraint fkpaimepub references utilisateur(pseudo),
    idpub number(3) constraint fkaimepub references publication(idpub),
    constraint pkaimepub primary key (pseudo, idpub)
);

create table cibles(
    pseudo varchar2(30) constraint fkpcibles references utilisateur(pseudo),
    idmessage number(3) constraint fkmessgaes references message(idmessage),
    constraint pkcibles primary key (pseudo, idmessage)
);

alter table utilisateur add constraint carobase check ( email like '%@%' );

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY' ;

insert into ville(idville, nomville, pays) values(1, 'Rio de Janeiro', 'Brésil');
insert into ville(idville, nomville, pays) values(2, 'Brasilia', 'Brésil');
insert into ville(idville, nomville, pays) values(3, 'Epinal', 'France');
insert into ville(idville, nomville, pays) values(4, 'Paris', 'France');
insert into ville(idville, nomville, pays) values(5, 'Paris', 'USA');
insert into ville(idville, nomville, pays) values(6, 'Londres', 'UK');

insert into utilisateur(pseudo, nom, prenom, email, telephone, datenaiss, sexe, idville, datecrea, datecloture)
values('Joao125', 'Da Silva', 'Joao', 'joao125@gmail.com', '12912345678', '12/01/1998', 'M', 1, '19/02/2016', null);
insert into utilisateur(pseudo, nom, prenom, email, telephone, datenaiss, sexe, idville, datecrea, datecloture)
values('Miguel42', 'Pereira', 'Miguel', 'pereira72@hotmail.com', '13943218765', '04/07/1987', 'M', 2, '07/10/2009', null);
insert into utilisateur(pseudo, nom, prenom, email, telephone, datenaiss, sexe, idville, datecrea, datecloture)
values('Helena72', 'Dos Santos', 'Helena', 'helena98@aol.com', '13942318675', '22/11/2001', 'F', 2, '01/12/2019', null);
insert into utilisateur(pseudo, nom, prenom, email, telephone, datenaiss, sexe, idville, datecrea, datecloture)
values('Kevin69', 'Dupont', 'Kevin', 'kevin69@orange.fr', '0625051231', '14/07/1998', 'M', 3, '12/01/2016', null);
insert into utilisateur(pseudo, nom, prenom, email, telephone, datenaiss, sexe, idville, datecrea, datecloture)
values('MichelDu75', 'Durand', 'Michel', 'micheldurand75@sfr.fr', '0215031271', '14/07/1975', 'M', 4, '15/09/2008', null);
insert into utilisateur(pseudo, nom, prenom, email, telephone, datenaiss, sexe, idville, datecrea, datecloture)
values('Jane1958', 'doe', 'Jane', 'janedoe1958@aol.com', '32021503', '10/03/1958', 'F', 5, '18/02/2011', null);
insert into utilisateur(pseudo, nom, prenom, email, telephone, datenaiss, sexe, idville, datecrea, datecloture)
values('Gunther78', 'hermann', 'Gunther', 'guntherhermann@gmail.com', '2837298372', '10/03/2002', 'M', null, '20/03/2020', null);
insert into utilisateur(pseudo, nom, prenom, email, telephone, datenaiss, sexe, idville, datecrea, datecloture)
values('Bob55', 'Smith', 'Bob', 'bobsmith@yahoo.com', '328936223', '10/03/1984', 'M', 6, '12/03/2010', null);
insert into utilisateur(pseudo, nom, prenom, email, telephone, datenaiss, sexe, idville, datecrea, datecloture)
values('Sylvia32', 'Lennon', 'Sylvia', 'paupaul@hotmail.com', '323262231', '07/11/1995', 'F', 6, '12/03/2015', null);


insert into page(idpage, nompage, typepage, createur)
values(1, 'Flat earth society', 'groupe', 'Jane1958');
insert into page(idpage, nompage, typepage, createur)
values(2, 'Flat earth society', 'privée', 'Helena72');
insert into page(idpage, nompage, typepage, createur)
values(3, 'Vive la choucroute', 'publique', 'MichelDu75');
insert into page(idpage, nompage, typepage, createur)
values(4, 'Happy New Year', 'publique', 'Jane1958');
insert into page(idpage, nompage, typepage, createur)
values(5, 'Ham fan', 'groupe', 'Bob55');
insert into page(idpage, nompage, typepage, createur)
values(6, 'Football fan', 'groupe', 'Gunther78');
insert into page(idpage, nompage, typepage, createur)
values(7, 'Tuning fan', 'groupe', 'Joao125');
insert into page(idpage, nompage, typepage, createur)
values(8, 'Carrot fan', 'groupe', 'Joao125');
insert into page(idpage, nompage, typepage, createur)
values(9, 'Brocoli fan', 'groupe', 'Kevin69');
insert into page(idpage, nompage, typepage, createur)
values(10, 'Tulip fan', 'groupe', 'Kevin69');


insert into publication(idpub, titrepub, datepub, textepub, idparent, pseudo, idpage)
values(1, 'Salut', '10/12/2021', 'Ca va?', null, 'Kevin69', 1);
insert into publication(idpub, titrepub, datepub, textepub, idparent, pseudo, idpage)
values(2, 'Re:Salut', '08/07/2022', 'Bienvenue', 1, 'MichelDu75', 1);
insert into publication(idpub, titrepub, datepub, textepub, idparent, pseudo, idpage)
values(3, 'Earth is flat', '01/07/2022', 'Really', null, 'Helena72', 2);
insert into publication(idpub, titrepub, datepub, textepub, idparent, pseudo, idpage)
values(4, 'Re:Salut', '09/07/2022', 'Merci', 2, 'Kevin69', 1);
insert into publication(idpub, titrepub, datepub, textepub, idparent, pseudo, idpage)
values(5, 'Re:Salut', '11/07/2022', 'De rien', 4, 'MichelDu75', 1);
insert into publication(idpub, titrepub, datepub, textepub, idparent, pseudo, idpage)
values(6, 'Hello world', '06/10/2021', 'How are you today?', null, 'Helena72', 2);
insert into publication(idpub, titrepub, datepub, textepub, idparent, pseudo, idpage)
values(7, 'Re:Hello world', '07/10/2021', 'Fine, and you?', 6, 'Miguel42', 2);
insert into publication(idpub, titrepub, datepub, textepub, idparent, pseudo, idpage)
values(8, 'Et Trump?', '10/12/2022', 'Oui Trump, vous en pensez quoi?', null, 'Kevin69', 4);
insert into publication(idpub, titrepub, datepub, textepub, idparent, pseudo, idpage)
values(9, 'Re:Et Trump?', '04/01/2023', 'Bof Trump', 8, 'MichelDu75', 4);



insert into message(idmessage, textemessage, datemessage, auteur)
values(1, 'Comment ça va', '21/12/2022', 'Kevin69');
insert into message(idmessage, textemessage, datemessage, auteur)
values(2, 'Hello', '01/04/2018', 'Miguel42');
insert into message(idmessage, textemessage, datemessage, auteur)
values(3, 'How are you today', '21/12/2022', 'Kevin69');

insert into aimepub(pseudo, idpub)
values ('MichelDu75', 1);
insert into aimepub(pseudo, idpub)
values ('Miguel42', 1);
insert into aimepub(pseudo, idpub)
values ('Jane1958', 1);
insert into aimepub(pseudo, idpub)
values ('Kevin69', 1);
insert into aimepub(pseudo, idpub)
values ('MichelDu75', 2);
insert into aimepub(pseudo, idpub)
values ('Miguel42', 2);
insert into aimepub(pseudo, idpub)
values ('MichelDu75', 4);
insert into aimepub(pseudo, idpub)
values ('Miguel42', 4);
insert into aimepub(pseudo, idpub)
values ('MichelDu75', 5);
insert into aimepub(pseudo, idpub)
values ('Miguel42', 5);
insert into aimepub(pseudo, idpub)
values ('Jane1958', 5);
insert into aimepub(pseudo, idpub)
values ('MichelDu75', 3);
insert into aimepub(pseudo, idpub)
values ('Miguel42', 3);
insert into aimepub(pseudo, idpub)
values ('Jane1958', 3);
insert into aimepub(pseudo, idpub)
values ('Bob55', 3);
insert into aimepub(pseudo, idpub)
values ('Jane1958', 9);
insert into aimepub(pseudo, idpub)
values ('Kevin69', 9);
insert into aimepub(pseudo, idpub)
values ('MichelDu75', 8);
insert into aimepub(pseudo, idpub)
values ('Miguel42', 8);


insert into aimepage(pseudo, idpage)
values('Kevin69', 1);
insert into aimepage(pseudo, idpage)
values('MichelDu75', 1);
insert into aimepage(pseudo, idpage)
values('MichelDu75', 2);
insert into aimepage(pseudo, idpage)
values('Kevin69', 2);
insert into aimepage(pseudo, idpage)
values('Gunther78', 4);

insert into estMembre(pseudo, idpage)
values('Jane1958', 1);
insert into estMembre(pseudo, idpage)
values('Miguel42', 1);
insert into estMembre(pseudo, idpage)
values('Kevin69', 1);
insert into estMembre(pseudo, idpage)
values('Kevin69', 6);
insert into estMembre(pseudo, idpage)
values('Kevin69', 7);
insert into estMembre(pseudo, idpage)
values('Kevin69', 8);
insert into estMembre(pseudo, idpage)
values('MichelDu75', 1);
insert into estMembre(pseudo, idpage)
values('MichelDu75', 5);
insert into estMembre(pseudo, idpage)
values('MichelDu75', 6);
insert into estMembre(pseudo, idpage)
values('Bob55', 5);
insert into estMembre(pseudo, idpage)
values('Bob55', 6);
insert into estMembre(pseudo, idpage)
values('Bob55', 7);
insert into estMembre(pseudo, idpage)
values('Helena72', 7);
insert into estMembre(pseudo, idpage)
values('Joao125', 5);
insert into estMembre(pseudo, idpage)
values('Joao125', 9);
insert into estMembre(pseudo, idpage)
values('Joao125', 10);
insert into estMembre(pseudo, idpage)
values('Jane1958', 8);


insert into enLien(pseudoA, pseudoB, typeLien, datelien)
values ('Kevin69', 'Helena72', 'ami', '21/12/2022');
insert into enLien(pseudoA, pseudoB, typeLien, datelien)
values ('MichelDu75', 'Kevin69', 'ami', '12/05/2020');
insert into enLien(pseudoA, pseudoB, typeLien, datelien)
values ('Kevin69', 'Miguel42', 'ami', '01/04/2018');
insert into enLien(pseudoA, pseudoB, typeLien, datelien)
values ('Miguel42', 'Helena72', 'ami', '12/03/2020');
insert into enLien(pseudoA, pseudoB, typeLien, datelien)
values ('Bob55', 'Helena72', 'ami', '19/04/2021');
insert into enLien(pseudoA, pseudoB, typeLien, datelien)
values ('Miguel42', 'Bob55', 'ami', '10/01/2022');
insert into enLien(pseudoA, pseudoB, typeLien, datelien)
values ('Sylvia32', 'Joao125', 'ami', '10/12/2020');
insert into enLien(pseudoA, pseudoB, typeLien, datelien)
values ('Gunther78', 'Helena72', 'ami', '11/02/2022');
insert into enLien(pseudoA, pseudoB, typeLien, datelien)
values ('MichelDu75', 'Gunther78', 'ami', '02/09/2020');
insert into enLien(pseudoA, pseudoB, typeLien, datelien)
values ('Gunther78', 'Miguel42', 'ami', '13/10/2018');



insert into cibles (pseudo, idmessage)
values('Helena72', 1);
insert into cibles (pseudo, idmessage)
values('Kevin69', 2);
insert into cibles (pseudo, idmessage)
values('MichelDu75', 3);

commit;
