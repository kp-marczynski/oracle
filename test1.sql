-- noinspection SpellCheckingInspectionForFile

select *
from Kocury
where plec = 'M'
  and PSEUDO not in (select distinct pseudo from WROGOWIE_KOCUROW)
  and NR_BANDY in (select NR_BANDY from KOCURY group by NR_BANDY having avg(PRZYDZIAL_MYSZY) > 55);

select K.plec, K.funkcja, max(K.PRZYDZIAL_MYSZY), (count(*) - count(K.MYSZY_EXTRA))
from KOCURY K,
     KOCURY K2
where (K.NR_BANDY = K2.NR_BANDY and K2.PSEUDO in ('ZOMBIE', 'LASKA'))
   OR K.NR_BANDY in (select NR_BANDY from kocury group by NR_BANDY having avg(PRZYDZIAL_MYSZY) > 50)
group by K.plec, K.FUNKCJA;

select KOCURY.pseudo, NR_BANDY
from KOCURY
       left join WROGOWIE_KOCUROW on KOCURY.PSEUDO = WROGOWIE_KOCUROW.PSEUDO
where PLEC = 'M'
  and IMIE_WROGA is null
  and NR_BANDY in (select NR_BANDY from KOCURY group by NR_BANDY having avg(PRZYDZIAL_MYSZY) < 55);

select K.NR_BANDY
from KOCURY K
       join Myszy M1 on K.PSEUDO = M1.PSEUDO_LAPACZA
       join Myszy M2 on K.PSEUDO = M2.PSEUDO_ZJADACZA
group by NR_BANDY
having count(NR_BANDY) > 4
   and count(M1.NR_MYSZY) < count(M2.NR_MYSZY);

select nr_bandy
from KOCURY K
       left join MYSZY M1 on K.PSEUDO = M1.PSEUDO_LAPACZA
       left join MYSZY M2 on K.PSEUDO = M2.PSEUDO_ZJADACZA
group by NR_BANDY
having count(M1.NR_MYSZY) in
       (select *
        from (select DISTINCT count(M.NR_MYSZY)
              from KOCURY K
                     left join MYSZY M on K.PSEUDO = M.PSEUDO_ZJADACZA
              group by NR_BANDY
              order by count(M.NR_MYSZY) DESC)
        where ROWNUM <= 2)
   and count(m2.NR_MYSZY) in
       (select *
        from (select DISTINCT count(M.NR_MYSZY)
              from KOCURY K
                     left join MYSZY M on K.PSEUDO = M.PSEUDO_LAPACZA
              group by NR_BANDY
              order by count(M.NR_MYSZY) ASC)
        where ROWNUM <= 2);

select plec, max(PRZYDZIAL_MYSZY)
from kocury K
       inner join FUNKCJE F on K.FUNKCJA = F.FUNKCJA
where K.FUNKCJA in (select FUNKCJA from KOCURY where PSEUDO in ('RAFA', 'SZYBKA'))
  and PRZYDZIAL_MYSZY > 1.1 * MIN_MYSZY
group by PLEC;

select NR_BANDY
from kocury k
       left join WROGOWIE_KOCUROW wk on k.PSEUDO = wk.PSEUDO
where NR_BANDY in(select NR_BANDY, count(*)
                  from KOCURY k
                         left join WROGOWIE_KOCUROW wk on k.PSEUDO = wk.PSEUDO
                  GROUP BY NR_BANDY
                  having count(k.PSEUDO) >= 5
                     and count(wk.DATA_INCYDENTU) = 2)
  and IMIE_WROGA in (select * from (select IMIE_WROGA from WROGOWIE order by STOPIEN_WROGOSCI desc) where ROWNUM <= 3);


select NR_BANDY
from KOCURY K
       left join MYSZY M1 on K.PSEUDO = M1.PSEUDO_LAPACZA
       left join MYSZY M2 on K.PSEUDO = M2.PSEUDO_ZJADACZA
group by NR_BANDY
having count(*) > 4
   and sum(M1.WAGA_MYSZY) > sum(M2.WAGA_MYSZY);

select FUNKCJA
from KOCURY k
       right join myszy m on k.PSEUDO = m.PSEUDO_LAPACZA
where m.WAGA_MYSZY in
      (select * from (select WAGA_MYSZY from myszy order by WAGA_MYSZY) where ROWNUM <= 4)
  and FUNKCJA in ((select FUNKCJA
                   from KOCURY k
                          right join MYSZY m on k.PSEUDO = m.PSEUDO_LAPACZA
                   group by FUNKCJA
                   having count(m.nr_myszy) >= 2), (select funkcja from kocury group by FUNKCJA having count(*) >= 4));