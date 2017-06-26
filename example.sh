
rm -rf run

mkdir run

cd run

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
# https://www2.census.gov/geo/tiger/GENZ2015/shp/

wget https://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_us_county_500k.zip
wget https://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_us_state_500k.zip

## declare an array variable
declare -a arr=("01" "02" "04")

## now loop through the above array
for i in "${arr[@]}"
do
wget https://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_"$i"_bg_500k.zip
wget https://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_"$i"_place_500k.zip
wget https://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_"$i"_tract_500k.zip
done




# repeat for all geo files
for file in *.zip
do unzip $file; done;
# end repeat for all geo files

# programmatically combine?  Separate routine?
mapshaper -i *_tract_500k.shp combine-files \
	-merge-layers \
	-o pacific_states.shp


# repeat for all shp files
for file in *.shp
do mapshaper $file -o format=geojson; done;
# end repeat for all shp files 

# custom per each json file
# alter geoid to match between data and geo file 0400000US31
sed -i -e 's/0400000US/04000US/g' cb_2015_us_county_500k.json
sed -i -e 's/0500000US/05000US/g' cb_2015_us_state_500k.json
# only retain geoid column
tippecanoe -f -o acs1115_county.mbtiles -l county -z 10 -y GEOID -pk cb_2015_us_county_500k.json
tippecanoe -f -o acs1115_state.mbtiles -l state -z 10 -y GEOID -pk cb_2015_us_state_500k.json
# end custom for each json file


exit 1;

# download all CSV files from multi file bucket
gsutil cp gs://acs1115_multisequence/*.csv .

mkdir complete
mkdir encoded
mkdir outputmbtiles

# for each CSV file
# swap columns so geo key is first
for $file in *.csv
do awk -F $',' ' { t = $1; $1 = $50; $50 = t; print; } ' OFS=$',' $file > ./complete/$file;
iconv -f iso-8859-1 -t utf-8 ./complete/$file > ./encoded/$file
done;



# for each mbtiles file 
tile-join -pk -f -o ./outputmbtiles/acs1115_county_eseq001.mbtiles -c ./encoded/eseq001.csv acs1115_county.mbtiles
# end for each mbtiles
# end for each csv 

gsutil rm -r gs://mbtiles_staging
gsutil mb gs://mbtiles_staging

# copy all mbtiles files at once
gsutil cp ./outputmbtiles/acs1115_county_eseq001.mbtiles gs://mbtiles_staging



