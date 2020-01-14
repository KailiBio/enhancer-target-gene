#!/bin/bash

# Aim:
#    Generate feature matrices of peaks files
#    Generate 3 matrices of enhancer, tss and window
#    Add distance in the last column
#    Make the final big table of all the features(including enhancer, tss and window features in the same matrix)

# Parameters:
#    1. cell line
#    2. benchmark, such as RNAPII-ChIAPET
#    3. Data collection，such as legacy and new
#    4. Data form，such as peaks and signal
#    5. list of peak file names
#    6. Directory of peak files
#    7. Output directory

version=v3

cell=$1
data=$2
Data_collection=$3
Data_form=$4
fileList=$5
peakDir=$6
featureDir=$7

train=/data/tusers/lixiangr/BENGI/Benchmark/All-Pairs.Natural-Ratio/${cell}.${data}-Benchmark.$version.txt
scriptDir=/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Scripts/TargetFinder

enhancers=/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Benchmark/Version-1.0/${cell}-Enhancers-new.bed
tss=/data/tusers/lixiangr/Benchmark_190613/Target-Gene-Prediction/Benchmark/Version-1.0/TSS.2019.bed

n_file=`cat ${fileList} | wc -l`

if [ -d ${featureDir} ];then rm -rf ${featureDir};fi
if [ ! -d ${featureDir} ];then mkdir -p ${featureDir};fi
if [ ! -d ${featureDir}/peakFile_removeOverlapWithWindow ];then mkdir -p ${featureDir}/peakFile_removeOverlapWithWindow;fi
cd ${featureDir}

