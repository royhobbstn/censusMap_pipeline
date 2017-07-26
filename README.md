# censusTileInsanity
Use tippecanoe and tile-join to automate the creation of american community survey  and decennial census vector tilesets.

# Setup

When creating a Google Compute Instance, enable all APIs.

```
sudo apt-get install git

git clone https://github.com/royhobbstn/censusTileInsanity.git
cd censusTileInsanity

bash create_basic_tilesets_acs1115.sh
```

Install NodeJS (if not already installed).  Then, to create the data files needed specifically for the map, run:

```
node createTableCSV_acs1115.js
```

Then, iterate over those datasets and join with the basic tilesets to create the final tilesets:
```
bash create_acs_tilesets_acs1115.sh
```


For the 2010 US Census, the process is similar, but the scripts would be:

```
bash create_basic_tilesets_c2010.sh
node createTableCSV_c2010.js
bash create_census_tilesets_c2010.sh
```

