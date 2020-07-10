-- Ivan Oana - Mariana, 241
-- Proiect baze de date - Urmarirea materialelor dintr-un magazin de materiale textile

-- Creare tabele si constrangeri
create table modalitati_de_plata_oiv (
  id_plata varchar(15),
  nr_cont_bancar number(4) not null,
  nume_detinator_cont varchar2(10),
  primary key (id_plata)
);

alter table modalitati_de_plata_oiv
add constraint nr_cont_plata_unic unique(nr_cont_bancar);

alter table modalitati_de_plata_oiv
modify(nr_cont_bancar number(6));

create table puncte_de_preluare_oiv (
  id_adresa_preluare varchar(15),
  oras varchar2(30) not null,
  strada varchar2(30),
  numar number(4),
  primary key (id_adresa_preluare)
);

create table comenzi_oiv (
  id_comanda varchar(15),
  id_plata varchar(15),
  id_adresa_livrare varchar(15),
  data_comanda date default sysdate,
  suma number(6),
  primary key (id_comanda),
  foreign key(id_plata) references modalitati_de_plata_oiv(id_plata),
  foreign key(id_adresa_livrare) references puncte_de_preluare_oiv(id_adresa_preluare)
);

create table materiale_oiv (
  id_material varchar(15),
  denumire varchar(20) not null,
  pret_metru_patrat number(4) not null,
  primary key (id_material)
);

create table materiale_comandate_oiv (
  id_comanda varchar(15),
  id_material varchar(15),
  cantitate number(4) not null,
  primary key (id_comanda, id_material),
  foreign key(id_comanda) references comenzi_oiv(id_comanda),
  foreign key(id_material) references materiale_oiv(id_material)
);

create table furnizori_oiv (
  id_furnizor varchar(15),
  denumire varchar2(20),
  primary key (id_furnizor)
);

create table client_oiv (
  id_client varchar(15),
  denumire varchar2(20),
  cui number(6), -- cod unic de inregistrare(clientii sunt persoane juridice)
  primary key (id_client)
);
alter table client_oiv
add constraint cui_unic_client unique(cui);

create table lista_comenzi_oiv(
  id_comanda varchar(15),
  id_client varchar(15),
  data_livrare date,
  este_platita number(1) default 0,
  primary key (id_comanda, id_client),
  foreign key(id_comanda) references comenzi_oiv(id_comanda),
  foreign key(id_client) references client_oiv(id_client)
);

create table stoc_materiale_oiv (
  id_material varchar(15),
  id_furnizor varchar(15),
  cantitate number(4) not null,
  data_achizitie date default sysdate,
  pret_achizitie number(6) not null,
  primary key (id_material, id_furnizor, data_achizitie),
  foreign key(id_material) references materiale_oiv(id_material),
  foreign key(id_furnizor) references furnizori_oiv(id_furnizor)
);

-- Afisare detalii tabele
select *
from user_tables
where lower(table_name) like '%oiv';

-- Afisare constrangeri
select constraint_name, constraint_type, table_name
from user_constraints
where lower(table_name) like '%oiv'; 

--------------------------------------------------------------------------------
-- Inserare date in tabele

-- Creare secvente pentru a genera cheile primare
create sequence s_id_plata;
create sequence s_id_adresa_preluare;
create sequence s_id_client;
create sequence s_id_furnizor;
create sequence s_id_material;
create sequence s_id_comanda;

-- inserare valori in tabelul modalitati de plata
insert into modalitati_de_plata_oiv (id_plata, nr_cont_bancar, nume_detinator_cont)
values ('plata_' || s_id_plata.nextval, 123456, 'Popescu');
insert into modalitati_de_plata_oiv (id_plata, nr_cont_bancar, nume_detinator_cont)
values ('plata_' || s_id_plata.nextval, 123457, 'Ionescu');
insert into modalitati_de_plata_oiv (id_plata, nr_cont_bancar, nume_detinator_cont)
values ('plata_' || s_id_plata.nextval, 123458, 'Matei');
insert into modalitati_de_plata_oiv (id_plata, nr_cont_bancar, nume_detinator_cont)
values ('plata_' || s_id_plata.nextval, 123459, 'Dramescu');

