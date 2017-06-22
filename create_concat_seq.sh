mkdir schemas; mkdir readyfiles

curl --progress-bar https://www2.census.gov/programs-surveys/acs/summary_file/2015/documentation/user_tools/ACS_5yr_Seq_Table_Number_Lookup.txt -O

sed 1d ACS_5yr_Seq_Table_Number_Lookup.txt > no_header.csv

awk -F, '$4 ~ /^[0-9]+$/' no_header.csv > columns_list.csv

n=122;for i in $(seq -f "%04g" ${n});do echo -n "KEY,FILEID,STUSAB,SUMLEVEL,COMPONENT,LOGRECNO,US,REGION,DIVISION,STATECE,STATE,COUNTY,COUSUB,PLACE,TRACT,BLKGRP,CONCIT,AIANHH,AIANHHFP,AIHHTLI,AITSCE,AITS,ANRC,CBSA,CSA,METDIV,MACC,MEMI,NECTA,CNECTA,NECTADIV,UA,BLANK1,CDCURR,SLDU,SLDL,BLANK2,BLANK3,ZCTA5,SUBMCD,SDELM,SDSEC,SDUNI,UR,PCI,BLANK4,BLANK5,PUMA5,BLANK6,GEOID,NAME,BTTR,BTBG,BLANK7" > "./schemas/schema$i.txt"; done;
while IFS=',' read f1 f2 f3 f4 f5; do echo -n ","`printf $f2`"_"`printf %03d $f4`"" >> "./schemas/schema$f3.txt"; done < columns_list.csv;

wget https://storage.googleapis.com/acs1115_stage/eseq001.csv; wget https://storage.googleapis.com/acs1115_stage/eseq002.csv; wget https://storage.googleapis.com/acs1115_stage/eseq003.csv;

# gsutil cp *.csv gs://acs1115_stage




# n=122;for i in $(seq -f "%03g" ${n}); do echo -n -e ",\n" >> ./schemas/schema0$i.txt; cat ./schemas/schema0$i.txt eseq$i.csv > ./readyfiles/eseq$i.csv; done;


echo -n -e ",\n" >> ./schemas/schema0001.txt; cat ./schemas/schema0001.txt eseq001.csv > ./readyfiles/eseq001.csv;

echo -n -e ",\n" >> ./schemas/schema0002.txt; cat ./schemas/schema0002.txt eseq002.csv > ./readyfiles/eseq002.csv;

echo -n -e ",\n" >> ./schemas/schema0003.txt; cat ./schemas/schema0003.txt eseq003.csv > ./readyfiles/eseq003.csv;

cd readyfiles

      
awk -v FPAT="([^,]*)|(\"[^\"]+\")" -F $',' '{$1=$2=$3=$4=$5=$6=$7=$8=$9=$10=$11=$12=$13=$14=$15=$16=$17=$18=$19=$20=$21=$22=$23=$24=$25=$26=$27=$28=$29=$30=$31=$32=$33=$34=$35=$36=$37=$38=$39=$40=$41=$42=$43=$44=$45=$46=$47=$48=$49=$50=$51=$52=$53=$54=$55=""; print $0}' OFS=$',' eseq002.csv > seq2.txt

awk -v FPAT="([^,]*)|(\"[^\"]+\")" -F $',' '{$1=$2=$3=$4=$5=$6=$7=$8=$9=$10=$11=$12=$13=$14=$15=$16=$17=$18=$19=$20=$21=$22=$23=$24=$25=$26=$27=$28=$29=$30=$31=$32=$33=$34=$35=$36=$37=$38=$39=$40=$41=$42=$43=$44=$45=$46=$47=$48=$49=$50=$51=$52=$53=$54=$55=""; print $0}' OFS=$',' eseq003.csv > seq3.txt

cut -c 56- seq2.txt > seq2.ooo
cut -c 56- seq3.txt > seq3.ooo


# paste -d , eseq001.csv seq2.txt seq3.txt > eseqCAT001002003.csv

paste -d , eseq001.csv seq2.ooo seq3.ooo > paste.csv


