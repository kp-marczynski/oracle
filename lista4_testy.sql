-- Zad. 47.

SELECT KOCUR.PSEUDO, KOCUR.suma_myszy()
from KOCUR_OBJ KOCUR;

SELECT plebs.KOCUR.pseudo, plebs.ilu_elitarnym_sluzy()
from PLEBS_OBJ plebs;

SELECT elita.imie_kota()
from ELITA_OBJ elita;

SELECT konto.pseudo_wlasciciela()
from KONTO_OBJ konto;

SELECT inc.NR_INCYDENTU, inc.ile_lat_od_incydentu()
from INCYDENT_OBJ inc;

SELECT *
from (SELECT inc.KOCUR.pseudo, count(*) "liczba incydentow"
      from INCYDENT_OBJ inc
      GROUP BY inc.KOCUR.PSEUDO
      ORDER BY "liczba incydentow" desc, inc.KOCUR.PSEUDO)
where rownum <= 5;

-- Zad. 19. Dla kotów pełniących funkcję KOT i MILUSIA wyświetlić w kolejności hierarchii imiona wszystkich ich szefów.
-- Zadanie rozwiązać na trzy sposoby:
-- a. z wykorzystaniem tylko złączeń,
SELECT K1.IMIE           "Imie",
       K1.FUNKCJA        "Funkcja",
       NVL(K1.SZEF.IMIE, ' ') "Szef 1",
       NVL(K1.SZEF.SZEF.IMIE, ' ') "Szef 2",
       NVL(K1.SZEF.SZEF.SZEF.IMIE, ' ') "Szef 3"
FROM KOCUR_OBJ K1
WHERE K1.FUNKCJA IN ('KOT', 'MILUSIA');

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
  nie_spelnia_warunkow BOOLEAN               := true;
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
-- Zad. 48.*

SELECT KOCUR.PSEUDO, KOCUR.suma_myszy()
from KOCURY_NAKLADKA KOCUR;
SELECT plebs.KOCUR.pseudo, plebs.ilu_elitarnym_sluzy()
from PLEBS_NAKLADKA plebs;
SELECT elita.imie_kota()
from ELITA_NAKLADKA elita;
SELECT konto.pseudo_wlasciciela()
from KONTA_NAKLADKA konto;
SELECT inc.NR_INCYDENTU, inc.ile_lat_od_incydentu()
from INCYDENTY_NAKLADKA inc;

SELECT *
from (SELECT inc.KOCUR.pseudo, count(*) "liczba incydentow"
      from INCYDENTY_NAKLADKA inc
      GROUP BY inc.KOCUR.PSEUDO
      ORDER BY "liczba incydentow" desc, inc.KOCUR.PSEUDO)
where rownum <= 5;

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
  nie_spelnia_warunkow BOOLEAN               := true;
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
-- Zad. 49.

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
SELECT *
FROM KOCURY;

BEGIN
  SELECT * FROM dba_tables;
  EXCEPTION
  WHEN OTHERS
  THEN
    DBMS_OUTPUT.PUT_LINE('NOPE');
    IF SQLCODE != -942 THEN
      DBMS_OUTPUT.PUT_LINE('NOPE');
    END IF;

end;


select *
from konto_tygrys;


begin
  for i in 1..100
    loop
      przechowaj_na_prywatnym_koncie('TYGRYS', 10, SYSDATE - 45);
    end loop;
end;

begin
  przyjmij_myszy_na_stan('TYGRYS');
end;


delete
from myszy;


insert into MYSZY(LOWCA, WAGA_MYSZY, DATA_ZLOWIENIA)
select 'TYGRYS', waga_myszy, data_zlowienia
from KONTO_TYGRYS;


select count(*)
from user_tables
where table_name = 'KOCURY';


select *
from myszy
order by NR_MYSZY;

select MAX(NR_MYSZY)
from myszy;


select *
from myszy
order by DATA_ZLOWIENIA desc;