function files_exist() { for file in $*; do if [ ! -e $file ]; then stop "File $file does not exist" ; fi; done }

# assume outDir is the /processed folder
outDir=$1
submissionFolder=${outDir}/cluster/submission/
mkdir -p ${outDir}/junctions

files_exist $submissionFolder $outDir

script=${submissionFolder}/junction_extract_submission.sh

echo "
#$ -S /bin/bash
#$ -l h_vmem=5G,tmem=5G
#$ -l h_rt=72:00:00
#$ -pe smp 1
#$ -R y
#$ -o ${submissionFolder}/../out
#$ -e ${submissionFolder}/../error
#$ -N junction_extract
#$ -wd ${outDir}
" > $script

for i in  `ls ${outDir}/*/*_unique.bam`; do 
sampleName=`basename $i | awk -F '_unique.bam' '{print $1}'`

junctionsFile=${outDir}/junctions/${sampleName}_junctions.bed

echo "/SAN/vyplab/HuRNASeq/regtools/build/regtools junctions extract -o $junctionsFile $i" >> $script

done