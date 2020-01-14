cell=$1
data=$2
Data_collection=$3
Data_form=$4
data_class=$5
model=$6
#
version=v3
scriptDir=/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Scripts/TargetFinder
enhancers=/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Benchmark/Version-1.0/${cell}-Enhancers-new.bed
tss=/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Benchmark/Version-1.0/TSS.2019.bed
train=/data/tusers/lixiangr/BENGI/Benchmark/All-Pairs.Natural-Ratio/${cell}.${data}-Benchmark.${version}.txt
#
featureDir=/data/tusers/lixiangr/BENGI/GM12878/Output/${Data_collection}-${Data_form}/Feature-Matrices/${data}
loggingDir=/data/tusers/lixiangr/BENGI/GM12878/Output/${Data_collection}-${Data_form}/Logging/${data}
predictionDir=/data/tusers/lixiangr/BENGI/GM12878/Output/${Data_collection}-${Data_form}/Predictions/${data}
total=${data}-${Data_collection}-${Data_form}-${data_class}

# AUPR calculation 
N_Predictions_file=`ls -lh ${featureDir}/Predictions_${model}_${data_class}_cv-*.v3.txt | wc -l`
N_data=`cat ${train} | wc -l`
if [ ${N_Predictions_file} -eq 12] # 12 cv-groups
then
	cat ${featureDir}/Predictions_${model}_${data_class}_cv-*.v3.txt > ${featureDir}/Predictions_${model}_${data_class}_cvAll.v3.txt
	N_Predictions_row=`cat ${featureDir}/Predictions_${model}_${data_class}_cvAll.v3.txt | wc -l`
	if [ ${N_Predictions_row} -eq ${N_data} ] # N. col (Predictions) == N. col (benchmark)
	then
		output=`/home/lixiangr/anaconda2/envs/r-env/bin/Rscript /data/tusers/lixiangr/BENGI/scripts/AUPR.R ${featureDir}/Predictions_${model}_${data_class}_cvAll.v3.txt`
		value=`echo ${output} | awk '{print $2}'`
		echo ${total}-${model}-${value}
	fi
fi

