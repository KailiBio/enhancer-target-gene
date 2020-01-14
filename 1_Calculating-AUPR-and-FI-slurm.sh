echo "#!/bin/bash"
echo "#SBATCH -n 1  # number of cores"
echo "#SBATCH -N 1  # number of nodes"
echo "#SBATCH --cpus-per-task=1"
echo "#SBATCH -a 0-1727%144"
echo "#SBATCH -t 5-00:00:00"
echo "#SBATCH -o /data/tusers/lixiangr/BENGI/scripts/Calculating-AUPR-and-FI-slurm.out  # log"
echo "#SBATCH -e /data/tusers/lixiangr/BENGI/scripts/Calculating-AUPR-and-FI-slurm.err  # error"
echo "#SBATCH --partition=5days # queue 4hours, 12hours, 5days"
echo "#SBATCH --job-name=Calculating-AUPR-and-FI-slurm   # job name"

version=v3

cell=GM12878
subdir=Predictions

tss=/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Benchmark/Version-1.0/TSS.2019.bed

#### Start calculating FI_gini for the full model ####
# echo "@@@@@@@@@@ Start running now @@@@@@@@@@@@@"; date;
for data in {CTCF-ChIAPET,RNAPII-ChIAPET}
do
	train=/data/tusers/lixiangr/BENGI/Benchmark/All-Pairs.Natural-Ratio/${cell}.${data}-Benchmark.$version.txt
	for Data_collection in {legacy,new}
	do
		for Data_form in {peaks,signal}
		do
			for data_class in {draw,dlog,draw-0.6-praw,draw-0.6-plog,dlog-0.6-praw,dlog-0.6-plog,draw-0.7-praw,draw-0.7-plog,dlog-0.7-praw,dlog-0.7-plog,draw-0.8-praw,draw-0.8-plog,dlog-0.8-praw,dlog-0.8-plog,draw-0.9-praw,draw-0.9-plog,dlog-0.9-praw,dlog-0.9-plog}
			do
				for cv in {0..11}
				do
					total=${data}-${Data_collection}-${Data_form}-${data_class}-${cv}
					featureDir=/data/tusers/lixiangr/BENGI/GM12878/Output/${Data_collection}-${Data_form}/Feature-Matrices/${data}
					loggingDir=/data/tusers/lixiangr/BENGI/GM12878/Output/${Data_collection}-${Data_form}/Logging/${data}
					predictionDir=/data/tusers/lixiangr/BENGI/GM12878/Output/${Data_collection}-${Data_form}/${subdir}/${data}

					if [ ! -d ${predictionDir} ];then mkdir -p ${predictionDir}; fi
					if [ ! -d ${loggingDir} ];then mkdir -p ${loggingDir}; fi
					if [ -f ${featureDir}/${data}-${data_class}.txt ]
					then
						# echo "/home/lixiangr/anaconda2/envs/r-env/bin/python /data/tusers/lixiangr/BENGI/Calculating-AUPR-and-FI.py ${train} ${featureDir}/${data}-${data_class}.txt ${tss} full_${data_class} ${predictionDir} v3 ${cv} gini perm > ${loggingDir}/full_${data_class}_${cv}.nohup"
						cat /data/tusers/lixiangr/BENGI/Calculating-AUPR-and-FI-oneExp.slurm | sed "s|train|${train}|g" | sed "s|featureDir|${featureDir}|g" | sed "s|benchmark|${data}|g" | sed "s|tss|${tss}|g" | sed "s|data_class|${data_class}|g" | sed "s|predictionDir|${predictionDir}|g" | sed "s|loggingDir|${loggingDir}|g" | sed "s|cv|${cv}|g" > /data/tusers/lixiangr/BENGI/Calculating-AUPR-and-FI-${data}-${Data_collection}-${Data_form}-${data_class}-${cv}.slurm
						echo "sbatch /data/tusers/lixiangr/BENGI/Calculating-AUPR-and-FI-${data}-${Data_collection}-${Data_form}-${data_class}-${cv}.slurm"
						# echo "bash /data/tusers/lixiangr/BENGI/Calculating-AUPR-and-FI-${data}-${Data_collection}-${Data_form}-${data_class}-${cv}.slurm > ${loggingDir}/Calculating-AUPR-and-FI-${total}.nohup &"

					fi
			    done
		    done
	    done
	done
done
