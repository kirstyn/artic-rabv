#! /bin/bash
set -e
#Prelim mapping to generic reference

ref=$1
pathToFastq=$2
runname=$3
nb=$4
mkdir -p ~/pipeline_output/primer-schemes/$runname"_prelim"/$nb
output=$(echo ~/pipeline_output/primer-schemes/$runname"_prelim"/$nb)
#preliminary map to original reference
minimap2 -ax map-ont ~/github/artic-rabv/primer-schemes/$ref/V1/$ref.reference.fasta $pathToFastq/$runname"_all-"$nb.fastq | samtools view -u -| samtools sort - -T temp -o $runname"_"$nb"_prelim".bam

#trim primers and normalise coverage for better representation
align_trim --normalise 200 ~/github/artic-rabv/primer-schemes/$ref/V1/$ref.scheme.bed --report $runname"_"$nb"_prelim".alignreport.txt < $runname"_"$nb"_prelim".bam 2> $runname"_"$nb"_prelim".alignreport.er | samtools view -bS - | samtools sort -T temp - -o $runname"_"$nb"_prelim".primertrimmed.sorted.bam

#produce quick consensus
bcftools mpileup -Ou -f ~/github/artic-rabv/primer-schemes/$ref/V1/$ref.reference.fasta $runname"_"$nb"_prelim".primertrimmed.sorted.bam | bcftools call -mv --skip-variants indels --ploidy 1 -Oz -o $runname"_"$nb"_prelim".vcf.gz
tabix $runname"_"$nb"_prelim".vcf.gz
cat ~/github/artic-rabv/primer-schemes/$ref/V1/$ref.reference.fasta | bcftools consensus $runname"_"$nb"_prelim".vcf.gz > $runname"_prelim".reference.fasta

#rename files/headers to create new scheme based on prelim reference
#fasta:
awk '/^>/ {gsub(/.fa(sta)?$/,"",FILENAME);printf(">%s\n",FILENAME);next;} {print}' $runname"_prelim".reference.fasta > $output/$runname"_prelim".reference.fasta
samtools faidx $output/$runname"_prelim".reference.fasta
bwa index $output/$runname"_prelim".reference.fasta

#create prelim bed:
newname=$(grep -e ">" $output/$runname"_prelim".reference.fasta | awk 'sub(/^>/, "")')
echo $newname
cp ~/github/artic-rabv/primer-schemes/$ref/V1/$ref.scheme.bed $output/$runname"_prelim".scheme.bed
sed -i -e "s/AB517659/${newname}/g" -e "s/KF155002.1/${newname}/g" -e "s/KX148275/${newname}/g" $output/$runname"_prelim".scheme.bed
