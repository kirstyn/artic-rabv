#!   /bin/bash
usage()
{
    echo "usage: <command> run_name path_to_fast5 barcode_kit primer_scheme scheme_version"
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
scheme_v=$5
#bc_set=( $(grep -o "barcode.." $bc_config | grep "barcode") )

mkdir -p analysis/$run_name
bc_dir=$(builtin cd $path_to_reads; (cd .. && pwd))
cp $bc_dir/barcodes.csv analysis/$run_name/.

cd analysis/$run_name
# mkdir -p $run_name"_demux"
bc_config=$(find . -name barcodes.csv)

<<<<<<< Updated upstream
#
# #fast basecalling
# #guppy_basecaller -c dna_r9.4.1_450bps_fast.cfg -i $path_to_reads -s $run_name"_guppy" --recursive -x auto
#
# #demultiplex
# guppy_barcoder -r --require_barcodes_both_ends -i $run_name"_guppy" -s $run_name"_demux" --barcode_kits "$barcodes" -x auto
# # guppy pre v6.0
# #guppy_barcoder -r --require_barcodes_both_ends -i $run_name"_guppy" -s $run_name"_demux" --arrangements_files "barcode_arrs_nb12.cfg barcode_arrs_nb24.cfg"
=======
#fast basecalling
#guppy_basecaller -c dna_r9.4.1_450bps_fast.cfg -i $path_to_reads -s $run_name"_guppy" -r -x auto
#guppy_basecaller -c dna_r9.4.1_450bps_fast.cfg -i $path_to_reads/fast5_* -s $run_name"_guppy" -r -x auto

#demultiplex
# guppy_barcoder -r --require_barcodes_both_ends -i $path_to_reads -s $run_name"_demux" --barcode_kits "$barcodes" -x auto
# guppy pre v6.0
#guppy_barcoder -r --require_barcodes_both_ends -i $run_name"_guppy" -s $run_name"_demux" --arrangements_files "barcode_arrs_nb12.cfg barcode_arrs_nb24.cfg"
>>>>>>> Stashed changes

#concat reads and filter on read length
mkdir -p $run_name"_filtered"
find $run_name"_demux"/* -maxdepth 0 -type d ! -name "*unclassified*" |
parallel --gnu -j $(($(nproc)/2)) \
artic guppyplex --min-length 350 --max-length 900 --directory {} --output $run_name"_filtered"/{/}.fastq

#rename files using sample ids from rampart barcode file

for f in $run_name"_filtered"/*.fastq; do

bc=$(echo basename $f | grep -o "barcode..")

bc_n=${bc#barcode}

#search for all normal barcode abbreviations
sample=$(egrep -i "$bc|nb$bc_n|bc$bc_n" $bc_config 2>/dev/null | cut -d "," -f 1)
echo $sample
if [[ -z "$sample" ]];then
continue
else
  echo $sample
mkdir -p $sample
fi
#rename files
artic minion --medaka --medaka-model r941_min_high_g351 --normalise 200 --threads 4 --scheme-directory /home/artic/Documents/Github/artic-rabv/primer-schemes --read-file $f $scheme $sample/$sample
#mv $f $run_name"_filtered"/$(basename $f | sed -e "s/$bc/$sample/")#concat reads and filter on read length
#mv $f $run_name"_filtered"/$(basename $f | sed -e "s/$bc/$sample/")


done
