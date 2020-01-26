#! /bin/bash
set -e

#prelim mapping followed by minion pipeline for set of barcodes

runname=$1
pathToFastq=$2
ref=$3
files=${pathToFastq}/${runname}_all-NB01.fastq
echo $files

echo -e "sample\ttime\treads\tmapped\tbasesCovered\tbasesCoveredx20\tbasesCoveredx100" > $runname"_nb_mappingstats".txt

for f in $files
do
#start=`date +%s`
nb=$(echo "$f" | sed 's/.*\(NB[0-9][0-9]\).*/\1/')
mkdir -p ~/pipeline_output/minion_output/$runname/$nb

~/github/artic-rabv/other-scripts/rabies_prelimMap.sh $ref $pathToFastq $runname $nb


#artic minion --normalise 200 --threads 4 --scheme-directory '~/pipeline_output/primer-schemes' --read-file $pathToFastq/$runname"_all-"$nb.fastq --nanopolish-read-file $pathToFastq/$runname"_all.fastq" $runname"_prelim"/$nb $runname"_"$nb"_prelimMapped"

#produce bam file for primer trimming step
#minimap2 -ax map-ont /home2/kb157b/pipeline_output/primer-schemes $runname"_all-"$bc.fastq | samtools view -u -| samtools sort - -T temp -o $output/$bc".sorted.bam"

#primer trimming
#align_trim  --normalise 200 ~/artic-rabv/primer-schemes/$ref/V1/$ref.scheme.bed --report $output/$bc".sorted".alignreport.txt < $output/$bc".sorted.bam" 2> $output/$bc".sorted".alignreport.er | samtools view -bS - | samtools sort -T %s - -o $output/$bc".primertrimmed.sorted.bam" 
#samtools index $output/$bc".primertrimmed.sorted.bam" 

#convert trimmed bam file to fastq for medaka step
#samtools bam2fq $output/$bc".primertrimmed.sorted.bam" > $output/$bc".primertrimmed.sorted".fastq

#produce consensus in medaka
#medaka_consensus -i $output/$bc".primertrimmed.sorted".fastq -d $output/$bc"_racon4".fasta -o $output/$bc"_medaka" -t 2 -m r941_min_fast_g303
#end=`date +%s`
#runtime=$((end-start))

#summary mapping stats
reads=$(samtools view $runname"_"$nb"_prelimMapped.sorted.bam" | cut -f 1 | sort | uniq | wc -l) 
mapped=$(samtools view -F 4 $runname"_"$nb"_prelimMapped.sorted.bam" | cut -f 1 | sort | uniq | wc -l) 
basesCovered=$(samtools depth $runname"_"$nb"_prelimMapped.trimmed.sorted.bam" | awk '($3>0)' |wc -l)
basesCoveredx20=$(samtools depth $runname"_"$nb"_prelimMapped.trimmed.sorted.bam" | awk '($3>=20)' |wc -l) 
basesCoveredx100=$(samtools depth $runname"_"$nb"_prelimMapped.trimmed.sorted.bam" | awk '($3>=100)' |wc -l) 
echo -e $runname"_"${nb}"\t"$runtime"\t"$reads"\t"$mapped"\t"$basesCovered"\t"$basesCoveredx20"\t"$basesCoveredx100 >>$runname"_nb_mappingstats".txt


#organise output files
mv $runname"_"$nb"_prelimMapped"* ~/pipeline_output/minion_output/$runname/$nb

done
mkdir -p ~/pipeline_output/archived
mv $runname"_nb_mappingstats".txt ~/pipeline_output/minion_output/$runname
mv $runname* ~/pipeline_output/archived

