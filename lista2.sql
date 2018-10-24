-- noinspection SpellCheckingInspectionForFile

-- Zad. 17. Wyświetlić pseudonimy, przydziały myszy oraz nazwy band dla kotów operujących na terenie POLE posiadających przydział myszy większy od 50.
-- Uwzględnić fakt, że są w stadzie koty posiadające prawo do polowań na całym „obsługiwanym” przez stado terenie.
-- Nie stosować podzapytań.
SELECT KOCURY.PSEUDO "POLUJE W POLU", KOCURY.PRZYDZIAL_MYSZY, BANDY.NAZWA "BANDA"
FROM KOCURY
       INNER JOIN BANDY USING (NR_BANDY)
WHERE KOCURY.PRZYDZIAL_MYSZY > 50
  AND BANDY.TEREN IN ('POLE', 'CALOSC')
ORDER BY KOCURY.PRZYDZIAL_MYSZY DESC;

-- Zad. 18. Wyświetlić bez stosowania podzapytania imiona i daty przystąpienia do stada kotów,
-- które przystąpiły do stada przed kotem o imieniu ’JACEK’.
-- Wyniki uporządkować malejąco wg daty przystąpienia do stadka.
SELECT K1.IMIE, K1.W_STADKU_OD "POLUJE OD"
FROM KOCURY K1,
     KOCURY K2
WHERE K2.IMIE = 'JACEK'
  AND K1.W_STADKU_OD < K2.W_STADKU_OD
ORDER BY K1.W_STADKU_OD DESC;

-- Zad. 19. Dla kotów pełniących funkcję KOT i MILUSIA wyświetlić w kolejności hierarchii imiona wszystkich ich szefów.
-- Zadanie rozwiązać na trzy sposoby:
-- a. z wykorzystaniem tylko złączeń,
SELECT K1.IMIE "Imie", K1.FUNKCJA "Funkcja", K2.IMIE "Szef 1", K3.IMIE "Szef 2", K4.IMIE "Szef 3"
FROM KOCURY K1
       LEFT JOIN KOCURY K2 ON K1.SZEF = K2.PSEUDO
       LEFT JOIN KOCURY K3 ON K2.SZEF = K3.PSEUDO
       LEFT JOIN KOCURY K4 ON K3.SZEF = K4.PSEUDO
WHERE K1.FUNKCJA IN ('KOT', 'MILUSIA');

-- TODO b. z wykorzystaniem drzewa, operatora CONNECT_BY_ROOT i tabel przestawnych,

-- c. z wykorzystaniem drzewa i funkcji SYS_CONNECT_BY_PATH i operatora CONNECT_BY_ROOT.
SELECT IMIE, FUNKCJA, "Imiona kolejnych szefow"
FROM KOCURY K
       JOIN (SELECT CONNECT_BY_ROOT PSEUDO "PSEUDO", SYS_CONNECT_BY_PATH(IMIE, '|') "Imiona kolejnych szefow"
             FROM KOCURY
             WHERE CONNECT_BY_ISLEAF = 1
             CONNECT BY PSEUDO = PRIOR SZEF
             START WITH PSEUDO IN (SELECT SZEF FROM KOCURY WHERE FUNKCJA IN ('KOT', 'MILUSIA'))) x on K.SZEF = x.PSEUDO
WHERE FUNKCJA IN ('KOT', 'MILUSIA');

-- SELECT CONNECT_BY_ROOT IMIE           "Imie",
--        CONNECT_BY_ROOT FUNKCJA        "Funkcja",
--        SYS_CONNECT_BY_PATH(IMIE, '|') "Imiona kolejnych szefow"
-- FROM KOCURY
-- CONNECT BY PSEUDO = PRIOR SZEF
-- START WITH FUNKCJA IN ('KOT', 'MILUSIA')
-- ORDER BY CONNECT_BY_ROOT IMIE, LEVEL DESC;

