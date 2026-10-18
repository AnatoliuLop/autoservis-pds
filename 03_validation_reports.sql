-- 1. Pocty zaznamov v kazdej tabulke (ocakavane: 5/5/3/5/5/5/5/4/3/3/2)
SELECT 'ZAKAZNIK' tabulka, COUNT(*) pocet FROM zakaznik
UNION ALL SELECT 'VOZIDLO', COUNT(*) FROM vozidlo
UNION ALL SELECT 'ZAMESTNANEC', COUNT(*) FROM zamestnanec
UNION ALL SELECT 'SERVISNA_ZAKAZKA', COUNT(*) FROM servisna_zakazka
UNION ALL SELECT 'SERVISNY_UKON', COUNT(*) FROM servisny_ukon
UNION ALL SELECT 'VYKONANY_UKON', COUNT(*) FROM vykonany_ukon
UNION ALL SELECT 'NAHRADNY_DIEL', COUNT(*) FROM nahradny_diel
UNION ALL SELECT 'POUZITY_DIEL', COUNT(*) FROM pouzity_diel
UNION ALL SELECT 'FAKTURA', COUNT(*) FROM faktura
UNION ALL SELECT 'PLATBA', COUNT(*) FROM platba
UNION ALL SELECT 'PRILOHA', COUNT(*) FROM priloha;

-- 2. Zakazky s vlastnikom vozidla (bez dvojiteho pocitania M:N poloziek)
SELECT z.id_zakazka, za.meno || ' ' || za.priezvisko zakaznik,
       v.znacka || ' ' || v.model vozidlo, z.stav, z.datum_prijatia
FROM servisna_zakazka z
JOIN vozidlo v ON v.id_vozidlo = z.id_vozidlo
JOIN zakaznik za ON za.id_zakaznik = v.id_zakaznik
ORDER BY z.id_zakazka;

-- 3. Cena oprav vypocitana z poloziek (agregacne poddotazy zabrania nasobeniu riadkov)
SELECT z.id_zakazka, NVL(u.suma_ukony,0) suma_ukony,
       NVL(d.suma_diely,0) suma_diely,
       NVL(u.suma_ukony,0)+NVL(d.suma_diely,0) spolu
FROM servisna_zakazka z
LEFT JOIN (SELECT id_zakazka,SUM(mnozstvo*jednotkova_cena) suma_ukony
           FROM vykonany_ukon GROUP BY id_zakazka) u ON u.id_zakazka=z.id_zakazka
LEFT JOIN (SELECT id_zakazka,SUM(mnozstvo*jednotkova_cena) suma_diely
           FROM pouzity_diel GROUP BY id_zakazka) d ON d.id_zakazka=z.id_zakazka
ORDER BY z.id_zakazka;

-- 4. Zaplatene skutocne tržby (ocakavane 269 EUR)
SELECT NVL(SUM(suma),0) skutocne_prijmy FROM platba;

-- 5. Fakturovane sumy podla mesiaca (nie to iste ako zaplatene prijmy)
SELECT TRUNC(datum_vystavenia,'MM') mesiac, SUM(celkova_suma) fakturovana_suma
FROM faktura GROUP BY TRUNC(datum_vystavenia,'MM') ORDER BY mesiac;

-- 6. Priemerne trvanie dokoncenych oprav (v dnoch)
SELECT ROUND(AVG(datum_dokoncenia-datum_prijatia),2) priemer_dni
FROM servisna_zakazka WHERE datum_dokoncenia IS NOT NULL;

-- 7. Kontrola zhody vystavenych faktur a ich kalkulacie (ocakavane 0 riadkov)
WITH ceny AS (
 SELECT z.id_zakazka, NVL(u.cena,0)+NVL(d.cena,0) suma
 FROM servisna_zakazka z
 LEFT JOIN (SELECT id_zakazka,SUM(mnozstvo*jednotkova_cena) cena FROM vykonany_ukon GROUP BY id_zakazka) u
 ON z.id_zakazka=u.id_zakazka
 LEFT JOIN (SELECT id_zakazka,SUM(mnozstvo*jednotkova_cena) cena FROM pouzity_diel GROUP BY id_zakazka) d
 ON z.id_zakazka=d.id_zakazka
)
SELECT f.cislo_faktury,f.celkova_suma,c.suma vypocitana_suma
FROM faktura f JOIN ceny c ON c.id_zakazka=f.id_zakazka
WHERE f.celkova_suma <> c.suma;

-- 8. Negativny test - SPUSTAJTE SAMOSTATNE, ma skoncit ORA-02290:
-- INSERT INTO servisna_zakazka (id_vozidlo,datum_prijatia,datum_dokoncenia,popis_problemu,stav)
-- VALUES (1,DATE '2026-10-10',DATE '2026-10-09','Neplatny datum','DOKONCENA');
