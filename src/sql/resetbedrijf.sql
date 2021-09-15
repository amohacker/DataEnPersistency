DROP TABLE IF EXISTS medewerkers      CASCADE;
DROP TABLE IF EXISTS afdelingen       CASCADE;
DROP TABLE IF EXISTS schalen          CASCADE;
DROP TABLE IF EXISTS cursussen        CASCADE;
DROP TABLE IF EXISTS uitvoeringen     CASCADE;
DROP TABLE IF EXISTS inschrijvingen   CASCADE;
DROP TABLE IF EXISTS historie         CASCADE;
DROP TABLE IF EXISTS adressen         CASCADE;

CREATE TABLE medewerkers
(
    mnr      NUMERIC(4)     CONSTRAINT m_pk         PRIMARY KEY
        CONSTRAINT m_mnr_chk    CHECK (mnr > 7000),
    naam     VARCHAR(12)    CONSTRAINT m_naam_nn    NOT NULL,
    voorl    VARCHAR(5)     CONSTRAINT m_voorl_nn   NOT NULL,
    functie  VARCHAR(10),
    chef     NUMERIC(4)     CONSTRAINT m_chef_fk    REFERENCES medewerkers DEFERRABLE,
    gbdatum  DATE           CONSTRAINT m_gebdat_nn  NOT NULL,
    maandsal NUMERIC(6, 2)  CONSTRAINT m_mndsal_nn  NOT NULL,
    comm     NUMERIC(6, 2),
    afd      NUMERIC(2)     DEFAULT 10
);


CREATE TABLE afdelingen
(
    anr     NUMERIC(2)  CONSTRAINT a_pk         PRIMARY KEY
        CONSTRAINT a_anr_chk    CHECK (MOD(anr, 10) = 0),
    naam    VARCHAR(20) CONSTRAINT a_naam_nn    NOT NULL
        CONSTRAINT a_naam_un    UNIQUE
        CONSTRAINT a_naam_chk   CHECK (naam = UPPER(naam)),
    locatie VARCHAR(20) CONSTRAINT a_loc_nn     NOT NULL
        CONSTRAINT a_loc_chk    CHECK (locatie = UPPER(locatie)),
    hoofd   NUMERIC(4)  CONSTRAINT a_hoofd_fk   REFERENCES medewerkers DEFERRABLE
);

ALTER TABLE medewerkers
    ADD CONSTRAINT m_afd_fk FOREIGN KEY (afd) REFERENCES afdelingen DEFERRABLE;


CREATE TABLE schalen
(
    snr        NUMERIC(2)       CONSTRAINT s_pk         PRIMARY KEY,
    ondergrens NUMERIC(6, 2)    CONSTRAINT s_onder_nn   NOT NULL
        CONSTRAINT s_onder_chk  CHECK (ondergrens >= 0),
    bovengrens NUMERIC(6, 2)    CONSTRAINT s_boven_nn   NOT NULL,
    toelage    NUMERIC(6, 2)    CONSTRAINT s_toelg_nn   NOT NULL,
    CONSTRAINT s_ond_bov CHECK (ondergrens <= bovengrens)
);


CREATE TABLE cursussen
(
    code         VARCHAR(4)     CONSTRAINT c_pk         PRIMARY KEY,
    omschrijving VARCHAR(50)    CONSTRAINT c_omschr_nn  NOT NULL,
    type         CHAR(3)        CONSTRAINT c_type_nn    NOT NULL,
    lengte       NUMERIC(2)     CONSTRAINT c_lengte_nn  NOT NULL,
    CONSTRAINT c_code_chk CHECK (code = UPPER(code)),
    CONSTRAINT c_type_chk CHECK (type IN ('ALG', 'BLD', 'DSG'))
);


CREATE TABLE uitvoeringen
(
    cursus     VARCHAR(4)   CONSTRAINT u_cursus_nn  NOT NULL
        CONSTRAINT u_cursus_fk  REFERENCES cursussen DEFERRABLE,
    begindatum DATE         CONSTRAINT u_begin_nn   NOT NULL,
    docent     NUMERIC(4)   CONSTRAINT u_docent_fk  REFERENCES medewerkers DEFERRABLE,
    locatie    VARCHAR(20),
    CONSTRAINT u_pk PRIMARY KEY (cursus, begindatum)
);


CREATE TABLE inschrijvingen
(
    cursist    NUMERIC(4)   CONSTRAINT i_cursist_nn NOT NULL
        CONSTRAINT i_cursist_fk REFERENCES medewerkers DEFERRABLE,
    cursus     VARCHAR(4)   CONSTRAINT i_cursus_nn  NOT NULL,
    begindatum DATE         CONSTRAINT i_begin_nn   NOT NULL,
    evaluatie  NUMERIC(1)   CONSTRAINT i_eval_chk   CHECK (evaluatie IN (1, 2, 3, 4, 5)),
    CONSTRAINT i_pk         PRIMARY KEY (cursist, cursus, begindatum),
    CONSTRAINT i_uitv_fk    FOREIGN KEY (cursus, begindatum) REFERENCES uitvoeringen DEFERRABLE
);


CREATE TABLE historie
(
    mnr         NUMERIC(4)      CONSTRAINT h_mnr_nn     NOT NULL
        CONSTRAINT h_mnr_fk     REFERENCES medewerkers ON DELETE CASCADE DEFERRABLE,
    beginjaar   NUMERIC(4)      CONSTRAINT h_bjaar_nn   NOT NULL,
    begindatum  DATE            CONSTRAINT h_begin_nn   NOT NULL,
    einddatum   DATE,
    afd         NUMERIC(2)      CONSTRAINT h_afd_nn     NOT NULL
        CONSTRAINT h_afd_fk     REFERENCES afdelingen DEFERRABLE,
    maandsal    NUMERIC(6, 2)   CONSTRAINT h_sal_nn     NOT NULL,
    opmerkingen VARCHAR(60),
    CONSTRAINT h_pk           PRIMARY KEY (mnr, begindatum),
    CONSTRAINT h_beg_eind_chk CHECK (begindatum < einddatum)
);