-- Zad. 20. Wyświetlić imiona wszystkich kotek, które uczestniczyły w incydentach po 01.01.2007.
-- Dodatkowo wyświetlić nazwy band do których należą kotki, imiona ich wrogów wraz ze stopniem wrogości oraz datę incydentu.
SELECT IMIE             "Imie kotki",
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
SELECT BANDY.NAZWA "Nazwa bandy", COUNT(DISTINCT PSEUDO) "Koty z wrogami"
FROM (KOCURY
    INNER JOIN WROGOWIE_KOCUROW USING (PSEUDO))
       INNER JOIN BANDY USING (NR_BANDY)
GROUP BY BANDY.NAZWA;

-- Zad. 22. Znaleźć koty (wraz z pełnioną funkcją), które posiadają więcej niż jednego wroga.
SELECT MIN(FUNKCJA) "Funkcja", PSEUDO "Pseudonim kota", COUNT(*) "Liczba wrogow"
FROM KOCURY
       INNER JOIN WROGOWIE_KOCUROW USING (PSEUDO)
GROUP BY PSEUDO
HAVING COUNT(*) > 1;

-- Zad. 23. Wyświetlić imiona kotów, które dostają „myszą” premię wraz z ich całkowitym rocznym spożyciem myszy.
-- Dodatkowo jeśli ich roczna dawka myszy przekracza 864 wyświetlić tekst ’powyzej 864’,
-- jeśli jest równa 864 tekst ’864’, jeśli jest mniejsza od 864 tekst ’poniżej 864’.
-- Wyniki uporządkować malejąco wg rocznej dawki myszy. Do rozwiązania wykorzystać operator zbiorowy UNION.
SELECT IMIE, 12 * (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "DAWKA ROCZNA", 'powyzej 864' "DAWKA"
FROM KOCURY
WHERE NVL(MYSZY_EXTRA, 0) > 0
  AND (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) > 72
UNION
SELECT IMIE, 12 * (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "DAWKA ROCZNA", '864' "DAWKA"
FROM KOCURY
WHERE NVL(MYSZY_EXTRA, 0) > 0
  AND (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) = 72
UNION
SELECT IMIE, 12 * (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "DAWKA ROCZNA", 'ponizej 864' "DAWKA"
FROM KOCURY
WHERE NVL(MYSZY_EXTRA, 0) > 0
  AND (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) < 72
ORDER BY "DAWKA ROCZNA" DESC;

-- Zad. 24. Znaleźć bandy, które nie posiadają członków. Wyświetlić ich numery, nazwy i tereny operowania.
-- Zadanie rozwiązać na dwa sposoby:

-- a) bez podzapytań i operatorów zbiorowych
SELECT BANDY.NR_BANDY "NR BANDY", BANDY.NAZWA "NAZWA", BANDY.TEREN "TEREN"
FROM BANDY
       LEFT OUTER JOIN KOCURY ON KOCURY.NR_BANDY = BANDY.NR_BANDY
WHERE KOCURY.NR_BANDY IS NULL;

-- b) wykorzystując operatory zbiorowe.
SELECT NR_BANDY, NAZWA, TEREN
FROM BANDY
MINUS
SELECT NR_BANDY, NAZWA, TEREN
FROM BANDY
       INNER JOIN KOCURY USING (NR_BANDY);

-- Zad. 25. Znaleźć koty, których przydział myszy jest nie mniejszy
-- od potrojonego najwyższego przydziału spośród przydziałów wszystkich MILUŚ operujących w SADZIE.
-- Nie stosować funkcji MAX.
SELECT IMIE, FUNKCJA, PRZYDZIAL_MYSZY
FROM KOCURY
WHERE NVL(PRZYDZIAL_MYSZY, 0) >=
      3 * (SELECT *
           FROM (SELECT NVL(PRZYDZIAL_MYSZY, 0)
                 FROM KOCURY
                        INNER JOIN BANDY USING (NR_BANDY)
                 WHERE TEREN IN ('SAD', 'CALOSC')
                   AND FUNKCJA = 'MILUSIA'
                 ORDER BY PRZYDZIAL_MYSZY DESC)
           WHERE ROWNUM <= 1)
ORDER BY PRZYDZIAL_MYSZY;

-- Zad. 26. Znaleźć funkcje (pomijając SZEFUNIA), z którymi związany jest najwyższy i najniższy średni całkowity przydział myszy.
-- Nie używać operatorów zbiorowych (UNION, INTERSECT, MINUS).
SELECT FUNKCJA, ROUND(AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))) "Srednio najw. i najm. myszy"
FROM KOCURY
WHERE FUNKCJA != 'SZEFUNIO'
GROUP BY FUNKCJA
HAVING AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))
         IN ((SELECT *
              FROM (SELECT AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "result"
                    FROM KOCURY
                    WHERE FUNKCJA != 'SZEFUNIO'
                    GROUP BY FUNKCJA
                    ORDER BY "result" DESC)
              WHERE ROWNUM <= 1), (SELECT *
                                   FROM (SELECT AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "result"
                                         FROM KOCURY
                                         WHERE FUNKCJA != 'SZEFUNIO'
                                         GROUP BY FUNKCJA
                                         ORDER BY "result")
                                   WHERE ROWNUM <= 1));

