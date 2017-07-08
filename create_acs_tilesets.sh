
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
# wget https://storage.googleapis.com/acs1115_multisequence/eseq_001_002_003.csv
# wget https://storage.googleapis.com/acs1115_tiles_staging/acs1115_state.mbtiles

mkdir completed
mkdir encoded
mkdir outputmbtiles

# TODO should be part of tileCSVmerge
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
tile-join -pk -f -o ./outputmbtiles/${newfile#??????????}_${tile%????????}.mbtiles -c $file $tile
done;
done;



# for each mbtiles file 

# end for each mbtiles
# end for each csv 

gsutil rm -r gs://acs1115_tiles
gsutil mb gs://acs1115_tiles

# copy all mbtiles files at once
gsutil cp ./outputmbtiles/*.mbtiles gs://acs1115_tiles