###### Step 1 Generate original feature matrices for both peaks and signal files ######
if [ ${Data_form} == "peaks" ]
then
	######## Creating Enhancer Feature Matrix ################
	if [ ! -f "${featureDir}/${data}-Enhancer-Feature-Matrix.txt" ]
	then
	    echo -e "Generating enhancer feature matrix..."
	    cat ${train} | awk '{print $1}' | sort -u  > cres_${data}
	    awk 'FNR==NR {x[$1];next} ($4 in x)' cres_${data} ${enhancers} |  awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $9 }' > enhancers_${data}
	    for k in $(seq ${n_file})
	    do
	        echo $k
	        peakFile=$(cat ${fileList} | awk -F "\t" '{if (NR == '$k') print $1}')
	        if [[ ${peakFile} =~ "RAMPAGE" ]]
	        then
	            mode="RAMPAGE"
	        elif [[ ${peakFile} =~ "Cage" ]]
	        then
	            mode="cage"
	        elif [[ ${peakFile} =~ "Rrbs" ]]
	        then
	            mode="RRBS"
	        elif [[ ${peakFile} =~ "RRBS" ]]
	        then
	            mode="RRBS"
	        else
	            mode="peaks"
	        fi
	        bedtools intersect -wo -a enhancers_${data} -b ${peakDir}/${peakFile} > tmp_${data}
	        head -n 1 tmp_${data} | column -t
	        /home/lixiangr/anaconda2/envs/py2/bin/python ${scriptDir}/process.overlaps.peaks.py enhancers_${data} tmp_${data} ${mode} | sort -k1,1 | awk 'BEGIN {print "cREs" "\t" "'${peakFile}'"}{print $0}'> col_${data}.$k
	    done
	    paste col_${data}.* | awk '{printf "%s\t", $1; for(i=2;i<=NF;i+=2) printf "%s\t", $i;print ""}' > ${featureDir}/${data}-Enhancer-Feature-Matrix.txt
	    rm col_${data}.*
	fi

	######## Creating TSS Feature Matrix ################
	if [ ! -f "${featureDir}/${data}-TSS-Feature-Matrix.txt" ]
	then
	    echo -e "Generating tss feature matrix..."
	    cat ${train} | awk '{print $2}' | sort -u  > genes_${data}
	    awk 'FNR==NR {x[$1];next} ($7 in x)' genes_${data} ${tss} | awk '{print $1 "\t" $2-500 "\t" $3+500 "\t" $4 "\t" $7 }' > tss_${data}
	    for k in $(seq ${n_file})
	    do
	        echo $k
	        peakFile=$(cat ${fileList} | awk -F "\t" '{if (NR == '$k')    print $1}')
	        if [[ ${peakFile} =~ "RAMPAGE" ]]
	        then
	            mode="RAMPAGE"
	        elif [[ ${peakFile} =~ "Cage" ]]
	        then
	            mode="cage"
	        elif [[ ${peakFile} =~ "Rrbs" ]]
	        then
	            mode="RRBS"
	        elif [[ ${peakFile} =~ "RRBS" ]]
	        then
	            mode="RRBS"
	        else
	            mode="peaks"
	        fi
	        bedtools intersect -wo -a tss_${data} -b ${peakDir}/${peakFile} > tmp_${data}
	        /home/lixiangr/anaconda2/envs/py2/bin/python ${scriptDir}/process.overlaps.peaks.py tss_${data} tmp_${data} ${mode} | sort -k1,1 | awk 'BEGIN {print "cREs" "\t" "'${peakFile}'"}{print $0}'> col_${data}.$k
	    done
	    paste col_${data}.* | awk '{printf "%s\t", $1; for(i=2;i<=NF;i+=2) printf "%s\t",$i;print ""}' > ${featureDir}/${data}-TSS-Feature-Matrix.txt
	    rm col_${data}.*
	fi

	######## Creating Window Matrix ################
	if [ ! -f "${featureDir}/${data}-Window-Feature-Matrix.txt" ]
	then
	    echo -e "Generating window feature matrix..."
	    cat ${train} | sort -u > pairs_${data}
	    /home/lixiangr/anaconda2/envs/py2/bin/python ${scriptDir}/create.window.py ${tss} ${enhancers} pairs_${data} > windows_${data}
	    for k in $(seq ${n_file})
	    do
	        echo $k
	        peakFile=$(cat ${fileList} | awk -F "\t" '{if (NR == '$k') print $1}')
	        if [[ ${peakFile} =~ "RAMPAGE" ]]
	        then
	            mode="RAMPAGE"
	        elif [[ ${peakFile} =~ "Cage" ]]
	        then
	            mode="cage"
	        elif [[ ${peakFile} =~ "Rrbs" ]]
	        then
	            mode="RRBS"
	        elif [[ ${peakFile} =~ "RRBS" ]]
	        then
	            mode="RRBS"
	        else
	            mode="peaks"
	        fi
	        cat enhancers_${data} tss_${data} | sort -k1,1 -k2,2n > et_${data}
	        # Only report those entries in A that have no overlap in B. Restricted by -f and -r.
	        bedtools intersect -a ${peakDir}/${peakFile} -b et_${data} -v > ${featureDir}/peakFile_removeOverlapWithWindow/${peakFile}
	        # Write the original A and B entries plus the number of base pairs of overlap between the two features. Only A features with overlap are reported. Restricted by -f and -r.
	        bedtools intersect -wo -a windows_${data} -b ${featureDir}/peakFile_removeOverlapWithWindow/${peakFile} > tmp_${data}

	        /home/lixiangr/anaconda2/envs/py2/bin/python ${scriptDir}/process.overlaps.peaks.py windows_${data} tmp_${data} ${mode} | sort -k1,1 | awk 'BEGIN {print "cREs" "\t" "'${peakFile}'"}{print $0}'> col_${data}.$k
	    done
	    paste col_${data}.* | awk '{printf "%s\t", $1; for(i=2;i<=NF;i+=2) printf "%s\t",$i;print ""}' > ${featureDir}/${data}-Window-Feature-Matrix.txt
	    rm col_${data}.*
	fi