-- nr_cont_bancar trebuie sa fie unic in tabel, prin urmare urmatoarele randuri vor returna o eroare
--insert into modalitati_de_plata_oiv (id_plata, nr_cont_bancar, nume_detinator_cont)
--values ('plata_' || s_id_plata.nextval, 123459, 'Vasilescu');

insert into modalitati_de_plata_oiv (id_plata, nr_cont_bancar, nume_detinator_cont)
values ('plata_' || s_id_plata.nextval, 123490, 'Vasilescu');

savepoint adaugat_plati;

-- inserare valori in tabelul puncte de prelucrare
insert into puncte_de_preluare_oiv (id_adresa_preluare, oras, strada, numar)
values ('pct_' || s_id_adresa_preluare.nextval, 'Bucuresti', 'Iuliu Maniu', 46);
insert into puncte_de_preluare_oiv (id_adresa_preluare, oras, strada, numar)
values ('pct_' || s_id_adresa_preluare.nextval, 'Bucuresti', 'Mihai Eminescu', 3);
insert into puncte_de_preluare_oiv (id_adresa_preluare, oras, strada, numar)
values ('pct_' || s_id_adresa_preluare.nextval, 'Cluj', 'Ion Creanga', 16);
insert into puncte_de_preluare_oiv (id_adresa_preluare, oras, strada, numar)
values ('pct_' || s_id_adresa_preluare.nextval, 'Craiova', 'Tudor Vladimirescu', 4);
insert into puncte_de_preluare_oiv (id_adresa_preluare, oras, strada)
values ('pct_' || s_id_adresa_preluare.nextval, 'Titu', 'Unirea');

savepoint adaugat_puncte_preluare;

-- inserare valori in tabelul client
insert into client_oiv (id_client, denumire, cui)
values ('client_'|| s_id_client.nextval, 'Croitoria ABC', 654321);
insert into client_oiv (id_client, denumire, cui)
values ('client_'|| s_id_client.nextval, 'Croitoria XYZ', 754321);
insert into client_oiv (id_client, denumire, cui)
values ('client_'|| s_id_client.nextval, 'Atelier rochii', 854321);
insert into client_oiv (id_client, denumire, cui)
values ('client_'|| s_id_client.nextval, 'Croitoria Dalia', 954321);
insert into client_oiv (id_client, denumire, cui)
values ('client_'|| s_id_client.nextval, 'Atelier Ionecu', 958321);
insert into client_oiv (id_client, denumire, cui)
values ('client_'|| s_id_client.nextval, 'Croitoria Maria', 958381);
insert into client_oiv (id_client, denumire, cui)
values ('client_'|| s_id_client.nextval, 'Croitorie - costume', 958329);
savepoint adaugat_clienti;

-- inserare valori in tabelul furnizori
insert into furnizori_oiv (id_furnizor, denumire)
values ('fz_'|| s_id_furnizor.nextval, 'Gigel-Stofa');
insert into furnizori_oiv (id_furnizor, denumire)
values ('fz_'|| s_id_furnizor.nextval, 'Dantela si altele');
insert into furnizori_oiv (id_furnizor, denumire)
values ('fz_'|| s_id_furnizor.nextval, 'Materiale textile');
insert into furnizori_oiv (id_furnizor, denumire)
values ('fz_'|| s_id_furnizor.nextval, 'Materiale calitative');
insert into furnizori_oiv (id_furnizor, denumire)
values ('fz_'|| s_id_furnizor.nextval, 'LaTextile');
savepoint adaugat_furnizori;

-- inserare valori in tabelul materiale
insert into materiale_oiv (id_material, denumire, pret_metru_patrat)
values ('mat_'|| s_id_material.nextval, 'Stofa', 20);
insert into materiale_oiv (id_material, denumire, pret_metru_patrat)
values ('mat_'|| s_id_material.nextval, 'Dantela', 60);
insert into materiale_oiv (id_material, denumire, pret_metru_patrat)
values ('mat_'|| s_id_material.nextval, 'Brocard', 45);
insert into materiale_oiv (id_material, denumire, pret_metru_patrat)
values ('mat_'|| s_id_material.nextval, 'Tafta', 50);
insert into materiale_oiv (id_material, denumire, pret_metru_patrat)
values ('mat_'|| s_id_material.nextval, 'Material draperie', 20);
insert into materiale_oiv (id_material, denumire, pret_metru_patrat)
values ('mat_'|| s_id_material.nextval, 'Matase', 57);
insert into materiale_oiv (id_material, denumire, pret_metru_patrat)
values ('mat_'|| s_id_material.nextval, 'Material bumbac', 25);
insert into materiale_oiv (id_material, denumire, pret_metru_patrat)
values ('mat_'|| s_id_material.nextval, 'Tifon', 15);
savepoint adaugat_materiale;

