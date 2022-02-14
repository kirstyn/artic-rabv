#!   /bin/bash
usage()
{
    echo "usage: <command> run_name path_to_fast5 barcode_kit primer_scheme"
}
if [ -z "$*" ]
then
   usage
   exit
fi

# set up analysis folders
run_name=$1
path_to_reads=$2
barcodes=$3
scheme=$4
#bc_set=( $(grep -o "barcode.." $bc_config | grep "barcode") )

mkdir -p analysis
mkdir -p analysis/$run_name
cp barcodes.csv analysis/$run_name/.
cd analysis/$run_name
bc_config=$(find . -name barcodes.csv)
#fast basecalling
guppy_basecaller -c dna_r9.4.1_450bps_fast.cfg -i $path_to_reads -s $run_name"_guppy" -r -x auto

#demultiplex
guppy_barcoder -r --require_barcodes_both_ends -i $run_name"_guppy" -s $run_name"_demux" --barcode_kits "${barcodes}"
# guppy pre v6.0
#guppy_barcoder -r --require_barcodes_both_ends -i $run_name"_guppy" -s $run_name"_demux" --arrangements_files "barcode_arrs_nb12.cfg barcode_arrs_nb24.cfg"

#concat reads and filter on read length
mkdir -p $run_name"_filtered"
find $run_name"_demux"/* -maxdepth 0 -type d |
parallel --gnu -j $(($(nproc)/2)) \
artic guppyplex --min-length 400 --max-length 700 --directory {} --output $run_name"_filtered"/{/}.fastq

#rename files using sample ids from rampart barcode file

for f in $run_name"_filtered"/*.fastq; do
bc=$(echo basename $f | grep -o "barcode..")
bc_n=${bc#barcode}

#search for all normal barcode abbreviations
sample=$(egrep "$bc|nb$bc_n|bc$bc_n" $bc_config 2>/dev/null | cut -d "," -f 1)
if [[ -z "$sample" ]];then
continue
else
mkdir -p $sample
#rename files
artic minion --medaka --normalise 200 --threads 4 --scheme-directory ~/Github/artic-rabv/primer-schemes --read-file $f ${primer_scheme} $sample/$sample

#mv $f $run_name"_filtered"/$(basename $f | sed -e "s/$bc/$sample/")
fi
done
