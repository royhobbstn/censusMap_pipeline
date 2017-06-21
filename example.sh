
sudo apt-get install -y ruby unzip
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)" < /dev/null
PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >>~/.bash_profile

brew install tippecanoe

wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node

npm install -g mapshaper

wget https://www2.census.gov/geo/tiger/TIGER2015/COUNTY/tl_2015_us_county.zip
unzip tl_2015_us_county.zip

mapshaper tl_2015_us_county.shp -o format=geojson
sed -i -e 's/"GEOID":"/"GEOID":"05000US/g' tl_2015_us_county.json

tippecanoe -f -o acs1115_county.mbtiles -l county -z 12 -y GEOID -pk tl_2015_us_county.json

# run create_concat_seq first to make data available here
# I cut that code out of this place

mkdir complete
awk -F $',' ' { t = $1; $1 = $50; $50 = t; print; } ' OFS=$',' ./readyfiles/eseqCAT001002003.csv > ./complete/eseq001.csv

mkdir encoded
iconv -f iso-8859-1 -t utf-8 ./complete/eseq001.csv > ./encoded/eseq001.csv


mkdir outputmbtiles
tile-join -pk -f -o ./outputmbtiles/acs1115_county_eseq001.mbtiles -c ./encoded/eseq001.csv acs1115_county.mbtiles

gsutil rm -r gs://mbtiles_staging
gsutil mb gs://mbtiles_staging

gsutil cp ./outputmbtiles/acs1115_county_eseq001.mbtiles gs://mbtiles_staging

# cartographic shapefiles
# https://www2.census.gov/geo/tiger/GENZ2015/shp/

# multiple csv files into one tileset
# manual scheme, 3 files at a time?
# try with BG will give better sense on how much information can be fit in tiles

# separate script to combine multiple shapefiles together


# separate script concatenate into groups of 3 into own bucket