###### signal #######
elif [ ${Data_form} == "signal" ]
then
	######## Creating Enhancer Feature Matrix ############
	if [ ! -f "${featureDir}/${data}-Enhancer-Feature-Matrix.txt" ]
	then
	    echo -e "Generating enhancer feature matrix..."
	    cat ${train} | awk '{print $1}' | sort -u  > cres_${data}
	    awk 'FNR==NR {x[$1];next} ($4 in x)' cres_${data} ${enhancers} |  awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $9 }' |sort -k4,4 > enhancers_${data}
	    awk 'FNR==NR {x[$1];next} ($4 in x)' cres_${data} ${enhancers} |  awk '{print $1 "\t" $2 "\t" $3 "\t" $4 }' | sort -k4,4 > enhancers_cat_${data}
	    for k in $(seq ${n_file})
	    do
	        echo $k
	        peakFile=$(cat ${fileList} | awk -F "\t" '{if (NR == '$k') print $1}')
	        if [[ ${peakFile} =~ "RRBS" ]]
	        then
	            bedtools intersect -wo -a enhancers_${data} -b ${peakDir}/${peakFile} > tmp_${data}
	            mode="RRBS"
	            /home/lixiangr/anaconda2/envs/py2/bin/python ${scriptDir}/process.overlaps.signal.py enhancers_${data} tmp_${data} ${mode} | sort -k1,1 | awk 'BEGIN {print "cREs" "\t" "'${peakFile}'"}{print $0}'> col_${data}.$k

	        else
	            mode="signal"
	            bigWigAverageOverBed ${peakDir}/${peakFile} enhancers_cat_${data} ${data}.txt && sort -k1,1 ${data}.txt > sort_${data}.txt && paste enhancers_cat_${data}  sort_${data}.txt > tmp_${data}
	            /home/lixiangr/anaconda2/envs/py2/bin/python ${scriptDir}/process.overlaps.signal.py enhancers_${data} tmp_${data} ${mode} | sort -k1,1 | awk 'BEGIN {print "cREs" "\t" "'${peakFile}'"}{print $0}'> col_${data}.$k

	        fi

	        head -n 1 tmp_${data} | column -t
	    done
	    paste col_${data}.* | awk '{printf "%s\t", $1; for(i=2;i<=NF;i+=2) printf "%s\t", $i;print ""}' > ${featureDir}/${data}-Enhancer-Feature-Matrix.txt
	    rm col_${data}.*
	fi


	######## Creating TSS Feature Matrix ############
	if [ ! -f "${featureDir}/${data}-TSS-Feature-Matrix.txt" ]
	then
	    echo -e "Generating tss feature matrix..."
	    cat ${train} | awk '{print $2}' | sort -u  > genes_${data}
	    awk 'FNR==NR {x[$1];next} ($7 in x)' genes_${data} ${tss} | awk '{print $1 "\t" $2-500 "\t" $3+500 "\t" $4 "\t" $7 }' | sort -k4,4 > tss_${data}
	    awk 'FNR==NR {x[$1];next} ($7 in x)' genes_${data} ${tss} | awk '{print $1 "\t" $2-500 "\t" $3+500 "\t" $4 "\t" }' | sort -k4,4 > tss_cat_${data}
	    for k in $(seq ${n_file})
	    do
	        echo $k
	        peakFile=$(cat ${fileList} | awk -F "\t" '{if (NR == '$k') print $1}')
	        if [[ ${peakFile} =~ "RRBS" ]]
	        then
	            mode="RRBS"
	            bedtools intersect -wo -a tss_${data} -b ${peakDir}/${peakFile} > tmp_${data}
	            /home/lixiangr/anaconda2/envs/py2/bin/python ${scriptDir}/process.overlaps.signal.py tss_${data} tmp_${data} ${mode} | sort -k1,1 | awk 'BEGIN {print "cREs" "\t" "'${peakFile}'"}{print $0}'> col_${data}.$k

	        else
	            mode="signal"
	            bigWigAverageOverBed ${peakDir}/${peakFile} tss_cat_${data} ${data}.txt && sort -k1,1 ${data}.txt >sorted_${data}.txt && paste tss_cat_${data} sorted_${data}.txt > tmp_${data}
	            /home/lixiangr/anaconda2/envs/py2/bin/python ${scriptDir}/process.overlaps.signal.py tss_${data} tmp_${data} ${mode} | sort -k1,1 | awk 'BEGIN {print "cREs" "\t" "'${peakFile}'"}{print $0}'> col_${data}.$k
	        fi
	    done
	    paste col_${data}.* | awk '{printf "%s\t", $1; for(i=2;i<=NF;i+=2) printf "%s\t",$i;print ""}' > ${featureDir}/${data}-TSS-Feature-Matrix.txt
	    rm col_${data}.*
	fi

	######## Creating Window Matrix ##########
	if [ ! -f "${featureDir}/${data}-Window-Feature-Matrix.txt" ]
	then
	    echo -e "Generating window feature matrix..."
	    cat ${train} | sort -u > pairs_${data}
	    /home/lixiangr/anaconda2/envs/py2/bin/python ${scriptDir}/create.window.py ${tss} ${enhancers} pairs_${data} > windowsn_${data}
	    sort -k4,4 windowsn_${data} > windows_${data}
	    cat windows_${data}| awk '{print $1 "\t" $2 "\t" $3 "\t" $4 }'|sort -k4,4 > windows_cat_${data}
	    for k in $(seq ${n_file})
	    do
	        echo $k
	        peakFile=$(cat ${fileList} | awk -F "\t" '{if (NR == '$k') print $1}')
	        if [[ ${peakFile} =~ "RRBS" ]]
	        then
	            cat enhancers_${data} tss_${data} | sort -k1,1 -k2,2n > et_${data}

	            mode="RRBS"
	            bedtools intersect -a ${peakDir}/${peakFile} -b et_${data} -v > ${featureDir}/peakFile_removeOverlapWithWindow/${peakFile}
	            bedtools intersect -wo -a windows_${data} -b ${featureDir}/peakFile_removeOverlapWithWindow/${peakFile} > tmp_${data}
	            /home/lixiangr/anaconda2/envs/py2/bin/python ${scriptDir}/process.overlaps.signal.py windows_${data} tmp_${data} ${mode} | sort -k1,1 | awk 'BEGIN {print "cREs" "\t" "'${peakFile}'"}{print $0}'> col_${data}.$k
	        else
	            mode="signal"
	            bigWigAverageOverBed ${peakDir}/${peakFile} windows_cat_${data} ${data}.txt && sort -k1,1 ${data}.txt > sort_${data}.txt &&  paste windows_cat_${data} sort_${data}.txt > tmp_${data}
	            /home/lixiangr/anaconda2/envs/py2/bin/python ${scriptDir}/process.overlaps.signal.py windows_${data} tmp_${data} ${mode} | sort -k1,1 | awk 'BEGIN {print "cREs" "\t" "'${peakFile}'"}{print $0}'> col_${data}.$k

	        fi

	    done
	    paste col_${data}.* | awk '{printf "%s\t", $1; for(i=2;i<=NF;i+=2) printf "%s\t",$i;print ""}' > ${featureDir}/${data}-Window-Feature-Matrix.txt
	    rm col_${data}.*
