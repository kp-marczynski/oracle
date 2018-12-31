ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SESSION SET NLS_DATE_LANGUAGE = 'ENGLISH';

-- todo Zad. 47. Założyć, że w stadzie kotów pojawił się podział na elitę i na plebs.
-- Członek elity posiadał prawo do jednego sługi wybranego spośród plebsu.
-- Dodatkowo mógł gromadzić myszy na dostępnym dla każdego członka elity koncie.
-- Konto ma zawierać dane o dacie wprowadzenia na nie pojedynczej myszy i o dacie jej usunięcia.
-- O tym, do kogo należy mysz ma mówić odniesienie do jej właściciela z elity.
-- Przyjmując te dodatkowe założenia zdefiniować schemat bazy danych kotów (bez odpowiedników relacji Funkcje, Bandy, Wrogowie)
-- w postaci relacyjno-obiektowej, gdzie dane dotyczące kotów, elity, plebsu. kont, incydentów będą określane przez odpowiednie typy obiektowe.
-- Dla każdego z typów zaproponować i zdefiniować przykładowe metody.
-- Powiązania referencyjne należy zdefiniować za pomocą typów odniesienia.
-- Tak przygotowany schemat wypełnić danymi z rzeczywistości kotów (dane do opisu elit, plebsu i kont zaproponować samodzielnie)
-- a następnie wykonać przykładowe zapytania SQL, operujące na rozszerzonym schemacie bazy,
-- wykorzystujące referencje (jako realizacje złączeń), podzapytania, grupowanie oraz metody zdefiniowane w ramach typów.
-- Dla każdego z mechanizmów (referencja, podzapytanie, grupowanie) należy przedstawić jeden taki przykład.
-- Zrealizować dodatkowo, w ramach nowego, relacyjno-obiektowego schematu, po dwa wybrane zadania z list nr 2 i 3.

DROP TABLE KOCUR_OBJ;
DROP TABLE ELITA_OBJ;
DROP TABLE PLEBS_OBJ;
DROP TABLE KONTO_OBJ;
DROP TABLE INCYDENT_OBJ;

DROP TYPE KONTO_TYPE;
DROP TYPE INCYDENT_TYPE;
DROP TYPE ELITA_TYPE;
DROP TYPE PLEBS_TYPE;
DROP TYPE KOCUR_TYPE;

CREATE OR REPLACE TYPE KOCUR_TYPE AS OBJECT (
                                              imie VARCHAR2(15),
                                              plec VARCHAR2(1),
                                              pseudo VARCHAR2(15),
                                              funkcja VARCHAR2(10),
                                              szef REF KOCUR_TYPE,
                                              w_stadku_od DATE,
                                              przydzial_myszy NUMBER(3),
                                              myszy_extra NUMBER(3),
                                              nr_bandy NUMBER(2),

                                              MEMBER FUNCTION suma_myszy RETURN NUMBER,
                                              MEMBER FUNCTION pseudo_szefa RETURN NUMBER
                                            );

CREATE OR REPLACE TYPE BODY KOCUR_TYPE IS
  MEMBER FUNCTION suma_myszy RETURN NUMBER IS
    BEGIN
      RETURN NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0);
    END;
  MEMBER FUNCTION pseudo_szefa RETURN NUMBER IS
    tmp VARCHAR2(255);
    BEGIN
      SELECT DEREF(szef).pseudo into tmp from dual;
      RETURN tmp;
    END;
END;

CREATE OR REPLACE TYPE PLEBS_TYPE AS OBJECT (
                                              nr_plebsu NUMBER,
                                              KOCUR REF KOCUR_TYPE,
                                              MEMBER FUNCTION ilu_elitarnym_sluzy RETURN NUMBER
                                            );


CREATE OR REPLACE TYPE ELITA_TYPE AS OBJECT (
                                              nr_elity NUMBER,
                                              KOCUR REF KOCUR_TYPE,
                                              sluga REF PLEBS_TYPE,
                                              MEMBER FUNCTION get_KOCUR RETURN KOCUR_TYPE,
                                              MEMBER FUNCTION imie_kota RETURN VARCHAR2
                                            );

