-- Ivan Oana - Mariana, 241
-- Proiect baze de date - Urmarirea materialelor dintr-un magazin de materiale textile

-- Interogari

-- 1: Sa se afiseze denumirea si totalul de cantitate comandata pentru fiecare material
--    pentru materialele a caror total este mai mare decat 25, in ordine descrescatoare 
--    a cantitatilor.
select m.denumire denumire_material, sum(m_com.cantitate) total_cantitate_comandata
from materiale_oiv m left join materiale_comandate_oiv m_com using (id_material)
group by m.denumire
having sum(m_com.cantitate) > 25
order by sum(m_com.cantitate) desc;
-- Concepte folosite: sum, left join, group by, order by

-- 2: Sa se afiseze denumirea ?i pretul tuturor materialelor comandate in perioada 1.06.2020 - 15.06.2020.
select m.denumire "Denumire material", m.pret_metru_patrat "Pret", com.data_comanda "Data comanda"
from materiale_oiv m left join materiale_comandate_oiv m_com using (id_material)
     join comenzi_oiv com on (com.id_comanda = m_com.id_comanda)
where com.data_comanda between to_date('01.06.2020', 'dd-mm-yyyy') and to_date('15.06.2020', 'dd-mm-yyyy');
-- Concepte folosite: left join, to_date, comparare date calendaristice

-- 3: Sa se afiseze date despre toti clientii care au comandat stofa sau dantela, ordonati alfabetic dupa denumire.
select *
from client_oiv
where id_client in (select id_client
                    from lista_comenzi_oiv
                    where id_comanda in (select id_comanda
                                         from (select id_comanda
                                               from materiale_comandate_oiv
                                               where id_material in (select id_material
                                                                    from materiale_oiv
                                                                    where lower(denumire) like '%stofa' or lower(denumire) like '%dantela'
                                                                    )
                                              )
                                         )
                    )
order by denumire;
-- Concepte folosite: subcereri in where, lower(sir_caractere)

-- 4: Sa se afiseze date despre toate materialele care au un pret mai mare de 20 de lei, 
--    mai putin cele care au fost comandate intr-o cantitate mai mica decat media cantitatilor
--    comandate din fiecare material(rotunjit prin adaos).
select * 
from materiale_oiv
where pret_metru_patrat > 20
minus
select * 
from materiale_oiv
where id_material in (select id_material
                      from materiale_comandate_oiv 
                      having avg(cantitate) > (select round(avg(cantitate), 0) 
                                               from materiale_comandate_oiv) 
                      group by id_material);
--  Concepte folosite: operatii pe multimi(minus), subcerere in having, group by, avg                    

-- 5: Sa se afiseze detalii despre metodele de plata inregistrate, precum si de cate
--    ori au fost numite ca modalitatea de plata pentru o comanda
select mp.*, (select count(id_plata) from comenzi_oiv where id_plata = mp.id_plata) "Nr folosiri"
from modalitati_de_plata_oiv mp;
-- Concepte folosite: subcerere in select, count

-- 6: Sa se afiseze detalii despre fiecare furnizor de la care magazinul s-a aprovizionat in luna mai a anului 2020
select *
from furnizori_oiv join (select distinct id_furnizor, data_achizitie
                         from stoc_materiale_oiv
                         where to_char(data_achizitie, 'mm-yyyy') like '05-2020')
     using (id_furnizor)
order by id_furnizor;
-- Concepte folosite: subcerere in from, join, to_char, order by

-- 7: Sa se afiseze cea mai mica cantitate comandata in luna mai 2020 si cea mai 
--    mare cantitate comandata in luna iunie 2020, altfel valoarea 0.  
select decode(to_char(data_achizitie, 'mm-yyyy'), 
              '05-2020', 'Cantitatea minima comandata pentru luna mai 2020', 
              '06-2020', 'Cantitatea maxima comandata pentru luna iunie 2020', 
              '-') "Luna", 
       decode(to_char(data_achizitie, 'mm-yyyy'), 
              '05-2020', min(cantitate), 
              '06-2020', max(cantitate),
              0) "Min/max cantitate"
from stoc_materiale_oiv
group by to_char(data_achizitie, 'mm-yyyy');
-- Concepte folosite: decode, min, max, to_char

-- 8: Sa se afiseze strada si numarul pentru punctele de preluare din Bucuresti
--    si adresa completa pentru punctele de preluare din alte orase.
select case upper(oras)
       when 'BUCURESTI' then 'strada ' || strada || ' la numarul ' || numar
       else 'Orasul: ' || oras || ' => strada ' || strada 
             || decode(nvl(numar, -1), -1, '(nu se cunoaste numarul strazii)', ' la numarul ' || numar)
       end "Adrese completa preluare"
