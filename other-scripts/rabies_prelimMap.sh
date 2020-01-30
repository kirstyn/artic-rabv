#! /bin/bash
set -e
#Prelim mapping to generic reference

#takes these inputs from command entered in rabies_map script
ref=$1
pathToFastq=$2
runname=$3
nb=$4

#set up output files
mkdir -p ~/pipeline_output/primer-schemes/$runname"_prelim"/$nb
newscheme=$(echo ~/pipeline_output/primer-schemes/$runname"_prelim"/$nb)
mkdir -p ~/pipeline_output/$runname/prelim/mapped/$nb
prelim=$(echo ~/pipeline_output/$runname/prelim/mapped/$nb)

#preliminary map to original reference
minimap2 -ax map-ont ~/Github/artic-rabv/primer-schemes/$ref/V1/$ref.reference.fasta $pathToFastq/$runname"_all-"$nb.fastq | samtools view -u -| samtools sort - -T temp -o $prelim/$runname"_"$nb"_prelim".bam

#trim primers and normalise coverage for better representation
align_trim --normalise 200 ~/Github/artic-rabv/primer-schemes/$ref/V1/$ref.scheme.bed --report $prelim/$runname"_"$nb"_prelim".alignreport.txt < $prelim/$runname"_"$nb"_prelim".bam 2> $prelim/$runname"_"$nb"_prelim".alignreport.er | samtools view -bS - | samtools sort -T temp - -o $prelim/$runname"_"$nb"_prelim".primertrimmed.sorted.bam

#produce quick consensus
bcftools mpileup -Ou -f ~/Github/artic-rabv/primer-schemes/$ref/V1/$ref.reference.fasta $prelim/$runname"_"$nb"_prelim".primertrimmed.sorted.bam | bcftools call -mv --skip-variants indels --ploidy 1 -Oz -o $prelim/$runname"_"$nb"_prelim".vcf.gz
tabix $prelim/$runname"_"$nb"_prelim".vcf.gz
cat ~/Github/artic-rabv/primer-schemes/$ref/V1/$ref.reference.fasta | bcftools consensus $prelim/$runname"_"$nb"_prelim".vcf.gz > $prelim/$runname"_prelim".reference.fasta

#rename files/headers to create new scheme based on prelim reference
#fasta:
awk '/^>/ {gsub(/.fa(sta)?$/,"",FILENAME);printf(">%s\n",FILENAME);next;} {print}' $prelim/$runname"_prelim".reference.fasta > $newscheme/$runname"_prelim".reference.fasta
samtools faidx $newscheme/$runname"_prelim".reference.fasta
bwa index $newscheme/$runname"_prelim".reference.fasta

# #create prelim bed:
# newname=$(grep -e ">" $newscheme/$runname"_prelim".reference.fasta | awk 'sub(/^>/, "")')
# echo $newname
# cp ~/Github/artic-rabv/primer-schemes/$ref/V1/$ref.scheme.bed $newscheme/$runname"_prelim".scheme.bed
# sed -i -e 's/AB517659/${newname}/g' -e 's/KF155002.1/${newname}/g' -e 's/KX148275/${newname}/g' $newscheme/$runname"_prelim".scheme.bed
