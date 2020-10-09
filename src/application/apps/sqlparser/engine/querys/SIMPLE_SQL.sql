/*
Простой SQL файл для теста
 */
select
    A.kek,  -- Kek comment
    B.lol   -- Lol comment
from
    SOURCE_1 A  -- Kek source
join
    SOURCE_2 B  -- Lol source
/* Xmm comment adf
   vot tak vot
   i tyt toje napishy
   */
on A.id = B.id and b.dtt <= to_date('01.01.2020')