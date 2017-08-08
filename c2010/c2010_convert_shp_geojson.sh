
rm -rf run

mkdir run

cd run

sudo apt-get install -y unzip

wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node 8.2.1

npm install -g mapshaper


mkdir stateshp

cd stateshp

mkdir block

# declare an array variable
declare -a arr=("01" "02" "04" "05" "06" "08" "09" "10" "11" "12" "13" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34" "35" "36" "37" "38" "39" "40" "41" "42" "44" "45" "46" "47" "48" "49" "50" "51" "53" "54" "55" "56" "60" "66" "69" "72" "78")

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

for file in *.json
do
 mv "$file" "${file%.json}.geojson"
done

gsutil rb -f gs://c2010_block_tiles_staging

gsutil mb gs://c2010_block_tiles_staging

# copy all files at once
gsutil cp *.geojson gs://c2010_block_tiles_staging