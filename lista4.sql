-- ctrl + f8 = enable dbms output
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SESSION SET NLS_DATE_LANGUAGE = 'ENGLISH';

-- Zad. 47. Założyć, że w stadzie kotów pojawił się podział na elitę i na plebs.
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

CREATE OR REPLACE TYPE KONTO_TYPE AS OBJECT (
  nr_konta NUMBER,
  wlasciciel REF ELITA_TYPE,
  data_wprowadzenia DATE,
  data_usuniecia DATE,

  MEMBER FUNCTION pseudo_wlasciciela RETURN VARCHAR2
);

CREATE OR REPLACE TYPE INCYDENT_TYPE AS OBJECT (
  nr_incydentu NUMBER(3),
  KOCUR REF KOCUR_TYPE,
  imie_wroga VARCHAR2(25),
  data_incydentu DATE,
  opis_incydentu VARCHAR2(50),

  MEMBER FUNCTION ile_lat_od_incydentu RETURN NUMBER
);

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

CREATE OR REPLACE TYPE BODY KONTO_TYPE IS
  MEMBER FUNCTION pseudo_wlasciciela RETURN VARCHAR2 IS
    tmp VARCHAR2(255);
    BEGIN
      SELECT DEREF(DEREF(wlasciciel).KOCUR).pseudo INTO tmp FROM DUAL;
      RETURN tmp;
    END;
END;


CREATE OR REPLACE TYPE BODY INCYDENT_TYPE IS
  MEMBER FUNCTION ile_lat_od_incydentu RETURN NUMBER IS
    BEGIN
      RETURN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM data_incydentu);
    END;
END;

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
SELECT inc.NR_INCYDENTU, inc.ile_lat_od_incydentu() from INCYDENT_OBJ inc;

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

-------------------------------------------------------------------------------------------------------------------------------
-- Zad. 48.* Rozszerzyć relacyjną bazę danych kotów o dodatkowe relacje opisujące elitę, plebs i konta elity (patrz opis z zad. 47)
-- a następnie zdefiniować "nakładkę", w postaci perspektyw obiektowych (bez odpowiedników relacji Funkcje, Bandy, Wrogowie),
-- na tak zmodyfikowaną bazę. Odpowiadające relacjom typy obiektowe mają zawierać przykładowe metody (mogą to być metody z zad. 47).
-- Zamodelować wszystkie powiązania referencyjne z wykorzystaniem identyfikatorów OID i funkcji MAKE_REF.
-- Relacje wypełnić przykładowymi danymi (mogą to być dane z zad. 47).
-- Dla tak przygotowanej bazy wykonać wszystkie zapytania SQL i bloki PL/SQL zrealizowane w ramach zad. 47.

DROP TABLE ELITY CASCADE CONSTRAINTS;
DROP TABLE PLEBSY CASCADE CONSTRAINTS;
DROP TABLE KONTA CASCADE CONSTRAINTS;

CREATE TABLE PLEBSY
(
  nr_plebsu NUMBER CONSTRAINT pk_plebsu PRIMARY KEY,
  kocur     VARCHAR2(15) CONSTRAINT fk_plebsy_kocury REFERENCES KOCURY(pseudo)
);

CREATE TABLE ELITY
(
  nr_elity NUMBER CONSTRAINT pk_elity PRIMARY KEY,
  kocur    VARCHAR2(15) CONSTRAINT fk_elity_kocury REFERENCES KOCURY(pseudo),
  sluga    NUMBER CONSTRAINT fk_elity_plebsy REFERENCES PLEBSY(nr_plebsu)
);

CREATE TABLE KONTA
(
  nr_konta          NUMBER CONSTRAINT pk_konta PRIMARY KEY,
  wlasciciel        NUMBER CONSTRAINT fk_konta_elity REFERENCES ELITY(nr_elity),
  data_wprowadzenia DATE CONSTRAINT req_konta NOT NULL,
  data_usuniecia    DATE,
  CONSTRAINT check_konta_1 CHECK(data_wprowadzenia <= data_usuniecia)
);