-- ------------------------------------------------------------------------
-- Data & Persistency - Casus 'bedrijf'
--
-- Dit is een verkorte overname uit:
-- Lex de Haan (2004) Leerboek Oracle SQL (Derde editie, Academic Service)
--
-- Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
-- ------------------------------------------------------------------------
SET DATESTYLE = 'DMY'; -- voor het date format in de inserts

-- Vul de tabellen

-- Tabel `medewerkers` en `afdelingen` samen in één transactie vanwege cyclische referentie

TRUNCATE TABLE medewerkers CASCADE;
TRUNCATE TABLE afdelingen CASCADE;

START TRANSACTION;

SET CONSTRAINTS m_afd_fk DEFERRED; -- Foreign key constraints uitzetten

INSERT INTO medewerkers (mnr, naam, voorl, functie, chef, gbdatum, maandsal, comm, afd)
VALUES (7369, 'SMIT', 'N', 'TRAINER', 7902, '17-12-1985', 800, NULL, 20),
       (7499, 'ALDERS', 'JAM', 'VERKOPER', 7698, '20-02-1981', 1600, 200, 30),
       (7521, 'DE WAARD', 'TF', 'VERKOPER', 7698, '22-02-1982', 1250, 500, 30),
       (7566, 'JANSEN', 'JM', 'MANAGER', 7839, '02-04-1987', 2975, NULL, 20),
       (7654, 'MARTENS', 'P', 'VERKOPER', 7698, '28-09-1976', 1250, 1400, 30),
       (7698, 'BLAAK', 'R', 'MANAGER', 7839, '01-11-1983', 2850, NULL, 30),
       (7782, 'CLERCKX', 'AB', 'MANAGER', 7839, '09-06-1985', 2450, NULL, 10),
       (7788, 'SCHOTTEN', 'SCJ', 'TRAINER', 7566, '26-11-1979', 3000, NULL, 20),
       (7839, 'DE KONING', 'CC', 'DIRECTEUR', NULL, '17-11-1972', 5000, NULL, 10),
       (7844, 'DEN DRAAIER', 'JJ', 'VERKOPER', 7698, '28-09-1988', 1500, 0, 30),
       (7876, 'ADAMS', 'AA', 'TRAINER', 7788, '30-12-1986', 1100, NULL, 20),
       (7900, 'JANSEN', 'R', 'BOEKHOUDER', 7698, '03-12-1989', 800, NULL, 30),
       (7902, 'SPIJKER', 'MG', 'TRAINER', 7566, '13-02-1979', 3000, NULL, 20),
       (7934, 'MOLENAAR', 'TJA', 'BOEKHOUDER', 7782, '23-01-1982', 1300, NULL, 10);

INSERT INTO afdelingen (anr, naam, locatie, hoofd)
VALUES (10, 'HOOFDKANTOOR', 'LEIDEN', 7782),
       (20, 'OPLEIDINGEN', 'DE MEERN', 7566),
       (30, 'VERKOOP', 'UTRECHT', 7698),
       (40, 'PERSONEELSZAKEN', 'GRONINGEN', 7839);

COMMIT;


TRUNCATE TABLE schalen CASCADE;

INSERT INTO schalen (snr, ondergrens, bovengrens, toelage)
VALUES (1, 700, 1200, 0),
       (2, 1201, 1400, 50),
       (3, 1401, 2000, 100),
       (4, 2001, 3000, 200),
       (5, 3001, 9999, 500);


TRUNCATE TABLE cursussen CASCADE;

INSERT INTO cursussen (code, omschrijving, type, lengte)
VALUES ('S02', 'Introductiecursus SQL', 'ALG', 4),
       ('OAG', 'Oracle voor applicatiegebruikers', 'ALG', 1),
       ('JAV', 'Java voor Oracle ontwikkelaars', 'BLD', 4),
       ('PLS', 'Introductie PL/SQL', 'BLD', 1),
       ('XML', 'XML voor Oracle ontwikkelaars', 'BLD', 2),
       ('ERM', 'Datamodellering met ERM', 'DSG', 3),
       ('PMT', 'Procesmodelleringstechnieken', 'DSG', 1),
       ('RSO', 'Relationeel systeemontwerp', 'DSG', 2),
       ('PRO', 'Prototyping', 'DSG', 5),
       ('GEN', 'Systeemgeneratie', 'DSG', 4);


TRUNCATE TABLE uitvoeringen CASCADE;

INSERT INTO uitvoeringen (cursus, begindatum, docent, locatie)
VALUES ('S02', '12-04-2019', 7902, 'DE MEERN'),
       ('OAG', '10-08-2019', 7566, 'UTRECHT'),
       ('S02', '04-10-2019', 7369, 'MAASTRICHT'),
       ('S02', '13-12-2019', 7369, 'DE MEERN'),
       ('JAV', '13-12-2019', 7566, 'MAASTRICHT'),
       ('XML', '03-02-2020', 7369, 'DE MEERN'),
       ('JAV', '01-02-2020', 7876, 'DE MEERN'),
       ('PLS', '11-09-2020', 7788, 'DE MEERN'),
       ('XML', '18-09-2020', NULL, 'MAASTRICHT'),
       ('OAG', '27-09-2020', 7902, 'DE MEERN');

-- Toekomstige uitvoeringen
INSERT INTO uitvoeringen (cursus, begindatum, docent, locatie)
VALUES ('ERM', '15-01-2021', NULL, NULL),
       ('PRO', '19-02-2021', NULL, 'DE MEERN'),
       ('RSO', '24-02-2021', 7788, 'UTRECHT');


