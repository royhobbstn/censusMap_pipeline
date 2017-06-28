
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
nvm install node

npm install -g mapshaper

# cartographic shapefiles
# https://www2.census.gov/geo/tiger/GENZ2015/shp/

wget https://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_us_county_500k.zip
wget https://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_us_state_500k.zip

# repeat for all geo files COUNTRY
for file in *.zip
do unzip $file; done;
# end repeat for all geo files


# process shapefiles that are broken out into states

mkdir stateshp

cd stateshp

## declare an array variable
declare -a arr=("01" "02" "04" "05" "06" "08" "09" "10" "11" "12" "13" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34" "35" "36" "37" "38" "39" "40" "41" "42" "44" "45" "46" "47" "48" "49" "50" "51" "53" "54" "55" "56" "60" "66" "69" "72" "78")

## now loop through the above array
for i in "${arr[@]}"
do
wget https://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_"$i"_bg_500k.zip
wget https://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_"$i"_place_500k.zip
wget https://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_"$i"_tract_500k.zip
done

# repeat for all geo files STATES
for file in *.zip
do unzip $file; done;
# end repeat for all geo files

# programmatically combine?  Separate routine?
mapshaper -i *_bg_500k.shp combine-files -merge-layers -o ../cb_2015_us_bg_500k.shp
mapshaper -i *_place_500k.shp combine-files -merge-layers -o ../cb_2015_us_place_500k.shp
mapshaper -i *_tract_500k.shp combine-files -merge-layers -o ../cb_2015_us_tract_500k.shp

cd ..

# repeat for all shp files
for file in *.shp
do mapshaper $file -o format=geojson; done;
# end repeat for all shp files 

# custom per each json file
# alter geoid to match between data and geo file 0400000US31
sed -i -e 's/0400000US/04000US/g' cb_2015_us_county_500k.json
sed -i -e 's/0500000US/05000US/g' cb_2015_us_state_500k.json
sed -i -e 's/1500000US/15000US/g' cb_2015_us_bg_500k.json
sed -i -e 's/1600000US/16000US/g' cb_2015_us_place_500k.json
sed -i -e 's/1400000US/14000US/g' cb_2015_us_tract_500k.json


# only retain geoid column
tippecanoe -f -o acs1115_county.mbtiles -l county -z 10 -y GEOID -pk cb_2015_us_county_500k.json
tippecanoe -f -o acs1115_state.mbtiles -l state -z 10 -y GEOID -pk cb_2015_us_state_500k.json
tippecanoe -f -o acs1115_bg.mbtiles -l bg -z 10 -y GEOID -pk cb_2015_us_bg_500k.json
tippecanoe -f -o acs1115_place.mbtiles -l place -z 10 -y GEOID -pk cb_2015_us_place_500k.json
tippecanoe -f -o acs1115_tract.mbtiles -l tract -z 10 -y GEOID -pk cb_2015_us_tract_500k.json
# end custom for each json file

gsutil rm -r gs://acs1115_tiles_staging
gsutil mb gs://acs1115_tiles_staging

# copy all mbtiles files at once
gsutil cp *.mbtiles gs://acs1115_tiles_staging
gsutil cp *.json gs://acs1115_tiles_staging