from puncte_de_preluare_oiv;
-- Concepte folosite: case, decode

-- 9: Sa se afiseze data la care va fi trecut o luna de la prima comanda inregistrata 
--    ca neplatita, precum si numele clientului care a facut comanda respectiva.
select *
from 
    (select add_months(data_comanda, 1) data, denumire client
    from comenzi_oiv join lista_comenzi_oiv using (id_comanda)
         join client_oiv using (id_client)
    where este_platita = 0
    order by data)
where rownum < 2;
-- Concepte folosite: add_months, join, order by

-- 10: Sa se afiseze numele clientilor care au comenzi ce vor fi livrate la adresa cu id-ul 'pct_1'
select id_client
from lista_comenzi_oiv
where id_comanda in 
      (select id_comanda
       from comenzi_oiv
       where lower(id_adresa_livrare) like 'pct_1')
group by id_client
having count(id_comanda) = (select count(*)
                            from comenzi_oiv
                            where lower(id_adresa_livrare) like 'pct_1');
-- Concepte folosite: division

-- 11: Sa se afiseze detalii despre materialele care au fost cumparate de la furnizori
--     intr-o cantitate mai mare decat o valoare introdusa de la tastatura
select *
from materiale_oiv
where id_material in (select id_material
                      from stoc_materiale_oiv
                      where cantitate = &cant_material);
--Concepte folosite: cerere in where 

-- 12: Sa se afiseze toti furnizorii care au asigurat stocul de materiale 
--     cu dantela cu mai mult de 10 metri sau cu brocard cu mai mult de 15 metri
select *
from 
    (with id_dantela as (select id_material from materiale_oiv where lower(denumire) = 'dantela'),
         id_brocard as (select id_material from materiale_oiv where lower(denumire) = 'brocard')
    select id_furnizor
    from stoc_materiale_oiv
    where id_material in (select * from id_dantela) and cantitate > 10
    union
    select id_furnizor
    from stoc_materiale_oiv
    where id_material in (select * from id_brocard) and cantitate > 15)

    join furnizori_oiv using (id_furnizor);
--Concepte folosite: union, with

-- 13: Sa se afiseze detalii complete despre primele 3 comenzi cu cantitatile comandate cele mai mari.
select *
from (select distinct mc.id_comanda, sum_cant.cantitate "Total cantitate comandata", client.denumire Client, com.data_comanda, 
             lc.data_livrare, com.id_adresa_livrare adresa,
             decode(lc.este_platita, 0, 'plata in asteptare', 1, 'este platita') plata 
             
      from materiale_comandate_oiv mc join lista_comenzi_oiv lc on (mc.id_comanda = lc.id_comanda)
           join comenzi_oiv com on (com.id_comanda = lc.id_comanda)
           join materiale_oiv m on (m.id_material = mc.id_material)
           join client_oiv client on (client.id_client = lc.id_client)
           join (select sum(cantitate) cantitate, id_comanda 
                 from materiale_comandate_oiv 
                 group by id_comanda) sum_cant on (sum_cant.id_comanda = lc.id_comanda)
      order by sum_cant.cantitate desc
     )
where rownum < 4;
--Concepte folosite: subcerere in form, rownum, decode, join

-- 14: Sa se afisieze denumirea materialului si cererea pentru el, respectiv cantitatea aflata pe stoc
select denumire, cantitate, tip
from 
    (select id_material, sum(cantitate) cantitate, 'stoc' tip
     from stoc_materiale_oiv 
     group by id_material
    union all
     select id_material, sum(cantitate) cantitate, 'comandat' tip
     from materiale_comandate_oiv
     group by id_material)
    
    join materiale_oiv using (id_material)
order by id_material;
-- Concepte folosite: union all, join, order by, group by

-- 15: Afi?area cantit??ii de aprovizionat din fiecare material (unde este cazul) pentru a onora toate comenzile.
with stoc_pe_material as (select id_material, sum(cantitate) cantitate_stoc, 'stoc' tip
                          from stoc_materiale_oiv 
                          group by id_material),
     cerere_pe_material as (select id_material, sum(cantitate) cantitate_ceruta, 'comandat' tip
                            from materiale_comandate_oiv
                            group by id_material)
select denumire "Denumire", cantitate_ceruta - cantitate_stoc "Metri patrati de achizitionat"
from stoc_pe_material join cerere_pe_material using (id_material)
     join materiale_oiv using (id_material)
where cantitate_stoc - cantitate_ceruta < 0;
-- Concepte folosite: join, with, group by