INSERT ALL
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (1,'LOLA')
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (2,'BOLEK')
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (3,'MALA')
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (4,'PUSZYSTA')
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (5,'PLACEK')
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (6,'RURA')
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (7,'SZYBKA')
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (8,'LASKA')
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (9,'UCHO')
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (10,'MALY')
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (11,'MAN')
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (12,'DAMA')
INTO PLEBSY(NR_PLEBSU,KOCUR) VALUES (13,'ZERO')


INTO ELITY(nr_elity,kocur,sluga) VALUES(1,'TYGRYS',1)
INTO ELITY(nr_elity,kocur,sluga) VALUES(2,'LYSY',8)
INTO ELITY(nr_elity,kocur,sluga) VALUES(3,'ZOMBI',4)
INTO ELITY(nr_elity,kocur,sluga) VALUES(4,'RAFA',9)
INTO ELITY(nr_elity,kocur,sluga) VALUES(5,'KURKA',13)


INTO KONTA(nr_konta,wlasciciel,data_wprowadzenia,data_usuniecia) VALUES (1,1,'2017-05-11','2017-06-12')
INTO KONTA(nr_konta,wlasciciel,data_wprowadzenia,data_usuniecia) VALUES (2,2,'2017-05-11','2017-06-12')
INTO KONTA(nr_konta,wlasciciel,data_wprowadzenia,data_usuniecia) VALUES (3,3,'2017-05-11','2017-06-12')
INTO KONTA(nr_konta,wlasciciel,data_wprowadzenia,data_usuniecia) VALUES (4,4,'2017-05-11','2017-06-12')
INTO KONTA(nr_konta,wlasciciel,data_wprowadzenia,data_usuniecia) VALUES (5,5,'2017-05-11','2017-06-12')
INTO KONTA(nr_konta,wlasciciel,data_wprowadzenia,data_usuniecia) VALUES (6,1,'2017-05-12',null)
INTO KONTA(nr_konta,wlasciciel,data_wprowadzenia,data_usuniecia) VALUES (7,2,'2017-05-12',null)
INTO KONTA(nr_konta,wlasciciel,data_wprowadzenia,data_usuniecia) VALUES (8,3,'2017-05-12',null)
SELECT * FROM dual;


CREATE OR REPLACE VIEW KOCURY_NAKLADKA OF KOCUR_TYPE
  WITH OBJECT IDENTIFIER (pseudo) AS
SELECT imie,
       plec,
       pseudo,
       funkcja,
       MAKE_REF(KOCURY_NAKLADKA, szef),
       w_stadku_od,
       przydzial_myszy,
       myszy_extra,
       nr_bandy
FROM KOCURY;

CREATE OR REPLACE VIEW INCYDENTY_NAKLADKA OF INCYDENT_TYPE
  WITH OBJECT IDENTIFIER (nr_incydentu) AS
SELECT row_number() over (order by data_incydentu),
       MAKE_REF(KOCURY_NAKLADKA, pseudo) pseudo,
       imie_wroga,
       data_incydentu,
       opis_incydentu
FROM WROGOWIE_KOCUROW;

CREATE OR REPLACE VIEW PLEBS_NAKLADKA OF PLEBS_TYPE
  WITH OBJECT IDENTIFIER (nr_plebsu) AS
SELECT nr_plebsu,
       MAKE_REF(KOCURY_NAKLADKA, kocur) kocur
FROM PLEBSY;

CREATE OR REPLACE VIEW ELITA_NAKLADKA OF ELITA_TYPE
  WITH OBJECT IDENTIFIER (nr_elity) AS
SELECT nr_elity,
       MAKE_REF(KOCURY_NAKLADKA, kocur) kocur,
       MAKE_REF(PLEBS_NAKLADKA, sluga)  sluga
FROM ELITY;

