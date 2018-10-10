-- noinspection SpellCheckingInspectionForFile

-- Zad. 17. Wyświetlić pseudonimy, przydziały myszy oraz nazwy band dla kotów operujących na terenie POLE posiadających przydział myszy większy od 50.
-- Uwzględnić fakt, że są w stadzie koty posiadające prawo do polowań na całym „obsługiwanym” przez stado terenie.
-- Nie stosować podzapytań.
SELECT
  KOCURY.PSEUDO "POLUJE W POLU",
  KOCURY.PRZYDZIAL_MYSZY,
  BANDY.NAZWA   "BANDA"
FROM KOCURY
  INNER JOIN BANDY USING (NR_BANDY)
WHERE KOCURY.PRZYDZIAL_MYSZY > 50
      AND BANDY.TEREN IN ('POLE', 'CALOSC')
ORDER BY KOCURY.PRZYDZIAL_MYSZY DESC;

-- Zad. 18. Wyświetlić bez stosowania podzapytania imiona i daty przystąpienia do stada kotów,
-- które przystąpiły do stada przed kotem o imieniu ’JACEK’.
-- Wyniki uporządkować malejąco wg daty przystąpienia do stadka.
SELECT
  K1.IMIE,
  K1.W_STADKU_OD "POLUJE OD"
FROM KOCURY K1, KOCURY K2
WHERE K2.IMIE = 'JACEK'
      AND K1.W_STADKU_OD < K2.W_STADKU_OD
ORDER BY K1.W_STADKU_OD DESC;

-- Zad. 19. Dla kotów pełniących funkcję KOT i MILUSIA wyświetlić w kolejności hierarchii imiona wszystkich ich szefów.
-- Zadanie rozwiązać na trzy sposoby:
-- a. z wykorzystaniem tylko złączeń,
-- b. z wykorzystaniem drzewa, operatora CONNECT_BY_ROOT i tabel przestawnych,
-- c. z wykorzystaniem drzewa i funkcji SYS_CONNECT_BY_PATH i operatora CONNECT_BY_ROOT.


-- Zad. 20. Wyświetlić imiona wszystkich kotek, które uczestniczyły w incydentach po 01.01.2007.
-- Dodatkowo wyświetlić nazwy band do których należą kotki, imiona ich wrogów wraz ze stopniem wrogości oraz datę incydentu.
SELECT
  IMIE             "Imie kotki",
  NAZWA            "Nazwa bandy",
  IMIE_WROGA       "Imie wroga",
  STOPIEN_WROGOSCI "Ocena wroga",
  DATA_INCYDENTU   "Data inc."
FROM (KOCURY
  INNER JOIN WROGOWIE_KOCUROW USING (PSEUDO))
  INNER JOIN WROGOWIE USING (IMIE_WROGA)
  INNER JOIN BANDY USING (NR_BANDY)
WHERE PLEC = 'D'
      AND DATA_INCYDENTU > '2007-01-01'
ORDER BY IMIE;

-- Zad. 21. Określić ile kotów w każdej z band posiada wrogów
SELECT
  BANDY.NAZWA            "Nazwa bandy",
  COUNT(DISTINCT PSEUDO) "Koty z wrogami"
FROM (KOCURY
  INNER JOIN WROGOWIE_KOCUROW USING (PSEUDO))
  INNER JOIN BANDY USING (NR_BANDY)
GROUP BY BANDY.NAZWA;

-- Zad. 22. Znaleźć koty (wraz z pełnioną funkcją), które posiadają więcej niż jednego wroga.
SELECT
  MIN(FUNKCJA) "Funkcja",
  PSEUDO       "Pseudonim kota",
  COUNT(*)     "Liczba wrogow"
FROM KOCURY
  INNER JOIN WROGOWIE_KOCUROW USING (PSEUDO)
GROUP BY PSEUDO
HAVING COUNT(*) > 1;