TRUNCATE TABLE inschrijvingen CASCADE;

INSERT INTO inschrijvingen (cursist, cursus, begindatum, evaluatie)
VALUES (7499, 'S02', '12-04-2019', 4),
       (7934, 'S02', '12-04-2019', 5),
       (7698, 'S02', '12-04-2019', 4),
       (7876, 'S02', '12-04-2019', 2),
       (7788, 'S02', '04-10-2019', NULL),
       (7839, 'S02', '04-10-2019', 3),
       (7902, 'S02', '04-10-2019', 4),
       (7902, 'S02', '13-12-2019', NULL),
       (7698, 'S02', '13-12-2019', NULL),
       (7521, 'OAG', '10-08-2019', 4),
       (7900, 'OAG', '10-08-2019', 4),
       (7902, 'OAG', '10-08-2019', 5),
       (7844, 'OAG', '27-09-2020', 5),
       (7499, 'JAV', '13-12-2019', 2),
       (7782, 'JAV', '13-12-2019', 5),
       (7876, 'JAV', '13-12-2019', 5),
       (7788, 'JAV', '13-12-2019', 5),
       (7839, 'JAV', '13-12-2019', 4),
       (7566, 'JAV', '01-02-2020', 3),
       (7788, 'JAV', '01-02-2020', 4),
       (7698, 'JAV', '01-02-2020', 5),
       (7900, 'XML', '03-02-2020', 4),
       (7499, 'XML', '03-02-2020', 5),
       (7566, 'PLS', '11-09-2020', NULL),
       (7499, 'PLS', '11-09-2020', NULL),
       (7876, 'PLS', '11-09-2020', NULL);


-- Historie van personeelszaken: één blok per medewerker
TRUNCATE TABLE historie CASCADE;

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7369, 2020, '01-01-2020', '01-02-2020', 40, 950, ''),
       (7369, 2020, '01-02-2020', NULL, 20, 800, 'Overgang naar opleidingen, met salaris"correctie" 150');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7499, 2008, '01-06-2008', '01-07-2009', 30, 1000, ''),
       (7499, 2009, '01-07-2009', '01-12-2013', 30, 1300, ''),
       (7499, 2013, '01-12-2013', '01-10-2015', 30, 1500, ''),
       (7499, 2015, '01-10-2015', '01-11-2019', 30, 1700, ''),
       (7499, 2019, '01-11-2019', NULL, 30, 1600, 'Targets al weer niet gehaald; salarisverlaging');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7521, 2006, '01-10-2006', '01-08-2007', 20, 1000, ''),
       (7521, 2007, '01-08-2007', '01-01-2009', 30, 1000, 'Overgang naar afdeling verkoop op eigen verzoek'),
       (7521, 2009, '01-01-2009', '15-12-2012', 30, 1150, ''),
       (7521, 2012, '15-12-2012', '01-10-2014', 30, 1250, ''),
       (7521, 2014, '01-10-2014', '01-10-2017', 20, 1250, ''),
       (7521, 2017, '01-10-2017', '01-02-2020', 30, 1300, ''),
       (7521, 2020, '01-02-2020', NULL, 30, 1250, '');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7566, 2002, '01-01-2002', '01-12-2002', 20, 900, ''),
       (7566, 2002, '01-12-2002', '15-08-2004', 20, 950, ''),
       (7566, 2004, '15-08-2004', '01-01-2006', 30, 1000, 'Niet zo geschikt als docent; dan maar naar verkoop!'),
       (7566, 2006, '01-01-2006', '01-07-2006', 30, 1175, 'Verkoop is ook al niet zo''n succes...'),
       (7566, 2006, '01-07-2006', '15-03-2007', 10, 1175, ''),
       (7566, 2007, '15-03-2007', '01-04-2007', 10, 2200, ''),
       (7566, 2007, '01-04-2007', '01-06-2009', 10, 2300, ''),
       (7566, 2009, '01-06-2009', '01-07-2012', 40, 2300, 'Van hoofdkantoor naar personeelszaken; salaris blijft 2300'),
       (7566, 2012, '01-07-2012', '01-11-2012', 40, 2450, ''),
       (7566, 2012, '01-11-2012', '01-09-2014', 20, 2600, 'Terug naar afdeling opleidingen, als hoofd'),
       (7566, 2014, '01-09-2014', '01-03-2015', 20, 2550, ''),
       (7566, 2015, '01-03-2015', '15-10-2019', 20, 2750, ''),
       (7566, 2019, '15-10-2019', NULL, 20, 2975, '');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7654, 2019, '01-01-2019', '15-10-2019', 30, 1100, 'Senior verkoper; zou wel eens een aanwinst kunnen zijn?'),
       (7654, 2019, '15-10-2019', NULL, 30, 1250, 'Valt toch een beetje tegen.');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7698, 2002, '01-06-2002', '01-01-2003', 30, 900, ''),
       (7698, 2003, '01-01-2003', '01-01-2004', 30, 1275, ''),
       (7698, 2004, '01-01-2004', '15-04-2005', 30, 1500, ''),
       (7698, 2005, '15-04-2005', '01-01-2006', 30, 2100, ''),
       (7698, 2006, '01-01-2006', '15-10-2009', 30, 2200, ''),
       (7698, 2009, '15-10-2009', NULL, 30, 2850, 'Gepromoveerd tot hoofd van de afdeling verkoop');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7782, 2008, '01-07-2008', NULL, 10, 2450, 'Aangenomen als manager voor het hoofdkantoor');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7788, 2002, '01-07-2002', '01-01-2003', 20, 900, ''),
       (7788, 2003, '01-01-2003', '15-04-2005', 20, 950, ''),
       (7788, 2005, '15-04-2005', '01-06-2005', 40, 950, 'Overgang naar personeelszaken, zonder salarisverhoging'),
       (7788, 2005, '01-06-2005', '15-04-2006', 40, 1100, ''),
       (7788, 2006, '15-04-2006', '01-05-2006', 20, 1100, ''),
       (7788, 2006, '01-05-2006', '15-02-2007', 20, 1800, ''),
       (7788, 2007, '15-02-2007', '01-12-2009', 20, 1250, 'Salarisverlaging met 550, vanwege onvoldoende prestaties'),
       (7788, 2009, '01-12-2009', '15-10-2012', 20, 1350, ''),
       (7788, 2012, '15-10-2012', '01-01-2018', 20, 1400, ''),
       (7788, 2018, '01-01-2018', '01-01-2019', 20, 1700, ''),
       (7788, 2019, '01-01-2019', '01-07-2019', 20, 1800, ''),
       (7788, 2019, '01-07-2019', '01-06-2020', 20, 1800, ''),
       (7788, 2020, '01-06-2020', NULL, 20, 3000, '');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7839, 2002, '01-01-2002', '01-08-2002', 30, 1000, 'Oprichter en eerste werknemer van het bedrijf'),
       (7839, 2002, '01-08-2002', '15-05-2004', 30, 1200, ''),
       (7839, 2004, '15-05-2004', '01-01-2005', 30, 1500, ''),
       (7839, 2005, '01-01-2005', '01-07-2005', 30, 1750, ''),
       (7839, 2005, '01-07-2005', '01-11-2005', 10, 2000, 'Hoofdkantoor als nieuwe zelfstandige afdeling opgericht'),
       (7839, 2005, '01-11-2005', '01-02-2006', 10, 2200, ''),
       (7839, 2006, '01-02-2006', '15-06-2009', 10, 2500, ''),
       (7839, 2009, '15-06-2009', '01-12-2013', 10, 2900, ''),
       (7839, 2013, '01-12-2013', '01-09-2015', 10, 3400, ''),
       (7839, 2015, '01-09-2015', '01-10-2017', 10, 4200, ''),
       (7839, 2017, '01-10-2017', '01-10-2018', 10, 4500, ''),
       (7839, 2018, '01-10-2018', '01-11-2019', 10, 4800, ''),
       (7839, 2019, '01-11-2019', '15-02-2020', 10, 4900, ''),
       (7839, 2020, '15-02-2020', NULL, 10, 5000, '');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7844, 2015, '01-05-2015', '01-01-2017', 30, 900, ''),
       (7844, 2018, '15-10-2018', '01-11-2018', 10, 1200, 'Project (van een halve maand) voor het hoofdkantoor'),
       (7844, 2018, '01-11-2018', '01-01-2020', 30, 1400, ''),
       (7844, 2020, '01-01-2020', NULL, 30, 1500, '');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7876, 2020, '01-01-2020', '01-02-2020', 20, 950, ''),
       (7876, 2020, '01-02-2020', NULL, 20, 1100, '');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7900, 2020, '01-07-2020', NULL, 30, 800, 'Junior verkoper -- moet nog veel leren...');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7902, 2018, '01-09-2018', '01-10-2018', 40, 1400, ''),
       (7902, 2018, '01-10-2018', '15-03-2019', 30, 1650, ''),
       (7902, 2019, '15-03-2019', '01-01-2020', 30, 2500, ''),
       (7902, 2020, '01-01-2020', '01-08-2020', 30, 3000, ''),
       (7902, 2020, '01-08-2020', NULL, 20, 3000, '');

