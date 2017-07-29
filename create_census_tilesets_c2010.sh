
rm -rf advanced

mkdir advanced

cd advanced

mkdir splits

sudo apt-get install -y ruby
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)" < /dev/null
PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >>~/.bash_profile

brew install tippecanoe


# download all CSV files from multi file bucket
gsutil cp gs://c2010_tile_tables/*.csv ./splits/
gsutil cp gs://c2010_tiles_staging/*.mbtiles .

cd splits

# TODO recombine
ls | awk -F '_' '!x[$1]++{print $1}' | while read -r line
do
    cat $line* > all_$line\.txt
done

mv *.txt ./../

mkdir completed
mkdir encoded
mkdir outputmbtiles

# for each CSV file
# swap columns so geo key is first
for file in *.txt
do awk -F $',' ' { t = $1; $1 = $98; $98 = t; print; } ' OFS=$',' $file > ./completed/$file;
iconv -f iso-8859-1 -t utf-8 ./completed/$file > ./encoded/$file
done;

# nested loops to join every csv with every tileset
for file in ./encoded/*.txt
do for tile in *.mbtiles
do newfile=${file%????}
echo "joining $newfile with $tile"
tile-join -pk -f -o ./outputmbtiles/${newfile#??????????}_${tile%????????}.mbtiles -c $file --exclude=KEY --exclude=SUMLEV --exclude=GEOCOMP --exclude=REGION --exclude=DIVISION --exclude=STATE --exclude=COUNTY --exclude=COUNTYCC --exclude=COUNTYSC --exclude=COUSUB --exclude=COUSUBCC --exclude=COUSUBSC --exclude=PLACE --exclude=PLACECC --exclude=PLACESC --exclude=TRACT --exclude=BLKGRP --exclude=BLOCK --exclude=IUC --exclude=CONCIT --exclude=CONCITCC --exclude=CONCITSC --exclude=AIANHH --exclude=AIANHHFP --exclude=AIANHHCC --exclude=AIHHTLI --exclude=AITSCE --exclude=AITS --exclude=AITSCC --exclude=TTRACT --exclude=TBLKGRP --exclude=ANRC --exclude=ANRCCC --exclude=CBSA --exclude=CBSASC --exclude=METDIV --exclude=CSA --exclude=NECTA --exclude=NECTASC --exclude=NECTADIV --exclude=CNECTA --exclude=CBSAPCI --exclude=NECTAPCI --exclude=UA --exclude=UASC --exclude=UATYPE --exclude=UR --exclude=CD --exclude=SLDU --exclude=SLDL --exclude=VTD --exclude=VTDI --exclude=RESERVE2 --exclude=ZCTA5 --exclude=SUBMCD --exclude=SUBMCDCC --exclude=SDELM --exclude=SDSEC --exclude=SDUNI --exclude=AREALAND --exclude=AREAWATR --exclude=NAME --exclude=FUNCSTAT --exclude=GCUNI --exclude=POP100 --exclude=HU100 --exclude=INTPTLAT --exclude=INTPTLON --exclude=LSADC --exclude=PARTFLAG --exclude=RESERVE3 --exclude=UGA --exclude=STATENS --exclude=COUNTYNS --exclude=COUSUBNS --exclude=PLACENS --exclude=CONCITNS --exclude=AIANHHNS --exclude=AITSNS --exclude=ANRCNS --exclude=SUBMCDNS --exclude=CD113 --exclude=CD114 --exclude=CD115 --exclude=SLDU2 --exclude=SLDU3 --exclude=SLDU4 --exclude=SLDL2 --exclude=SLDL3 --exclude=SLDL4 --exclude=AIANHHSC --exclude=CSASC --exclude=CNECTASC --exclude=MEMI --exclude=NMEMI --exclude=PUMA --exclude=RESERVED --exclude=FILEID --exclude=STUSAB --exclude=CHARITER --exclude=CIFSN --exclude=LOGRECNO $tile
done;
done;


gsutil rm -r gs://c2010_tiles
gsutil mb gs://c2010_tiles

# copy all mbtiles files at once
gsutil cp ./outputmbtiles/*.mbtiles gs://c2010_tiles



