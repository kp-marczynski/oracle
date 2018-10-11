-- noinspection SpellCheckingInspectionForFile

-- Zad. 1. Znajdź imiona wrogów, którzy dopuścili się incydentów w 2009r.
SELECT IMIE_WROGA "WROG", OPIS_INCYDENTU "PRZEWINA"
FROM WROGOWIE_KOCUROW
WHERE EXTRACT(YEAR from DATA_INCYDENTU) = 2009;

-- Zad. 2. Znajdź wszystkie kotki (płeć żeńska), które przystąpiły do stada między 1 września 2005r. a 31 lipca 2007r.
SELECT IMIE, FUNKCJA, W_STADKU_OD "Z NAMI OD"
FROM KOCURY
WHERE PLEC = 'D'
  AND W_STADKU_OD BETWEEN '2005-09-01' AND '2007-07-30';

-- Zad. 3. Wyświetl imiona, gatunki i stopnie wrogości nieprzekupnych wrogów.
-- Wyniki mają być uporządkowane rosnąco według stopnia wrogości.
SELECT IMIE_WROGA "WROG", GATUNEK, STOPIEN_WROGOSCI "STOPIEN WROGOSCI"
FROM WROGOWIE
ORDER BY STOPIEN_WROGOSCI;

-- Zad. 4. Wyświetlić dane o kotach płci męskiej zebrane w jednej kolumnie postaci: 
-- JACEK zwany PLACEK (fun. LOWCZY) lowi myszki w bandzie2 od 2008-12-01
-- Wyniki należy uporządkować malejąco wg daty przystąpienia do stada. 
-- W przypadku tej samej daty przystąpienia wyniki uporządkować alfabetycznie wg pseudonimów.
SELECT IMIE || ' zwany ' || PSEUDO || ' (fun. ' || FUNKCJA || ') lowi myszki w bandzie ' || NR_BANDY || ' od ' ||
       W_STADKU_OD
FROM KOCURY
WHERE PLEC = 'M'
ORDER BY W_STADKU_OD DESC, IMIE;

-- Zad. 5. Znaleźć pierwsze wystąpienie litery A i pierwsze wystąpienie litery L w każdym pseudonimie 
-- a następnie zamienić znalezione litery na odpowiednio # i %. 
-- Wykorzystać funkcje działające na łańcuchach. Brać pod uwagę tylko te pseudonimy, w których występują obie litery.
-- REGEXP_REPLACE(<source_string>, <pattern>,<replace_string>, <position>, <occurrence>, <match_parameter>)
SELECT PSEUDO, REGEXP_REPLACE(REGEXP_REPLACE(PSEUDO, 'L', '%', 1, 1), 'A', '#', 1, 1) "Po wymianie A na # oraz L na %"
FROM KOCURY
WHERE PSEUDO LIKE '%A%'
  AND PSEUDO LIKE '%L%';

-- Zad. 6. Wyświetlić imiona kotów z co najmniej dziewięcioletnim stażem
-- (które dodatkowo przystępowały do stada od 1 marca do 30 września), daty ich przystąpienia do stada, 
-- początkowy przydział myszy (obecny przydział, ze względu na podwyżkę po pół roku członkostwa, jest o 10% wyższy od początkowego), 
-- datę wspomnianej podwyżki o 10% oraz aktualnym przydział myszy. 
-- Wykorzystać odpowiednie funkcje działające na datach. W poniższym rozwiązaniu datą bieżącą jest 20.06.2018
SELECT IMIE,
       W_STADKU_OD                          "W stadku",
       ROUND(NVL(PRZYDZIAL_MYSZY, 0) / 1.1) "Zjadal",
       ADD_MONTHS(W_STADKU_OD, 6)           "Podwyzka",
       NVL(PRZYDZIAL_MYSZY, 0)              "Zjada"
FROM KOCURY
WHERE ADD_MONTHS(W_STADKU_OD, 9 * 12) <= SYSDATE --'2018-06-20'
  AND EXTRACT(MONTH FROM W_STADKU_OD) BETWEEN 3 AND 9;

