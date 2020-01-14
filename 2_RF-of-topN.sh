cell=$1
data=$2
Data_collection=$3
Data_form=$4
data_class=$5
sort_or_not=$6
top_N=$7

# Aim: 
# 	1. Rank features according to perm FI and gini FI.
# 	2. Generate matrices of Top N features.
# 	3. Calculate RF AUPR of Top N features.
# Parameters:
# 	1. cell line
# 	2. benchmark
# 	3. Data collection
# 	4. Data form
# 	5. Such as draw, dlog, draw-0.6-dlog
# 	6. Sort or not. If sorting is needed, "sort", else, "none"
# 	7. Top N, such as 16 and so on
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

# gini sort
n_FI_gini_file=`ls -lh ${predictionDir}/FI_gini_rep*_full_${data_class}_cv-*.v3.txt | wc -l`
n_FI_perm_file=`ls -lh ${predictionDir}/FI_perm_rep*_full_${data_class}_cv-*.v3.txt | wc -l`
#
if [ ${sort}=="sort" && ${n_FI_gini_file} -eq 60 && ${n_FI_perm_file} -eq 60 ]
then
	/home/lixiangr/anaconda2/envs/r-env/bin/Rscript /data/tusers/lixiangr/BENGI/scripts/FI_gini_sort.R ${cell} ${data} ${Data_collection} ${Data_form} ${data_class}
	echo "${predictionDir}/FI_gini_full_${data_class}_sorted.${version}.txt"
	# perm sort
	/home/lixiangr/anaconda2/envs/r-env/bin/Rscript /data/tusers/lixiangr/BENGI/scripts/FI_perm_sort.R ${cell} ${data} ${Data_collection} ${Data_form} ${data_class}
	echo "${predictionDir}/FI_perm_full_${data_class}_sorted.${version}.txt"
fi

# topN matrices
if [ -f ${predictionDir}/FI_gini_full_${data_class}_sorted.${version}.txt && -f ${predictionDir}/FI_perm_full_${data_class}_sorted.${version}.txt ]
then
	/home/lixiangr/anaconda2/envs/r-env/bin/Rscript /data/tusers/lixiangr/BENGI/scripts/gini-and-perm-topN.R ${featureDir}/${data}-${data_class}.txt ${predictionDir}/FI_gini_full_${data_class}_sorted.v3.txt ${predictionDir}/FI_perm_full_${data_class}_sorted.v3.txt ${top_N} ${featureDir}/${data}-${data_class}-gini-top${top_N}.txt ${featureDir}/${data}-${data_class}-perm-top${top_N}.txt
fi
# RF of topN
if [ -f ${featureDir}/${data}-${data_class}-gini-top${top_N}.txt && -f ${featureDir}/${data}-${data_class}-perm-top${top_N}.txt ]
then
	/home/lixiangr/anaconda2/envs/r-env/bin/python /data/tusers/lixiangr/BENGI/Calculating-AUPR-and-FI.py ${train} ${featureDir}/${data}-${data_class}-gini-top${top_N}.txt ${tss} gini${top_N}_${data_class} ${predictionDir} v3 none none > ${loggingDir}/gini${top_N}_${data_class}.nohup
	/home/lixiangr/anaconda2/envs/r-env/bin/python /data/tusers/lixiangr/BENGI/Calculating-AUPR-and-FI.py ${train} ${featureDir}/${data}-${data_class}-perm-top${top_N}.txt ${tss} perm${top_N}_${data_class} ${predictionDir} v3 none none > ${loggingDir}/perm${top_N}_${data_class}.nohup
fi