INSERT INTO historie (mnr, beginjaar, begindatum, einddatum, afd, maandsal, opmerkingen)
VALUES (7934, 2018, '01-02-2018', '01-05-2018', 10, 1275, ''),
       (7934, 2018, '01-05-2018', '01-02-2019', 10, 1280, ''),
       (7934, 2019, '01-02-2019', '01-01-2020', 10, 1290, ''),
       (7934, 2020, '01-01-2020', NULL, 10, 1300, '');


-- Verzamel OBJECT-STATISTICS voor de optimizer
-- EXECUTE dbms_stats.gather_schema_stats(ownname => user, cascade => TRUE);

-- ------------------------------------------------------------------------
-- Data & Persistency - Casus 'bedrijf'
--
-- Testraamwerk SQL-opdrachten
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
--
--
-- Voer dit 'testsuite'-bestand uit op de aangemaakte 'bedijf' database.
-- Daarna kun je de opdrachten (b.v. S2_CRUD_student.sql) openen in
-- pgAdmin of een andere IDE. Na het maken van de opdrachten kun je je
-- uitwerkingen (grotendeels) testen. Zie het commentaar in de opdrachten
-- voor meer informatie.
-- ------------------------------------------------------------------------

DROP FUNCTION IF EXISTS test_select(_exercise_nr text);
CREATE OR REPLACE FUNCTION test_select(_exercise_nr text) RETURNS text AS $$
	DECLARE _sol_name text := REPLACE(LOWER(_exercise_nr), '.', '_');
	DECLARE _test_name text := _sol_name || '_test';
	DECLARE _query_res text;
	DECLARE _missing_count int := 0;
	DECLARE _excess_count int := 0;
	DECLARE _missing_query text := 'SELECT * FROM ' || _test_name || ' EXCEPT SELECT * FROM ' || _sol_name;
	DECLARE _excess_query text := 'SELECT * FROM ' || _sol_name || ' EXCEPT SELECT * FROM ' || _test_name;
	DECLARE _rows RECORD;
BEGIN
BEGIN
EXECUTE 'SELECT * FROM ' || _sol_name INTO _query_res;
IF POSITION('heeft nog geen uitwerking' IN _query_res) <> 0
				THEN RETURN _query_res;
END IF;
EXCEPTION
			WHEN OTHERS THEN
				RAISE notice 'mislukt: %', sqlerrm;
NULL;
END;