-- inserare valori in tabelul stoc_materiale
insert into stoc_materiale_oiv (id_material, id_furnizor, cantitate, data_achizitie, pret_achizitie)
values ('mat_1', 'fz_1', 100, to_date('20-05-2020', 'dd-mm-yyyy'), 15);
insert into stoc_materiale_oiv (id_material, id_furnizor, cantitate, data_achizitie, pret_achizitie)
values ('mat_1', 'fz_3', 90, to_date('12-05-2020', 'dd-mm-yyyy'), 17);
insert into stoc_materiale_oiv (id_material, id_furnizor, cantitate, data_achizitie, pret_achizitie)
values ('mat_2', 'fz_2', 60, to_date('20-05-2020', 'dd-mm-yyyy'), 50);
insert into stoc_materiale_oiv (id_material, id_furnizor, cantitate, data_achizitie, pret_achizitie)
values ('mat_6', 'fz_2', 100, to_date('20-05-2020', 'dd-mm-yyyy'), 39);
insert into stoc_materiale_oiv (id_material, id_furnizor, cantitate, data_achizitie, pret_achizitie)
values ('mat_7', 'fz_5', 60, to_date('29-05-2020', 'dd-mm-yyyy'), 17);
insert into stoc_materiale_oiv (id_material, id_furnizor, cantitate, data_achizitie, pret_achizitie)
values ('mat_8', 'fz_5', 70, to_date('29-05-2020', 'dd-mm-yyyy'), 10);
insert into stoc_materiale_oiv (id_material, id_furnizor, cantitate, data_achizitie, pret_achizitie)
values ('mat_3', 'fz_4', 20, to_date('01-06-2020', 'dd-mm-yyyy'), 35);
insert into stoc_materiale_oiv (id_material, id_furnizor, cantitate, data_achizitie, pret_achizitie)
values ('mat_4', 'fz_5', 20, to_date('18-06-2020', 'dd-mm-yyyy'), 15);
insert into stoc_materiale_oiv (id_material, id_furnizor, cantitate, data_achizitie, pret_achizitie)
values ('mat_1', 'fz_1', 20, to_date('20-06-2020', 'dd-mm-yyyy'), 30);
insert into stoc_materiale_oiv (id_material, id_furnizor, cantitate, data_achizitie, pret_achizitie)
values ('mat_7', 'fz_3', 20, to_date('01-06-2020', 'dd-mm-yyyy'), 32);
insert into stoc_materiale_oiv (id_material, id_furnizor, cantitate, pret_achizitie)
values ('mat_2', 'fz_3', 20, 55);
insert into stoc_materiale_oiv (id_material, id_furnizor, cantitate, pret_achizitie)
values ('mat_6', 'fz_2', 10, 49);
savepoint adaugat_stoc;

-- inserare valori in tabelul comenzi_oiv
insert into comenzi_oiv (id_comanda, id_plata, id_adresa_livrare, data_comanda)
values ('comanda_'|| s_id_comanda.nextval, 'plata_1', 'pct_1', to_date('03-06-2020', 'dd-mm-yyyy'));
insert into comenzi_oiv (id_comanda, id_plata, id_adresa_livrare, data_comanda)
values ('comanda_'|| s_id_comanda.nextval, 'plata_5', 'pct_4', to_date('12-06-2020', 'dd-mm-yyyy'));
insert into comenzi_oiv (id_comanda, id_plata, id_adresa_livrare, data_comanda)
values ('comanda_'|| s_id_comanda.nextval, 'plata_2', 'pct_3', to_date('17-06-2020', 'dd-mm-yyyy'));
insert into comenzi_oiv (id_comanda, id_plata, id_adresa_livrare, data_comanda)
values ('comanda_'|| s_id_comanda.nextval, 'plata_4', 'pct_1', to_date('19-06-2020', 'dd-mm-yyyy'));
insert into comenzi_oiv (id_comanda, id_plata, id_adresa_livrare) -- data_comenzii va lua valoarea default
values ('comanda_'|| s_id_comanda.nextval, 'plata_3', 'pct_2');  
insert into comenzi_oiv (id_comanda, id_plata, id_adresa_livrare) -- data_comenzii va lua valoarea default
values ('comanda_'|| s_id_comanda.nextval, 'plata_1', 'pct_2');  
savepoint adaugat_comenzi;

