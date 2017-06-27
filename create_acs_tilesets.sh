
rm -rf advanced

mkdir advanced

cd advanced

sudo apt-get install -y ruby
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)" < /dev/null
PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >>~/.bash_profile

brew install tippecanoe


# download all CSV files from multi file bucket
gsutil cp gs://acs1115_multisequence/*.csv .

mkdir complete
mkdir encoded
mkdir outputmbtiles

# TODO should be part of tileCSVmerge
# for each CSV file
# swap columns so geo key is first
for $file in *.csv
do awk -F $',' ' { t = $1; $1 = $50; $50 = t; print; } ' OFS=$',' $file > ./complete/$file;
iconv -f iso-8859-1 -t utf-8 ./complete/$file > ./encoded/$file
done;



# for each mbtiles file 
tile-join -pk -f -o ./outputmbtiles/acs1115_county_eseq001.mbtiles -c ./encoded/eseq001.csv acs1115_county.mbtiles
# end for each mbtiles
# end for each csv 

gsutil rm -r gs://mbtiles_staging
gsutil mb gs://mbtiles_staging

# copy all mbtiles files at once
gsutil cp ./outputmbtiles/acs1115_county_eseq001.mbtiles gs://mbtiles_staging



