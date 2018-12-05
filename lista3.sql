-- Zad. 34. Napisać blok PL/SQL, który wybiera z relacji Kocury koty o funkcji podanej z klawiatury.
-- Jedynym efektem działania bloku ma być komunikat informujący czy znaleziono, czy też nie, kota pełniącego podaną funkcję
-- (w przypadku znalezienia kota wyświetlić nazwę odpowiedniej funkcji).
DECLARE
  l_kotow NUMBER;
  fun     FUNKCJE.FUNKCJA%type := &funckja;
BEGIN
  SELECT count(*) into l_kotow FROM KOCURY WHERE FUNKCJA = upper(fun);
  If l_kotow > 0
  THEN
    DBMS_OUTPUT.PUT_LINE('Znaleziono kota pelniacego funkcje: ' || fun);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota pelniacego podana funkcje.');
  end if;
end;

-- Zad. 35. Napisać blok PL/SQL, który wyprowadza na ekran następujące informacje o kocie
-- o pseudonimie wprowadzonym z klawiatury (w zależności od rzeczywistych danych):
-- 'calkowity roczny przydzial myszy >700'
-- 'styczeń jest miesiacem przystapienia do stada'
-- 'imię zawiera litere A' 'nie odpowiada kryteriom'.
-- Powyższe informacje wymienione są zgodnie z hierarchią ważności. Każdą wprowadzaną informację poprzedzić imieniem kota.
DECLARE
  myszy                NUMBER;
  w_stadku             DATE;
  imie_kota            KOCURY.IMIE%type;
  ps                   KOCURY.PSEUDO%type := &ps;
  nie_spelnia_warunkow BOOLEAN := true;
BEGIN
  SELECT (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) * 12, W_STADKU_OD, IMIE  into myszy, w_stadku, imie_kota
  FROM KOCURY
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

-- Zad. 36. W związku z dużą wydajnością w łowieniu myszy SZEFUNIO postanowił wynagrodzić swoich podwładnych.
-- Ogłosił więc, że podwyższa indywidualny przydział myszy każdego kota o 10% poczynając od kotów o najniższym przydziale.
-- Jeśli w którymś momencie suma wszystkich przydziałów przekroczy 1050, żaden inny kot nie dostanie podwyżki.
-- Jeśli przydział myszy po podwyżce przekroczy maksymalną wartość należną dla pełnionej funkcji (relacja Funkcje),
-- przydział myszy po podwyżce ma być równy tej wartości. Napisać blok PL/SQL z kursorem,
-- który wyznacza sumę przydziałów przed podwyżką a realizuje to zadanie.
-- Blok ma działać tak długo, aż suma wszystkich przydziałów rzeczywiście przekroczy 1050
-- (liczba „obiegów podwyżkowych” może być większa od 1 a więc i podwyżka może być większa niż 10%).
-- Wyświetlić na ekranie sumę przydziałów myszy po wykonaniu zadania wraz z liczbą podwyżek (liczbą zmian w relacji Kocury).
-- Na końcu wycofać wszystkie zmiany.
declare
  CURSOR kursor is select PRZYDZIAL_MYSZY, MAX_MYSZY
                   from KOCURY
                          JOIN FUNKCJE F on KOCURY.FUNKCJA = F.FUNKCJA
                   ORDER BY PRZYDZIAL_MYSZY for update of PRZYDZIAL_MYSZY;
  suma_myszy     NUMBER;
  nowy_przydzial NUMBER;
begin
  select sum(PRZYDZIAL_MYSZY) into suma_myszy from KOCURY;
  DBMS_OUTPUT.PUT_LINE('Suma przydzialu myszy przed zmianami: ' || suma_myszy);
  <<zewn>> loop
    for rekord in kursor
    loop
      select sum(PRZYDZIAL_MYSZY) into suma_myszy from KOCURY;
      if suma_myszy > 1050
      then
        exit zewn;
      end if;
      nowy_przydzial := ROUND(rekord.PRZYDZIAL_MYSZY * 1.1);
      if nowy_przydzial > rekord.MAX_MYSZY
      then
        nowy_przydzial := rekord.MAX_MYSZY;
      end if;
      update KOCURY set PRZYDZIAL_MYSZY = nowy_przydzial;
    end loop;
  end loop zewn;
  DBMS_OUTPUT.PUT_LINE('Suma przydzialu myszy po zmianach: ' || suma_myszy);
  rollback;