fi

######## Creating Distance Matrix ################
if [ ! -f "${featureDir}/${data}-Distance.txt" ]
then
    echo -e "Generating distance matrix..."
    cat ${train} | sort -u > pairs_${data}
    /home/lixiangr/anaconda2/envs/py2/bin/python ${scriptDir}/calculate.distance.py ${tss} ${enhancers} pairs_${data} > ${featureDir}/${data}-Distance.txt
fi

########## Add Distance ###########
echo "Adding distance"
echo "distance" > ${featureDir}/${data}-onlyDistance.txt
cat ${featureDir}/${data}-Distance.txt | awk '{print $3}' >> ${featureDir}/${data}-onlyDistance.txt
paste -d " " ${featureDir}/${data}-Window-Feature-Matrix.txt ${featureDir}/${data}-onlyDistance.txt > ${featureDir}/${data}-Window-Feature-Matrix-Dis.txt

########## Make the final big table of all the features ##########
echo "Generating the final table of all the features(without colnames, but with column of label)"
/home/lixiangr/anaconda2/envs/py2/bin/python /data/tusers/lixiangr/enhancer-crispr/juicer_loops/code/jill_PeakDataTable.py ${train} ${featureDir}/${data}-Enhancer-Feature-Matrix.txt ${featureDir}/${data}-TSS-Feature-Matrix.txt ${featureDir}/${data}-Window-Feature-Matrix-Dis.txt tss_${data} ${data}-Dis ${featureDir} 3 ${featureDir}/${data}-AllPeakFeature-Matrix-Dis.txt

#### Step 2 : Generating matrices to calculate RF AUPR ####

#### Extract colnames from Enhancer-Feature-Matrix ####
if [ -f ${featureDir}/${data}-Enhancer-Feature-Matrix.txt ]
then
    head -1 ${featureDir}/${data}-Enhancer-Feature-Matrix.txt | sed 's/\t/\n/g' > ${featureDir}/${data}-extracted-colnames.txt
fi

#### Generating full matrices ####
if [ -f ${featureDir}/${data}-extracted-colnames.txt && -f ${featureDir}/${data}-AllPeakFeature-Matrix-Dis.txt ]
then  
    echo "Generating full matrices"; date
    /home/lixiangr/anaconda2/envs/r-env/bin/Rscript ${scriptDir}/Generate-full-matrices.R ${data} ${featureDir}/${data}-extracted-colnames.txt ${featureDir}/${data}-AllPeakFeature-Matrix-Dis.txt ${featureDir}/${data}-draw.txt ${featureDir}/${data}-dlog.txt
    echo "Generating full matrices is finished"; date
fi

#### Generating pruning matrices ####
if [ -f ${featureDir}/${data}-draw.txt ] && [ -f ${featureDir}/${data}-dlog.txt ]
then
    echo "Generating pruning matrices"; date
    /home/lixiangr/anaconda2/envs/r-env/bin/Rscript ${scriptDir}/Generate-pruning-matrices.R ${featureDir}/${data}-draw.txt ${featureDir}/${data}-dlog.txt ${featureDir}/${data} ${featureDir}/${data}-extracted-colnames.txt
    echo "Generating pruning matrices is finished"; date
fi