-- Zad. 7. Wyświetlić imiona, kwartalne przydziały myszy i kwartalne przydziały dodatkowe dla wszystkich kotów,
-- u których przydział myszy jest większy od dwukrotnego przydziału dodatkowego ale nie mniejszy od 55.
SELECT IMIE, 3 * NVL(PRZYDZIAL_MYSZY, 0) "MYSZY KWARTALNE", 3 * NVL(MYSZY_EXTRA, 0) "KWARTALNE DODATKI"
FROM KOCURY
WHERE NVL(PRZYDZIAL_MYSZY, 0) > 2 * NVL(MYSZY_EXTRA, 0)
  AND NVL(PRZYDZIAL_MYSZY, 0) >= 55;

-- Zad. 8. Wyświetlić dla każdego kota (imię) następujące informacje o całkowitym rocznym spożyciu myszy:
-- wartość całkowitego spożycia jeśli przekracza 660, ’Limit’ jeśli jest równe 660, ’Ponizej 660’ jeśli jest mniejsze od 660. 
-- Nie używać operatorów zbiorowych (UNION, INTERSECT, MINUS).
SELECT IMIE,
       CASE
         WHEN (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) > 55
                 THEN TO_CHAR((NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) * 12)
         WHEN (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) = 55
                 THEN 'Limit'
         ELSE 'Ponizej 660'
           END "Zjada Rocznie"
FROM KOCURY
ORDER BY IMIE;

-- Zad. 9. Po kilkumiesięcznym, spowodowanym kryzysem, zamrożeniu wydawania myszy Tygrys z dniem bieżącym wznowił wypłaty zgodnie z zasadą,
-- że koty, które przystąpiły do stada w pierwszej połowie miesiąca (łącznie z 15-m) 
-- otrzymują pierwszy po przerwie przydział myszy w ostatnią środę bieżącego miesiąca, 
-- natomiast koty, które przystąpiły do stada po 15-ym, pierwszy po przerwie przydział myszy otrzymują w ostatnią środę następnego miesiąca. 
-- W kolejnych miesiącach myszy wydawane są wszystkim kotom w ostatnią środę każdego miesiąca. 
-- Wyświetlić dla każdego kota jego pseudonim, datę przystąpienia do stada oraz datę pierwszego po przerwie przydziału myszy, 
-- przy założeniu, że datą bieżącą jest

-- a) 25 wrzesień 2018.
SELECT PSEUDO,
       W_STADKU_OD "W STADKU",
       CASE
         WHEN '2018-09-25' > NEXT_DAY(LAST_DAY('2018-09-25') - INTERVAL '7' DAY, 'WEDNESDAY') OR
              EXTRACT(DAY FROM W_STADKU_OD) > 15
                 THEN NEXT_DAY(LAST_DAY(ADD_MONTHS('2018-09-25', 1)) - INTERVAL '7' DAY, 'WEDNESDAY')
         ELSE NEXT_DAY(LAST_DAY('2018-09-25') - INTERVAL '7' DAY, 'WEDNESDAY')
           END     "WYPLATA"
FROM KOCURY
ORDER BY W_STADKU_OD;

-- b) 27 wrzesień 2018.
SELECT PSEUDO,
       W_STADKU_OD "W STADKU",
       CASE
         WHEN '2018-09-27' > NEXT_DAY(LAST_DAY('2018-09-27') - INTERVAL '7' DAY, 'WEDNESDAY') OR
              EXTRACT(DAY FROM W_STADKU_OD) > 15
                 THEN NEXT_DAY(LAST_DAY(ADD_MONTHS('2018-09-27', 1)) - INTERVAL '7' DAY, 'WEDNESDAY')
         ELSE NEXT_DAY(LAST_DAY('2018-09-27') - INTERVAL '7' DAY, 'WEDNESDAY')
           END     "WYPLATA"
FROM KOCURY
ORDER BY W_STADKU_OD;

-- Zad. 10. Atrybut pseudo w tabeli Kocury jest kluczem głównym tej tabeli.
-- Sprawdzić, czy rzeczywiście wszystkie pseudonimy są wzajemnie różne. Zrobić to samo dla atrybutu szef.
SELECT PSEUDO || ' - ' || CASE
                            WHEN COUNT(PSEUDO) = 1
                                    THEN 'Unikalny'
                            ELSE 'Nieunikalny'
    END "Unikalnosc atr. PSEUDO"
