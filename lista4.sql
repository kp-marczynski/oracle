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