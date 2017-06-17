
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

wget http://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_us_county_20m.zip
unzip cb_2015_us_county_20m.zip

mapshaper cb_2015_us_county_20m.shp -o format=geojson

tippecanoe -f -o acs1115_county.mbtiles -l county -z 10 -y GEOID -pk cb_2015_us_county_20m.json

gsutil mb gs://mbtiles_staging
gsutil cp acs1115_county gs://mbtiles_staging

