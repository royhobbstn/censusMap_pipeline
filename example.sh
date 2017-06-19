
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
sed -i -e 's/0500000US/05000US/g' cb_2015_us_county_20m.json

tippecanoe -f -o acs1115_county.mbtiles -l county -z 12 -y AFFGEOID -pk cb_2015_us_county_20m.json

mkdir schemas
curl --progress-bar https://www2.census.gov/programs-surveys/acs/summary_file/2015/documentation/user_tools/ACS_5yr_Seq_Table_Number_Lookup.txt -O
sed 1d ACS_5yr_Seq_Table_Number_Lookup.txt > no_header.csv
awk -F, '$4 ~ /^[0-9]+$/' no_header.csv > columns_list.csv
n=122;for i in $(seq -f "%04g" ${n});do echo -n "KEY,FILEID,STUSAB,SUMLEVEL,COMPONENT,LOGRECNO,US,REGION,DIVISION,STATECE,STATE,COUNTY,COUSUB,PLACE,TRACT,BLKGRP,CONCIT,AIANHH,AIANHHFP,AIHHTLI,AITSCE,AITS,ANRC,CBSA,CSA,METDIV,MACC,MEMI,NECTA,CNECTA,NECTADIV,UA,BLANK1,CDCURR,SLDU,SLDL,BLANK2,BLANK3,ZCTA5,SUBMCD,SDELM,SDSEC,SDUNI,UR,PCI,BLANK4,BLANK5,PUMA5,BLANK6,AFFGEOID,NAME,BTTR,BTBG,BLANK7" > "./schemas/schema$i.txt"; done;
while IFS=',' read f1 f2 f3 f4 f5; do echo -n ","`printf $f2`"_"`printf %03d $f4`"" >> "./schemas/schema$f3.txt"; done < columns_list.csv;

wget https://storage.googleapis.com/acs1115_stage/eseq001.csv

mkdir readyfiles
echo -n -e ",\n" >> ./schemas/schema0001.txt
cat ./schemas/schema0001.txt eseq001.csv > ./readyfiles/eseq001.csv 

mkdir complete
awk -F $',' ' { t = $1; $1 = $50; $50 = t; print; } ' OFS=$',' ./readyfiles/eseq001.csv > ./complete/eseq001.csv

mkdir outputmbtiles
tile-join -pk -f -o ./outputmbtiles/acs1115_county_eseq001.mbtiles -c ./complete/eseq001.csv acs1115_county.mbtiles

gsutil rm -r gs://mbtiles_staging
gsutil mb gs://mbtiles_staging

gsutil cp ./outputmbtiles/acs1115_county_eseq001.mbtiles gs://mbtiles_staging
gsutil cp ./complete/eseq001.csv gs://mbtiles_staging