CREATE OR REPLACE VIEW KONTA_NAKLADKA OF KONTO_TYPE
  WITH OBJECT IDENTIFIER (nr_konta) AS
SELECT nr_konta,
       MAKE_REF(ELITA_NAKlADKA, wlasciciel) wlasciciel,
       data_wprowadzenia,
       data_usuniecia
FROM KONTA;


SELECT KOCUR.PSEUDO, KOCUR.suma_myszy() from KOCURY_NAKLADKA KOCUR;
SELECT  plebs.KOCUR.pseudo, plebs.ilu_elitarnym_sluzy() from PLEBS_NAKLADKA plebs;
SELECT elita.imie_kota() from ELITA_NAKLADKA elita;
SELECT konto.pseudo_wlasciciela() from KONTA_NAKLADKA konto;
SELECT inc.NR_INCYDENTU, inc.ile_lat_od_incydentu() from INCYDENTY_NAKLADKA inc;

-- Zad. 21. Określić ile kotów w każdej z band posiada wrogów
SELECT inc.KOCUR.NR_BANDY "Nr bandy", COUNT(DISTINCT inc.KOCUR.PSEUDO) "Koty z wrogami"
FROM INCYDENTY_NAKLADKA inc
GROUP BY inc.KOCUR.NR_BANDY;

-- Zad. 22. Znaleźć koty (wraz z pełnioną funkcją), które posiadają więcej niż jednego wroga.
SELECT MIN(inc.KOCUR.FUNKCJA) "Funkcja", inc.KOCUR.PSEUDO "Pseudonim kota", COUNT(*) "Liczba wrogow"
FROM INCYDENTY_NAKLADKA inc
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
  FROM KOCURY_NAKLADKA kocur
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
                         from KOCURY_NAKLADKA KOCUR
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

-------------------------------------------------------------------------------------------------------------------------------
-- Zad. 49. W związku z wejściem do Unii Europejskiej konieczna stała się szczegółowa ewidencja myszy upolowanych i spożywanych.
-- Należało więc odnotowywać zarówno kota, który mysz upolował (wraz z datą upolowania) jak i kota,
-- który mysz zjadł (wraz z datą „wypłaty”). Dodatkowo istotna stała się waga myszy (waga ta musi spełniać Unijną normę (normę tę proszę ustalić)). C
-- o najgorsze, jednak, dane należało uzupełnić w tył zaczynając od 1 stycznia 2004.
-- Niestety, jak to czasami bywa, nastąpiło „niewielkie” opóźnienie w realizacji programu ewidencjonującego upolowane i zjedzone myszy.
-- Dziwnym zbiegiem okoliczności ewidencja ta stała się możliwa dopiero na dzień przed terminem oddawania bieżącej listy.
-- Napisać blok (bloki), który zrealizuje ewidencję, a więc:
-- a. zmodyfikuje schemat bazy danych o nową relację Myszy z atrybutami:
-- nr_myszy (klucz główny), lowca (klucz obcy), zjadacz (klucz obcy), waga_myszy, data_zlowienia, data_wydania (zawsze ostatnia środa miesiąca),
-- b. wypełni relację Myszy sztucznie wygenerowanymi danymi, od 1 stycznia 2004 począwszy,
-- na dniu poprzednim w stosunku do terminu oddania bieżącej listy skończywszy.
-- Liczba wpisanych myszy, upolowanych w konkretnym miesiącu, ma być zgodna z liczbą myszy,
-- które koty otrzymały w ramach „wypłaty” w tym miesiącu (z uwzględnieniem myszy extra).
-- W trakcie uzupełniania danych należy przyjąć założenie, że każdy kot jest w stanie upolować w ciągu miesiąca
-- liczbę myszy równą liczbie myszy spożywanych średnio w ciągu miesiąca przez każdego kota
-- („zagospodarować” ewentualne nadwyżki związane z zaokrągleniami).
-- Daty złowienia myszy mają być ustawione „w miarę” równomiernie w ciągu całego miesiąca. Datą wydania ma być ostatnia środa każdego miesiąca.
-- W rozwiązaniu należy wykorzystać pierwotny dynamiczny SQL (tworzenie nowej relacji) oraz pierwotne wiązanie masowe (wypełnianie relacji wygenerowanymi danymi).

