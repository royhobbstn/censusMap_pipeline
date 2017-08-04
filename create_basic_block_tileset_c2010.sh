

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

exit 1;

# apply header to every applicable CSV
# for every state 2 number code, loop through and add applicable header
# you can use all *.txt files to give you an inventory of table prefixes

for i in *.txt; do echo ${i%%.*}; 
cat header_${i%%.*}_STATE.csv P1_01.csv > header/P1_01.csv; done;
# this is where you left off.  loop through all states available (probably hard code)
# and add header to each of them



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

