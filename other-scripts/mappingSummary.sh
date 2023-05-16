
#! /bin/bash

set -e

for bam in $(find . -name "*.sorted.bam")
do
dirname=$(dirname $bam)
runnametest=$(dirname $dirname)
path=$(realpath $bam | sed 's/ //g')
runname=$(echo ${runnametest} | sed -e 's/NB..//' -e 's/\///g' -e 's/\.//g')
if [ -z ${runname} ]
then
runname=$(builtin cd ${dirname}; pwd | sed 's/.*\///g')
fi
stub=$(basename $bam)
stub=${stub%*.sorted.bam}
fasta=${path%*.sorted.bam}.consensus.fasta
mkdir -p ${PWD##*/}_depthFiles


# summary of mapped reads
reads=$(samtools view $bam | cut -f 1 | sort | uniq | wc -l)
mapped=$(samtools view -F 4 $bam | cut -f 1 | sort | uniq | wc -l)
mean=$(samtools depth -d 500000 -a $bam | datamash mean 3 sstdev 3 median 3 min 3 max 3)
basesCovered=$(samtools depth $bam | awk '($3>0)' |wc -l)
basesCoveredx5=$(samtools depth $bam | awk '($3>=5)' |wc -l)
basesCoveredx20=$(samtools depth $bam | awk '($3>=20)' |wc -l)
basesCoveredx100=$(samtools depth $bam | awk '($3>=100)' |wc -l)
basesCoveredx200=$(samtools depth $bam | awk '($3>=200)' |wc -l)
count=$(fgrep -o N $fasta | wc -l)
if [[ "$count" == 0 ]];then
  count=11923
fi
nonMaskedConsensusCov=$((11923-$count))
echo -e $runname $stub $reads $mapped $mean $basesCovered $basesCoveredx5 $basesCoveredx20 $basesCoveredx100 $basesCoveredx200 $nonMaskedConsensusCov $path>> temp.txt

{ printf 'runname sample_id total_reads mapped_reads meanReads sd_reads median_reads min_reads max_reads basesCovered_1 basesCovered_5 basesCovered_20 basesCovered_100 basesCovered_200 nonMaskedConsensusCov filepath\n'; cat temp.txt; }> ${runname}_mappingStats.txt
sed -i -e 's/ /\t/g' ${runname}_mappingStats.txt

# depth of cov per base
if [ -f ${PWD##*/}_depthFiles/${stub}_${runname}_depth.txt ]
then
    continue
fi
 samtools depth -a $bam -d 500000 > ${PWD##*/}_depthFiles/${stub}_${runname}_depth.txt
  done

rm temp.txt
