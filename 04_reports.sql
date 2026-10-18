-- AUTOSERVIS / CLEN 1 / CHECKPOINT 5T
-- Styri samostatne SQL reporty: c. 1, 2, 5, 9
-- Datovy model: 01_schema.sql; testovacie udaje: 02_demo_data.sql
-- Spustenie v Oracle SQL Developer: F5 (Run Script).
-- Tento subor obsahuje len SELECT a PROMPT; nic nemeni v databaze.
--
-- DOHODA O METRIKE:
-- 'Trzby' v reportoch 1 a 2 = skutocne prijate platby v tabulke PLATBA.
-- Vystavene faktury (FAKTURA) su odlisna financna metrika.

PROMPT ============================================================
PROMPT 1. CELKOVE TRZBY AUTOSERVISU (SUM, COUNT)
PROMPT ============================================================
-- OCAKAVANE S DEMO DATAMI: CELKOVE_TRZBY_EUR = 269, POCET_PLATIEB = 3
SELECT
    NVL(SUM(p.suma), 0) AS celkove_trzby_eur,
    COUNT(p.id_platba) AS pocet_platieb
FROM platba p;

PROMPT ============================================================
PROMPT 2. MESACNE TRZBY AUTOSERVISU (GROUP BY, TRUNC)
PROMPT ============================================================
-- OCAKAVANE S DEMO DATAMI:
-- 2026-09-01: 40 EUR / 1 platba
-- 2026-10-01: 229 EUR / 2 platby
SELECT
    TRUNC(p.datum_platby, 'MM') AS mesiac,
    COUNT(*) AS pocet_platieb,
    SUM(p.suma) AS trzby_eur
FROM platba p
GROUP BY TRUNC(p.datum_platby, 'MM')
ORDER BY mesiac;

PROMPT ============================================================
PROMPT 5. PRIEMERNA DLZKA OPRAVY VOZIDLA (AVG, DATUMY)
PROMPT ============================================================
-- Pocitame len zakazky s vyplnenym datumom dokoncenia.
-- Rozdiel dvoch DATE v Oracle sa vyjadruje v dnoch.
-- OCAKAVANE S DEMO DATAMI: 3 dokoncenia, priemer 1 den
SELECT
    COUNT(*) AS pocet_dokoncenych_oprav,
    ROUND(AVG(z.datum_dokoncenia - z.datum_prijatia), 2)
        AS priemerna_dlzka_dni
FROM servisna_zakazka z
WHERE z.datum_dokoncenia IS NOT NULL;

PROMPT ============================================================
PROMPT 9. POCET OPRAV PODLA ZNACKY A MODELU (JOIN, GROUP BY, COUNT)
PROMPT ============================================================
-- LEFT JOIN zahrna aj modely vozidiel bez akejkolvek zakazky (pocet = 0).
-- OCAKAVANE S DEMO DATAMI: 5 modelov, kazdy s 1 opravou
SELECT
    v.znacka,
    v.model,
    COUNT(z.id_zakazka) AS pocet_oprav
FROM vozidlo v
LEFT JOIN servisna_zakazka z
    ON z.id_vozidlo = v.id_vozidlo
GROUP BY
    v.znacka,
    v.model
ORDER BY
    pocet_oprav DESC,
    v.znacka,
    v.model;

PROMPT ============================================================
PROMPT DOPLNKOVY REPORT - FAKTUROVANA SUMA PODLA MESIACA (KONTROLA)
PROMPT ============================================================
-- Tento vystup je doplnkovy: nie je to skutocny prijem z platieb.
-- OCAKAVANE S DEMO DATAMI: september 40 EUR; oktober 297 EUR.
SELECT
    TRUNC(f.datum_vystavenia, 'MM') AS mesiac,
    COUNT(*) AS pocet_faktur,
    SUM(f.celkova_suma) AS fakturovana_suma_eur
FROM faktura f
GROUP BY TRUNC(f.datum_vystavenia, 'MM')
ORDER BY mesiac;
