

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

exit 1;

# download geojson

# join with geojson

# use https://github.com/node-geojson/geojson-join

# merge all joined files together again

# loop through
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

