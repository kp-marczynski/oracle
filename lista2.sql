-- Zad. 17. Wyświetlić pseudonimy, przydziały myszy oraz nazwy band dla kotów operujących na terenie POLE posiadających przydział myszy większy od 50.
-- Uwzględnić fakt, że są w stadzie koty posiadające prawo do polowań na całym „obsługiwanym” przez stado terenie.
-- Nie stosować podzapytań.


-- Zad. 18. Wyświetlić bez stosowania podzapytania imiona i daty przystąpienia do stada kotów,
-- które przystąpiły do stada przed kotem o imieniu ’JACEK’.
-- Wyniki uporządkować malejąco wg daty przystąpienia do stadka.


-- Zad. 19. Dla kotów pełniących funkcję KOT i MILUSIA wyświetlić w kolejności hierarchii imiona wszystkich ich szefów.
-- Zadanie rozwiązać na trzy sposoby:
-- a. z wykorzystaniem tylko złączeń,
-- b. z wykorzystaniem drzewa, operatora CONNECT_BY_ROOT i tabel przestawnych,
-- c. z wykorzystaniem drzewa i funkcji SYS_CONNECT_BY_PATH i operatora CONNECT_BY_ROOT.


-- Zad. 20. Wyświetlić imiona wszystkich kotek, które uczestniczyły w incydentach po 01.01.2007.
-- Dodatkowo wyświetlić nazwy band do których należą kotki, imiona ich wrogów wraz ze stopniem wrogości oraz datę incydentu.


-- Zad. 21. Określić ile kotów w każdej z band posiada wrogów


-- Zad. 22. Znaleźć koty (wraz z pełnioną funkcją), które posiadają więcej niż jednego wroga.


-- Zad. 23. Wyświetlić imiona kotów, które dostają „myszą” premię wraz z ich całkowitym rocznym spożyciem myszy.
-- Dodatkowo jeśli ich roczna dawka myszy przekracza 864 wyświetlić tekst ’powyzej 864’,
-- jeśli jest równa 864 tekst ’864’, jeśli jest mniejsza od 864 tekst ’poniżej 864’.
-- Wyniki uporządkować malejąco wg rocznej dawki myszy. Do rozwiązania wykorzystać operator zbiorowy UNION.


-- Zad. 24. Znaleźć bandy, które nie posiadają członków. Wyświetlić ich numery, nazwy i tereny operowania.
-- Zadanie rozwiązać na dwa sposoby: bez podzapytań i operatorów zbiorowych oraz wykorzystując operatory zbiorowe.


-- Zad. 25. Znaleźć koty, których przydział myszy jest nie mniejszy
-- od potrojonego najwyższego przydziału spośród przydziałów wszystkich MILUŚ operujących w SADZIE.
-- Nie stosować funkcji MAX.


-- Zad. 26. Znaleźć funkcje (pomijając SZEFUNIA), z którymi związany jest najwyższy i najniższy średni całkowity przydział myszy.
-- Nie używać operatorów zbiorowych (UNION, INTERSECT, MINUS).


-- Zad. 27. Znaleźć koty zajmujące pierwszych n miejsc pod względem całkowitej liczby spożywanych myszy (koty o tym samym spożyciu zajmują to samo miejsce!).
-- Zadanie rozwiązać na cztery sposoby:
-- a. wykorzystując podzapytanie skorelowane,
-- b. wykorzystując pseudokolumnę ROWNUM,
-- c. wykorzystując złączenie relacji Kocury z relacją Kocury
-- d. wykorzystując funkcje analityczne.


-- Zad. 28. Określić lata, dla których liczba wstąpień do stada jest najbliższa
-- (od góry i od dołu) średniej liczbie wstąpień dla wszystkich lat
-- (średnia z wartości określających liczbę wstąpień w poszczególnych latach). Nie stosować perspektywy.


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