-- inserare in tabelul lista_comenzi
insert into lista_comenzi_oiv (id_comanda, id_client)
values ('comanda_1', 'client_3');
insert into lista_comenzi_oiv (id_comanda, id_client)
values ('comanda_2', 'client_7');
insert into lista_comenzi_oiv (id_comanda, id_client)
values ('comanda_3', 'client_5');
insert into lista_comenzi_oiv (id_comanda, id_client)
values ('comanda_4', 'client_3');
insert into lista_comenzi_oiv (id_comanda, id_client)
values ('comanda_5', 'client_4');
insert into lista_comenzi_oiv (id_comanda, id_client)
values ('comanda_6', 'client_4');
savepoint adaugat_val_lista_comenzi;

-- inserare in tabelul materiale_comandate
insert into materiale_comandate_oiv (id_comanda, id_material, cantitate)
values ('comanda_1', 'mat_2', 12);
insert into materiale_comandate_oiv (id_comanda, id_material, cantitate)
values ('comanda_1', 'mat_3', 20);
insert into materiale_comandate_oiv (id_comanda, id_material, cantitate)
values ('comanda_2', 'mat_1', 30);
insert into materiale_comandate_oiv (id_comanda, id_material, cantitate)
values ('comanda_2', 'mat_7', 24);
insert into materiale_comandate_oiv (id_comanda, id_material, cantitate)
values ('comanda_2', 'mat_5', 10);
insert into materiale_comandate_oiv (id_comanda, id_material, cantitate)
values ('comanda_3', 'mat_5', 25);
insert into materiale_comandate_oiv (id_comanda, id_material, cantitate)
values ('comanda_4', 'mat_4', 22);
insert into materiale_comandate_oiv (id_comanda, id_material, cantitate)
values ('comanda_5', 'mat_2', 40);
insert into materiale_comandate_oiv (id_comanda, id_material, cantitate)
values ('comanda_5', 'mat_6', 20);
insert into materiale_comandate_oiv (id_comanda, id_material, cantitate)
values ('comanda_6', 'mat_7', 10);

-- actualizare tabel lista_comenzi_oiv cu comenzile care au fost platite
update lista_comenzi_oiv
set este_platita = 1
where id_comanda in ('comanda_1', 'comanda_3', 'comanda_4'); 

-- setare data_livrarii ca data_comanda + 15 zile pentru toate comenzile
update lista_comenzi_oiv l
set data_livrare = (select data_comanda from comenzi_oiv where id_comanda = l.id_comanda) + 15;

commit;

-- Afisare continut tabele
--select * from modalitati_de_plata_oiv;
--select * from puncte_de_preluare_oiv;
--select * from client_oiv;
--select * from furnizori_oiv;
--select * from materiale_oiv;
--select * from stoc_materiale_oiv;
--select * from materiale_comandate_oiv;
--select * from lista_comenzi_oiv;
--select * from comenzi_oiv;

-- Stergere secvente
--drop sequence s_id_plata;
--drop sequence s_id_adresa_preluare;
--drop sequence s_id_client;
--drop sequence s_id_furnizor;
--drop sequence s_id_material;
--drop sequence s_id_comanda;

-- Stergere tabele
--drop table modalitati_de_plata_oiv;
--drop table puncte_de_preluare_oiv;
--drop table comenzi_oiv;
--drop table materiale_oiv;
--drop table materiale_comandate_oiv;
--drop table furnizori_oiv;
--drop table client_oiv;
--drop table lista_comenzi_oiv;
--drop table stoc_materiale_oiv;