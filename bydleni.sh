#!/bin/sh

echo "Checking prerequisities..."
for utility in wget html2text xmllint; do
  if ! type $utility >/dev/null; then
    echo "ERROR: $utility not available"
    exit 1
  fi
done

echo "Searching..."
i=1
while true; do
  # Pozemky Brno mesto a venkov
  wget "http://www.sreality.cz/search?category_type_cb=1&category_main_cb=3&sub[]=19&price_min=&price_max=5000000&region=&distance=0&rg[]=14&dt[]=73&dt[]=72&estate_area-min=500&estate_area-max=2000&age=0&extension=1&sort=0&perPage=30&hideRegions=0&discount=-1&page=$i" -O search-$i.html -q || echo '   ERROR'
  # Get list of items  in the html
  echo 'cat /html/body/div[3]/div[2]/div/div[4]/div[*]/div/h3/a/@href' | xmllint --html --shell search-$i.html | grep '^\s*href=' | sed 's/^.*"\(.*\)".*$/\1/' | sed 's|^|http://www.sreality.cz|' > search-$i.list
  wc -l search-$i.list
  [ "$( wc -l search-$i.list | cut -d ' ' -f 1 )" -eq 0 ] && break
  let i+=1
  if [ $i -gt 100 ]; then
    echo "WARN: Sreality gave me same results on page 1, 101, 201... so I think it do not allow more than 100 pages."
    break
  fi
done

echo "Investigating..."
touch search-mapping.list
cat search-*.list | sort | while read url; do
  echo "...$url"
  id=$( echo "$url" | sed 's|^.*/\([0-9]\+\)|\1|' )
  wget "$url" -O byt-$id.html -q || echo '   ERROR'
  # Fix
  sed -i 's|</a></li> </ul> </p>|</a></li> </ul>|' byt-$id.html
  grep --quiet "$url" search-mapping.list \
    || echo "$url byt-$id.html" >> search-mapping.list
done

function get_field() {
  echo "cat /html/body/div/div[3]/div/div/div/p[contains(span[1]/strong/text(), '$2')]/span[2]" \
    | xmllint --html --shell $1 2>/dev/null \
    | grep '^<span' | html2text | sed 's/^\s*\(.*\)\s*$/\1/'
}

echo "Parsing..."
for page in $( ls byt-*.html ); do
  # Parse it
  #idzakazky=$( get_field $page "ID:" )
  adresa=$( get_field $page "Adresa:" )
  cena=$( get_field $page "Celkov&aacute; cena:" )
  [ -z "$cena" ] && cena=$( get_field $page "Celková cena:" )
  [ -z "$cena" ] && cena=$( get_field $page "Zlevn&#283;no:" )
  [ -z "$cena" ] && cena=$( get_field $page "Zlevněno:" )
  plocha_pozemku=$( get_field $page "Plocha pozemku:" )
  plocha_podlahova=$( get_field $page "Plocha podlahov&aacute;:" )
  [ -z "$cena" ] && plocha_podlahova=$( get_field $page "Plocha podlahová:" )
  # Skip localities we are not interested in
  echo "$adresa" | grep -i --quiet \
    -e "Babice nad Svitavou" \
    -e "Bedřichovice" \
    -e "Bílovice nad Svitavou" \
    -e "Bohunice" \
    -e "Bosonohy" \
    -e "Branišovice" \
    -e "Bratčice" \
    -e "Březina" \
    -e "Brněnské Ivanovice" \
    -e "Brno-jih" \
    -e "Budkovice" \
    -e "Čebín" \
    -e "Černá Pole" \
    -e "Chrlice" \
    -e "Chudčice" \
    -e "Domašov" \
    -e "Drásov" \
    -e "Dvorska" \
    -e "Heroltice" \
    -e "Holásky" \
    -e "Horákov" \
    -e "Horní Heršpice" \
    -e "Husovice" \
    -e "Jinačovice" \
    -e "Kanice" \
    -e "Kobylnice" \
    -e "Křižínkov" \
    -e "Kupařovice" \
    -e "Kuřimské Jestřabí" \
    -e "Ledce" \
    -e "Lelkova, Jundrov" \
    -e "Líšeň" \
    -e "Lukovany" \
    -e "Medlov" \
    -e "Modřice" \
    -e "Moravany" \
    -e "Nebovidy" \
    -e "Němčičky" \
    -e "Neslovice" \
    -e "Nosislav" \
    -e "Nový Lískovec" \
    -e "Ochoz u Brna" \
    -e "Odrovice" \
    -e "Opatovice" \
    -e "Ostopovice" \
    -e "Ostrovačice" \
    -e "Otmarov" \
    -e "Podolí" \
    -e "Pohořelice" \
    -e "Ponětovice" \
    -e "Popůvky" \
    -e "Pozořice" \
    -e "Prace" \
    -e "Pravlov" \
    -e "Přízřenice" \
    -e "Radostice" \
    -e "Rajhrad" \
    -e "Rajhradice" \
    -e "Rosice" \
    -e "Rozdrojovice" \
    -e "Řícmanice" \
    -e "Sentice" \
    -e "šlapanice" \
    -e "Slatina" \
    -e "Smolín" \
    -e "Starý Lískovec" \
    -e "Střelice" \
    -e "Syrovice" \
    -e "Telnice" \
    -e "Tetčice" \
    -e "Troubsko" \
    -e "Tuřany" \
    -e "Viničné šumice" \
    -e "Vlasatice" \
    -e "Vranov" \
    -e "Žabčice" \
    -e "Zbýšov" \
    -e "Žebětín" \
    -e "Želešice" \
    -e "Železné" \
    -e "Židenice" \
    && continue
  # Show what we have
  link=$( grep "$page" search-mapping.list | cut -d ' ' -f 1 )
  echo "... $page"
  #echo "      idzakazky: $idzakazky"
  echo "      adresa: $adresa"
  echo "      cena: $cena"
  echo "      plocha_pozemku: $plocha_pozemku"
  echo "      plocha_podlahova: $plocha_podlahova"
  echo "      link: $link"
done > byty.txt

#### Get links from search results page
###echo 'cat /html/body/div[3]/div[2]/div/div[*]/diva/@href' | xmllint --html --shell search.html | grep '^\s*href=' | sed 's/^.*"\(.*\)".*$/\1/'
###
#### Get value from house detail
###echo 'cat /html/body/div[4]/div[3]/div/div/div/p[contains(span[1]//text(), "Budova:")]/span[2]' | xmllint --html --shell 2726556252.html
###
#### Show all in krpole
### ./bydleni.sh | grep --before-context=1 'Královo Pole'