-- Zad. 27. Znaleźć koty zajmujące pierwszych n miejsc pod względem całkowitej liczby spożywanych myszy (koty o tym samym spożyciu zajmują to samo miejsce!).
-- Zadanie rozwiązać na cztery sposoby:
-- a. wykorzystując podzapytanie skorelowane,
SELECT PSEUDO, (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "ZJADA"
FROM KOCURY K
WHERE &n > (SELECT COUNT(*)
            FROM KOCURY K2
            WHERE (NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0)) <
                  (NVL(K2.PRZYDZIAL_MYSZY, 0) + NVL(K2.MYSZY_EXTRA, 0)))
ORDER BY "ZJADA" DESC;

-- b. wykorzystując pseudokolumnę ROWNUM,
SELECT PSEUDO, (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "ZJADA"
FROM KOCURY
WHERE (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))
        IN(SELECT *
           FROM (SELECT DISTINCT NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0) x FROM KOCURY ORDER BY x DESC)
           WHERE ROWNUM <= &n)
ORDER BY "ZJADA" DESC;

-- c. wykorzystując złączenie relacji Kocury z relacją Kocury
SELECT K.PSEUDO, (NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0)) "ZJADA"
FROM KOCURY K,
     KOCURY K2
WHERE (NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0)) <= (NVL(K2.PRZYDZIAL_MYSZY, 0) + NVL(K2.MYSZY_EXTRA, 0))
GROUP BY K.PSEUDO, K.PRZYDZIAL_MYSZY, K.MYSZY_EXTRA
HAVING &n >= COUNT(DISTINCT (NVL(K2.PRZYDZIAL_MYSZY, 0) + NVL(K2.MYSZY_EXTRA, 0)))
ORDER BY "ZJADA" DESC;

-- d. wykorzystując funkcje analityczne.
SELECT PSEUDO, (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "ZJADA"
FROM (SELECT PSEUDO,
             PRZYDZIAL_MYSZY,
             MYSZY_EXTRA,
             DENSE_RANK() OVER (ORDER BY (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) DESC) "rank"
      FROM KOCURY)
WHERE "rank" <= &n;

-- Zad. 28. Określić lata, dla których liczba wstąpień do stada jest najbliższa
-- (od góry i od dołu) średniej liczbie wstąpień dla wszystkich lat
-- (średnia z wartości określających liczbę wstąpień w poszczególnych latach). Nie stosować perspektywy.
SELECT TO_CHAR(EXTRACT(YEAR FROM W_STADKU_OD)) "ROK", COUNT(*) "LICZBA WSTAPIEN"
FROM KOCURY
GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
HAVING COUNT(*) =
       (SELECT *
        FROM (SELECT COUNT(*)
              FROM KOCURY
              GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
              HAVING COUNT(*) <=
                     (SELECT AVG(COUNT(*)) FROM KOCURY GROUP BY EXTRACT(YEAR FROM W_STADKU_OD))
              ORDER BY COUNT(*) DESC)
        WHERE ROWNUM <= 1)

UNION ALL
SELECT 'Srednia', AVG(COUNT(*))
FROM KOCURY
GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)

