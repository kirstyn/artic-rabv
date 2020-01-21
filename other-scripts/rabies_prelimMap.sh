#! /bin/bash
set -e
#Prelim mapping to generic reference

ref=$1
runname=$2
bc=$3

#make directories for storage only if they don't exist already
mkdir -p ~/pipeline_output/primer-schemes/$runname"_prelim"/$bc
output=$(echo ~/pipeline_output/primer-schemes/$runname"_prelim"/$bc)
#preliminary map to original reference
minimap2 -ax map-ont ~/artic-rabv/primer-schemes/$ref/V1/$ref.reference.fasta ~/$runname"_all-"$bc.fastq | samtools view -u -| samtools sort - -T temp -o $runname"_"$bc"_prelim".bam

#trim primers and normalise coverage for better representation
align_trim --normalise 200 ~/artic-rabv/primer-schemes/$ref/V1/$ref.scheme.bed --report $runname"_"$bc"_prelim".alignreport.txt < $runname"_"$bc"_prelim".bam 2> $runname"_"$bc"_prelim".alignreport.er | samtools view -bS - | samtools sort -T temp - -o $runname"_"$bc"_prelim".primertrimmed.sorted.bam

#produce quick consensus
bcftools mpileup -Ou -f ~/artic-rabv/primer-schemes/$ref/V1/$ref.reference.fasta $runname"_"$bc"_prelim".primertrimmed.sorted.bam |   $runname"_"$bc"_prelim".vcf.gz
tabix $runname"_"$bc"_prelim".vcf.gz
cat ~/artic-rabv/primer-schemes/$ref/V1/$ref.reference.fasta | bcftools consensus $runname"_"$bc"_prelim".vcf.gz > $runname"_prelim".reference.fasta

#rename files/headers to create new scheme based on prelim reference 
#fasta:
awk '/^>/ {gsub(/.fa(sta)?$/,"",FILENAME);printf(">%s\n",FILENAME);next;} {print}' $runname"_prelim".reference.fasta > $output/$runname"_prelim".reference.fasta
samtools faidx $output/$runname"_prelim".reference.fasta
bwa index $output/$runname"_prelim".reference.fasta

#bed:
newname=$(grep -e ">" $output/$runname"_prelim".reference.fasta | awk 'sub(/^>/, "")')
cp ~/artic-rabv/primer-schemes/$ref/V1/$ref.scheme.bed $output/$runname"_prelim".scheme.bed
sed -i "s/\(KX148266|KF155002.1\)/${newname}/g" $output/$runname"_prelim".scheme.bed

