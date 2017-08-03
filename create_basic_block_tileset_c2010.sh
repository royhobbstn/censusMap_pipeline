
rm -rf run

mkdir run

cd run

sudo apt-get install -y unzip

sudo apt-get install -y ruby
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)" < /dev/null
PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >>~/.bash_profile

brew install tippecanoe

wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node 8.2.1

npm install -g mapshaper


mkdir stateshp

cd stateshp

mkdir block

declare -a arr=("01" "02")

# declare an array variable
# declare -a arr=("01" "02" "04" "05" "06" "08" "09" "10" "11" "12" "13" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34" "35" "36" "37" "38" "39" "40" "41" "42" "44" "45" "46" "47" "48" "49" "50" "51" "53" "54" "55" "56" "60" "66" "69" "72" "78")

## now loop through the above array
for i in "${arr[@]}"
do
# tiger
wget https://www2.census.gov/geo/tiger/TIGER2010/TABBLOCK/2010/tl_2010_"$i"_tabblock10.zip -P block/
done

cd block

# repeat for all geo files STATES
for file in *.zip
do unzip $file; done;
# end repeat for all geo files

# convert all shp files
mapshaper *.shp -o format=geojson;

# custom per each json file
# alter geoid to match between data and geo file
for file in *.json
do echo "update key $file"; sed -i -e 's/GEOID10/GEO_ID/g' $file;
done;

# TODO - bucketize individual state geojson

# TODO - do attribute join here

mv *.json ./../../../

cd ../../../

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
"; awk -F ',' -v fn=`basename ${file%????}` '{print > fn$6".csv"}' $file; done;

exit 1;


# join 

node merge_geojson_stream.js


# only retain geoid column
tippecanoe -f -o c2010_block.mbtiles -l block -z 10 -y GEO_ID -pk -pf output.geojson
# end custom for each json file

# try some of these:
# --drop-smallest-as-needed
# --drop-densest-as-needed
# --no-tile-size-limit

gsutil mb gs://c2010_block_tiles_staging

gsutil rm gs://c2010_block_tiles_staging/c2010_block.mbtiles

# copy all mbtiles files at once
gsutil cp *.mbtiles gs://c2010_block_tiles_staging
# gsutil cp *.json gs://c2010_tiles_staging

