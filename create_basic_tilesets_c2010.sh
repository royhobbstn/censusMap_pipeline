
rm -rf run

mkdir run

cd run

sudo apt-get install -y unzip

sudo apt-get install -y ruby
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

# cartographic shapefiles
# https://www2.census.gov/geo/tiger/GENZ2010/

wget https://www2.census.gov/geo/tiger/GENZ2010/gz_2010_us_050_00_500k.zip
wget https://www2.census.gov/geo/tiger/GENZ2010/gz_2010_us_040_00_500k.zip

# repeat for all geo files COUNTRY
for file in *.zip
do unzip $file; done;
# end repeat for all geo files


# process shapefiles that are broken out into states

mkdir stateshp

cd stateshp

## declare an array variable
declare -a arr=("01" "02" "04" "05" "06" "08" "09" "10" "11" "12" "13" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "31" "32" "33" "34" "35" "36" "37" "38" "39" "40" "41" "42" "44" "45" "46" "47" "48" "49" "50" "51" "53" "54" "55" "56" "60" "66" "69" "72" "78")

declare -A states; states[01]=Alabama; states[ak]=Alaska; states[az]=Arizona; states[ar]=Arkansas; states[ca]=California; states[co]=Colorado; states[ct]=Connecticut; states[de]=Delaware; states[dc]=Distric_of_Columbia; states[fl]=Florida; states[ga]=Georgia; states[hi]=Hawaii; states[id]=Idaho; states[il]=Illinois; states[in]=Indiana; states[ia]=Iowa; states[ks]=Kansas; states[ky]=Kentucky; states[la]=Louisiana; states[me]=Maine; states[md]=Maryland; states[ma]=Massachusetts; states[mi]=Michigan; states[mn]=Minnesota; states[ms]=Mississippi; states[mo]=Missouri; states[mt]=Montana; states[ne]=Nebraska; states[nv]=Nevada; states[nh]=New_Hampshire; states[nj]=New_Jersey; states[nm]=New_Mexico; states[ny]=New_York; states[nc]=North_Carolina; states[nd]=North_Dakota; states[oh]=Ohio; states[ok]=Oklahoma; states[or]=Oregon; states[pa]=Pennsylvania; states[pr]=Puerto_Rico; states[ri]=Rhode_Island; states[sc]=South_Carolina; states[sd]=South_Dakota; states[tn]=Tennessee; states[tx]=Texas; states[us]=UnitedStates; states[ut]=Utah; states[vt]=Vermont; states[va]=Virginia; states[wa]=Washington; states[wv]=West_Virginia; states[wi]=Wisconsin; states[wy]=Wyoming; states[us]=National;
# TODO declare associative array with key as the above number, and value as state name

## now loop through the above array
for i in "${arr[@]}"
do
# gz_2010_54_140_00_500k.zip
wget https://www2.census.gov/geo/tiger/GENZ2010/gz_2010_"$i"_150_00_500k.zip
wget https://www2.census.gov/geo/tiger/GENZ2010/gz_2010_"$i"_160_00_500k.zip
wget https://www2.census.gov/geo/tiger/GENZ2010/gz_2010_"$i"_140_00_500k.zip
# tiger
wget ftp://ftp2.census.gov/geo/pvs/tiger2010st/"$i"_$states[$i]/$i/tl_2010_$i_tabblock10.zip
done

# repeat for all geo files STATES
for file in *.zip
do unzip $file; done;
# end repeat for all geo files

# programmatically combine?  Separate routine?
mapshaper -i *_150_00_500k.shp combine-files -merge-layers -o ../gz_2010_us_bg_500k.shp
mapshaper -i *_160_00_500k.shp combine-files -merge-layers -o ../gz_2010_us_place_500k.shp
mapshaper -i *_140_00_500k.shp combine-files -merge-layers -o ../gz_2010_us_tract_500k.shp
# TODO blocks
cd ..

# repeat for all shp files
for file in *.shp
do mapshaper $file -o format=geojson; done;
# end repeat for all shp files 

# custom per each json file
# alter geoid to match between data and geo file 0400000US31
sed -i -e 's/0500000US/05000US/g' gz_2010_us_050_00_500k.json
sed -i -e 's/0400000US/04000US/g' gz_2010_us_040_00_500k.json
sed -i -e 's/1500000US/15000US/g' gz_2010_us_bg_500k.json
sed -i -e 's/1600000US/16000US/g' gz_2010_us_place_500k.json
sed -i -e 's/1400000US/14000US/g' gz_2010_us_tract_500k.json
# TODO blocks


# only retain geoid column
tippecanoe -f -o c2010_county.mbtiles -l county -z 10 -y GEO_ID -aL -D9 gz_2010_us_050_00_500k.json
tippecanoe -f -o c2010_state.mbtiles -l state -z 10 -y GEO_ID -aL -D9 gz_2010_us_040_00_500k.json
tippecanoe -f -o c2010_bg.mbtiles -l bg -z 10 -y GEO_ID -aL -D9 gz_2010_us_bg_500k.json
tippecanoe -f -o c2010_place.mbtiles -l place -z 10 -y GEO_ID -aL -D9 gz_2010_us_place_500k.json
tippecanoe -f -o c2010_tract.mbtiles -l tract -z 10 -y GEO_ID -aL -D9 gz_2010_us_tract_500k.json
# TODO blocks
# end custom for each json file

# try some of these:
# --drop-smallest-as-needed
# --drop-densest-as-needed
# --no-tile-size-limit

gsutil rm -r gs://c2010_tiles_staging
gsutil mb gs://c2010_tiles_staging

# copy all mbtiles files at once
gsutil cp *.mbtiles gs://c2010_tiles_staging
gsutil cp *.json gs://c2010_tiles_staging