end;

-- Zad. 37. Napisać blok, który powoduje wybranie w pętli kursorowej FOR pięciu kotów o najwyższym całkowitym przydziale myszy.
-- Wynik wyświetlić na ekranie.
declare
  cursor kursor is select *
                   from (select pseudo, nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0) "ZJADA"
                         from Kocury
                         order by "ZJADA" DESC)
                   where rownum <= 5;
  licznik NUMBER := 1;
begin
  DBMS_OUTPUT.PUT_LINE('Nr  Psedonim  Zjada');
  DBMS_OUTPUT.PUT_LINE('-------------------');
  for rekord in kursor
  loop
    DBMS_OUTPUT.PUT_LINE(RPAD(licznik, 4) || RPAD(rekord.PSEUDO, 10) || LPAD(rekord.ZJADA, 5));
    licznik := licznik + 1;
  end loop;
end;


-- Zad. 38. Napisać blok, który zrealizuje wersję a. lub wersję b. zad. 19 w sposób uniwersalny
-- (bez konieczności uwzględniania wiedzy o głębokości drzewa).
-- Daną wejściową ma być maksymalna liczba wyświetlanych przełożonych.

declare
  l_szefow      NUMBER := &szefowie;
  cursor kursor is select IMIE, FUNKCJA, SZEF FROM KOCURY WHERE FUNKCJA IN ('KOT', 'MILUSIA');
  aktualny_szef KOCURY.SZEF%type := null;
  imie_szefa    KOCURY.IMIE%type := null;
begin
  if l_szefow < 1
  then
    dbms_output.put_line('wprowadzono niepoprawna liczbe szefow: <1');
  else
    dbms_output.put(RPAD('IMIE', 15) || RPAD('FUNKCJA', 15));
    for i in 1..l_szefow
    loop
      dbms_output.put(RPAD(('SZEF ' || i), 15));
    end loop;
    dbms_output.new_line();
    dbms_output.put_line(LPAD(' ', 15 * (l_szefow + 2), '-'));
    for rekord in kursor
    loop
      dbms_output.put(RPAD(rekord.IMIE, 15));
      dbms_output.put(RPAD(rekord.FUNKCJA, 15));
      aktualny_szef := rekord.SZEF;
      for i in 1..l_szefow
      loop
        if aktualny_szef is null
        then
          exit;
        else
          select imie, szef into imie_szefa, aktualny_szef from KOCURY where PSEUDO = aktualny_szef;
          dbms_output.put(RPAD(imie_szefa, 15));
        end if;
      end loop;
      dbms_output.new_line();
    end loop;
  end if;
end;

-- Zad. 39. Napisać blok PL/SQL wczytujący trzy parametry reprezentujące nr bandy, nazwę bandy oraz teren polowań.
-- Skrypt ma uniemożliwiać wprowadzenie istniejących już wartości parametrów poprzez obsługę odpowiednich wyjątków.
-- Sytuacją wyjątkową jest także wprowadzenie numeru bandy <=0. W przypadku zaistnienia sytuacji wyjątkowej
-- należy wyprowadzić na ekran odpowiedni komunikat. W przypadku prawidłowych parametrów należy stworzyć nową bandę w relacji Bandy.
-- Zmianę należy na końcu wycofać.

declare
  nowy_nr     BANDY.NR_BANDY%type := &nr_bandy;
  nowa_nazwa  BANDY.NAZWA%type := &nazwa;
  nowy_teren  BANDY.TEREN%type := &teren;
  elems_count NUMBER;
  err_msg     STRING(256);
    juz_istnieje EXCEPTION;
    bledny_numer EXCEPTION;