FOR _rows IN EXECUTE _missing_query LOOP
			_missing_count := _missing_count + 1;
END LOOP;

FOR _rows IN EXECUTE _excess_query LOOP
			_excess_count := _excess_count + 1;
END LOOP;

		IF _missing_count = 0 AND _excess_count = 0 THEN
			RETURN _exercise_nr || ' geeft de juiste resultaten!';
ELSE
			RETURN _exercise_nr || ' geeft niet de juiste resultaten: er zijn ' || _excess_count::text || ' verkeerde rijen teveel en ' || _missing_count::text || ' goede rijen ontbreken.';
END IF;
EXCEPTION
		WHEN SQLSTATE '42804' THEN
			RETURN _exercise_nr || ' is niet correct: de kolomnamen of de kolomtypen kloppen niet.';
WHEN SQLSTATE '42601' THEN
			RETURN _exercise_nr || ' is niet correct: het aantal kolommen klopt niet.';
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS test_exists(_exercise_nr TEXT, _row_test BIGINT, _compare_type TEXT);
CREATE OR REPLACE FUNCTION test_exists(_exercise_nr TEXT, _row_test BIGINT, _compare_type TEXT DEFAULT 'exact') RETURNS TEXT AS $$
	DECLARE _sol_name TEXT := REPLACE(LOWER(_exercise_nr), '.', '_');
	DECLARE _test_name TEXT := _sol_name || '_test';
	DECLARE _row_count INT := 0;
BEGIN
EXECUTE FORMAT('SELECT COUNT(*) FROM %I;', _test_name) INTO _row_count;

IF _compare_type = 'exact' AND _row_count = _row_test THEN
            RETURN _exercise_nr || ' heeft de juiste uitwerking op de database!';
        ELSIF _compare_type = 'maximaal' AND _row_count <= _row_test THEN
            RETURN _exercise_nr || ' heeft de juiste uitwerking op de database!';
        ELSIF _compare_type = 'minimaal' AND _row_count >= _row_test THEN
            RETURN _exercise_nr || ' heeft de juiste uitwerking op de database!';
END IF;

        RETURN _exercise_nr || ' heeft niet de juiste uitwerking op de database: er moeten ' || _compare_type || ' ' || _row_test || ' rijen of kolommen zijn, maar de database heeft er ' || _row_count || '.';
END;
$$ LANGUAGE plpgsql;



DROP VIEW IF EXISTS s1_1_test; CREATE OR REPLACE VIEW s1_1_test AS
SELECT column_name FROM information_schema.columns WHERE table_schema='public' AND table_name='medewerkers' AND column_name='geslacht';

DROP VIEW IF EXISTS s1_2_test; CREATE OR REPLACE VIEW s1_2_test AS
SELECT m.naam FROM medewerkers m JOIN afdelingen a ON m.mnr = a.hoofd WHERE a.naam = 'ONDERZOEK' AND m.chef = 7839;

DROP VIEW IF EXISTS s1_4_test; CREATE OR REPLACE VIEW s1_4_test AS
SELECT column_name FROM information_schema.columns WHERE table_schema='public' AND table_name='adressen' AND column_name IN ('postcode', 'huisnummer', 'ingangsdatum', 'einddatum', 'telefoon', 'med_mnr');

-- Ongebruikt.
DROP VIEW IF EXISTS s1_5_test; CREATE OR REPLACE VIEW s1_5_test AS
SELECT naam FROM medewerkers WHERE mnr < 9000;



DROP VIEW IF EXISTS s2_1; CREATE OR REPLACE VIEW s2_1 AS SELECT 'S2.1 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s2_2; CREATE OR REPLACE VIEW s2_2 AS SELECT 'S2.2 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s2_3; CREATE OR REPLACE VIEW s2_3 AS SELECT 'S2.3 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s2_4; CREATE OR REPLACE VIEW s2_4 AS SELECT 'S2.4 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;


DROP VIEW IF EXISTS s2_1_test; CREATE OR REPLACE VIEW s2_1_test AS
SELECT code, omschrijving FROM cursussen WHERE code IN ('S02', 'JAV', 'GEN');

DROP VIEW IF EXISTS s2_2_test; -- CREATE OR REPLACE VIEW s2_2_test AS
-- SELECT * FROM medewerkers;

DROP VIEW IF EXISTS s2_3_test; CREATE OR REPLACE VIEW s2_3_test AS
SELECT * FROM (VALUES
                   ('OAG'::VARCHAR(4), '2019-08-10'::DATE),
                   ('S02',	'2019-10-04'),
                   ('JAV',	'2019-12-13'),
                   ('XML',	'2020-09-18'),
                   ('RSO',	'2021-02-24')
              ) answer (cursus, begindatum);

DROP VIEW IF EXISTS s2_4_test; CREATE OR REPLACE VIEW s2_4_test AS
SELECT naam, voorl FROM medewerkers WHERE mnr != 7900;

DROP VIEW IF EXISTS s2_5_test; CREATE OR REPLACE VIEW s2_5_test AS
SELECT cursus
FROM uitvoeringen JOIN medewerkers ON mnr = docent
WHERE naam = 'SMIT' AND cursus = 'S02' AND
        EXTRACT(MONTH FROM begindatum) = 3 AND
        EXTRACT(DAY FROM begindatum) = 2;

DROP VIEW IF EXISTS s2_6_test; CREATE OR REPLACE VIEW s2_6_test AS
SELECT naam FROM medewerkers WHERE mnr >= 8000 AND functie = 'STAGIAIR';

DROP VIEW IF EXISTS s2_7_test; CREATE OR REPLACE VIEW s2_7_test AS
SELECT snr FROM schalen;



