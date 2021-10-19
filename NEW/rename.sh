#!   /bin/bash

#rename filenames using rampart barcodes.csv

for f in */*.fastq; do
bc_config=$(find . -name barcodes.csv)
bc=$(echo basename $f | grep -o "barcode..")
bc_n=${bc#barcode}

#search for all possible barcode abbreviations
sample=$(egrep "$bc|nb$bc_n|bc$bc_n" $bc_config  | cut -d "," -f 1)

#rename files
mv "$f" "test/$(basename "$f" | sed -e "s/$bc/$sample/")"

done