UNION ALL
SELECT TO_CHAR(EXTRACT(YEAR FROM W_STADKU_OD)), COUNT(*)
FROM KOCURY
GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
HAVING COUNT(*) =
       (SELECT *
        FROM (SELECT COUNT(*)
              FROM KOCURY
              GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
              HAVING COUNT(*) >=
                     (SELECT AVG(COUNT(*)) FROM KOCURY GROUP BY EXTRACT(YEAR FROM W_STADKU_OD))
              ORDER BY COUNT(*) ASC)
        WHERE ROWNUM <= 1);
-- GROUP BY "LICZBA WSTAPIEN";

-- Zad. 29. Dla kocurów (płeć męska), dla których całkowity przydział myszy nie przekracza średniej w ich bandzie wyznaczyć następujące dane:
-- imię, całkowite spożycie myszy, numer bandy, średnie całkowite spożycie w bandzie.
-- Nie stosować perspektywy. Zadanie rozwiązać na trzy sposoby:
-- a. ze złączeniem ale bez podzapytań,
SELECT K.IMIE,
       (NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0))        "ZJADA",
       K.NR_BANDY,
       AVG((NVL(K2.PRZYDZIAL_MYSZY, 0) + NVL(K2.MYSZY_EXTRA, 0))) "SREDNIA BANDY"
FROM KOCURY K
       RIGHT JOIN KOCURY K2 ON K.NR_BANDY = K2.NR_BANDY
WHERE K.PLEC = 'M'
GROUP BY K.IMIE, K.PRZYDZIAL_MYSZY, K.MYSZY_EXTRA, K.NR_BANDY
HAVING (NVL(K.PRZYDZIAL_MYSZY, 0) + NVL(K.MYSZY_EXTRA, 0)) <= AVG((NVL(K2.PRZYDZIAL_MYSZY, 0) + NVL(K2.MYSZY_EXTRA, 0)))
ORDER BY K.NR_BANDY DESC;

-- b. ze złączenie i z jedynym podzapytaniem w klauzurze FROM,
SELECT IMIE, (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "ZJADA", NR_BANDY, "SREDNIA BANDY"
FROM KOCURY
       LEFT JOIN (SELECT NR_BANDY banda, AVG((NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))) "SREDNIA BANDY"
                  FROM KOCURY
                  GROUP BY NR_BANDY) ON NR_BANDY = banda
WHERE PLEC = 'M'
  AND (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) < "SREDNIA BANDY"
ORDER BY NR_BANDY DESC;

-- c. bez złączeń i z dwoma podzapytaniami: w klauzurach SELECT i WHERE.
SELECT IMIE,
       (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) "ZJADA",
       NR_BANDY,
       (SELECT AVG((NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)))
        FROM KOCURY K2
        WHERE K2.NR_BANDY = K.NR_BANDY
        GROUP BY K2.NR_BANDY)                          "SREDNIA BANDY"
FROM KOCURY K
WHERE PLEC = 'M'
  AND (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) < (SELECT AVG((NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)))
                                                         FROM KOCURY K2
                                                         WHERE K2.NR_BANDY = K.NR_BANDY
                                                         GROUP BY K2.NR_BANDY)
ORDER BY "SREDNIA BANDY";

-- Zad. 30. Wygenerować listę kotów z zaznaczonymi kotami o najwyższym i o najniższym stażu w swoich bandach.
-- Zastosować operatory zbiorowe.
SELECT IMIE, W_STADKU_OD "WSTAPIL DO STADKA", 'NAJMLODSZY STAZEM W BAZNDZIE ' || NAZWA " "
FROM KOCURY
       LEFT JOIN BANDY ON KOCURY.NR_BANDY = BANDY.NR_BANDY
