# Informačný systém autoservisu – Checkpoint 5T

Oracle SQL Developer, Oracle Database 12c+.

## Súbory a poradie vykonania
1. 01_schema.sql – 11 tabuliek, PK, FK, UNIQUE, CHECK, 10 pomocných indexov. Spustiť len vo vlastnej povolenej schéme po overení konfliktov názvov.
2. 02_demo_data.sql – 45 navzájom konzistentných testovacích záznamov, COMMIT na konci. Spustiť iba raz.
3. 03_validation_reports.sql – kontrolné SELECT dotazy a reporty.

## Bezpečnosť
- Skripty nevykonávajú DROP.
- DDL v Oracle implicitne vykonáva COMMIT.
- Pred vytváraním objektov overte, či sú v schéme povolené vlastné projektové tabuľky.
- Nespúšťajte 01_schema.sql opakovane; nespúšťajte 02_demo_data.sql opakovane.
- Ak vykonanie skončí chybou, zastavte sa a prečítajte Script Output; neopakujte celý súbor naslepo.

## Očakávaný počet záznamov
ZAKAZNIK 5, VOZIDLO 5, ZAMESTNANEC 3, SERVISNA_ZAKAZKA 5, SERVISNY_UKON 5, VYKONANY_UKON 5, NAHRADNY_DIEL 5, POUZITY_DIEL 4, FAKTURA 3, PLATBA 3, PRILOHA 2. Celkom 45.

## Obmedzenia návrhu
- Prílohy v ukážke sú textové dokumenty uložené do BLOB, nie fotografie.
- Automatický odpočet skladu, platobný limit faktúry a história vlastníkov nie sú súčasťou základného modelu.
- Objektový typ a GUI implementujú ďalší členovia tímu; checkpoint vyžaduje aj tieto funkcie na úrovni celej aplikácie.
