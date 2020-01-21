#! /bin/bash
set -e
#Prelim mapping to generic reference

ref=$1
runname=$2
bc=$3

#make directories for storage only if they don't exist already
mkdir -p ~/pipeline_output/racon_polish/$runname"_racon"
output=$(echo ~/pipeline_output/racon_polish/$runname"_racon")

minimap2 -x map-ont ~/artic-rabv/primer-schemes/$ref/V1/$ref.reference.fasta $runname"_all-"$bc.fastq > $output/$bc"_map0.paf"

racon -t 1 $runname"_all-"$bc.fastq $output/$bc"_map0.paf" ~/artic-rabv/primer-schemes/$ref/V1/$ref.reference.fasta > $output/$bc"_racon0.fasta"

#racon 4x polish
for i in {1..4}
do
minimap2 -x map-ont $output/$bc"_racon"$[i-1]".fasta" $runname"_all-"$bc.fastq > $output/$bc"_map"$i".paf"

racon -t 1 $runname"_all-"$bc.fastq $output/$bc"_map"$i".paf" $output/$bc"_racon"$[i-1]".fasta" > $output/$bc"_racon"$i".fasta"

done

#produce bam file for primer trimming step
minimap2 -ax map-ont $output/$bc"_racon4".fasta $runname"_all-"$bc.fastq | samtools view -u -| samtools sort - -T temp -o $output/$bc".sorted.bam"

#primer trimming
align_trim  --normalise 200 ~/artic-rabv/primer-schemes/$ref/V1/$ref.scheme.bed --report $output/$bc".sorted".alignreport.txt < $output/$bc".sorted.bam" 2> $output/$bc".sorted".alignreport.er | samtools view -bS - | samtools sort -T %s - -o $output/$bc".primertrimmed.sorted.bam" 
samtools index $output/$bc".primertrimmed.sorted.bam" 

#convert trimmed bam file to fastq for medaka step
samtools bam2fq $output/$bc".primertrimmed.sorted.bam" > $output/$bc".primertrimmed.sorted".fastq

#produce consensus in medaka
medaka_consensus -i $output/$bc".primertrimmed.sorted".fastq -d $output/$bc"_racon4".fasta -o $output/$bc"_medaka" -t 2 -m r941_min_fast

#fill in gaps if consensus is in segments
#get positions of missing regions
cd $output/$bc"_medaka"
grep "^>" consensus.fasta | sed 's/[>:]/\t/g'| cut -f 3 | sed 's/[-]/\t/g' >tmp.txt
sed -i 's/[.0]//g' tmp.txt 
if [[ $(wc -l <tmp.txt) -ge 1 ]]
then
echo "Consensus has gaps"
 a=$(wc -l <tmp.txt)
for i in $(seq 1 "$a")
do
start=$(sed -n "$i""p" tmp.txt| cut -f2)
end=$(sed -n $((i+1))"p" tmp.txt| cut -f1)
gaplength1=$((end - start))
gaplength2=$((gaplength1 -1))
#gaplength2=$((gaplength-1))
gapfill=$(perl -E print 'N' x"$gaplength2")
sed -i "0,/^>.*/! {0,/^>.*/ s/^>.*/$gapfill/}" consensus.fasta
done
tr '\n' 'x' <consensus.fasta  | sed 's/x//2g' > consensus2.fasta
sed -i 's/x/\n/g' consensus2.fasta
rm -rf consensus.fasta
mv consensus2.fasta consensus.fasta 
fi





