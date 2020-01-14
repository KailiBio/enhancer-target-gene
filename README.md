

## Main Scripts 

```sh
# Step 1 : Generate feature matrices, and use different correlation cut-off to prune features
scp lixiangr@z006:/data/tusers/lixiangr/BENGI/scripts/Generate-Matrices.sh ./
# Scripts are called in Generate-Matrices.sh
scp lixiangr@z006:/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Scripts/TargetFinder/process.overlaps.peaks.py ./
scp lixiangr@z006:/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Scripts/TargetFinder/create.window.py ./
scp lixiangr@z006:/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Scripts/TargetFinder/process.overlaps.signal.py ./
scp lixiangr@z006:/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Scripts/TargetFinder/calculate.distance.py ./
scp lixiangr@z006:/data/tusers/lixiangr/enhancer-crispr/juicer_loops/code/jill_PeakDataTable.py ./
scp lixiangr@z006:/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Scripts/TargetFinder/Generate-full-matrices.R ./
scp lixiangr@z006:/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Scripts/TargetFinder/Generate-pruning-matrices.R ./

# Step 2 : Calculate AUPR of full models; calculate perm FI and gini FI
scp lixiangr@z006:/data/tusers/lixiangr/BENGI/Calculating-AUPR-and-FI-oneExp.slurm ./
scp lixiangr@z006:/data/tusers/lixiangr/BENGI/scripts/Calculating-AUPR-and-FI-slurm.sh ./
scp lixiangr@z006:/data/tusers/lixiangr/BENGI/scripts/Calculating-AUPR-and-FI.slurm ./
# bash /data/tusers/lixiangr/BENGI/scripts/Calculating-AUPR-and-FI-slurm.sh > /data/tusers/lixiangr/BENGI/scripts/Calculating-AUPR-and-FI.slurm
# sbatch /data/tusers/lixiangr/BENGI/scripts/Calculating-AUPR-and-FI.slurm

# Script is called in Calculating-AUPR-and-FI.slurm
scp lixiangr@z006:/data/tusers/lixiangr/BENGI/Calculating-AUPR-and-FI.py ./

# Step 3 : Rank features according to mean perm FI and gini FI; Generate Top N feature matrices
scp lixiangr@z006:/data/tusers/lixiangr/BENGI/scripts/RF-of-topN.sh ./
# Scripts are called in RF-of-topN.sh
scp lixiangr@z006:/data/tusers/lixiangr/BENGI/scripts/FI_gini_sort.R ./
scp lixiangr@z006:/data/tusers/lixiangr/BENGI/scripts/FI_perm_sort.R ./
scp lixiangr@z006:/data/tusers/lixiangr/BENGI/scripts/gini-and-perm-topN.R ./


# Step 4 : AUPR of different models, such as full, perm16, gini16
scp lixiangr@z006:/data/tusers/lixiangr/BENGI/scripts/AUPR-value.sh ./
# Script is called in AUPR-value.sh
scp lixiangr@z006:/data/tusers/lixiangr/BENGI/scripts/AUPR.R ./
```


## Step 1 : Generate feature matrices && Prune features

### z006

* about 24 cores
```sh
for benchmark in {CTCF-ChIAPET,RNAPII-ChIAPET,HiC,CHiC,GTEx,GEUVADIS}
do
    for data_form in {peaks,signal}
    do
        for data_collection in {legacy,new}
        do
            nohup bash /data/tusers/lixiangr/BENGI/scripts/Generate-Matrices.sh GM12878 ${benchmark} ${data_collection} ${data_form} /data/tusers/lixiangr/BENGI/GM12878/File/Dataset-${data_collection}-${data_form}.txt /data/tusers/lixiangr/BENGI/GM12878/File/${data_collection}-${data_form} /data/tusers/lixiangr/BENGI/GM12878/Output/${data_collection}-${data_form}/Feature-Matrices/${benchmark} > /data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Scripts/TargetFinder/Generate-Matrices-GM12878.${benchmark}-${data_collection}-${data_form}.nohup &
        done
    done
done 
```

