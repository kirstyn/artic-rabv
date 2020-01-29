#! /bin/bash
set -e

#command line inputs
rawFast5file=$1
runname=$2
savepath=$3

#defined variables
filepath=$(dirname $rawFast5file)
rawFast5=${rawFast5file%.tar.gz}

#extract compressed reads
tar -xvzf $rawFast5file -C $filepath

#basecall raw fast5 files
guppy_basecaller -r --input_path $rawFast5 --save_path $savepath/"basecalled_"$runname -c dna_r9.4.1_450bps_fast.cfg --device cuda:0

# gather fastq files
artic gather --min-length 300 --directory $savepath/"basecalled_"$runname --prefix $runname

#demultiplex with porechop
artic demultiplex --threads 4 $savepath/$runname"_all.fastq"

#index raw reads
nanopolish index -d $rawFast5 $savepath/$runname"_all.fastq"