DROP VIEW IF EXISTS s3_1; CREATE OR REPLACE VIEW s3_1 AS SELECT 'S3.1 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s3_2; CREATE OR REPLACE VIEW s3_2 AS SELECT 'S3.2 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s3_3; CREATE OR REPLACE VIEW s3_3 AS SELECT 'S3.3 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s3_4; CREATE OR REPLACE VIEW s3_4 AS SELECT 'S3.4 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s3_5; CREATE OR REPLACE VIEW s3_5 AS SELECT 'S3.5 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s3_6; CREATE OR REPLACE VIEW s3_6 AS SELECT 'S3.6 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;


DROP VIEW IF EXISTS s3_1_test; CREATE OR REPLACE VIEW s3_1_test AS
SELECT * FROM (VALUES
                   ('S02'::VARCHAR(4), '2019-04-12'::DATE, 4::NUMERIC(2), 'SPIJKER'::VARCHAR(12)),
                   ('OAG', '2019-08-10', 1, 'JANSEN'),
                   ('S02', '2019-10-04', 4, 'SMIT'),
                   ('S02', '2019-12-13', 4, 'SMIT'),
                   ('JAV', '2019-12-13', 4, 'JANSEN'),
                   ('XML', '2020-02-03', 2, 'SMIT'),
                   ('JAV', '2020-02-01', 4, 'ADAMS'),
                   ('PLS', '2020-09-11', 1, 'SCHOTTEN'),
                   ('OAG', '2020-09-27', 1, 'SPIJKER'),
                   ('RSO', '2021-02-24', 2, 'SCHOTTEN')
              ) answer (code, begindatum, lengte, naam);

DROP VIEW IF EXISTS s3_2_test; CREATE OR REPLACE VIEW s3_2_test AS
SELECT * FROM (VALUES
                   ('ALDERS'::VARCHAR(12), 'SPIJKER'::VARCHAR(12)),
                   ('BLAAK', 'SMIT'),
                   ('BLAAK', 'SPIJKER'),
                   ('SCHOTTEN', 'SMIT'),
                   ('DE KONING', 'SMIT'),
                   ('ADAMS', 'SPIJKER'),
                   ('SPIJKER', 'SMIT'),
                   ('SPIJKER', 'SMIT'),
                   ('MOLENAAR', 'SPIJKER')
              ) answer (cursist, docent);

DROP VIEW IF EXISTS s3_3_test; CREATE OR REPLACE VIEW s3_3_test AS
SELECT * FROM (VALUES
                   ('HOOFDKANTOOR'::VARCHAR(20), 'CLERCKX'::VARCHAR(12)),
                   ('OPLEIDINGEN', 'JANSEN'),
                   ('VERKOOP', 'BLAAK'),
                   ('PERSONEELSZAKEN', 'DE KONING')
              ) answer (afdeling, hoofd);

DROP VIEW IF EXISTS s3_4_test; CREATE OR REPLACE VIEW s3_4_test AS
SELECT * FROM (VALUES
                   ('ALDERS'::VARCHAR(12), 'VERKOOP'::VARCHAR(20), 'UTRECHT'::VARCHAR(20)),
                   ('DE WAARD',    'VERKOOP',      'UTRECHT'),
                   ('JANSEN',      'OPLEIDINGEN',  'DE MEERN'),
                   ('MARTENS',     'VERKOOP',      'UTRECHT'),
                   ('BLAAK',       'VERKOOP',      'UTRECHT'),
                   ('CLERCKX',     'HOOFDKANTOOR', 'LEIDEN'),
                   ('SCHOTTEN',    'OPLEIDINGEN',  'DE MEERN'),
                   ('DE KONING',   'HOOFDKANTOOR', 'LEIDEN'),
                   ('DEN DRAAIER', 'VERKOOP',      'UTRECHT'),
                   ('ADAMS',       'OPLEIDINGEN',  'DE MEERN'),
                   ('SPIJKER',     'OPLEIDINGEN',  'DE MEERN'),
                   ('MOLENAAR',    'HOOFDKANTOOR', 'LEIDEN'),
                   ('SMIT',        'OPLEIDINGEN',  'DE MEERN'),
                   ('JANSEN',      'VERKOOP',      'UTRECHT')
              ) answer (afdeling, hoofd);

DROP VIEW IF EXISTS s3_5_test; CREATE OR REPLACE VIEW s3_5_test AS
SELECT naam FROM medewerkers WHERE mnr IN (7499, 7934, 7698, 7876);

DROP VIEW IF EXISTS s3_6_test; CREATE OR REPLACE VIEW s3_6_test AS
SELECT * FROM (VALUES
                   ('ALDERS'::VARCHAR(12), 100.00::NUMERIC(6, 2)),
                   ('DE WAARD', 50.00),
                   ('JANSEN', 200.00),
                   ('MARTENS', 50.00),
                   ('BLAAK', 200.00),
                   ('CLERCKX', 200.00),
                   ('SCHOTTEN', 200.00),
                   ('DE KONING', 500.00),
                   ('DEN DRAAIER', 100.00),
                   ('ADAMS', 0.00),
                   ('SPIJKER', 200.00),
                   ('MOLENAAR', 50.00),
                   ('SMIT', 0.00),
                   ('JANSEN', 0.00)
              ) answer (naam, toelage);



DROP VIEW IF EXISTS s4_1; CREATE OR REPLACE VIEW s4_1 AS SELECT 'S4.1 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s4_2; CREATE OR REPLACE VIEW s4_2 AS SELECT 'S4.2 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s4_3; CREATE OR REPLACE VIEW s4_3 AS SELECT 'S4.3 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s4_4; CREATE OR REPLACE VIEW s4_4 AS SELECT 'S4.4 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s4_5; CREATE OR REPLACE VIEW s4_5 AS SELECT 'S4.5 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s4_6; CREATE OR REPLACE VIEW s4_6 AS SELECT 'S4.6 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s4_7; CREATE OR REPLACE VIEW s4_7 AS SELECT 'S4.7 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;


