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

Install NodeJS (if not already installed).  Then:

```
node createTableCSV.js
```

Then to create the final tilesets:
```
bash create_acs_tilesets.sh
```