#! /bin/bash
set -e

#prelim mapping followed by minion pipeline for set of barcodes

runname=$1
ref=$2
files=${runname}_all-*.fastq
echo $files

echo -e "sample\ttime\treads\tmapped\tbasesCovered\tbasesCoveredx20\tbasesCoveredx100" > $runname"_nb_mappingstats".txt

for f in $files
do
#start=`date +%s`
nb=$(echo "$f" | sed 's/.*\(NB[0-9][0-9]\).*/\1/')
mkdir -p ~/pipeline_output/minion_output/$runname/$nb

rabies_prelimMap.sh $ref $runname $nb

artic minion --normalise 200 --threads 4 --scheme-directory '/home2/kb157b/pipeline_output/primer-schemes' --read-file $runname"_all-"$nb.fastq --nanopolish-read-file $runname"_all.fastq" $runname"_prelim"/$nb $runname"_"$nb"prelimMapped"

#end=`date +%s`
#runtime=$((end-start))

#summary mapping stats
reads=$(samtools view $runname"_"$nb"prelimMapped.sorted.bam" | cut -f 1 | sort | uniq | wc -l) 
mapped=$(samtools view -F 4 $runname"_"$nb"prelimMapped.sorted.bam" | cut -f 1 | sort | uniq | wc -l) 
basesCovered=$(samtools depth $runname"_"$nb"prelimMapped.trimmed.sorted.bam" | awk '($3>0)' |wc -l)
basesCoveredx20=$(samtools depth $runname"_"$nb"prelimMapped.trimmed.sorted.bam" | awk '($3>=20)' |wc -l) 
basesCoveredx100=$(samtools depth $runname"_"$nb"prelimMapped.trimmed.sorted.bam" | awk '($3>=100)' |wc -l) 
echo -e $runname"_"${nb}"\t"$runtime"\t"$reads"\t"$mapped"\t"$basesCovered"\t"$basesCoveredx20"\t"$basesCoveredx100 >>$runname"_nb_mappingstats".txt


#organise output files
mv $runname"_"$nb"prelimMapped"* ~/pipeline_output/minion_output/$runname/$nb

done
mkdir -p ~/pipeline_output/archived
mv $runname"_nb_mappingstats".txt ~/pipeline_output/minion_output/$runname
mv $runname* ~/pipeline_output/archived