DROP VIEW IF EXISTS s4_1_test; CREATE OR REPLACE VIEW s4_1_test AS
SELECT * FROM (VALUES
                   (7654::NUMERIC(4),	'VERKOPER'::VARCHAR(10),	'1976-09-28'::DATE),
                   (7788, 'TRAINER', 	'1979-11-26'),
                   (7902, 'TRAINER', 	'1979-02-13')
              ) answer (mnr, functie, gbdatum);


DROP VIEW IF EXISTS s4_2_test; CREATE OR REPLACE VIEW s4_2_test AS
SELECT * FROM (VALUES
                   ('DE WAARD'::VARCHAR(12)),
                   ('DE KONING'),
                   ('DEN DRAAIER')
              ) answer (naam);

DROP VIEW IF EXISTS s4_3_test; CREATE OR REPLACE VIEW s4_3_test AS
SELECT * FROM (VALUES
                   ('JAV'::VARCHAR(4),	'2019-12-13'::DATE,	5::BIGINT),
                   ('OAG',	'2019-08-10',	3),
                   ('S02',	'2019-04-12',	4),
                   ('S02',	'2019-10-04',	3)
              ) answer (cursus, begindatum, aantal_inschrijvingen);

DROP VIEW IF EXISTS s4_4_test; CREATE OR REPLACE VIEW s4_4_test AS
SELECT * FROM (VALUES
                   (7788::NUMERIC(4),	'JAV'::VARCHAR(4)),
                   (7902,	'S02'),
                   (7698,	'S02')
              ) answer (cursist, cursus);

DROP VIEW IF EXISTS s4_5_test; CREATE OR REPLACE VIEW s4_5_test AS
SELECT * FROM (VALUES
                   ('JAV'::VARCHAR(4),	2::BIGINT),
                   ('S02',	3),
                   ('PRO',	1),
                   ('OAG',	2),
                   ('RSO',	1),
                   ('ERM',	1),
                   ('PLS',	1),
                   ('XML',	2)
              ) answer (cursus, aantal);

-- Geen test voor S4.6 mogelijk.

DROP VIEW IF EXISTS s4_7_test; CREATE OR REPLACE VIEW s4_7_test AS
SELECT * FROM (VALUES
                   (14::BIGINT, 150::NUMERIC, 525::NUMERIC)
              ) answer (aantal_medewerkers, commissie_medewerkers, commissie_verkopers);



DROP VIEW IF EXISTS s5_1; CREATE OR REPLACE VIEW s5_1 AS SELECT 'S5.1 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s5_2; CREATE OR REPLACE VIEW s5_2 AS SELECT 'S5.2 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s5_3; CREATE OR REPLACE VIEW s5_3 AS SELECT 'S5.3 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s5_4a; CREATE OR REPLACE VIEW s5_4a AS SELECT 'S5.4a heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s5_4b; CREATE OR REPLACE VIEW s5_4b AS SELECT 'S5.4b heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s5_5; CREATE OR REPLACE VIEW s5_5 AS SELECT 'S5.5 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s5_6; CREATE OR REPLACE VIEW s5_6 AS SELECT 'S5.6 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s5_7; CREATE OR REPLACE VIEW s5_7 AS SELECT 'S5.7 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s5_8; CREATE OR REPLACE VIEW s5_8 AS SELECT 'S5.8 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;


DROP VIEW IF EXISTS s5_1_test; CREATE OR REPLACE VIEW s5_1_test AS
SELECT * FROM (VALUES
                   (7499::NUMERIC(4))
              ) answer (cursist);

DROP VIEW IF EXISTS s5_2_test; CREATE OR REPLACE VIEW s5_2_test AS
SELECT * FROM (VALUES
                   (7934::NUMERIC(4)),
                   (7839),
                   (7782),
                   (7499),
                   (7900),
                   (7844),
                   (7698),
                   (7521),
                   (7654)
              ) answer (mnr);

DROP VIEW IF EXISTS s5_3_test; CREATE OR REPLACE VIEW s5_3_test AS
SELECT * FROM (VALUES
                   (7902::NUMERIC(4)),
                   (7934),
                   (7369),
                   (7654),
                   (7521),
                   (7844),
                   (7900)
              ) answer (mnr);

DROP VIEW IF EXISTS s5_4a_test; CREATE OR REPLACE VIEW s5_4a_test AS
SELECT * FROM (VALUES
                   ('JANSEN'::VARCHAR(12)),
                   ('CLERCKX'),
                   ('SCHOTTEN'),
                   ('DE KONING'),
                   ('SPIJKER'),
                   ('BLAAK')
              ) answer (naam);

DROP VIEW IF EXISTS s5_4b_test; CREATE OR REPLACE VIEW s5_4b_test AS
SELECT * FROM (VALUES
                   ('SMIT'::VARCHAR(12)),
                   ('ALDERS'),
                   ('DE WAARD'),
                   ('MARTENS'),
                   ('ADAMS'),
                   ('JANSEN'),
                   ('MOLENAAR'),
                   ('DEN DRAAIER')
              ) answer (naam);

DROP VIEW IF EXISTS s5_5_test; CREATE OR REPLACE VIEW s5_5_test AS
SELECT * FROM (VALUES
                   ('XML'::VARCHAR(12), '2020-02-03'::DATE),
                   ('JAV',	'2020-02-01'),
                   ('PLS',	'2020-09-11'),
                   ('XML',	'2020-09-18')
              ) answer (cursus, begindatum);