CREATE OR REPLACE TYPE BODY ELITA_TYPE IS
  MEMBER FUNCTION get_KOCUR RETURN KOCUR_TYPE IS
    tmp KOCUR_TYPE;
    BEGIN
      SELECT DEREF(KOCUR) INTO tmp FROM DUAL;
      RETURN tmp;
    END;

  MEMBER FUNCTION imie_kota RETURN VARCHAR2 IS BEGIN
    RETURN SELF.get_KOCUR().imie;
  END;

END;

CREATE OR REPLACE TYPE KONTO_TYPE AS OBJECT (
                                              nr_konta NUMBER,
                                              wlasciciel REF ELITA_TYPE,
                                              data_wprowadzenia DATE,
                                              data_usuniecia DATE,
                                                MEMBER FUNCTION pseudo_wlasciciela RETURN VARCHAR2
                                            );

CREATE OR REPLACE TYPE BODY KONTO_TYPE IS
  MEMBER FUNCTION pseudo_wlasciciela RETURN VARCHAR2 IS
    tmp VARCHAR2(255);
    BEGIN
      SELECT DEREF(DEREF(wlasciciel).KOCUR).pseudo INTO tmp FROM DUAL;
      RETURN tmp;
    END;
END;

CREATE OR REPLACE TYPE INCYDENT_TYPE AS OBJECT (
                                                 nr_incydentu NUMBER(3),
                                                 KOCUR REF KOCUR_TYPE,
                                                 imie_wroga VARCHAR2(25),
                                                 data_incydentu DATE,
                                                 opis_incydentu VARCHAR2(50),

                                                MEMBER FUNCTION ile_lat_od_incydentu RETURN NUMBER
                                               );

CREATE OR REPLACE TYPE BODY INCYDENT_TYPE IS
  MEMBER FUNCTION ile_lat_od_incydentu RETURN NUMBER IS
    BEGIN
      RETURN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_incydentu);
    END;
END;


CREATE TABLE KOCUR_OBJ OF KOCUR_TYPE (
  CONSTRAINT obj_req_kocury CHECK(imie IS NOT NULL),
  CONSTRAINT obj_check_kocury CHECK (plec IN ('M', 'D')),
  CONSTRAINT obj_pk_kocury PRIMARY KEY(pseudo),
  CONSTRAINT obj_fk_szef szef SCOPE IS KOCUR_OBJ
  );

CREATE TABLE PLEBS_OBJ OF PLEBS_TYPE (
  CONSTRAINT obj_pk_plebs PRIMARY KEY (nr_plebsu),
  CONSTRAINT obj_fk_plebs_KOCUR KOCUR SCOPE IS KOCUR_OBJ
  );

CREATE TABLE ELITA_OBJ OF ELITA_TYPE (
  CONSTRAINT obj_pk_elita PRIMARY KEY (nr_elity),
  CONSTRAINT obj_fk_elita_KOCUR KOCUR SCOPE IS KOCUR_OBJ,
  CONSTRAINT obj_fk_sluga sluga SCOPE IS PLEBS_OBJ
  );

CREATE TABLE KONTO_OBJ OF KONTO_TYPE (
  CONSTRAINT obj_pk_konto PRIMARY KEY (nr_konta),
  CONSTRAINT obj_fk_konto_elita wlasciciel SCOPE IS ELITA_OBJ,
  CONSTRAINT obj_reg_konto CHECK(data_wprowadzenia IS NOT NULL),
  CONSTRAINT obj_reg_konto2 CHECK(data_wprowadzenia <= data_usuniecia)
  );

CREATE TABLE INCYDENT_OBJ OF INCYDENT_TYPE (
                                             CONSTRAINT obj_fk_incydent_kocury KOCUR SCOPE IS KOCUR_OBJ,
                                             CONSTRAINT obj_req_incdyent CHECK(data_incydentu IS NOT NULL),
  CONSTRAINT obj_pk_incydent PRIMARY KEY (nr_incydentu)
  );


CREATE OR REPLACE TYPE BODY PLEBS_TYPE IS
  MEMBER FUNCTION ilu_elitarnym_sluzy RETURN NUMBER IS
    suma NUMBER;
    BEGIN
      SELECT COUNT(REF(elita)) into suma FROM ELITA_OBJ elita WHERE elita.sluga.KOCUR.PSEUDO = (SELECT DEREF(SELF.KOCUR).PSEUDO FROM dual);
      return suma;
    END;
END;

INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('MRUCZEK', 'M', 'TYGRYS', 'SZEFUNIO', NULL, '2002-01-01', 103, 33, 1));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('MICKA', 'D', 'LOLA', 'MILUSIA', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='TYGRYS'), '2009-10-14', 25, 47, 1));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('CHYTRY', 'M', 'BOLEK', 'DZIELCZY', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='TYGRYS'), '2002-05-05', 50, NULL, 1));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('KOREK', 'M', 'ZOMBI', 'BANDZIOR', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='TYGRYS'), '2004-03-16', 75, 13, 3));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('BOLEK', 'M', 'LYSY', 'BANDZIOR', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='TYGRYS'), '2006-08-15', 72, 21, 2));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('RUDA', 'D', 'MALA', 'MILUSIA', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='TYGRYS'), '2006-09-17', 22, 42, 1));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('PUCEK', 'M', 'RAFA', 'LOWCZY', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='TYGRYS'), '2006-10-15', 65, NULL, 4));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('SONIA', 'D', 'PUSZYSTA', 'MILUSIA', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='ZOMBI'), '2010-11-18', 20, 35, 3));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('PUNIA', 'D', 'KURKA', 'LOWCZY', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='ZOMBI'), '2008-01-01', 61, NULL, 3));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('JACEK', 'M', 'PLACEK', 'LOWCZY', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='LYSY'), '2008-12-01', 67, NULL, 2));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('BARI', 'M', 'RURA', 'LAPACZ', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='LYSY'), '2009-09-01', 56, NULL, 2));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('ZUZIA', 'D', 'SZYBKA', 'LOWCZY', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='LYSY'), '2006-07-21', 65, NULL, 2));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('BELA', 'D', 'LASKA', 'MILUSIA', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='LYSY'), '2008-02-01', 24, 28, 2));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('LATKA', 'D', 'UCHO', 'KOT', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='RAFA'), '2011-01-01', 40, NULL, 4));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('DUDEK', 'M', 'MALY', 'KOT', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='RAFA'), '2011-05-15', 40, NULL, 4));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('KSAWERY', 'M', 'MAN', 'LAPACZ', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='RAFA'), '2008-07-12', 51, NULL, 4));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('MELA', 'D', 'DAMA', 'LAPACZ', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='RAFA'), '2008-11-01', 51, NULL, 4));
INSERT INTO KOCUR_OBJ VALUES (KOCUR_TYPE('LUCEK', 'M', 'ZERO', 'KOT', (SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='KURKA'), '2010-03-01', 43, NULL, 3));


INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(1,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='TYGRYS'), 'KAZIO', '2004-10-13', 'USILOWAL NABIC NA WIDLY'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(2,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='ZOMBI'), 'SWAWOLNY DYZIO', '2005-03-07', 'WYBIL OKO Z PROCY'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(3,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='BOLEK'), 'KAZIO', '2005-03-29', 'POSZCZUL BURKIEM'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(4,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='SZYBKA'), 'GLUPIA ZOSKA', '2006-09-12', 'UZYLA KOTA JAKO SCIERKI'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(5,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='MALA'), 'CHYTRUSEK', '2007-03-07', 'ZALECAL SIE'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(6,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='TYGRYS'), 'DZIKI BILL', '2007-06-12', 'USILOWAL POZBAWIC ZYCIA'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(7,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='BOLEK'), 'DZIKI BILL', '2007-11-10', 'ODGRYZL UCHO'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(8,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='LASKA'), 'DZIKI BILL', '2008-12-12', 'POGRYZL ZE LEDWO SIE WYLIZALA'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(9,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='LASKA'), 'KAZIO', '2009-01-07', 'ZLAPAL ZA OGON I ZROBIL WIATRAK'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(10,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='DAMA'), 'KAZIO', '2009-02-07', 'CHCIAL OBEDRZEC ZE SKORY'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(11,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='MAN'), 'REKSIO', '2009-04-14', 'WYJATKOWO NIEGRZECZNIE OBSZCZEKAL'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(12,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='LYSY'), 'BETHOVEN', '2009-05-11', 'NIE PODZIELIL SIE SWOJA KASZA'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(13,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='RURA'), 'DZIKI BILL', '2009-09-03', 'ODGRYZL OGON'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(14,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='PLACEK'), 'BAZYLI', '2010-07-12', 'DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(15,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='PUSZYSTA'), 'SMUKLA', '2010-11-19', 'OBRZUCILA SZYSZKAMI'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(16,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='KURKA'), 'BUREK', '2010-12-14', 'POGONIL'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(17,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='MALY'), 'CHYTRUSEK', '2011-07-13', 'PODEBRAL PODEBRANE JAJKA'));
INSERT INTO INCYDENT_OBJ VALUES (INCYDENT_TYPE(18,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='UCHO'), 'SWAWOLNY DYZIO', '2011-07-14', 'OBRZUCIL KAMIENIAMI'));


INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(1,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='LOLA')));
INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(2,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='BOLEK')));
INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(3,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='MALA')));
INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(4,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='PUSZYSTA')));
INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(5,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='PLACEK')));
INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(6,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='RURA')));
INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(7,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='SZYBKA')));
INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(8,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='LASKA')));
INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(9,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='UCHO')));
INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(10,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='MALY')));
INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(11,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='MAN')));
INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(12,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='DAMA')));
INSERT INTO PLEBS_OBJ VALUES (PLEBS_TYPE(13,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='ZERO')));


INSERT INTO ELITA_OBJ VALUES (ELITA_TYPE(1,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='TYGRYS'),(SELECT REF(plebs) FROM PLEBS_OBJ plebs WHERE plebs.KOCUR.PSEUDO='LOLA')));
INSERT INTO ELITA_OBJ VALUES (ELITA_TYPE(2,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='LYSY'),(SELECT REF(plebs) FROM PLEBS_OBJ plebs WHERE plebs.KOCUR.PSEUDO='LASKA')));
INSERT INTO ELITA_OBJ VALUES (ELITA_TYPE(3,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='ZOMBI'),(SELECT REF(plebs) FROM PLEBS_OBJ plebs WHERE plebs.KOCUR.PSEUDO='PUSZYSTA')));
INSERT INTO ELITA_OBJ VALUES (ELITA_TYPE(4,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='RAFA'),(SELECT REF(plebs) FROM PLEBS_OBJ plebs WHERE plebs.KOCUR.PSEUDO='UCHO')));
INSERT INTO ELITA_OBJ VALUES (ELITA_TYPE(5,(SELECT REF(KOCUR) FROM KOCUR_OBJ KOCUR WHERE KOCUR.pseudo='KURKA'),(SELECT REF(plebs) FROM PLEBS_OBJ plebs WHERE plebs.KOCUR.PSEUDO='ZERO')));


INSERT INTO KONTO_OBJ VALUES (KONTO_TYPE(1,(SELECT REF(elita) FROM ELITA_OBJ elita WHERE elita.KOCUR.pseudo='TYGRYS'),'2017-05-11','2017-06-12'));
INSERT INTO KONTO_OBJ VALUES (KONTO_TYPE(2,(SELECT REF(elita) FROM ELITA_OBJ elita WHERE elita.KOCUR.pseudo='LYSY'),'2017-05-11','2017-06-12'));
INSERT INTO KONTO_OBJ VALUES (KONTO_TYPE(3,(SELECT REF(elita) FROM ELITA_OBJ elita WHERE elita.KOCUR.pseudo='ZOMBI'),'2017-05-11','2017-06-12'));
INSERT INTO KONTO_OBJ VALUES (KONTO_TYPE(4,(SELECT REF(elita) FROM ELITA_OBJ elita WHERE elita.KOCUR.pseudo='RAFA'),'2017-05-11','2017-06-12'));
INSERT INTO KONTO_OBJ VALUES (KONTO_TYPE(5,(SELECT REF(elita) FROM ELITA_OBJ elita WHERE elita.KOCUR.pseudo='KURKA'),'2017-05-11','2017-06-12'));
INSERT INTO KONTO_OBJ VALUES (KONTO_TYPE(6,(SELECT REF(elita) FROM ELITA_OBJ elita WHERE elita.KOCUR.pseudo='TYGRYS'),'2017-05-12',null));
INSERT INTO KONTO_OBJ VALUES (KONTO_TYPE(7,(SELECT REF(elita) FROM ELITA_OBJ elita WHERE elita.KOCUR.pseudo='LYSY'),'2017-05-12',null));
INSERT INTO KONTO_OBJ VALUES (KONTO_TYPE(8,(SELECT REF(elita) FROM ELITA_OBJ elita WHERE elita.KOCUR.pseudo='ZOMBI'),'2017-05-12',null));