-- Zad. 23. Wyświetlić imiona kotów, które dostają „myszą” premię wraz z ich całkowitym rocznym spożyciem myszy.
-- Dodatkowo jeśli ich roczna dawka myszy przekracza 864 wyświetlić tekst ’powyzej 864’,
-- jeśli jest równa 864 tekst ’864’, jeśli jest mniejsza od 864 tekst ’poniżej 864’.
-- Wyniki uporządkować malejąco wg rocznej dawki myszy. Do rozwiązania wykorzystać operator zbiorowy UNION.
SELECT
  IMIE,
  12 * (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "DAWKA ROCZNA",
  'powyzej 864'                                        "DAWKA"
FROM KOCURY
WHERE NVL(MYSZY_EXTRA, 0) > 0
      AND (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) > 72
UNION
SELECT
  IMIE,
  12 * (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "DAWKA ROCZNA",
  '864'                                                "DAWKA"
FROM KOCURY
WHERE NVL(MYSZY_EXTRA, 0) > 0
      AND (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) = 72
UNION
SELECT
  IMIE,
  12 * (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "DAWKA ROCZNA",
  'ponizej 864'                                        "DAWKA"
FROM KOCURY
WHERE NVL(MYSZY_EXTRA, 0) > 0
      AND (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) < 72
ORDER BY "DAWKA ROCZNA" DESC;

-- Zad. 24. Znaleźć bandy, które nie posiadają członków. Wyświetlić ich numery, nazwy i tereny operowania.
-- Zadanie rozwiązać na dwa sposoby: bez podzapytań i operatorów zbiorowych oraz wykorzystując operatory zbiorowe.
SELECT
  BANDY.NR_BANDY "NR BANDY",
  BANDY.NAZWA    "NAZWA",
  BANDY.TEREN    "TEREN"
FROM
  BANDY
  LEFT OUTER JOIN KOCURY ON KOCURY.NR_BANDY = BANDY.NR_BANDY
WHERE KOCURY.NR_BANDY IS NULL;

SELECT
  NR_BANDY,
  NAZWA,
  TEREN
FROM BANDY
MINUS
SELECT
  NR_BANDY,
  NAZWA,
  TEREN
FROM BANDY
  INNER JOIN KOCURY USING (NR_BANDY);

-- Zad. 25. Znaleźć koty, których przydział myszy jest nie mniejszy
-- od potrojonego najwyższego przydziału spośród przydziałów wszystkich MILUŚ operujących w SADZIE.
-- Nie stosować funkcji MAX.
SELECT
  IMIE,
  FUNKCJA,
  PRZYDZIAL_MYSZY
FROM KOCURY
WHERE NVL(PRZYDZIAL_MYSZY, 0) >=
      3 * (SELECT *
           FROM (SELECT NVL(PRZYDZIAL_MYSZY, 0)
                 FROM KOCURY
                   INNER JOIN BANDY USING (NR_BANDY)
                 WHERE TEREN IN ('SAD', 'CALOSC') AND FUNKCJA = 'MILUSIA'
                 ORDER BY PRZYDZIAL_MYSZY DESC)
           WHERE ROWNUM <= 1)
ORDER BY PRZYDZIAL_MYSZY;

-- Zad. 26. Znaleźć funkcje (pomijając SZEFUNIA), z którymi związany jest najwyższy i najniższy średni całkowity przydział myszy.
-- Nie używać operatorów zbiorowych (UNION, INTERSECT, MINUS).
SELECT
  FUNKCJA,
  ROUND(AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))) "Srednio najw. i najm. myszy"
FROM KOCURY
WHERE FUNKCJA != 'SZEFUNIO'
GROUP BY FUNKCJA
HAVING AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))
       IN (
         (SELECT *
          FROM (SELECT AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "result"
                FROM KOCURY
                WHERE FUNKCJA != 'SZEFUNIO'
                GROUP BY FUNKCJA
                ORDER BY "result" DESC)
          WHERE ROWNUM <= 1),
         (SELECT *
          FROM (SELECT AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "result"
                FROM KOCURY
                WHERE FUNKCJA != 'SZEFUNIO'
                GROUP BY FUNKCJA
                ORDER BY "result")
          WHERE ROWNUM <= 1));

-- Zad. 27. Znaleźć koty zajmujące pierwszych n miejsc pod względem całkowitej liczby spożywanych myszy (koty o tym samym spożyciu zajmują to samo miejsce!).
-- Zadanie rozwiązać na cztery sposoby:
-- a. wykorzystując podzapytanie skorelowane,
-- b. wykorzystując pseudokolumnę ROWNUM,
-- c. wykorzystując złączenie relacji Kocury z relacją Kocury
-- d. wykorzystując funkcje analityczne.