* check
```sh
for benchmark in {CTCF-ChIAPET,RNAPII-ChIAPET,HiC,CHiC,GTEx,GEUVADIS}
do
    for data_class in {legacy-peaks,legacy-signal,new-peaks,new-signal}
    do
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-draw.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-dlog.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-draw-0.6-plog.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-draw-0.6-praw.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-dlog-0.6-plog.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-dlog-0.6-praw.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-draw-0.7-plog.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-draw-0.7-praw.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-dlog-0.7-plog.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-dlog-0.7-praw.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-draw-0.8-plog.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-draw-0.8-praw.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-dlog-0.8-plog.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-dlog-0.8-praw.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-draw-0.9-plog.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-draw-0.9-praw.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-dlog-0.9-plog.txt
        ls -lh /data/tusers/lixiangr/BENGI/GM12878/Output/${data_class}/Feature-Matrices/${benchmark}/${benchmark}-dlog-0.9-praw.txt
    done
done
```


## Step 2 : Calculate RF AUPR, gini FI or perm FI

### z018

```sh
bash /data/tusers/lixiangr/BENGI/scripts/Calculating-AUPR-and-FI-slurm.sh > /data/tusers/lixiangr/BENGI/scripts/Calculating-AUPR-and-FI.slurm
sbatch /data/tusers/lixiangr/BENGI/scripts/Calculating-AUPR-and-FI.slurm
```


## Step 3 : Top 16 from FI_perm and FI_gini

### z018

```sh
cell=GM12878
for data in {CTCF-ChIAPET,RNAPII-ChIAPET,HiC,CHiC,GTEx,GEUVADIS}
do
	for Data_collection in {legacy,new}
	do
		for Data_form in {peaks,signal}
		do
			for data_class in {draw,dlog,draw-0.6-praw,draw-0.6-plog,dlog-0.6-praw,dlog-0.6-plog,draw-0.7-praw,draw-0.7-plog,dlog-0.7-praw,dlog-0.7-plog,draw-0.8-praw,draw-0.8-plog,dlog-0.8-praw,dlog-0.8-plog,draw-0.9-praw,draw-0.9-plog,dlog-0.9-praw,dlog-0.9-plog}
			do
				total=${data}-${Data_collection}-${Data_form}-${data_class}
				loggingDir=/data/tusers/lixiangr/BENGI/GM12878/Output/${Data_collection}-${Data_form}/Logging/${data}
				bash /data/tusers/lixiangr/BENGI/scripts/RF-of-topN.sh ${cell} ${data} ${Data_collection} ${Data_form} ${data_class} sort 16 > ${loggingDir}/AUPR-and-topN-${total}.nohup
		    done
	    done
        wait;
	done
done
```


## Step 4 : AUPR of the full, perm16 and gini16 models

### z006

```sh
cell=GM12878
for data in {CTCF-ChIAPET,RNAPII-ChIAPET,HiC,CHiC,GTEx,GEUVADIS}
do
	for Data_collection in {legacy,new}
	do
		for Data_form in {peaks,signal}
		do
			for data_class in {draw,dlog,draw-0.6-praw,draw-0.6-plog,dlog-0.6-praw,dlog-0.6-plog,draw-0.7-praw,draw-0.7-plog,dlog-0.7-praw,dlog-0.7-plog,draw-0.8-praw,draw-0.8-plog,dlog-0.8-praw,dlog-0.8-plog,draw-0.9-praw,draw-0.9-plog,dlog-0.9-praw,dlog-0.9-plog}
			do
				total=${data}-${Data_collection}-${Data_form}-${data_class}
				loggingDir=/data/tusers/lixiangr/BENGI/GM12878/Output/${Data_collection}-${Data_form}/Logging/${data}
				bash /data/tusers/lixiangr/BENGI/scripts/AUPR-value.sh ${cell} ${data} ${Data_collection} ${Data_form} ${data_class} full > ${loggingDir}/AUPR-value-full.nohup
				bash /data/tusers/lixiangr/BENGI/scripts/AUPR-value.sh ${cell} ${data} ${Data_collection} ${Data_form} ${data_class} gini16 > ${loggingDir}/AUPR-value-gini16.nohup
				bash /data/tusers/lixiangr/BENGI/scripts/AUPR-value.sh ${cell} ${data} ${Data_collection} ${Data_form} ${data_class} perm16 > ${loggingDir}/AUPR-value-perm16.nohup
                echo "${loggingDir}/AUPR-value-full.nohup"
                echo "${loggingDir}/AUPR-value-gini16.nohup"
                echo "${loggingDir}/AUPR-value-perm16.nohup"
		    done
	    done
	done
done
```




































