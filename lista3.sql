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

-- todo Zad. 36. W związku z dużą wydajnością w łowieniu myszy SZEFUNIO postanowił wynagrodzić swoich podwładnych.
-- Ogłosił więc, że podwyższa indywidualny przydział myszy każdego kota o 10% poczynając od kotów o najniższym przydziale.
-- Jeśli w którymś momencie suma wszystkich przydziałów przekroczy 1050, żaden inny kot nie dostanie podwyżki.
-- Jeśli przydział myszy po podwyżce przekroczy maksymalną wartość należną dla pełnionej funkcji (relacja Funkcje),
-- przydział myszy po podwyżce ma być równy tej wartości. Napisać blok PL/SQL z kursorem,
-- który wyznacza sumę przydziałów przed podwyżką a realizuje to zadanie.
-- Blok ma działać tak długo, aż suma wszystkich przydziałów rzeczywiście przekroczy 1050
-- (liczba „obiegów podwyżkowych” może być większa od 1 a więc i podwyżka może być większa niż 10%).
-- Wyświetlić na ekranie sumę przydziałów myszy po wykonaniu zadania wraz z liczbą podwyżek (liczbą zmian w relacji Kocury).
-- Na końcu wycofać wszystkie zmiany.


-- Zad. 37. Napisać blok, który powoduje wybranie w pętli kursorowej FOR pięciu kotów o najwyższym całkowitym przydziale myszy.
-- Wynik wyświetlić na ekranie.
declare
  cursor koty is select *
                 from (select pseudo, nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0) "ZJADA"
                       from Kocury
                       order by "ZJADA" DESC)
                 where rownum <= 5;
  licznik NUMBER := 1;
begin
  DBMS_OUTPUT.PUT_LINE('Nr  Psedonim  Zjada');
  DBMS_OUTPUT.PUT_LINE('-------------------');
  for kursor in koty
  loop
    DBMS_OUTPUT.PUT_LINE(RPAD(licznik, 4) || RPAD(kursor.PSEUDO, 10) || LPAD(kursor.ZJADA, 5));
    licznik := licznik + 1;
  end loop;
end;


-- todo Zad. 38. Napisać blok, który zrealizuje wersję a. lub wersję b. zad. 19 w sposób uniwersalny
-- (bez konieczności uwzględniania wiedzy o głębokości drzewa).
-- Daną wejściową ma być maksymalna liczba wyświetlanych przełożonych.


-- todo Zad. 39. Napisać blok PL/SQL wczytujący trzy parametry reprezentujące nr bandy, nazwę bandy oraz teren polowań.
-- Skrypt ma uniemożliwiać wprowadzenie istniejących już wartości parametrów poprzez obsługę odpowiednich wyjątków.
-- Sytuacją wyjątkową jest także wprowadzenie numeru bandy <=0. W przypadku zaistnienia sytuacji wyjątkowej
-- należy wyprowadzić na ekran odpowiedni komunikat. W przypadku prawidłowych parametrów należy stworzyć nową bandę w relacji Bandy.
-- Zmianę należy na końcu wycofać.


-- todo Zad. 40. Przerobić blok z zadania 39 na procedurę umieszczoną w bazie danych.


-- todo Zad. 41. Zdefiniować wyzwalacz, który zapewni, że numer nowej bandy będzie zawsze większy o 1 od najwyższego numeru istniejącej już bandy.
-- Sprawdzić działanie wyzwalacza wykorzystując procedurę z zadania 40.


-- todo Zad. 42. Milusie postanowiły zadbać o swoje interesy. Wynajęły więc informatyka, aby zapuścił wirusa w system Tygrysa.
-- Teraz przy każdej próbie zmiany przydziału myszy na plus (o minusie w ogóle nie może być mowy)
-- o wartość mniejszą niż 10% przydziału myszy Tygrysa żal Miluś ma być utulony podwyżką ich przydziału
-- o tę wartość oraz podwyżką myszy extra o 5. Tygrys ma być ukarany stratą wspomnianych 10%.
-- Jeśli jednak podwyżka będzie satysfakcjonująca, przydział myszy extra Tygrysa ma wzrosnąć o 5.
-- Zaproponować dwa rozwiązania zadania, które ominą podstawowe ograniczenie dla wyzwalacza wierszowego aktywowanego
-- poleceniem DML tzn. brak możliwości odczytu lub zmiany relacji, na której operacja (polecenie DML) „wyzwala” ten wyzwalacz.
-- W pierwszym rozwiązaniu (klasycznym) wykorzystać kilku wyzwalaczy i pamięć w postaci specyfikacji dedykowanego zadaniu pakietu,
-- w drugim wykorzystać wyzwalacz COMPOUND. Podać przykład funkcjonowania wyzwalaczy a następnie zlikwidować wprowadzone przez nie zmiany.


-- todo Zad. 43. Napisać blok, który zrealizuje zad. 33 w sposób uniwersalny
-- (bez konieczności uwzględniania wiedzy o funkcjach pełnionych przez koty).


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


-- todo . 45. Tygrys zauważył dziwne zmiany wartości swojego prywatnego przydziału myszy (patrz zadanie 42).
-- Nie niepokoiły go zmiany na plus ale te na minus były, jego zdaniem, niedopuszczalne.
-- Zmotywował więc jednego ze swoich szpiegów do działania i dzięki temu odkrył niecne praktyki Miluś (zadanie 42).
-- Polecił więc swojemu informatykowi skonstruowanie mechanizmu zapisującego w relacji Dodatki_extra (patrz Wykłady - cz. 2)
-- dla każdej z Miluś -10 (minus dziesięć) myszy dodatku extra przy zmianie na plus któregokolwiek z przydziałów myszy Miluś,
-- wykonanej przez innego operatora niż on sam. Zaproponować taki mechanizm, w zastępstwie za informatyka Tygrysa.
-- W rozwiązaniu wykorzystać funkcję LOGIN_USER zwracającą nazwę użytkownika aktywującego wyzwalacz oraz elementy dynamicznego SQL'a.


-- todo Zad. 46. Napisać wyzwalacz, który uniemożliwi wpisanie kotu przydziału myszy spoza przedziału (min_myszy, max_myszy)
-- określonego dla każdej funkcji w relacji Funkcje. Każda próba wykroczenia poza obowiązujący przedział
-- ma być dodatkowo monitorowana w osobnej relacji (kto, kiedy, jakiemu kotu, jaką operacją).