-- Od daty bieżącej począwszy mają być już wpisywane rzeczywiste dane dotyczące upolowanych myszy.
-- Należy więc przygotować procedurę, która umożliwi przyjęcie na stan myszy upolowanych w ciągu dnia przez konkretnego kota
-- (założyć, że dane o upolowanych w ciągu dnia myszach dostępne są w, indywidualnej dla każdego kota, zewnętrznej relacji)
-- oraz procedurę, która umożliwi co miesięczną wypłatę (myszy mają być przydzielane po jednej kolejnym kotom
-- w kolejności zgodnej z pozycją kota w hierarchii stada aż do uzyskania przysługującego przydziału
-- lub do momentu wyczerpania się zapasów). W obu procedurach należy wykorzystać pierwotne wiązanie masowe.
drop table myszy cascade constraints;

-- stwórz tabelę myszy
CREATE OR REPLACE PROCEDURE stworz_tabele_myszy AUTHID CURRENT_USER IS
  czy_tabela_myszy_istnieje NUMBER := 0;
BEGIN
  select count(*) into czy_tabela_myszy_istnieje from user_tables where table_name = 'MYSZY';
  IF czy_tabela_myszy_istnieje = 0 then
    EXECUTE IMMEDIATE 'CREATE TABLE MYSZY(
nr_myszy NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) CONSTRAINT pk_myszy PRIMARY KEY,
lowca VARCHAR2(15) CONSTRAINT fk_myszy_kocury_1 REFERENCES KOCURY(pseudo),
zjadacz VARCHAR2(15) CONSTRAINT fk_myszy_kocury_2 REFERENCES KOCURY(pseudo),
waga_myszy NUMBER(3) CONSTRAINT check_myszy_1 CHECK (waga_myszy BETWEEN 10 AND 100),
data_zlowienia DATE CONSTRAINT req_myszy_1 NOT NULL,
data_wydania DATE,
CONSTRAINT check_myszy_2 CHECK(data_zlowienia <= data_wydania)
)';
  end if;

  EXCEPTION
  WHEN OTHERS
  THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

-- wypełnij danymi archiwalnymi
-- 2019-01-17 - czwartek
-- 2004-01-01 - czwartek
DECLARE
  TYPE wiersz_kota IS RECORD (pseudo kocury.pseudo%TYPE, myszy NUMBER(3));
  TYPE tab_kotow IS TABLE OF wiersz_kota INDEX BY BINARY_INTEGER;
  TYPE wiersz_myszy IS RECORD (lowca myszy.lowca%TYPE, zjadacz myszy.zjadacz%TYPE, waga_myszy myszy.waga_myszy%TYPE,
    data_zlowienia myszy.data_zlowienia%TYPE, data_wydania myszy.data_wydania%TYPE);
  TYPE tab_myszy IS TABLE OF wiersz_myszy INDEX BY BINARY_INTEGER;

  koty                    tab_kotow;
  dane_myszy              tab_myszy;
  pierwszy_dzien_lowienia DATE           := '2004-01-01';
  dzien_wyplaty           DATE           := (next_day(last_day('2004-01-01') - 7, 'WEDNESDAY'));
  liczba_myszy_w_miesiacu NUMBER;
  myszy_do_rozdania       BINARY_INTEGER := 0;
  rozdane_myszy           BINARY_INTEGER := 0;
  ostatni_dzien_ewidencji DATE           := '2019-01-16';
