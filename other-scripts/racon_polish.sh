#! /bin/bash
set -e
#Prelim mapping to generic reference

ref=$1
runname=$2
nb=$3

#make directories for storage only if they don't exist already
mkdir -p ~/pipeline_output/$runname/racon_polish/$nb
output=$(echo ~/pipeline_output/$runname/racon_polish/$nb)
trimmed=$(echo ~/pipeline_output/$runname/initial_mapTrim/$nb)
newscheme=$(echo ~/pipeline_output/primer-schemes/$runname"_prelim"/$nb)

minimap2 -x map-ont $newscheme/$runname"_prelim".reference.fasta $trimmed/$runname"_"$nb".clipped.fastq" > $output/$nb"_map0.paf"

racon -m 8 -x -6 -g -8 -w 500 $trimmed/$runname"_"$nb".clipped.fastq" $output/$nb"_map0.paf" $newscheme/$runname"_prelim".reference.fasta > $output/$nb"_racon0.fasta"

#racon -t 1 $runname"_all-"$nb.fastq $output/$nb"_map0.paf" ~/artic-rabv/primer-schemes/$ref/V1/$ref.reference.fasta > $output/$nb"_racon0.fasta"

#racon 4x polish
for i in {1..4}
do
minimap2 -x map-ont $output/$nb"_racon"$[i-1]".fasta" $trimmed/$runname"_"$nb".clipped.fastq" > $output/$nb"_map"$i".paf"

racon -m 8 -x -6 -g -8 -w 500  $trimmed/$runname"_"$nb".clipped.fastq" $output/$nb"_map"$i".paf" $output/$nb"_racon"$[i-1]".fasta" > $output/$nb"_racon"$i".fasta"

#racon -t 1 $runname"_all-"$nb.fastq $output/$nb"_map"$i".paf" $output/$nb"_racon"$[i-1]".fasta" > $output/$nb"_racon"$i".fasta"

done

#produce consensus in medaka
#medaka_consensus -i $output/$nb".primertrimmed.sorted".fastq -d $output/$nb"_racon4".fasta -o $output/$nb"_medaka" -t 2 -m r941_min_fast_g303

medaka_consensus -i $trimmed/$runname"_"$nb".clipped" -d $output/$nb"_racon4".fasta -o $output/$nb"_medaka2" -t 2 -m r941_min_fast_g303

#fill in gaps if consensus is in segments
#get positions of missing regions
cd $output/$nb"_medaka2"
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
