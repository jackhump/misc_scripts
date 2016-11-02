inFolder="/SAN/vyplab/IoN_RNAseq/F210I/New_embryonic_brain/processed"
support="/SAN/vyplab/IoN_RNAseq/F210I/New_embryonic_brain/F210I_embryo_June_2016_support.tab"
outFolder="/SAN/vyplab/IoN_RNAseq/F210I/New_embryonic_brain/processed/dapars/whole_genome"
script=${outFolder}/submission.sh

echo "
#$ -S /bin/bash
#$ -l h_vmem=5G,tmem=5G
#$ -l h_rt=72:00:00
#$ -pe smp 1
#$ -R y
#$ -o ${outFolder}/../../cluster/out
#$ -e ${outFolder}/../../cluster/error
#$ -N dapars_prepare
#$ -wd ${outFolder}
" > $script


for i in `ls ${inFolder}/*/*unique.bam`;do
	sample=`basename "$i" | awk -F'.' '{print $1}' `
	echo $sample
	echo "
	genomeCoverageBed -bg -ibam $i -g  /SAN/vyplab/HuRNASeq/dapars/mm10_chromInfo.txt.gz -split > ${outFolder}/${sample}.bedgraph
	" >> $script
done

# create array of conditions from the support file
conditions=(`tail -n +2 $support | awk '$4 != "NA" {print $4}' | sort | uniq`)
control_cond=${conditions[0]}
case_cond=${conditions[1]}

controls=()
cases=()

tail -n +2  $support  | awk '{print $1,$2,$3,$4}' | while read sample f1 f2 condition;do
	if [ "$condition" == "$case_cond" ];then
		echo "it's a case"
		echo $sample

		cases+=($sample)
	
	elif [ "$condition" == "$control_cond" ];then
		echo "it's a control"
		echo $sample
		controls+=($sample)
	fi
done

echo ${controls[@]}
echo ${cases[@]}

conditions=()
tail -n +2  $support  | awk '{print $1,$2,$3,$4}' | while read sample f1 f2 condition;do
	i=`awk -v sample=$sample '$1 == sample {print NR}' `
	echo $i
	echo $condition
	conditions[i]=$condition
done