begin
  if nowy_nr < 0
  then
    raise bledny_numer;
  end if;
  select count(NR_BANDY) into elems_count FROM BANDY where NR_BANDY = nowy_nr;
  if elems_count > 0
  then
    err_msg := nowy_nr;
  end if;
  select count(*) into elems_count FROM BANDY where NAZWA = nowa_nazwa;
  if elems_count > 0
  then
    if length(err_msg) > 0
    then
      err_msg := err_msg || ', ';
    end if;
    err_msg := err_msg || nowa_nazwa;
  end if;
  select count(*) into elems_count FROM BANDY where TEREN = nowy_teren;
  if elems_count > 0
  then
    if length(err_msg) > 0
    then
      err_msg := err_msg || ', ';
    end if;
    err_msg := err_msg || nowy_teren;
  end if;

  if length(err_msg) > 0
  then
    raise juz_istnieje;
  end if;
  insert into BANDY (NR_BANDY, NAZWA, TEREN) values (nowy_nr, nowa_nazwa, nowy_teren);
  dbms_output.put_line('Dodano bande: ' || nowy_nr || ', ' || nowa_nazwa || ', ' || nowy_teren);
  rollback;

  exception
  when juz_istnieje
  then dbms_output.put_line(err_msg || ': już istnieje');
  when bledny_numer
  then dbms_output.put_line('Numer bandy musi być dodatni!');
  when others
  then dbms_output.put_line(sqlerrm);
end;

-- Zad. 40. Przerobić blok z zadania 39 na procedurę umieszczoną w bazie danych.

create or replace procedure nowa_banda(nowy_nr    BANDY.NR_BANDY%TYPE, nowa_nazwa BANDY.NAZWA%TYPE,
                                       nowy_teren BANDY.TEREN%TYPE) is
  elems_count NUMBER;
  err_msg     STRING(256);
    juz_istnieje EXCEPTION;
    bledny_numer EXCEPTION;

  begin
    if nowy_nr < 0
    then
      raise bledny_numer;
    end if;
    select count(NR_BANDY) into elems_count FROM BANDY where NR_BANDY = nowy_nr;
    if elems_count > 0
    then
      err_msg := nowy_nr;
    end if;
    select count(*) into elems_count FROM BANDY where NAZWA = nowa_nazwa;
    if elems_count > 0
    then
      if length(err_msg) > 0
      then
        err_msg := err_msg || ', ';
      end if;
      err_msg := err_msg || nowa_nazwa;
    end if;
    select count(*) into elems_count FROM BANDY where TEREN = nowy_teren;
    if elems_count > 0
    then
      if length(err_msg) > 0
      then
        err_msg := err_msg || ', ';
      end if;
      err_msg := err_msg || nowy_teren;
    end if;

    if length(err_msg) > 0
    then
      raise juz_istnieje;
    end if;
    insert into BANDY (NR_BANDY, NAZWA, TEREN) values (nowy_nr, nowa_nazwa, nowy_teren);
    dbms_output.put_line('Dodano bande: ' || nowy_nr || ', ' || nowa_nazwa || ', ' || nowy_teren);

    exception
    when juz_istnieje
    then dbms_output.put_line(err_msg || ': już istnieje');
    when bledny_numer
    then dbms_output.put_line('Numer bandy musi być dodatni!');
    when others
    then dbms_output.put_line(sqlerrm);
  end;

begin
  nowa_banda(nowy_nr=>1, nowa_nazwa=>'SZEFOSTWO', nowy_teren=>'Wroclaw');
  rollback;
end;

-- Zad. 41. Zdefiniować wyzwalacz, który zapewni, że numer nowej bandy będzie zawsze większy o 1 od najwyższego numeru istniejącej już bandy.
-- Sprawdzić działanie wyzwalacza wykorzystując procedurę z zadania 40.

CREATE OR REPLACE TRIGGER automatyczny_nr_bandy
  BEFORE INSERT
  ON BANDY
  FOR EACH ROW
  DECLARE
    max_nr BANDY.nr_bandy%TYPE := 0;
  BEGIN
    SELECT MAX(nr_bandy) INTO max_nr FROM BANDY;
    :NEW.nr_bandy := max_nr + 1;
  END;

declare
  numer_do_wstawienia NUMBER := 99;
  wstawiony_numer     NUMBER;