-- Zad. 28. Określić lata, dla których liczba wstąpień do stada jest najbliższa
-- (od góry i od dołu) średniej liczbie wstąpień dla wszystkich lat
-- (średnia z wartości określających liczbę wstąpień w poszczególnych latach). Nie stosować perspektywy.
SELECT
  TO_CHAR(EXTRACT(YEAR FROM W_STADKU_OD)) "ROK",
  COUNT(*)                                "LICZBA WSTAPIEN"
FROM KOCURY
GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
HAVING COUNT(*) =
       (SELECT *
        FROM (SELECT COUNT(*)
              FROM KOCURY
              GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
              HAVING COUNT(*) <=
                     (SELECT AVG(COUNT(*))
                      FROM KOCURY
                      GROUP BY EXTRACT(YEAR FROM W_STADKU_OD))
              ORDER BY COUNT(*) DESC)
        WHERE ROWNUM <= 1)

UNION ALL
SELECT
  'Srednia',
  AVG(COUNT(*))
FROM KOCURY
GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)

UNION ALL
SELECT
  TO_CHAR(EXTRACT(YEAR FROM W_STADKU_OD)),
  COUNT(*)
FROM KOCURY
GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
HAVING COUNT(*) =
       (SELECT *
        FROM (SELECT COUNT(*)
              FROM KOCURY
              GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
              HAVING COUNT(*) >=
                     (SELECT AVG(COUNT(*))
                      FROM KOCURY
                      GROUP BY EXTRACT(YEAR FROM W_STADKU_OD))
              ORDER BY COUNT(*) ASC)
        WHERE ROWNUM <= 1)
-- GROUP BY "LICZBA WSTAPIEN";

-- Zad. 29. Dla kocurów (płeć męska), dla których całkowity przydział myszy nie przekracza średniej w ich bandzie wyznaczyć następujące dane:
-- imię, całkowite spożycie myszy, numer bandy, średnie całkowite spożycie w bandzie.
-- Nie stosować perspektywy. Zadanie rozwiązać na trzy sposoby:
-- a. ze złączeniem ale bez podzapytań,
-- b. ze złączenie i z jedynym podzapytaniem w klauzurze FROM,
-- c. bez złączeń i z dwoma podzapytaniami: w klauzurach SELECT i WHERE.


-- Zad. 30. Wygenerować listę kotów z zaznaczonymi kotami o najwyższym i o najniższym stażu w swoich bandach.
-- Zastosować operatory zbiorowe.


-- Zad. 31. Zdefiniować perspektywę wybierającą następujące dane: nazwę bandy, średni, maksymalny i minimalny przydział myszy w bandzie,
-- całkowitą liczbę kotów w bandzie oraz liczbę kotów pobierających w bandzie przydziały dodatkowe.
-- Posługując się zdefiniowaną perspektywą wybrać następujące dane o kocie, którego pseudonim podawany jest interaktywnie z klawiatury:
-- pseudonim, imię, funkcja, przydział myszy, minimalny i maksymalny przydział myszy w jego bandzie oraz datę wstąpienia do stada.


-- Zad. 32. Dla kotów o trzech najdłuższym stażach w połączonych bandach CZARNI RYCERZE i ŁACIACI MYŚLIWI
-- zwiększyć przydział myszy o 10% minimalnego przydziału w całym stadzie lub o 10 w zależności od tego czy podwyżka dotyczy kota płci żeńskiej czy kota płci męskiej.
-- Przydział myszy extra dla kotów obu płci zwiększyć o 15% średniego przydziału extra w bandzie kota.
-- Wyświetlić na ekranie wartości przed i po podwyżce a następnie wycofać zmiany.


-- Zad. 33. Napisać zapytanie, w ramach którego obliczone zostaną sumy całkowitego spożycia myszy przez koty sprawujące każdą z funkcji z podziałem na bandy i płcie kotów.
-- Podsumować przydziały dla każdej z funkcji.
-- Zadanie wykonać na dwa sposoby:
-- a. z wykorzystaniem tzw. raportu macierzowego,
-- b. z wykorzystaniem klauzuli PIVOT