WHERE W_STADKU_OD = (SELECT MIN(W_STADKU_OD) FROM KOCURY K WHERE BANDY.NR_BANDY = K.NR_BANDY GROUP BY NR_BANDY)
UNION
SELECT IMIE, W_STADKU_OD "WSTAPIL DO STADKA", 'NAJSTARSZY STAZEM W BAZNDZIE ' || NAZWA " "
FROM KOCURY
       LEFT JOIN BANDY ON KOCURY.NR_BANDY = BANDY.NR_BANDY
WHERE W_STADKU_OD = (SELECT MAX(W_STADKU_OD) FROM KOCURY K WHERE BANDY.NR_BANDY = K.NR_BANDY GROUP BY NR_BANDY)
UNION
SELECT IMIE, W_STADKU_OD "WSTAPIL DO STADKA", ' '" "
FROM KOCURY
       LEFT JOIN BANDY ON KOCURY.NR_BANDY = BANDY.NR_BANDY
WHERE W_STADKU_OD NOT IN ((SELECT MIN(W_STADKU_OD) FROM KOCURY K WHERE BANDY.NR_BANDY = K.NR_BANDY GROUP BY NR_BANDY),
                          (SELECT MAX(W_STADKU_OD) FROM KOCURY K WHERE BANDY.NR_BANDY = K.NR_BANDY GROUP BY NR_BANDY));

-- Zad. 31. Zdefiniować perspektywę wybierającą następujące dane: nazwę bandy, średni, maksymalny i minimalny przydział myszy w bandzie,
-- całkowitą liczbę kotów w bandzie oraz liczbę kotów pobierających w bandzie przydziały dodatkowe.
-- Posługując się zdefiniowaną perspektywą wybrać następujące dane o kocie, którego pseudonim podawany jest interaktywnie z klawiatury:
-- pseudonim, imię, funkcja, przydział myszy, minimalny i maksymalny przydział myszy w jego bandzie oraz datę wstąpienia do stada.
DROP VIEW Perspektywa31;
CREATE VIEW Perspektywa31 (
    NAZWA_BANDY, SRE_SPOZ, MAX_SPOZ, MIN_SPOZ, KOTY, KOTY_Z_DOD
) AS
  SELECT BANDY.NAZWA,
         AVG(NVL(PRZYDZIAL_MYSZY, 0)),
         MAX(NVL(PRZYDZIAL_MYSZY, 0)),
         MIN(NVL(PRZYDZIAL_MYSZY, 0)),
         COUNT(*),
         COUNT(MYSZY_EXTRA)
  FROM BANDY
         LEFT JOIN KOCURY USING (NR_BANDY)
  GROUP BY BANDY.NAZWA;

SELECT *
FROM Perspektywa31;
SELECT PSEUDO                                  "PSEUDONIM",
       IMIE,
       FUNKCJA,
       PRZYDZIAL_MYSZY                         "ZJADA",
       'OD ' || MIN_SPOZ || ' DO ' || MAX_SPOZ "GRANICE SPOZYCIA",
       W_STADKU_OD                             "LOWI OD"
FROM KOCURY
       JOIN BANDY USING (NR_BANDY)
       JOIN Perspektywa31 ON BANDY.NAZWA = Perspektywa31.NAZWA_BANDY
WHERE PSEUDO = &x;

