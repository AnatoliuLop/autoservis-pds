# Informačný systém autoservisu
**Predmet:** Pokročilé databázové systémy  
**Checkpoint:** 5. týždeň  
**Databázový systém:** Oracle Database

## 1. Opis projektu

Cieľom projektu je vytvoriť informačný systém na správu autoservisu. Systém umožňuje evidovať zákazníkov a ich vozidlá, vytvárať servisné zákazky, zaznamenávať vykonané servisné úkony a použité náhradné diely, vystavovať faktúry a evidovať platby.

Súčasťou systému je aj evidencia príloh, napríklad fotografií vozidiel alebo servisných dokumentov.

## 2. Dátový model

Databáza obsahuje **11 vzájomne prepojených tabuliek**:

| Tabuľka | Účel |
|---|---|
| ZAKAZNIK | Evidencia zákazníkov |
| VOZIDLO | Evidencia vozidiel zákazníkov |
| ZAMESTNANEC | Evidencia zamestnancov autoservisu |
| SERVISNA_ZAKAZKA | Správa servisných zákaziek |
| SERVISNY_UKON | Katalóg servisných služieb |
| VYKONANY_UKON | Úkony vykonané v rámci zákazky |
| NAHRADNY_DIEL | Katalóg náhradných dielov |
| POUZITY_DIEL | Diely použité pri oprave |
| FAKTURA | Evidencia vystavených faktúr |
| PLATBA | Evidencia prijatých platieb |
| PRILOHA | Ukladanie dokumentov a BLOB súborov |

Každá tabuľka má primárny kľúč (PK). Vzťahy medzi tabuľkami sú zabezpečené pomocou 11 cudzích kľúčov (FK).

Dátový model je navrhnutý podľa zásad **tretej normálnej formy (3NF)**. Údaje sú rozdelené podľa jednotlivých entít, aby sa minimalizovala redundancia a zabránilo nekonzistentným údajom.

Napríklad údaje zákazníka sa neukladajú priamo do servisnej zákazky, ale získavajú sa cez tabuľku VOZIDLO.

Pri vykonaných úkonoch a použitých dieloch sa zároveň uchováva cena platná v čase opravy, aby neskoršie zmeny katalógových cien neovplyvnili historické údaje.

## 3. Priebeh servisnej zákazky

1. Zákazník prinesie vozidlo do autoservisu.
2. Vytvorí sa servisná zákazka so stavom `PRIJATA`.
3. Mechanik vykonáva servisné úkony a používa náhradné diely.
4. Po dokončení opravy sa stav zmení na `DOKONCENA`.
5. Vystaví sa faktúra na základe vykonaných prác a použitých dielov.
6. Zaeviduje sa platba a vozidlo sa odovzdá zákazníkovi (`ODOVZDANA`).

Podporované stavy zákazky sú `PRIJATA`, `V_OPRAVE`, `DOKONCENA`, `ODOVZDANA` a `ZRUSENA`.

## 4. Fakturácia a tržby

V systéme rozlišujeme **fakturovanú sumu a skutočne prijaté platby**.

- **FAKTURA** obsahuje sumu, ktorú má zákazník zaplatiť za opravu.
- **PLATBA** obsahuje skutočne prijaté platby od zákazníka.

Jedna faktúra môže mať viacero platieb, preto systém podporuje aj čiastočné úhrady.

**Príklad:** Ak je vystavená faktúra na 168 €, ale zákazník zatiaľ zaplatil iba 100 €, fakturovaná suma je 168 €, skutočný príjem je 100 € a neuhradený zostatok predstavuje 68 €.

Na základe testovacích údajov:

| Ukazovateľ | Suma |
|---|---:|
| Celková fakturovaná suma | 337 € |
| Skutočne prijaté platby | 269 € |
| Neuhradený zostatok | 68 € |

V SQL reportoch preto počítame **tržby podľa prijatých platieb** z tabuľky PLATBA, nie podľa celkovej sumy vystavených faktúr.

Fakturované sumy zobrazujeme samostatne, aby bolo možné porovnávať vystavené faktúry so skutočnými príjmami.

## 5. Implementované SQL reporty

| № | Report | Použité SQL |
|---|---|---|
| 1 | Celkové tržby autoservisu | SUM, COUNT |
| 2 | Mesačné tržby autoservisu | GROUP BY, TRUNC |
| 5 | Priemerná dĺžka opravy vozidla | AVG, práca s dátumami |
| 9 | Počet opráv podľa značky a modelu vozidla | JOIN, GROUP BY, COUNT |

Reporty boli implementované a úspešne otestované na vzorových údajoch.

## 6. Testovanie databázy

Databáza bola vytvorená v Oracle SQL Developer a obsahuje **45 zmysluplných testovacích záznamov** rozdelených do 11 tabuliek.

Bola overená:

- Referenčná integrita pomocou cudzích kľúčov.
- Funkčnosť obmedzení PRIMARY KEY, FOREIGN KEY, UNIQUE a CHECK.
- Ochrana pred zápornými cenami a neexistujúcimi referenciami.
- Správnosť SQL reportov a výpočtov faktúr.

Všetky kontrolované obmedzenia sú aktívne a validované. Výpočty faktúr zodpovedajú cenám servisných úkonov a použitých dielov v testovacích údajoch.

**Výsledok:** Funkčný relačný dátový model s testovacími údajmi a SQL reportmi, pripravený na integráciu s PL/SQL logikou a aplikačným rozhraním.