SELECT KOCUR.PSEUDO, KOCUR.suma_myszy() from KOCUR_OBJ KOCUR;
SELECT  plebs.KOCUR.pseudo, plebs.ilu_elitarnym_sluzy() from PLEBS_OBJ plebs;
SELECT elita.imie_kota() from ELITA_OBJ elita;
SELECT konto.pseudo_wlasciciela() from KONTO_OBJ konto;
SELECT inc.NR_INCYDENTU, inc.ile_lat_od_incydentu() from INCYDENT_OBJ inc

-- Zad. 21. Określić ile kotów w każdej z band posiada wrogów
SELECT inc.KOCUR.NR_BANDY "Nr bandy", COUNT(DISTINCT inc.KOCUR.PSEUDO) "Koty z wrogami"
FROM INCYDENT_OBJ inc
GROUP BY inc.KOCUR.NR_BANDY;

-- Zad. 22. Znaleźć koty (wraz z pełnioną funkcją), które posiadają więcej niż jednego wroga.
SELECT MIN(inc.KOCUR.FUNKCJA) "Funkcja", inc.KOCUR.PSEUDO "Pseudonim kota", COUNT(*) "Liczba wrogow"
FROM INCYDENT_OBJ inc
GROUP BY inc.KOCUR.PSEUDO
HAVING COUNT(*) > 1;

-- Zad. 35. Napisać blok PL/SQL, który wyprowadza na ekran następujące informacje o kocie
-- o pseudonimie wprowadzonym z klawiatury (w zależności od rzeczywistych danych):
-- 'calkowity roczny przydzial myszy >700'
-- 'styczeń jest miesiacem przystapienia do stada'
-- 'imię zawiera litere A' 'nie odpowiada kryteriom'.
-- Powyższe informacje wymienione są zgodnie z hierarchią ważności. Każdą wprowadzaną informację poprzedzić imieniem kota.
DECLARE
  myszy                NUMBER;
  w_stadku             KOCUR_OBJ.W_STADKU_OD%type;
  imie_kota            KOCUR_OBJ.IMIE%type;
  ps                   KOCUR_OBJ.PSEUDO%type := &ps;
  nie_spelnia_warunkow BOOLEAN := true;
BEGIN
  SELECT kocur.suma_myszy() * 12, kocur.W_STADKU_OD, kocur.IMIE into myszy, w_stadku, imie_kota
  FROM KOCUR_OBJ kocur
  WHERE PSEUDO = ps;
  IF myszy > 700
  THEN
    DBMS_OUTPUT.PUT_LINE(imie_kota || ': Calkowity roczny przydzial myszy >700');
    nie_spelnia_warunkow := false;
  end if;
  if EXTRACT(MONTH FROM w_stadku) = 1
  THEN
    DBMS_OUTPUT.PUT_LINE(imie_kota || ': Styczen jest miesiacem przystapienia do stada');
    nie_spelnia_warunkow := false;
  end if;
  if imie_kota like '%A%'
  THEN
    DBMS_OUTPUT.PUT_LINE(imie_kota || ': imię zawiera litere A');
    nie_spelnia_warunkow := false;
  end if;
  if nie_spelnia_warunkow = true
  then
    DBMS_OUTPUT.PUT_LINE(imie_kota || ': Nie spelnia warunkow');
  end if;
end;

-- Zad. 37. Napisać blok, który powoduje wybranie w pętli kursorowej FOR pięciu kotów o najwyższym całkowitym przydziale myszy.
-- Wynik wyświetlić na ekranie.
declare
  cursor kursor is select *
                   from (select KOCUR.PSEUDO, nvl(KOCUR.PRZYDZIAL_MYSZY, 0) + nvl(KOCUR.MYSZY_EXTRA, 0) "ZJADA"
                         from KOCUR_OBJ KOCUR
                         order by "ZJADA" DESC)
                   where rownum <= 5;
  licznik NUMBER := 1;
begin
  DBMS_OUTPUT.PUT_LINE(RPAD('Nr', 4) || RPAD('Psedonim', 10) || LPAD('Zjada', 5));
  dbms_output.put_line(LPAD(' ', 20, '-'));
  for rekord in kursor
    loop
      DBMS_OUTPUT.PUT_LINE(RPAD(licznik, 4) || RPAD(rekord.PSEUDO, 10) || LPAD(rekord.ZJADA, 5));
      licznik := licznik + 1;
    end loop;