begin
  nowa_banda(nowy_nr=>numer_do_wstawienia, nowa_nazwa=>'KOLESIE', nowy_teren=>'Wroclaw');
  SELECT NR_BANDY into wstawiony_numer FROM BANDY where NAZWA = 'KOLESIE';
  dbms_output.put_line(
      'Próbowano wstawić numer: ' || numer_do_wstawienia || ', a wstawiono numer: ' || wstawiony_numer);
  rollback;
end;

drop trigger automatyczny_nr_bandy;
-- Zad. 42. Milusie postanowiły zadbać o swoje interesy. Wynajęły więc informatyka, aby zapuścił wirusa w system Tygrysa.
-- Teraz przy każdej próbie zmiany przydziału myszy na plus (o minusie w ogóle nie może być mowy)
-- o wartość mniejszą niż 10% przydziału myszy Tygrysa żal Miluś ma być utulony podwyżką ich przydziału
-- o tę wartość oraz podwyżką myszy extra o 5. Tygrys ma być ukarany stratą wspomnianych 10%.
-- Jeśli jednak podwyżka będzie satysfakcjonująca, przydział myszy extra Tygrysa ma wzrosnąć o 5.
-- Zaproponować dwa rozwiązania zadania, które ominą podstawowe ograniczenie dla wyzwalacza wierszowego aktywowanego
-- poleceniem DML tzn. brak możliwości odczytu lub zmiany relacji, na której operacja (polecenie DML) „wyzwala” ten wyzwalacz.
-- Podać przykład funkcjonowania wyzwalaczy a następnie zlikwidować wprowadzone przez nie zmiany.
-- todo W pierwszym rozwiązaniu (klasycznym) wykorzystać kilku wyzwalaczy i pamięć w postaci specyfikacji dedykowanego zadaniu pakietu,
-- CREATE OR REPLACE PACKAGE wirus
-- AS
--   przydzial_tygrys NUMBER :=0;
--   myszy_extra_tygrys NUMBER :=0;
--   kara BOOLEAN :=false;
-- end wirus;
-- CREATE OR REPLACE TRIGGER przydzial_tygrys_before
--   BEFORE UPDATE
--   ON KOCURY
--   BEGIN
--     SELECT PRZYDZIAL_MYSZY, MYSZY_EXTRA into wirus.przydzial_tygrys, wirus.myszy_extra_tygrys FROM KOCURY WHERE PSEUDO = 'TYGRYS';
--   end;
-- CREATE OR REPLACE TRIGGER podwyzka_milus_before
--   BEFORE UPDATE
--   ON KOCURY
--   FOR EACH ROW
--   WHEN (FUNKCJA = 'MILUSIA')
--   BEGIN
-- --     if true
-- --     then
-- --       wirus.kara := true;
-- --       dbms_output.put_line('Tygrys musi zostać ukarany!');
-- -- --       :new.PRZYDZIAL_MYSZY :=  wirus.przydzial_tygrys;
-- -- --       :new.MYSZY_EXTRA := :old.MYSZY_EXTRA ;
-- --       else
-- --         wirus.kara := false;
-- --         dbms_output.put_line('Tygrys zostanie nagrodzony!');
-- --     end if;
--   end;

