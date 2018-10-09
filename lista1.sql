-- noinspection SpellCheckingInspectionForFile

-- Zad. 1. Znajdź imiona wrogów, którzy dopuścili się incydentów w 2009r.


-- Zad. 2. Znajdź wszystkie kotki (płeć żeńska), które przystąpiły do stada między 1 września 2005r. a 31 lipca 2007r.


-- Zad. 3. Wyświetl imiona, gatunki i stopnie wrogości nieprzekupnych wrogów. 
-- Wyniki mają być uporządkowane rosnąco według stopnia wrogości.


-- Zad. 4. Wyświetlić dane o kotach płci męskiej zebrane w jednej kolumnie postaci: 
-- JACEK zwany PLACEK (fun. LOWCZY) lowi myszki w bandzie2 od 2008-12-01
-- Wyniki należy uporządkować malejąco wg daty przystąpienia do stada. 
-- W przypadku tej samej daty przystąpienia wyniki uporządkować alfabetycznie wg pseudonimów.


-- Zad. 5. Znaleźć pierwsze wystąpienie litery A i pierwsze wystąpienie litery L w każdym pseudonimie 
-- a następnie zamienić znalezione litery na odpowiednio # i %. 
-- Wykorzystać funkcje działające na łańcuchach. Brać pod uwagę tylko te pseudonimy, w których występują obie litery.


-- Zad. 6. Wyświetlić imiona kotów z co najmniej dziewięcioletnim stażem
-- (które dodatkowo przystępowały do stada od 1 marca do 30 września), daty ich przystąpienia do stada, 
-- początkowy przydział myszy (obecny przydział, ze względu na podwyżkę po pół roku członkostwa, jest o 10% wyższy od początkowego), 
-- datę wspomnianej podwyżki o 10% oraz aktualnym przydział myszy. 
-- Wykorzystać odpowiednie funkcje działające na datach. W poniższym rozwiązaniu datą bieżącą jest 20.06.2018


-- Zad. 7. Wyświetlić imiona, kwartalne przydziały myszy i kwartalne przydziały dodatkowe dla wszystkich kotów,
-- u których przydział myszy jest większy od dwukrotnego przydziału dodatkowego ale nie mniejszy od 55.


-- Zad. 8. Wyświetlić dla każdego kota (imię) następujące informacje o całkowitym rocznym spożyciu myszy:
-- wartość całkowitego spożycia jeśli przekracza 660, ’Limit’ jeśli jest równe 660, ’Ponizej 660’ jeśli jest mniejsze od 660. 
-- Nie używać operatorów zbiorowych (UNION, INTERSECT, MINUS).


-- Zad. 9. Po kilkumiesięcznym, spowodowanym kryzysem, zamrożeniu wydawania myszy Tygrys z dniem bieżącym wznowił wypłaty zgodnie z zasadą,
-- że koty, które przystąpiły do stada w pierwszej połowie miesiąca (łącznie z 15-m) 
-- otrzymują pierwszy po przerwie przydział myszy w ostatnią środę bieżącego miesiąca, 
-- natomiast koty, które przystąpiły do stada po 15-ym, pierwszy po przerwie przydział myszy otrzymują w ostatnią środę następnego miesiąca. 
-- W kolejnych miesiącach myszy wydawane są wszystkim kotom w ostatnią środę każdego miesiąca. 
-- Wyświetlić dla każdego kota jego pseudonim, datę przystąpienia do stada oraz datę pierwszego po przerwie przydziału myszy, 
-- przy założeniu, że datą bieżącą jest 25 i 27 wrzesień 2018.


-- Zad. 10. Atrybut pseudo w tabeli Kocury jest kluczem głównym tej tabeli.
-- Sprawdzić, czy rzeczywiście wszystkie pseudonimy są wzajemnie różne. Zrobić to samo dla atrybutu szef.


-- Zad. 11. Znaleźć pseudonimy kotów posiadających co najmniej dwóch wrogów.


-- Zad. 12. Znaleźć maksymalny całkowity przydział myszy dla wszystkich grup funkcyjnych
-- (z pominięciem SZEFUNIA i kotów płci męskiej) o średnim całkowitym przydziale 
-- (z uwzględnieniem dodatkowych przydziałów – myszy_extra) większym od 50.


-- Zad. 13. Wyświetlić minimalny przydział myszy w każdej bandzie z podziałem na płcie.


-- Zad. 14. Wyświetlić informację o kocurach (płeć męska) posiadających w hierarchii przełożonych szefa
-- pełniącego funkcję BANDZIOR (wyświetlić także dane tego przełożonego). 
-- Dane kotów podległych konkretnemu szefowi mają być wyświetlone zgodnie z ich miejscem w hierarchii podległości.


-- Zad. 15. Przedstawić informację o podległości kotów posiadających dodatkowy przydział myszy
-- tak aby imię kota stojącego najwyżej w hierarchii było wyświetlone z najmniejszym wcięciem 
-- a pozostałe imiona z wcięciem odpowiednim do miejsca w hierarchii.


-- Zad. 16. Wyświetlić określoną pseudonimami drogę służbową (przez wszystkich kolejnych przełożonych do głównego szefa)
-- kotów płci męskiej o stażu dłuższym niż dziewięć lat (w poniższym rozwiązaniu datą bieżącą jest 20.06.2018) 
-- nie posiadających dodatkowego przydziału myszy.