
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

# cartographic shapefiles
# programmatically combine?  Separate routine?
# https://www2.census.gov/geo/tiger/GENZ2015/shp/

# repeat for all geo files
wget https://www2.census.gov/geo/tiger/TIGER2015/COUNTY/tl_2015_us_county.zip
unzip tl_2015_us_county.zip
# end repeat for all geo files

# repeat for all shp files
mapshaper tl_2015_us_county.shp -o format=geojson
# end repeat for all shp files 

# repeat for all json files 
# alter geoid to match between data and geo file
sed -i -e 's/"GEOID":"/"GEOID":"05000US/g' tl_2015_us_county.json
# only retain geoid column
tippecanoe -f -o acs1115_county.mbtiles -l county -z 12 -y GEOID -pk tl_2015_us_county.json
# end repeat for all json files

# download all CSV files from multi file bucket

mkdir complete
mkdir encoded
mkdir outputmbtiles

# for each CSV file
# swap columns so geo key is first
awk -F $',' ' { t = $1; $1 = $50; $50 = t; print; } ' OFS=$',' ./readyfiles/eseqCAT001002003.csv > ./complete/eseq001.csv

iconv -f iso-8859-1 -t utf-8 ./complete/eseq001.csv > ./encoded/eseq001.csv

# for each mbtiles file 
tile-join -pk -f -o ./outputmbtiles/acs1115_county_eseq001.mbtiles -c ./encoded/eseq001.csv acs1115_county.mbtiles
# end for each mbtiles
# end for each csv 

gsutil rm -r gs://mbtiles_staging
gsutil mb gs://mbtiles_staging

# copy all mbtiles files at once
gsutil cp ./outputmbtiles/acs1115_county_eseq001.mbtiles gs://mbtiles_staging