/*CREATE OR REPLACE PACKAGE Zad42 AS
  przydzial NUMBER DEFAULT 0;
  kara NUMBER DEFAULT 0;
  nagroda NUMBER DEFAULT 0;
END Zad42;

CREATE OR REPLACE TRIGGER Zad42_BeforeUpdate
  BEFORE UPDATE
  ON kocury
  BEGIN
    SELECT przydzial_myszy INTO Zad42.przydzial FROM Kocury WHERE pseudo = 'TYGRYS';
  END;

CREATE OR REPLACE TRIGGER Zad42_BeforeUpdateEachRow
  BEFORE UPDATE
  ON Kocury
  FOR EACH ROW
  DECLARE
    f_min NUMBER DEFAULT 0;
    f_max NUMBER DEFAULT 0;
    diff  NUMBER DEFAULT 0;
  BEGIN
    SELECT min_myszy, max_myszy INTO f_min, f_max FROM Funkcje WHERE funkcja = :new.funkcja;

    IF :new.funkcja = 'MILUSIA'
    THEN
      IF :new.przydzial_myszy < :old.przydzial_myszy
      THEN
        :new.przydzial_myszy := :old.przydzial_myszy;
        DBMS_OUTPUT.PUT_LINE('Zablokowano probe obnizki kota ' || :new.pseudo
                             || ' z ' || :old.przydzial_myszy || ' na ' || :new.przydzial_myszy);
      END IF;

      diff := :new.przydzial_myszy - :old.przydzial_myszy;

      IF (diff > 0) AND (diff < 0.1 * Zad42.przydzial)
      THEN

        DBMS_OUTPUT.PUT_LINE('Kara dla Tygrysa za zmiane dla kota ' || :new.pseudo
                             || ' z ' || :old.przydzial_myszy || ' na ' || :new.przydzial_myszy);


        Zad42.kara := Zad42.kara + 1;
        :new.przydzial_myszy := :new.przydzial_myszy + 0.1 * Zad42.przydzial;
        :new.myszy_extra := :new.myszy_extra + 5;
      ELSIF (diff > 0) AND (diff >= 0.1 * Zad42.przydzial)
        THEN

          DBMS_OUTPUT.PUT_LINE('Nagroda dla Tygrysa za zmiane dla kota ' || :new.pseudo
                               || ' z ' || :old.przydzial_myszy || ' na ' || :new.przydzial_myszy);


          Zad42.nagroda := Zad42.nagroda + 1;
      END IF;
    END IF;

    -- Sprawdzanie przekroczenia wartosci dla funkcji:
    IF :new.przydzial_myszy < f_min
    THEN
      :new.przydzial_myszy := f_min;
    ELSIF :new.przydzial_myszy > f_max
      THEN
        :new.przydzial_myszy := f_max;
    END IF;

  END;

CREATE OR REPLACE TRIGGER Zad42_AfterUpdate
  AFTER UPDATE
  ON Kocury
  DECLARE
    tmp NUMBER DEFAULT 0;
  BEGIN

    IF Zad42.kara > 0
    THEN
      tmp := Zad42.kara;
      Zad42.kara := 0; -- przeciwdziala petli nieskonczonej
      UPDATE Kocury SET przydzial_myszy = przydzial_myszy * (1 - (0.1 * tmp)) WHERE pseudo = 'TYGRYS';
    END IF;

    IF Zad42.nagroda > 0
    THEN
      tmp := Zad42.nagroda;
      Zad42.nagroda := 0; -- przeciwdziala petli nieskonczonej
      UPDATE Kocury SET myszy_extra = myszy_extra + (Zad42.nagroda * 5) WHERE pseudo = 'TYGRYS';
    END IF;

  END;

SELECT *
FROM Kocury;
UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 1;
SELECT *
FROM Kocury;
ROLLBACK;*/

-- todo w drugim wykorzystać wyzwalacz COMPOUND.


-- todo Zad. 43. Napisać blok, który zrealizuje zad. 33 w sposób uniwersalny
-- (bez konieczności uwzględniania wiedzy o funkcjach pełnionych przez koty).
declare
  cursor kursor_funkcje is select FUNKCJA FROM FUNKCJE;
  cursor kursor_bandy is select KOCURY.NR_BANDY, BANDY.NAZWA, DECODE(PLEC, 'M', 'KOCOR', 'KOTKA') as PLEC, count(*) as ile
                         from BANDY
                                JOIN KOCURY on BANDY.NR_BANDY = KOCURY.NR_BANDY
                         group by BANDY.NAZWA, PLEC, KOCURY.NR_BANDY
                         order by BANDY.NAZWA, PLEC DESC;
  l_kolumn       NUMBER;
  suma_myszy     NUMBER;
  suma_czastkowa NUMBER;
