# censusTileInsanity
Use tippecanoe and tile-join to automate the creation of american community survey vector tilesets.

# Setup

When creating a Google Compute Instance, enable all APIs.

```
sudo apt-get install git

git clone https://github.com/royhobbstn/censusTileInsanity.git
cd censusTileInsanity

bash create_basic_tilesets.sh

```

Install NodeJS (if not already installed).  Then, to create the data files needed specifically for the map, ready the map datatree file and extract all the relevant tables:

```
node createTableCSV.js
```

Then, iterate over those datasets and join with the basic tilesets to create the final tilesets:
```
bash create_acs_tilesets.sh
```