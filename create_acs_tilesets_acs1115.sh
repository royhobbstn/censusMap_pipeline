
rm -rf advanced

mkdir advanced

cd advanced

sudo apt-get install -y ruby
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)" < /dev/null
PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >>~/.bash_profile

brew install tippecanoe


# download all CSV files from multi file bucket
gsutil cp gs://acs1115_tile_tables/*.csv .
gsutil cp gs://acs1115_tiles_staging/*.mbtiles .

mkdir completed
mkdir encoded
mkdir outputmbtiles

# for each CSV file
# swap columns so geo key is first
for file in *.csv
do awk -F $',' ' { t = $1; $1 = $50; $50 = t; print; } ' OFS=$',' $file > ./completed/$file;
iconv -f iso-8859-1 -t utf-8 ./completed/$file > ./encoded/$file
sed -i '1s/^/AFF/' ./encoded/$file
done;

# nested loops to join every csv with every tileset
for file in ./encoded/*.csv
do for tile in *.mbtiles
do newfile=${file%????}
echo "joining $newfile with $tile"
tile-join -pk -f -o ./outputmbtiles/${newfile#??????????}_${tile%????????}.mbtiles -c $file --exclude=FILEID --exclude=STUSAB --exclude=SUMLEVEL --exclude=COMPONENT --exclude=LOGRECNO --exclude=US --exclude=REGION --exclude=DIVISION --exclude=STATECE --exclude=STATE --exclude=COUNTY --exclude=COUSUB --exclude=PLACE --exclude=TRACT --exclude=BLKGRP --exclude=CONCIT --exclude=AIANHH --exclude=AIANHHFP --exclude=AIHHTLI --exclude=AITSCE --exclude=AITS --exclude=ANRC --exclude=CBSA --exclude=CSA --exclude=METDIV --exclude=MACC --exclude=MEMI --exclude=NECTA --exclude=CNECTA --exclude=NECTADIV --exclude=UA --exclude=BLANK1 --exclude=CDCURR --exclude=SLDU --exclude=SLDL --exclude=BLANK2 --exclude=BLANK3 --exclude=ZCTA5 --exclude=SUBMCD --exclude=SDELM --exclude=SDSEC --exclude=SDUNI --exclude=UR --exclude=PCI --exclude=BLANK4 --exclude=BLANK5 --exclude=PUMA5 --exclude=BLANK6 --exclude=KEY --exclude=BTTR --exclude=BTBG --exclude=BLANK7 $tile
done;
done;


gsutil rm -r gs://acs1115_tiles
gsutil mb gs://acs1115_tiles

# copy all mbtiles files at once
gsutil cp ./outputmbtiles/*.mbtiles gs://acs1115_tiles



