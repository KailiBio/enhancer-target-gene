#!/bin/bash
#SBATCH -n 1  # number of cores
#SBATCH -N 1  # number of nodes
#SBATCH --cpus-per-task=1
#SBATCH -t 5-00:00:00
#SBATCH -o /data/tusers/lixiangr/BENGI/scripts/Calculating-AUPR-and-FI-total.out  # log
#SBATCH -e /data/tusers/lixiangr/BENGI/scripts/Calculating-AUPR-and-FI-total.err  # error
#SBATCH --partition=5days # queue 4hours, 12hours, 5days
#SBATCH --job-name=Calculating-AUPR-and-FI-slurm   # job name

/home/lixiangr/anaconda2/envs/r-env/bin/python /data/tusers/lixiangr/BENGI/Calculating-AUPR-and-FI.py train featureDir/benchmark-data_class.txt tss full_data_class predictionDir v3 cv gini perm > loggingDir/full_data_class_cv.nohup