BEGIN
  stworz_tabele_myszy();

  WHILE dzien_wyplaty <= (next_day(last_day(ostatni_dzien_ewidencji) - 7, 'WEDNESDAY'))
    LOOP
      SELECT pseudo,
             nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0)
             BULK COLLECT INTO koty
      FROM kocury
      WHERE w_stadku_od <= pierwszy_dzien_lowienia;

      SELECT CEIL(AVG(nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0)))
             INTO liczba_myszy_w_miesiacu
      FROM kocury
      WHERE w_stadku_od <= pierwszy_dzien_lowienia;

      IF dzien_wyplaty > ostatni_dzien_ewidencji then
        liczba_myszy_w_miesiacu :=
            ROUND(liczba_myszy_w_miesiacu * (ostatni_dzien_ewidencji - pierwszy_dzien_lowienia) / 30);
      end if;

      FOR j IN 1..koty.COUNT
        LOOP
          FOR k IN 1..liczba_myszy_w_miesiacu
            LOOP
              dane_myszy(myszy_do_rozdania).lowca := koty(j).pseudo;
              dane_myszy(myszy_do_rozdania).waga_myszy := dbms_random.value(10, 100);
              IF dzien_wyplaty > ostatni_dzien_ewidencji then
                dane_myszy(myszy_do_rozdania).data_zlowienia := TRUNC(pierwszy_dzien_lowienia + dbms_random.value(0,
                                                                                                                  ostatni_dzien_ewidencji - pierwszy_dzien_lowienia));
              else
                dane_myszy(myszy_do_rozdania).data_zlowienia :=
                    TRUNC(pierwszy_dzien_lowienia + dbms_random.value(0, 27));
              end if;

              dane_myszy(myszy_do_rozdania).data_wydania := dzien_wyplaty;
              myszy_do_rozdania := myszy_do_rozdania + 1;

            END LOOP;
        END LOOP;

      IF dzien_wyplaty <= ostatni_dzien_ewidencji then
        FOR j IN 1..koty.COUNT
          LOOP
            FOR k IN 1..koty(j).myszy
              LOOP
                dane_myszy(rozdane_myszy).zjadacz := koty(j).pseudo;
                rozdane_myszy := rozdane_myszy + 1;
              END LOOP;
          END LOOP;

        WHILE rozdane_myszy < myszy_do_rozdania
          LOOP
            dane_myszy(rozdane_myszy).zjadacz := 'TYGRYS';
            rozdane_myszy := rozdane_myszy + 1;
          END LOOP;
      END IF;

      pierwszy_dzien_lowienia := dzien_wyplaty + 1;
      dzien_wyplaty := (next_day(last_day(add_months(dzien_wyplaty, 1)) - 7, 'WEDNESDAY'));
    END LOOP;

  FORALL j IN 0..(dane_myszy.count - 1) SAVE EXCEPTIONS
    INSERT INTO myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania)
    VALUES (dane_myszy(j).lowca, dane_myszy(j).zjadacz, dane_myszy(j).waga_myszy, dane_myszy(j).data_zlowienia,
            dane_myszy(j).data_wydania);

  EXCEPTION
  WHEN OTHERS
  THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

CREATE OR REPLACE PROCEDURE przechowaj_na_prywatnym_koncie(pseudo KOCURY.PSEUDO%TYPE, waga_myszy MYSZY.WAGA_MYSZY%TYPE,
                                                           data_zlowienia MYSZY.DATA_ZLOWIENIA%TYPE) AUTHID CURRENT_USER IS
  nazwa_konta VARCHAR2(255) := 'KONTO_' || pseudo;
  czy_konto_istnieje NUMBER := 0;
BEGIN
  select count(*) into czy_konto_istnieje from user_tables where table_name = nazwa_konta;
  if czy_konto_istnieje = 0 then
    EXECUTE IMMEDIATE 'CREATE TABLE ' || nazwa_konta || '(
