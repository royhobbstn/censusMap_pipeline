# censusTileInsanity
Use tippecanoe and tile-join to automate the creation of american community survey vector tilesets.

# Setup

Install linux brew and dependencies

```
sudo apt-get install ruby unzip
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >>~/.bash_profile
```

Install Tippecanoe

```
brew install tippecanoe
```

Install NodeJS using NVM
```
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node
```

Install Mapshaper (for converting SHP to GeoJSON)
```
npm install -g mapshaper
```

Download Census Shapefiles & Unzip
```
wget http://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_us_county_20m.zip
unzip cb_2015_us_county_20m.zip
```

Convert to GeoJSON
```
mapshaper cb_2015_us_county_20m.shp -o format=geojson
```

Convert to MBTiles
```
tippecanoe -f -o acs1115_county.mbtiles -l county -z 10 -y GEOID -pk cb_2015_us_county_20m.json
```

-f: Force Overwrite if output mbtiles name already exists
-o: output mbtiles filename
-l: layername (for use by maputnik style)
-z: max zoom level
-y: choose to only keep the GEOID attribute from the input GeoJSON file
-pk: don't enforce a tile size limit of 500KB


Install MBView
```
npm install -g mbview
```

Open up port 3000 to view your tilesets (REVISIT)
```
gcloud compute firewall-rules create openiport3000 --allow tcp:3000 --description="port3
000rule"
```

View Your Tiles
```
mbview -n acs1115_county.mbtiles
```