end;

-- todo Zad. 48.* Rozszerzyć relacyjną bazę danych kotów o dodatkowe relacje opisujące elitę, plebs i konta elity (patrz opis z zad. 47)
-- a następnie zdefiniować "nakładkę", w postaci perspektyw obiektowych (bez odpowiedników relacji Funkcje, Bandy, Wrogowie),
-- na tak zmodyfikowaną bazę. Odpowiadające relacjom typy obiektowe mają zawierać przykładowe metody (mogą to być metody z zad. 47).
-- Zamodelować wszystkie powiązania referencyjne z wykorzystaniem identyfikatorów OID i funkcji MAKE_REF.
-- Relacje wypełnić przykładowymi danymi (mogą to być dane z zad. 47).
-- Dla tak przygotowanej bazy wykonać wszystkie zapytania SQL i bloki PL/SQL zrealizowane w ramach zad. 47.


-- Zad. 49. W związku z wejściem do Unii Europejskiej konieczna stała się szczegółowa ewidencja myszy upolowanych i spożywanych.
-- Należało więc odnotowywać zarówno kota, który mysz upolował (wraz z datą upolowania) jak i kota,
-- który mysz zjadł (wraz z datą „wypłaty”). Dodatkowo istotna stała się waga myszy (waga ta musi spełniać Unijną normę (normę tę proszę ustalić)). C
-- o najgorsze, jednak, dane należało uzupełnić w tył zaczynając od 1 stycznia 2004.
-- Niestety, jak to czasami bywa, nastąpiło „niewielkie” opóźnienie w realizacji programu ewidencjonującego upolowane i zjedzone myszy.
-- Dziwnym zbiegiem okoliczności ewidencja ta stała się możliwa dopiero na dzień przed terminem oddawania bieżącej listy.
-- Napisać blok (bloki), który zrealizuje ewidencję, a więc:
-- todo a. zmodyfikuje schemat bazy danych o nową relację Myszy z atrybutami:
-- nr_myszy (klucz główny), lowca (klucz obcy), zjadacz (klucz obcy), waga_myszy, data_zlowienia, data_wydania (zawsze ostatnia środa miesiąca),
-- todo b. wypełni relację Myszy sztucznie wygenerowanymi danymi, od 1 stycznia 2004 począwszy,

-- na dniu poprzednim w stosunku do terminu oddania bieżącej listy skończywszy.
-- Liczba wpisanych myszy, upolowanych w konkretnym miesiącu, ma być zgodna z liczbą myszy,
-- które koty otrzymały w ramach „wypłaty” w tym miesiącu (z uwzględnieniem myszy extra).
-- W trakcie uzupełniania danych należy przyjąć założenie, że każdy kot jest w stanie upolować w ciągu miesiąca
-- liczbę myszy równą liczbie myszy spożywanych średnio w ciągu miesiąca przez każdego kota
-- („zagospodarować” ewentualne nadwyżki związane z zaokrągleniami).
-- Daty złowienia myszy mają być ustawione „w miarę” równomiernie w ciągu całego miesiąca. Datą wydania ma być ostatnia środa każdego miesiąca.
-- W rozwiązaniu należy wykorzystać pierwotny dynamiczny SQL (tworzenie nowej relacji) oraz pierwotne wiązanie masowe
-- (wypełnianie relacji wygenerowanymi danymi). Od daty bieżącej począwszy mają być już wpisywane rzeczywiste dane dotyczące upolowanych myszy.
-- Należy więc przygotować procedurę, która umożliwi przyjęcie na stan myszy upolowanych w ciągu dnia przez konkretnego kota
-- (założyć, że dane o upolowanych w ciągu dnia myszach dostępne są w, indywidualnej dla każdego kota, zewnętrznej relacji)
-- oraz procedurę, która umożliwi co miesięczną wypłatę (myszy mają być przydzielane po jednej kolejnym kotom
-- w kolejności zgodnej z pozycją kota w hierarchii stada aż do uzyskania przysługującego przydziału
-- lub do momentu wyczerpania się zapasów). W obu procedurach należy wykorzystać pierwotne wiązanie masowe.