

rm -rf run

mkdir run

cd run

sudo apt-get install -y unzip

wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node 8.2.1

sudo apt-get install -y ruby
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)" < /dev/null
PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >>~/.bash_profile

brew install tippecanoe

npm install
# node createTableCSV_c2010.js

mkdir splits

# download all files from bucket
gsutil cp gs://c2010_tile_tables/*.csv ./splits/

cd splits

# TODO recombine
echo "recombining table files"
ls | awk -F '_' '!x[$1]++{print $1}' | while read -r line
do
    cat $line* > $line\.txt
done

mkdir divide

mv *.txt ./divide

cd divide

# divide by state
for file in *.txt; do echo "splitting $file into states
"; awk -F ',' -v fn=`basename ${file%????}` '{print > fn"_"$6".csv"}' $file; done;

# extract head -1 to new file
for file in *STATE.csv; do head -1 $file > "header_"$file; done;

mkdir header

# apply header to every applicable CSV
# for every state 2 number code, loop through and add applicable header
# you can use all *.txt files to give you an inventory of table prefixes


# declare an array variable
declare -a arr=("01" "02" "04" "05" "06" "08" "09" "10" "11" "12" "13" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34" "35" "36" "37" "38" "39" "40" "41" "42" "44" "45" "46" "47" "48" "49" "50" "51" "53" "54" "55" "56" "60" "66" "69" "72" "78")

for j in "${arr[@]}"; do
echo "adding header to state: $j"
for i in *.txt; do echo ${i%%.*}; 
cat header_${i%%.*}_STATE.csv ${i%%.*}_$j.csv > header/${i%%.*}_$j.csv;
done;
done;


exit 1;

# download geojson
gsutil cp gs://c2010_block_tiles_staging/*.geojson .

# join with geojson
# use https://github.com/node-geojson/geojson-join
npm install -g geojson-join


# loop through geojson
# join 

geojson-join --format=csv test/against.dbf \
    --againstField=id \
    --geojsonField=GEO_ID < test/random.geojson


# merge all joined files together again

# loop through
# merge geojson should be configured to take an argument of the table name to be merged
node merge_geojson_stream.js

# loop through
# convert to tileset; only retain geoid column
tippecanoe -f -o c2010_block.mbtiles -l block -z 10 -y GEO_ID -pk -pf output.geojson
# end custom for each json file



# try some of these:
# --drop-smallest-as-needed
# --drop-densest-as-needed
# --no-tile-size-limit

gsutil rb -f gs://c2010_block_tiles

gsutil mb gs://c2010_block_tiles

# copy all mbtiles files at once
gsutil cp *.mbtiles gs://c2010_block_tiles

