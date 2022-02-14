
#! /bin/bash

set -e

for bam in $(find . -name "*.sorted.bam" ! -name "*trimmed*")
do
dirname=$(dirname $bam)
path=$(realpath $bam | sed 's/ //g')
runname=$(echo ${dirname} | sed -e 's/NB..//' -e 's/\///g' -e 's/\.//g')
if [ -z ${runname} ]
then
runname=$(builtin cd ${dirname}; pwd | sed 's/.*\///g')
fi
echo ${runname}
stub=$(basename $bam)
stub=${stub%*.sorted.bam}


#mean=samtools depth $bam |  awk '{sum+=$3; sumsq+=$3*$3} END { print "Average = ",sum/NR; print "Stdev = ",sqrt(sumsq/NR - (sum/NR)**2)}'

reads=$(samtools view $bam | cut -f 1 | sort | uniq | wc -l)
mapped=$(samtools view -F 4 $bam | cut -f 1 | sort | uniq | wc -l)
mean=$(samtools depth -d 500000 -a $bam | datamash mean 3 sstdev 3 median 3 min 3 max 3)
basesCovered=$(samtools depth $bam | awk '($3>0)' |wc -l)
basesCoveredx5=$(samtools depth $bam | awk '($3>=5)' |wc -l)
basesCoveredx20=$(samtools depth $bam | awk '($3>=20)' |wc -l)
basesCoveredx100=$(samtools depth $bam | awk '($3>=100)' |wc -l)
echo -e $runname $stub $reads $mapped $mean $basesCovered $basesCoveredx5 $basesCoveredx20 $basesCoveredx100 $path>> temp.txt
done

{ printf 'runname sample_id total_reads mapped_reads meanReads sd_reads median_reads min_reads max_reads basesCovered_1 basesCovered_5 basesCovered_20 basesCovered_100 filepath\n'; cat temp.txt; }> ${runname}_mappingStats.txt
gsed -i 's/ /\t/g' ${runname}_mappingStats.txt
rm temp.txt