FROM KOCURY
GROUP BY PSEUDO
ORDER BY PSEUDO;

SELECT SZEF || ' - ' || CASE
                          WHEN COUNT(SZEF) = 1
                                  THEN 'Unikalny'
                          ELSE 'Nieunikalny'
    END "Unikalnosc atr. SZEF"
FROM KOCURY
WHERE SZEF IS NOT NULL
GROUP BY SZEF
ORDER BY SZEF;

-- Zad. 11. Znaleźć pseudonimy kotów posiadających co najmniej dwóch wrogów.
SELECT PSEUDO "Pseudonim", COUNT(*) "Liczba wrogow"
FROM WROGOWIE_KOCUROW
GROUP BY PSEUDO
HAVING COUNT(*) >= 2;

-- Zad. 12. Znaleźć maksymalny całkowity przydział myszy dla wszystkich grup funkcyjnych
-- (z pominięciem SZEFUNIA i kotów płci męskiej) o średnim całkowitym przydziale 
-- (z uwzględnieniem dodatkowych przydziałów – myszy_extra) większym od 50.
SELECT 'Liczba kotow = '                                  " ",
       COUNT(*)                                           " ",
       ' lowi jako '                                      " ",
       FUNKCJA                                            " ",
       ' i zjada max. '                                   " ",
       MAX(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) " ",
       ' myszy miesiecznie'                               " "
FROM KOCURY
WHERE PLEC != 'M'
  AND FUNKCJA != 'SZEFUNIO'
GROUP BY FUNKCJA
HAVING AVG(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 1)) > 50;

-- Zad. 13. Wyświetlić minimalny przydział myszy w każdej bandzie z podziałem na płcie.
SELECT NR_BANDY "Nr bandy", PLEC "Plec", MIN(NVL(PRZYDZIAL_MYSZY, 0)) "Minimalny przydzial"
FROM KOCURY
GROUP BY NR_BANDY, PLEC;

-- Zad. 14. Wyświetlić informację o kocurach (płeć męska) posiadających w hierarchii przełożonych szefa
-- pełniącego funkcję BANDZIOR (wyświetlić także dane tego przełożonego). 
-- Dane kotów podległych konkretnemu szefowi mają być wyświetlone zgodnie z ich miejscem w hierarchii podległości.
SELECT LEVEL "Poziom", PSEUDO "Pseudonim", FUNKCJA "Funkcja", NR_BANDY "Nr bandy"
FROM KOCURY
WHERE PLEC = 'M'
CONNECT BY PRIOR PSEUDO = SZEF
START WITH FUNKCJA = 'BANDZIOR';

-- Zad. 15. Przedstawić informację o podległości kotów posiadających dodatkowy przydział myszy
-- tak aby imię kota stojącego najwyżej w hierarchii było wyświetlone z najmniejszym wcięciem 
-- a pozostałe imiona z wcięciem odpowiednim do miejsca w hierarchii.
SELECT LPAD(LEVEL - 1, 4 * (LEVEL - 1) + LENGTH(level - 1), '===>') || '            ' || IMIE "Hierarchia",
       NVL(SZEF, 'Sam sobie panem')                                                           "Pseudo szefa",
       FUNKCJA                                                                                "Funkcja"
From KOCURY
WHERE NVL(MYSZY_EXTRA, 0) > 0
CONNECT BY PRIOR PSEUDO = SZEF
START WITH SZEF IS NULL;

-- Zad. 16. Wyświetlić określoną pseudonimami drogę służbową (przez wszystkich kolejnych przełożonych do głównego szefa)
-- kotów płci męskiej o stażu dłuższym niż dziewięć lat (w poniższym rozwiązaniu datą bieżącą jest 20.06.2018) 
-- nie posiadających dodatkowego przydziału myszy.
SELECT LPAD(' ', 4 * (LEVEL - 1)) || PSEUDO "Droga sluzbowa"
FROM KOCURY
CONNECT BY PSEUDO = PRIOR SZEF
       AND PSEUDO != 'RAFA'
START WITH PLEC = 'M'
       AND MONTHS_BETWEEN('2018-06-20' /*SYSDATE*/, W_STADKU_OD) > 9 * 12
       AND NVL(MYSZY_EXTRA, 0) = 0;