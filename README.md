SRealityParser
==============

Stáhne a rozparsuje všechny nabídky ze serveru www.sreality.cz podle zadaných kritérií. Já to používal pro vytváření snapshotů aktuální nabídky a dělání diffu.

1. Naklikejte si na sreality.cz vaše preference a jděte na druhou stránku s výsledky
2. Odkaz na tu stránku s hodnotou parametru `page` nastavenou na `$1` dejte místo linku na 15. řádku skriptu
3. Na 58. řádku začíná ubercool blacklist který si asi taky budete chtít změnit
4. Po doběhnutí skriptu se podívejte do souboru `byty.txt`

Já to používal abych našel nové/upravené nabídky dle mých kritérií. Takže napríklad pozemky v okresech Brno město a venkov do 5ti miliónů uložím 1. 1. 2013 a 7. 1. 2013 a potom jednoduše diffnu výstup skriptu 20130101/byty.txt a 20130107/byty.txt.

Sreality.cz někdy změní HTML na stránkách a pak je potřeba opravit XPath výrazy. Taky určování ceny je dost fuzzy protože nikdy nevíte jestli je to s nebo bez provize a podobně.