-- Zad. 32. Dla kotów o trzech najdłuższym stażach w połączonych bandach CZARNI RYCERZE i ŁACIACI MYŚLIWI
-- zwiększyć przydział myszy o 10% minimalnego przydziału w całym stadzie lub o 10 w zależności od tego czy podwyżka dotyczy kota płci żeńskiej czy kota płci męskiej.
-- Przydział myszy extra dla kotów obu płci zwiększyć o 15% średniego przydziału extra w bandzie kota.
-- Wyświetlić na ekranie wartości przed i po podwyżce a następnie wycofać zmiany.
SELECT PSEUDO "Pseudonim", PLEC, PRZYDZIAL_MYSZY "Myszy przed podw.", MYSZY_EXTRA "Extra przed podw."
FROM KOCURY
WHERE PSEUDO IN (SELECT *
                 FROM (SELECT PSEUDO
                       FROM KOCURY
                              JOIN BANDY USING (NR_BANDY)
                       WHERE NAZWA = 'CZARNI RYCERZE'
                       ORDER BY W_STADKU_OD)
                 WHERE ROWNUM <= 3
                 UNION
                 SELECT *
                 FROM (SELECT PSEUDO
                       FROM KOCURY
                              JOIN BANDY USING (NR_BANDY)
                       WHERE NAZWA = 'LACIACI MYSLIWI'
                       ORDER BY W_STADKU_OD)
                 WHERE ROWNUM <= 3)
ORDER BY NR_BANDY, W_STADKU_OD;

UPDATE KOCURY K1
SET PRZYDZIAL_MYSZY = CASE
                        WHEN PLEC = 'D' THEN NVL(PRZYDZIAL_MYSZY, 0) + 0.1 * (SELECT MIN(NVL(PRZYDZIAL_MYSZY, 0))
                                                                              FROM KOCURY)
                        WHEN PLEC = 'M' THEN NVL(PRZYDZIAL_MYSZY, 0) + 10
    END,
    MYSZY_EXTRA     = NVL(MYSZY_EXTRA, 0) + 0.15 * (SELECT AVG(NVL(MYSZY_EXTRA, 0))
                                                    FROM KOCURY
                                                    WHERE K1.NR_BANDY = KOCURY.NR_BANDY)
WHERE PSEUDO IN (SELECT *
                 FROM (SELECT KOCURY.PSEUDO
                       FROM KOCURY
                              JOIN BANDY USING (NR_BANDY)
                       WHERE NAZWA = 'CZARNI RYCERZE'
                       ORDER BY W_STADKU_OD)
                 WHERE ROWNUM <= 3
                 UNION
                 SELECT *
                 FROM (SELECT PSEUDO
                       FROM KOCURY
                              JOIN BANDY USING (NR_BANDY)
                       WHERE NAZWA = 'LACIACI MYSLIWI'
                       ORDER BY W_STADKU_OD)
                 WHERE ROWNUM <= 3);

SELECT PSEUDO "Pseudonim", PLEC, PRZYDZIAL_MYSZY "Myszy po podw.", MYSZY_EXTRA "Extra po podw."
FROM KOCURY
WHERE PSEUDO IN (SELECT *
                 FROM (SELECT PSEUDO
                       FROM KOCURY
                              JOIN BANDY USING (NR_BANDY)
                       WHERE NAZWA = 'CZARNI RYCERZE'
                       ORDER BY W_STADKU_OD)
                 WHERE ROWNUM <= 3
                 UNION ALL
                 SELECT *
                 FROM (SELECT PSEUDO
                       FROM KOCURY
                              JOIN BANDY USING (NR_BANDY)
                       WHERE NAZWA = 'LACIACI MYSLIWI'
                       ORDER BY W_STADKU_OD)
                 WHERE ROWNUM <= 3)
ORDER BY NR_BANDY, W_STADKU_OD;
ROLLBACK;

-- Zad. 33. Napisać zapytanie, w ramach którego obliczone zostaną sumy całkowitego spożycia myszy przez koty sprawujące każdą z funkcji z podziałem na bandy i płcie kotów.
-- Podsumować przydziały dla każdej z funkcji.
-- Zadanie wykonać na dwa sposoby:
-- TODO a. z wykorzystaniem tzw. raportu macierzowego,

-- TODO b. z wykorzystaniem klauzuli PIVOT