begin
  select count(*) + 3 into l_kolumn from FUNKCJE;
  dbms_output.put(RPAD('NAZWA BANDY', 20));
  dbms_output.put(RPAD('PLEC', 10));
  dbms_output.put(RPAD('ILE', 5));
  for rekord in kursor_funkcje
  loop
    dbms_output.put(RPAD(rekord.FUNKCJA, 15));
  end loop;
  dbms_output.put(RPAD('SUMA', 10));
  dbms_output.new_line();
  for i in 1..l_kolumn
  loop
    dbms_output.put('---------------');
  end loop;
  dbms_output.new_line();
  for banda_rekord in kursor_bandy
  loop
    dbms_output.put(RPAD(banda_rekord.NAZWA, 20));
    dbms_output.put(RPAD(banda_rekord.PLEC, 10));
    dbms_output.put(RPAD(banda_rekord.ile, 5));
    suma_myszy := 0;
    suma_czastkowa := 0;
    for funkcja_rekord in kursor_funkcje
    loop
      select NVL(SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)), 0) into suma_czastkowa
      from KOCURY
      where NR_BANDY = banda_rekord.NR_BANDY
        and plec = banda_rekord.PLEC
        and FUNKCJA = funkcja_rekord.FUNKCJA;
      dbms_output.put(RPAD(suma_czastkowa, 15));
      suma_myszy := suma_myszy + suma_czastkowa;
    end loop;
    dbms_output.put(RPAD(suma_myszy, 10));
    dbms_output.new_line();
  end loop;
  for i in 1..l_kolumn
  loop
    dbms_output.put('---------------');
  end loop;
  dbms_output.new_line();
  suma_myszy := 0;
  dbms_output.put(RPAD('ZJADA RAZEM', 35));
  for funkcja_rekord in kursor_funkcje
  loop
    select NVL(SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)), 0) into suma_czastkowa
    from KOCURY
    where FUNKCJA = funkcja_rekord.FUNKCJA;
    dbms_output.put(RPAD(suma_czastkowa, 15));
    suma_myszy := suma_myszy + suma_czastkowa;
  end loop;
  dbms_output.put(RPAD(suma_myszy, 10));
  dbms_output.new_line();
end;

-- todo Zad. 44. Tygrysa zaniepokoiło niewytłumaczalne obniżenie zapasów "myszowych".
-- Postanowił więc wprowadzić podatek pogłówny, który zasiliłby spiżarnię.
-- Zarządził więc, że każdy kot ma obowiązek oddawać 5% (zaokrąglonych w górę) swoich całkowitych "myszowych" przychodów.
-- Dodatkowo od tego co pozostanie:
-- - koty nie posiadające podwładnych oddają po dwie myszy za nieudolność w umizgach o awans,
-- - koty nie posiadające wrogów oddają po jednej myszy za zbytnią ugodowość,
-- - koty płacą dodatkowy podatek, którego formę określa wykonawca zadania.
-- Napisać funkcję, której parametrem jest pseudonim kota, wyznaczającą należny podatek pogłówny kota.
-- Funkcję tą razem z procedurą z zad. 40 należy umieścić w pakiecie,
-- a następnie wykorzystać ją do określenia podatku dla wszystkich kotów.


-- Zad. 45. Tygrys zauważył dziwne zmiany wartości swojego prywatnego przydziału myszy (patrz zadanie 42).
-- Nie niepokoiły go zmiany na plus ale te na minus były, jego zdaniem, niedopuszczalne.
-- Zmotywował więc jednego ze swoich szpiegów do działania i dzięki temu odkrył niecne praktyki Miluś (zadanie 42).
-- Polecił więc swojemu informatykowi skonstruowanie mechanizmu zapisującego w relacji Dodatki_extra (patrz Wykłady - cz. 2)
-- dla każdej z Miluś -10 (minus dziesięć) myszy dodatku extra przy zmianie na plus któregokolwiek z przydziałów myszy Miluś,
-- wykonanej przez innego operatora niż on sam. Zaproponować taki mechanizm, w zastępstwie za informatyka Tygrysa.
-- W rozwiązaniu wykorzystać funkcję LOGIN_USER zwracającą nazwę użytkownika aktywującego wyzwalacz oraz elementy dynamicznego SQL'a.

