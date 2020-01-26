#! /bin/bash
set -e

#prelim mapping followed by minion pipeline for set of barcodes

runname=$1
pathToFastq=$2
ref=$3
files=${pathToFastq}/${runname}_all-*.fastq
echo $files

echo -e "sample\ttime\treads\tmapped\tbasesCovered\tbasesCoveredx20\tbasesCoveredx100" > $runname"_nb_mappingstats".txt

for f in $files
do
#start=`date +%s`
nb=$(echo "$f" | sed 's/.*\(NB[0-9][0-9]\).*/\1/')
mkdir -p ~/pipeline_output/primer-schemes/$runname"_prelim"/$nb
output=$(echo ~/pipeline_output/primer-schemes/$runname"_prelim"/$nb)
mkdir -p ~/pipeline_output/minion_output/$runname/$nb
output2=$(echo ~/pipeline_output/minion_output/$runname/$nb)

~/github/artic-rabv/other-scripts/rabies_prelimMap.sh $ref $pathToFastq $runname $nb


#artic minion --normalise 200 --threads 4 --scheme-directory '~/pipeline_output/primer-schemes' --read-file $pathToFastq/$runname"_all-"$nb.fastq --nanopolish-read-file $pathToFastq/$runname"_all.fastq" $runname"_prelim"/$nb $runname"_"$nb"_prelimMapped"

#produce bam file for primer trimming step
minimap2 -ax map-ont $output/$runname"_prelim".reference.fasta $f | samtools view -u -| samtools sort - -T temp -o $output2/$runname"_"$nb".sorted.bam"

#primer trimming
align_trim  --normalise 200 ~/github/artic-rabv/primer-schemes/$ref/V1/$ref.scheme.bed --report $output2/$runname"_"$nb".sorted".alignreport.txt < $output2/$runname"_"$nb".sorted.bam" 2> $output2/$nb".sorted".alignreport.er | samtools view -bS - | samtools sort -T %s - -o $output2/$runname"_"$nb".primertrimmed.sorted.bam"
samtools index $output2/$runname"_"$nb".primertrimmed.sorted.bam"
align_trim  ~/github/artic-rabv/primer-schemes/$ref/V1/$ref.scheme.bed --report $output2/$runname"_"$nb".sorted".alignreport.txt < $output2/$runname"_"$nb".sorted.bam" 2> $output2/$nb".sorted".alignreport.er | samtools view -bS - | samtools sort -T %s - -o $output2/$runname"_"$nb".primertrimmed.nonorm.sorted.bam"
samtools index $output2/$runname"_"$nb".primertrimmed.nonorm.sorted.bam"

#convert trimmed bam file to fastq for medaka step
samtools bam2fq $output2/$runname"_"$nb".primertrimmed.sorted.bam" > $output2/$runname"_"$nb".primertrimmed.sorted".fastq
samtools bam2fq $output2/$runname"_"$nb".primertrimmed.nonorm.sorted.bam" > $output2/$runname"_"$nb".primertrimmed.norm.sorted".fastq

#produce consensus in medaka
#medaka_consensus -i $output/$nb".primertrimmed.sorted".fastq -d $output/$nb"_racon4".fasta -o $output/$nb"_medaka" -t 2 -m r941_min_fast_g303
#end=`date +%s`
#runtime=$((end-start))

#summary mapping stats
reads=$(samtools view $output2/$runname"_"$nb".sorted.bam" | cut -f 1 | sort | uniq | wc -l)
mapped=$(samtools view -F 4 $output2/$runname"_"$nb".sorted.bam" | cut -f 1 | sort | uniq | wc -l)
basesCovered=$(samtools depth $output2/$runname"_"$nb".primertrimmed.sorted.bam" | awk '($3>0)' |wc -l)
basesCoveredx20=$(samtools depth $output2/$runname"_"$nb".primertrimmed.sorted.bam" | awk '($3>=20)' |wc -l)
basesCoveredx100=$(samtools depth $output2/$runname"_"$nb".primertrimmed.sorted.bam" | awk '($3>=100)' |wc -l)
echo -e $runname"_"${nb}"\t"$runtime"\t"$reads"\t"$mapped"\t"$basesCovered"\t"$basesCoveredx20"\t"$basesCoveredx100 >>$runname"_nb_mappingstats".txt

  done
mkdir -p ~/pipeline_output/archived
mv $runname"_nb_mappingstats".txt ~/pipeline_output/minion_output/$runname
mv $runname* ~/pipeline_output/archived