nr_myszy NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) CONSTRAINT pk_' || nazwa_konta || ' PRIMARY KEY,
waga_myszy NUMBER(3) CONSTRAINT check_' || nazwa_konta || ' CHECK (waga_myszy BETWEEN 10 AND 100),
data_zlowienia DATE CONSTRAINT req_' || nazwa_konta || ' NOT NULL)';
  end if;
  EXECUTE IMMEDIATE 'INSERT INTO ' || nazwa_konta || '(waga_myszy, data_zlowienia) VALUES (' || waga_myszy || ', ''' ||
                    data_zlowienia || ''' )';

end;


CREATE OR REPLACE PROCEDURE przyjmij_myszy_na_stan(pseudo KOCURY.PSEUDO%TYPE) IS
  TYPE wiersz_konta_kota IS RECORD (waga_myszy MYSZY.WAGA_MYSZY%TYPE, data_zlowienia MYSZY.DATA_ZLOWIENIA%TYPE);
  TYPE tab_konta_kota IS TABLE OF wiersz_konta_kota INDEX BY BINARY_INTEGER;

  zapasy_kota tab_konta_kota;
  nazwa_konta VARCHAR2(255) := 'KONTO_' || pseudo;
  czy_konto_istnieje NUMBER := 0;
BEGIN
  select count(*) into czy_konto_istnieje from user_tables where table_name = nazwa_konta;
  if czy_konto_istnieje > 0 then
    --     EXECUTE IMMEDIATE 'insert into MYSZY(LOWCA, WAGA_MYSZY, DATA_ZLOWIENIA) select ''' || pseudo ||
    --                       ''', waga_myszy, data_zlowienia from ' || nazwa_konta;
    EXECUTE IMMEDIATE 'select waga_myszy, data_zlowienia from ' || nazwa_konta bulk collect into zapasy_kota;

    FORALL j IN 1..(zapasy_kota.count) SAVE EXCEPTIONS
      INSERT INTO myszy(lowca, waga_myszy, data_zlowienia)
      VALUES (pseudo, zapasy_kota(j).waga_myszy, zapasy_kota(j).data_zlowienia);

    EXECUTE IMMEDIATE 'delete from ' || nazwa_konta;
    DBMS_OUTPUT.PUT_LINE('Myszy przyjęto na stan');
  else
    DBMS_OUTPUT.PUT_LINE('Kot o wybranym pseudo nie posiada konta');
  end if;

  --   EXCEPTION
  --   WHEN OTHERS
  --   THEN
  --     DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;


CREATE OR REPLACE PROCEDURE wyplac_myszy(dzien_wyplaty DATE) IS
  TYPE wiersz_kota IS RECORD (pseudo kocury.pseudo%TYPE, myszy NUMBER(3));
  TYPE tab_kotow IS TABLE OF wiersz_kota INDEX BY BINARY_INTEGER;
  TYPE wiersz_myszy IS RECORD (nr_myszy myszy.NR_MYSZY%TYPE);
  TYPE tab_myszy IS TABLE OF wiersz_myszy INDEX BY BINARY_INTEGER;
  TYPE wiersz_kolejka IS RECORD (nr_myszy myszy.NR_MYSZY%TYPE, pseudo kocury.pseudo%TYPE);
  TYPE tab_kolejka IS TABLE OF wiersz_kolejka INDEX BY BINARY_INTEGER;

  koty tab_kotow;
  dane_myszy tab_myszy;
  kolejka tab_kolejka;

  dzien_poprzedniej_wyplaty DATE := (next_day(last_day(add_months(dzien_wyplaty, -1)) - 7, 'WEDNESDAY'));
  ile_myszy_potrzeba NUMBER := 0;
  wskaznik_kota NUMBER := 1;

  bledna_data EXCEPTION;
BEGIN

  if dzien_wyplaty <> (next_day(last_day(dzien_wyplaty) - 7, 'WEDNESDAY')) then
    raise bledna_data;
  end if;

  SELECT NR_MYSZY bulk collect into dane_myszy
  from myszy
  where ZJADACZ is null
    and DATA_WYDANIA is null
    and DATA_ZLOWIENIA > dzien_poprzedniej_wyplaty
    and DATA_ZLOWIENIA <= dzien_wyplaty
  order by DATA_ZLOWIENIA, NR_MYSZY;

  SELECT pseudo,
         nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0) "myszy"
         BULK COLLECT INTO koty
  FROM kocury
  WHERE w_stadku_od <= dzien_wyplaty
  START WITH szef IS NULL
  CONNECT BY PRIOR pseudo = szef
  ORDER BY LEVEL ASC, "myszy" DESC;

  for i in 1..koty.COUNT
    loop
      ile_myszy_potrzeba := ile_myszy_potrzeba + koty(i).myszy;
    end loop;

  for i in 1..dane_myszy.COUNT
    loop
      if ile_myszy_potrzeba = 0 then
        exit;
      end if;
      while koty(wskaznik_kota).myszy = 0
        loop
          wskaznik_kota := wskaznik_kota + 1;
          if wskaznik_kota > koty.COUNT then
            wskaznik_kota := 1;
          end if;
        end loop;
      kolejka(i).pseudo := koty(wskaznik_kota).pseudo;
      kolejka(i).nr_myszy := dane_myszy(i).nr_myszy;
      koty(wskaznik_kota).myszy := koty(wskaznik_kota).myszy - 1;
      ile_myszy_potrzeba := ile_myszy_potrzeba - 1;

      wskaznik_kota := wskaznik_kota + 1;
      if wskaznik_kota > koty.COUNT then
        wskaznik_kota := 1;
      end if;
    end loop;

  while kolejka.COUNT < dane_myszy.count
    loop
      kolejka(kolejka.COUNT + 1).pseudo := 'TYGRYS';
      kolejka(kolejka.COUNT).nr_myszy := dane_myszy(kolejka.COUNT).nr_myszy;
    end loop;

  forall i in 1..kolejka.count SAVE EXCEPTIONS
    UPDATE MYSZY m
    set m.ZJADACZ      = kolejka(i).pseudo,
        m.DATA_WYDANIA = dzien_wyplaty
    where NR_MYSZY = kolejka(i).nr_myszy;


END;



----------------------------------------------------------------------------------------------------
-- pomocnicze
----------------------------------------------------------------------------------------------------

--   begin
--     select pseudo from kocury order by POLICZ_SZEFOW(pseudo);
--   end;

-- create or replace function policz_szefow(podane_pseudo KOCURY.PSEUDO%TYPE) RETURN NUMBER IS
--   --     declare
--   ps VARCHAR2(15);
--   licznik NUMBER := 0;
--
-- begin
--   select szef into ps from KOCURY where pseudo = podane_pseudo;
--   while ps is not null
--     loop
--       licznik := licznik + 1;
--       select szef into ps from KOCURY where pseudo = ps;
--     end loop;
--   return licznik;
-- end;

  begin
    wyplac_myszy('2019-01-30');
  end;
  SELECT  * FROM KOCURY;

BEGIN
  SELECT * FROM dba_tables;
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('NOPE');
    IF SQLCODE != -942 THEN
      DBMS_OUTPUT.PUT_LINE('NOPE');
    END IF;

end;


declare
  CURSOR kursor is select table_name
                   from user_tables
                   where table_name like 'KONTO\_%' ESCAPE '\';
begin
  for rekord in kursor
    loop
      execute immediate 'drop table ' || rekord.table_name;
    end loop;
end;

select * from konto_tygrys;
begin
  for i in 1..100 loop
  przechowaj_na_prywatnym_koncie('TYGRYS', 10, SYSDATE-45);
  end loop;
end;

begin
  przyjmij_myszy_na_stan('TYGRYS');
end;
delete from myszy;
insert into MYSZY(LOWCA, WAGA_MYSZY, DATA_ZLOWIENIA) select 'TYGRYS', waga_myszy, data_zlowienia from KONTO_TYGRYS;
select count(*) from user_tables where table_name = 'KOCURY';
select * from myszy order by NR_MYSZY;

select MAX(NR_MYSZY) from myszy;
select * from myszy  order by DATA_ZLOWIENIA desc;