DROP VIEW IF EXISTS s5_6_test; CREATE OR REPLACE VIEW s5_6_test AS
SELECT * FROM (VALUES
                   ('S02'::VARCHAR(12),	'2019-04-12'::DATE,	4::BIGINT),
                   ('OAG',	'2019-08-10',	3),
                   ('S02',	'2019-10-04',	3),
                   ('S02',	'2019-12-13',	2),
                   ('JAV',	'2019-12-13',	5),
                   ('JAV',	'2020-02-01',	3),
                   ('XML',	'2020-02-03',	2),
                   ('PLS',	'2020-09-11',	3),
                   ('XML',	'2020-09-18',	0),
                   ('OAG',	'2020-09-27',	1),
                   ('ERM',	'2021-01-15',	0),
                   ('PRO',	'2021-02-19',	0),
                   ('RSO',	'2021-02-24',	0)
              ) answer (cursus, begindatum, aantal_inschrijvingen);

DROP VIEW IF EXISTS s5_7_test; CREATE OR REPLACE VIEW s5_7_test AS
SELECT * FROM (VALUES
                   ('N'::VARCHAR(5), 'SMIT'::VARCHAR(12))
              ) answer (cursist);

DROP VIEW IF EXISTS s5_8_test; CREATE OR REPLACE VIEW s5_8_test AS
SELECT * FROM (VALUES
                   ('DE KONING'::VARCHAR(12)),
                   ('MOLENAAR'),
                   ('MARTENS'),
                   ('DE WAARD'),
                   ('BLAAK'),
                   ('JANSEN'),
                   ('ALDERS'),
                   ('CLERCKX'),
                   ('DEN DRAAIER')
              ) answer (naam);



DROP VIEW IF EXISTS s9_1; CREATE OR REPLACE VIEW s9_1 AS SELECT 'S9.1 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s9_3; CREATE OR REPLACE VIEW s9_3 AS SELECT 'S9.3 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s9_4; CREATE OR REPLACE VIEW s9_4 AS SELECT 'S9.4 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;
DROP VIEW IF EXISTS s9_5; CREATE OR REPLACE VIEW s9_5 AS SELECT 'S9.5 heeft nog geen uitwerking - misschien moet je de DROP VIEW ... regel nog activeren?' AS resultaat;


DROP VIEW IF EXISTS s9_1_test; CREATE OR REPLACE VIEW s9_1_test AS
SELECT m.mnr
FROM medewerkers m, afdelingen a, historie h
WHERE m.afd = 40 AND h.mnr = a.hoofd AND m.chef = 7839
  AND m.mnr = h.mnr AND h.einddatum IS NULL AND m.maandsal = h.maandsal;

DROP VIEW IF EXISTS s9_3_test; CREATE OR REPLACE VIEW s9_3_test AS
SELECT * FROM (VALUES
                   ('Overgang naar opleidingen, met salaris"correctie" 150'::VARCHAR(60),	7369::NUMERIC(4)),
                   ('Targets al weer niet gehaald; salarisverlaging',	7499),
                   ('Valt toch een beetje tegen.',	                    7654),
                   ('Gepromoveerd tot hoofd van de afdeling verkoop',	7698),
                   ('Aangenomen als manager voor het hoofdkantoor',	7782),
                   ('Junior verkoper -- moet nog veel leren...',	    7900)
              ) answer (opmerkingen, mnr);

DROP VIEW IF EXISTS s9_4_test; CREATE OR REPLACE VIEW s9_4_test AS
SELECT * FROM (VALUES
                   ('CLERCKX'::VARCHAR(12),	'2008-07-01'::DATE,	'HOOFDKANTOOR'::VARCHAR(20),	4::NUMERIC(2)),
                   ('DE KONING',	'2002-01-01',	'VERKOOP',	    1),
                   ('DE KONING',	'2002-08-01',	'VERKOOP',	    1),
                   ('DE KONING',	'2004-05-15',	'VERKOOP',	    3),
                   ('DE KONING',	'2005-01-01',	'VERKOOP',	    3),
                   ('DE KONING',	'2005-07-01',	'HOOFDKANTOOR',	3),
                   ('DE KONING',	'2005-11-01',	'HOOFDKANTOOR',	4),
                   ('DE KONING',	'2006-02-01',	'HOOFDKANTOOR',	4),
                   ('DE KONING',	'2009-06-15',	'HOOFDKANTOOR',	4),
                   ('DE KONING',	'2013-12-01',	'HOOFDKANTOOR',	5),
                   ('DE KONING',	'2015-09-01',	'HOOFDKANTOOR',	5),
                   ('DE KONING',	'2017-10-01',	'HOOFDKANTOOR',	5),
                   ('DE KONING',	'2018-10-01',	'HOOFDKANTOOR',	5),
                   ('DE KONING',	'2019-11-01',	'HOOFDKANTOOR',	5),
                   ('DE KONING',	'2020-02-15',	'HOOFDKANTOOR',	5),
                   ('MOLENAAR',	'2018-02-01',	'HOOFDKANTOOR',	2),
                   ('MOLENAAR',	'2018-05-01',	'HOOFDKANTOOR',	2),
                   ('MOLENAAR',	'2019-02-01',	'HOOFDKANTOOR',	2),
                   ('MOLENAAR',	'2020-01-01',	'HOOFDKANTOOR',	2)
              ) answer (naam, begindatum, afdeling, schaal);

DROP VIEW IF EXISTS s9_5_test; CREATE OR REPLACE VIEW s9_5_test AS
SELECT * FROM (VALUES
                   ('SMIT',	    0::DOUBLE PRECISION),
                   ('ALDERS',	    11),
                   ('DE WAARD',	13),
                   ('JANSEN',	    17),
                   ('MARTENS',	    0),
                   ('BLAAK',	    7),
                   ('CLERCKX',	    0),
                   ('SCHOTTEN',	17),
                   ('DE KONING',	18),
                   ('ADAMS',	    0),
                   ('JANSEN',	    0),
                   ('SPIJKER',	    1),
                   ('MOLENAAR',	1),
                   ('DEN DRAAIER',	5)
              ) answer (naam, tijdsduur);