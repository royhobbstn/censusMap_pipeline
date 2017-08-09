# censusTileInsanity
Use tippecanoe and tile-join to automate the creation of american community survey and decennial census vector tilesets.

# Setup

When creating a Google Compute Instance, enable all APIs.  Load it up with 200GB SSD.

```
sudo apt-get install git

git clone https://github.com/royhobbstn/censusTileInsanity.git
cd censusTileInsanity
```

Install NodeJS

```
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node
```

## ACS Tile Pipeline

```
cd acs1115_bg
```

**Overall Strategy**

Create basic .mbtiles files with only the AFFGEOID attribute for each geography level.  Join with CSV data for each table that the CensusMap requires, creating table-specific mbtiles files.

**Steps**

First, create the basic .mbtiles files to join with later.

```
bash create_basic_tilesets_acs1115.sh
```

Then create the data files needed specifically for the map:

```
node createTableCSV_acs1115.js
```

Then, iterate over those datasets and join with the basic tilesets to create the final tilesets:
```
bash create_acs_tilesets_acs1115.sh
```

## 2010 Census Tile Pipeline

```
cd c2010
```

For the 2010 US Census, the process is a bit more involved (due to difficulty of dealing with the size of census block data):


Create the data files needed specifically for the map (determined from the map's datatree.json file).  Upload to ```c2010_tile_tables```:

```
node createTableCSV_c2010.js
```

Download all block shapefiles.  Convert them to GeoJSON.  Copy them to bucket: ```gs://c2010_block_tiles_staging```

```
bash c2010_convert_shp_geojson.sh
```

Download all pre-created map CSV files from ```gs://c2010_tile_tables```.  Split them into state-level CSV files.  Download all state-level block geojson files from ```gs://c2010_block_tiles_staging```.  Join them with the CSV data.  Merge all the states into one big geojson.  Create one big .mbtiles block dataset per each data table.  Upload to ```gs://c2010_block_tiles```.

```
bash create_basic_block_tileset_c2010.sh
```

Download state, county, place, tract, and block group files from the US Census.  (place, tract and block group will need to be combined from state-level files.)  Convert them all to GeoJSON files, and then convert them all to .mbtiles datasets, keeping only the GEO\_ID attribute.  Upload to ```gs://c2010_tiles_staging```.

```
bash create_basic_tilesets_c2010.sh
```

Download all CSV tables (```gs://c2010_tile_tables```) and all (non-block) tile tables (```gs://c2010_tiles_staging```).  Join them together, and upload the result to ```gs://c2010_tiles```.

```
bash create_census_tilesets_c2010.sh
```