CREATE OR REPLACE TRIGGER kara_dla_milus
  BEFORE UPDATE OF PRZYDZIAL_MYSZY
  ON KOCURY
  FOR EACH ROW
  DECLARE
    log VARCHAR2(255) := LOGIN_USER;
    fun KOCURY.FUNKCJA%TYPE;
    ps  KOCURY.PSEUDO%TYPE;
    pm  KOCURY.PRZYDZIAL_MYSZY%TYPE;
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF UPDATING ('funkcja')
    THEN
      fun := :NEW.FUNKCJA;
    ELSE
      fun := :OLD.FUNKCJA;
    END IF;
    IF UPDATING ('pseudo')
    THEN
      ps := :NEW.PSEUDO;
    ELSE
      ps := :OLD.PSEUDO;
    END IF;
    pm := :NEW.PRZYDZIAL_MYSZY - :OLD.PRZYDZIAL_MYSZY;
    IF fun = 'MILUSIA' AND log <> 'TYGRYS' AND pm > 0
    THEN
      EXECUTE IMMEDIATE 'INSERT INTO DODATKI_EXTRA(PSEUDO,DOD_EXTRA) VALUES (''' || ps || ''',-10)';
      EXECUTE IMMEDIATE 'COMMIT';
    END IF;
  END;

BEGIN
  UPDATE KOCURY
  SET PRZYDZIAL_MYSZY = 34
  WHERE FUNKCJA = 'MILUSIA';
  ROLLBACK;
END;
SELECT * FROM DODATKI_EXTRA;


-- Zad. 46. Napisać wyzwalacz, który uniemożliwi wpisanie kotu przydziału myszy spoza przedziału (min_myszy, max_myszy)
-- określonego dla każdej funkcji w relacji Funkcje. Każda próba wykroczenia poza obowiązujący przedział
-- ma być dodatkowo monitorowana w osobnej relacji (kto, kiedy, jakiemu kotu, jaką operacją).

CREATE OR REPLACE TRIGGER co_z_myszkami
  BEFORE INSERT OR UPDATE OF przydzial_myszy, FUNKCJA
  ON Kocury
  FOR EACH ROW
  DECLARE
    ps          Kocury.pseudo%TYPE;
    pm          Kocury.przydzial_myszy%TYPE;
    f           Kocury.funkcja%TYPE;
    op          VARCHAR2(255);
    wykroczenie BOOLEAN;
    PROCEDURE sprawdz_wykroczenie IS
      log   VARCHAR2(255) := LOGIN_USER;
      max_m Funkcje.MAX_MYSZY%TYPE;
      min_m Funkcje.MIN_MYSZY%TYPE;
      PRAGMA AUTONOMOUS_TRANSACTION;
      BEGIN
        SELECT
          MIN_MYSZY,
          MAX_MYSZY
        INTO min_m, max_m
        FROM FUNKCJE
        WHERE FUNKCJE.FUNKCJA = f;
        IF pm > max_m OR pm < min_m
        THEN
          INSERT INTO HISTORIA_WYKROCZEN (LOGIN, DATA_WYKROCZENIA, PSEUDO, OPERACJA)
          VALUES (log, SYSDATE, ps, op || '(' || min_m || ':' || max_m || ') -> ' || pm);
          COMMIT;
          wykroczenie := TRUE;
        ELSE
          wykroczenie := FALSE;
        END IF;
      END;

  BEGIN
    IF INSERTING
    THEN ps := :NEW.pseudo;
      pm := :NEW.przydzial_myszy;
      f := :NEW.FUNKCJA;
      op := 'inserting';
      sprawdz_wykroczenie();
      IF wykroczenie = TRUE
      THEN
        RAISE_APPLICATION_ERROR(-20105, 'Nowy przydzial myszy nie miesci sie w przedziale dla funkcji!');
      END IF;
    ELSE
      ps := :OLD.pseudo;
      f := :OLD.FUNKCJA;
    END IF;
    IF UPDATING ('przydzial_myszy')
    THEN pm := :NEW.przydzial_myszy;
      op := 'updating przydzial';
      sprawdz_wykroczenie();
      IF wykroczenie = TRUE
      THEN
        :New.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
      END IF;
    END IF;
    IF UPDATING ('funkcja')
    THEN f := :NEW.FUNKCJA;
      op := 'updating funkcja';
      sprawdz_wykroczenie();
      IF wykroczenie = TRUE
      THEN
        :New.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
      END IF;
    END IF;
  END;

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 104;
SELECT *
FROM KOCURY;
SELECT *
FROM HISTORIA_WYKROCZEN;
