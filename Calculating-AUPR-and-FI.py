from operator import add
import os,random, subprocess,numpy, sys, sklearn, scipy, itertools, shutil, math
from sklearn import ensemble
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.ensemble import RandomForestClassifier
from rfpimp import *
import pandas as pd
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
from pandas.core.frame import DataFrame
import eli5
from eli5.sklearn import PermutationImportance
plt.switch_backend('agg')
import numpy as np
from sklearn.tree import _tree
import multiprocessing
import time

def Run_RF(allLabels, allFeatures, valLabels, valFeatures, outputPrefix, repetitions, group, header, outputDir, version, data_id, gini, perm):
	#
	defaultFI=[0]*len(valFeatures[0])
	oob=[]
	acc=[]
	o=[0]*len(valLabels)
	##
	allLabels_pridf=DataFrame(allLabels)
	allLabels_pridf.columns = ["label"]
	allLabels_df=allLabels_pridf['label'].apply(str)
	valLabels_pridf=DataFrame(valLabels)
	valLabels_pridf.columns = ["label"]
	valLabels_df=valLabels_pridf['label'].apply(str)
	##
	allFeatures_df=DataFrame(allFeatures, dtype=float)
	valFeatures_df=DataFrame(valFeatures, dtype=float)
	allFeatures_df.columns = header
	valFeatures_df.columns = header
	valFeatures_arr = np.array(valFeatures_df, dtype = "float32")
	##
	for rep in range(0, repetitions):
		print("@@@@       Repetition " + str(rep) + " is started " + time.asctime(time.localtime(time.time())) + "@@@@      ")
		# print("@@@@       Start fitting model. " + time.asctime(time.localtime(time.time())) + " @@@@      ")
		rfc=RandomForestClassifier(n_estimators=100, oob_score=True)
		rfc.fit(allFeatures_df, allLabels_df)
		print("@@@@       Fitting model is done! " + time.asctime(time.localtime(time.time())) + "       @@@@")
		print(rfc.oob_score_)
		oob.append(rfc.oob_score_)
		predictions=rfc.predict(valFeatures)
		#
		i=0
		correct=0
		incorrect=0
		for x in predictions:
			if x == valLabels[i]:
				correct += 1
			else:
				incorrect += 1
			i += 1
		#
		M=rfc.predict_proba(valFeatures)
		acc.append(correct/float(correct+incorrect))
		#
		k=0
		for entry in M:
			o[k] += entry[1]
			k += 1
		## default ##
		defaultFI=[x + y for x, y in zip(defaultFI, rfc.feature_importances_)]
		# perm
		if perm == "perm":
			print("@@@@       perm FI is started. " + time.asctime(time.localtime(time.time())) + "       @@@@")
			# # rfpimp
			# rfppermFIOutput=outputDir+"/FI_rfpperm_" + str(rep) + "_" + outputPrefix+"_"+str(group)+"."+version+".txt"
			# output3=open(rfppermFIOutput, "w")
			# rfppermFI=[0]*len(valFeatures[0])
			# imp = permutation_importances(rfc, valFeatures_df, valLabels_df, oob_classifier_accuracy)
			# imp_neworder = imp.loc[header]
			# rfppermFI=[x + y for x, y in zip(rfppermFI, imp_neworder["Importance"])]
			# if perm == "perm":
			# 	m=0
			# 	for element in rfppermFI:
			# 		 output3.write(header[m] + "\t" + str(element) + "\n")
			# 		 m+=1
			#
			## eli5 ##
			eli5permFIOutput=outputDir+"/FI_perm_rep" + str(rep) + "_" + outputPrefix+"_"+str(group)+"."+version+".txt"
			permFI = PermutationImportance(rfc, random_state = 1).fit(valFeatures_df, valLabels_df)
			eli5_permFI_df = eli5.explain_weights_df(permFI, feature_names= valFeatures_df.columns.tolist())
			eli5_permFI_df.to_csv(eli5permFIOutput, sep='\t', index=False)
			print("@@@@       perm FI is done! " + time.asctime(time.localtime(time.time())) + "       @@@@")
		# gini
		if gini == "gini":
			print("@@@@       gini FI is started. " + time.asctime(time.localtime(time.time())) + "       @@@@")
			valginifiOutput=outputDir+"/FI_gini_rep" + str(rep) + "_" + outputPrefix+"_"+str(group)+"."+version+".txt"
			output4=open(valginifiOutput, "w")
			## valginiFI ##
			## pos sample and neg sample ##
			pos_row = []
			neg_row = []
			pos_row = [i for i in range(len(valLabels_df)) if valLabels_df[i] == "1"]
			neg_row = [i for i in range(len(valLabels_df)) if valLabels_df[i] == "0"]
			# a = calculate_gini_impurity(rfc, 0, pos_row, neg_row, valLabels_df)
			ensemble_importances = dict(zip(header, [0]*len(header)))
			all_tree_importance = []
			pool = multiprocessing.Pool(processes=1)
			for tree_id in range(len(rfc.estimators_)):
				all_tree_importance.append(pool.apply_async(calculate_gini_impurity, args = (rfc, tree_id, pos_row, neg_row, valLabels_df, valFeatures_arr, data_id,  )))
			pool.close()
			pool.join()
			for i in range(len(rfc.estimators_)):
				for j in header:
					ensemble_importances[j] += all_tree_importance[i].get()[j]
			for j in header:
				ensemble_importances[j] /= len(rfc.estimators_)
			## gini FI ##
			if gini == "gini":
				k=0
				for element in ensemble_importances:
					 output4.write(element + "\t" + str(ensemble_importances[element]) + "\n")
					 k+=1
			output4.close()
			print("@@@@       gini FI is done! " + time.asctime(time.localtime(time.time())) + "       @@@@")
		print("@@@@       Repetition " + str(rep) + " is done! " + time.asctime(time.localtime(time.time())) + "       @@@@")
		print("\n")
	#
	print(numpy.mean(oob), "\t", numpy.mean(acc))
	#
	valOutput=outputDir+"/Predictions_"+outputPrefix+"_"+str(group)+"."+version+".txt"
	defaultFIOutput=outputDir+"/FI_default_"+outputPrefix+"_"+str(group)+"."+version+".txt"
	output1=open(valOutput, "w")
	output2=open(defaultFIOutput, "w")
	## validation ##
	i=0
	for entry in o:
		output1.write(str(valLabels[i]) + "\t" + str(entry/float(repetitions)) + "\n")
		i += 1
	## defaultFI ##
	j=0
	for element in defaultFI:
		 output2.write(header[j] + "\t" + str(element/float(repetitions)) + "\n")
		 j+=1		 
	output1.close()
	output2.close()
	# output3.close()

def Run_Model(trainFeat,trainLab, outputPrefix, cvList, cvGroups, header,\
	outputDir, version, gini, perm):
	i=1
	for group in cvList:
		data_id = '_' + outputPrefix + '_' + group + '_'
		print("@@@@       Running cross-validation for "+ group + "       @@@@")
		print("\n")
		trainMatrix=[]
		testMatrix=[]
		trainY=[]
		testY=[]
		j=0
		for entry in cvGroups:
			if entry == group:
				testMatrix.append(trainFeat[j])
				testY.append(trainLab[j])
			else:
				trainMatrix.append(trainFeat[j])
				trainY.append(trainLab[j])
			j+=1
		Run_RF(trainY, trainMatrix, testY, testMatrix, outputPrefix, 5, \
			group, header, outputDir, version, data_id, gini, perm)
		i+=1
	return

def calculate_gini_impurity(rfc, tree_id, pos_row, neg_row, valLabels_df, valFeatures_arr, data_id):
	tree_importance = dict(zip(header, [0]*len(header)))
	single_tree = rfc.estimators_[tree_id].tree_
	n_nodes = single_tree.node_count
	children_left = single_tree.children_left
	children_right = single_tree.children_right
	feature_index = single_tree.feature
	node_indicator = single_tree.decision_path(valFeatures_arr)  # position (i, j) indicates that the sample i goes through the node j
	position = list(node_indicator.todok().keys())
	position_array = np.array(position)
	#
	##
	data_id_tree_id = data_id + str(tree_id)
	nodes = np.array(range(0, n_nodes))
	os.chdir(outputDir + '/' + 'toBeDeleted/')
	##
	np.savetxt("nodes" + data_id_tree_id + ".txt", nodes, fmt='%s', delimiter='\t', newline='\n')
	np.savetxt("result" + data_id_tree_id + ".txt", position_array, fmt='%s', delimiter='\t', newline='\n')
	np.savetxt("pos_row" + data_id_tree_id + ".txt", np.array(pos_row), fmt='%s', delimiter='\t', newline='\n')
	np.savetxt("neg_row" + data_id_tree_id + ".txt", np.array(neg_row), fmt='%s', delimiter='\t', newline='\n')
	os.system("awk -F '\t' 'FNR==NR {x[$1];next} ($1 in x)' pos_row" + data_id_tree_id + ".txt result" + data_id_tree_id + ".txt > pos_node" + data_id_tree_id + ".txt") # pos samples: column 1, nodes: column 2
	os.system("awk -F '\t' 'FNR==NR {x[$1];next} ($1 in x)' neg_row" + data_id_tree_id + ".txt result" + data_id_tree_id + ".txt > neg_node" + data_id_tree_id + ".txt") # neg samples: column 1, nodes: column 2
	#
	os.system("cat pos_node" + data_id_tree_id + ".txt | awk '{print $2}' | sort | uniq -c | sort -k2,2n > pos_node_count" + data_id_tree_id + ".txt") # column 1: N. pos, column 2: node id
	os.system("cat neg_node" + data_id_tree_id + ".txt | awk '{print $2}' | sort | uniq -c | sort -k2,2n > neg_node_count" + data_id_tree_id + ".txt") # column 2: N. neg, column 2: node id
	## N. pos = 0 (which nodes)
	os.system("awk -F ' ' 'FNR==NR {x[$2];next} ($1 in x)' pos_node_count" + data_id_tree_id + ".txt nodes" + data_id_tree_id + ".txt | sort -k1,1n > pos_node_notZero" + data_id_tree_id + ".txt")
	os.system("sort nodes" + data_id_tree_id + ".txt pos_node_notZero" + data_id_tree_id + ".txt pos_node_notZero" + data_id_tree_id + ".txt | uniq -u | awk '{print 0,$1}' > pos_node_countZero" + data_id_tree_id + ".txt")
	## N. neg = 0 (which nodes)
	os.system("awk -F ' ' 'FNR==NR {x[$2];next} ($1 in x)' neg_node_count" + data_id_tree_id + ".txt nodes" + data_id_tree_id + ".txt | sort -k1,1n > neg_node_notZero" + data_id_tree_id + ".txt")
	os.system("sort nodes" + data_id_tree_id + ".txt neg_node_notZero" + data_id_tree_id + ".txt neg_node_notZero" + data_id_tree_id + ".txt | uniq -u | awk '{print 0,$1}' > neg_node_countZero" + data_id_tree_id + ".txt")
	## N. pos, N. neg and N. pos + neg of all nodes
	os.system("cat neg_node_count" + data_id_tree_id + ".txt neg_node_countZero" + data_id_tree_id + ".txt | sort -k2,2n > neg_node_count_all" + data_id_tree_id + ".txt")
	os.system("cat pos_node_count" + data_id_tree_id + ".txt pos_node_countZero" + data_id_tree_id + ".txt | sort -k2,2n > pos_node_count_all" + data_id_tree_id + ".txt")
	os.system("paste -d ' ' pos_node_count_all" + data_id_tree_id + ".txt neg_node_count_all" + data_id_tree_id + ".txt | awk '{print $2,$1,$3,$1+$3}' OFS='\t' > node_count" + data_id_tree_id + ".txt")
	#
	node_count = pd.read_csv("node_count" + data_id_tree_id + ".txt", header=None, delim_whitespace = True)
	node_gini_impurity = {}
	tree_importance = dict(zip(header, [0]*len(header)))
	for i in range(n_nodes):
		if children_left[i] == children_right[i] or node_count[3][i] == 0:
			node_gini_impurity[i] = 0
		else:
			pos_ratio = node_count[1][i]/(node_count[3][i])
			neg_ratio = node_count[2][i]/(node_count[3][i])
			node_gini_impurity[i] = 1 - pos_ratio*pos_ratio - neg_ratio*neg_ratio		
	#
	for i in range(n_nodes):
		if children_left[i] != children_right[i]:
			left_child_node = children_left[i]
			right_child_node = children_right[i]
			tree_importance[header[feature_index[i]]] += (node_count[3][i]*node_gini_impurity[i] - node_count[3][left_child_node]*node_gini_impurity[left_child_node] - node_count[3][right_child_node]*node_gini_impurity[right_child_node])/len(valLabels_df)
	return tree_importance

def Create_Distance_Dict(distances):
	distanceDict={}
	for line in distances:
		line=line.rstrip().split("\t")
		distanceDict[line[0].rstrip()+"-"+line[1].rstrip()]=[int(line[2])]
	return distanceDict

def Create_Gene_Dict(tss):
	tssDict={}
	geneDict={}
	for line in tss:
		line=line.rstrip().split("\t")
		tssDict[line[3]]=line[4]
		if line[4] not in geneDict:
			geneDict[line[4]]=[line[3]]
		else:
			geneDict[line[4]].append(line[3])
	return tssDict, geneDict

def Process_ELS_Gene_Pairs(pairs):
	pairArray=[]
	cvList=[]
	for line in pairs:
		line=line.rstrip().split("\t")
		pairArray.append([line[0],line[1],int(line[2]),line[3]])
		if line[3] not in cvList:
			cvList.append(line[3])
	return pairArray, cvList

def Process_Peak_Matrix(matrix, mode, header):
	elementDict={}
	h=matrix.__next__().rstrip().split("\t")[1:]
	for entry in h:
		header.append(entry+""+mode)
	for line in matrix:
		line=line.rstrip().split("\t")
		elementDict[line[0]]=[float(i) for i in line[1:]]
	return elementDict, header

def Create_Feature_Array(data, enhancerSignals, tssSignals, optionalSignals, geneDict):
	labels=[]
	cvGroups=[]
	features=[]
	for pair in data:
		tssFeatures=[]
		for tss in geneDict[pair[1]]:
			if len(tssFeatures) > 0:
				tssFeatures=map(add, tssFeatures, tssSignals[tss])
			else:
				tssFeatures=tssSignals[tss]
		tssFeatures=[x / float(len(geneDict[pair[1]])) for x in tssFeatures]
		optionalFeatures=[]
		for i in optionalSignals:
			optionalFeatures+=i[pair[0]+"-"+pair[1]]
		features.append(enhancerSignals[pair[0]]+tssFeatures+ \
			optionalFeatures)
		labels.append(pair[2])
		cvGroups.append(pair[3])
	return features, labels, cvGroups

def Create_Selected_Feature_Array(data, SelectedSignals, geneDict):
	labels=[]
	trainingCVGroups=[]
	features=[]
	for pair in data:
		features.append(SelectedSignals[pair[0]+"-"+pair[1]])
		labels.append(pair[2])
		trainingCVGroups.append(pair[3])
	return features, labels, trainingCVGroups

print("@@@@       Start Time: " + time.asctime(time.localtime(time.time())) + "       @@@@")
print("\n")

header=[]
trainingPairs=open(sys.argv[1])
trainingArray, cvList=Process_ELS_Gene_Pairs(trainingPairs)
trainingPairs.close()

SelectedMatrix=open(sys.argv[2])
SelectedSignals, header=Process_Peak_Matrix(SelectedMatrix, "", header)
SelectedMatrix.close()

tss=open(sys.argv[3])
tssDict, geneDict=Create_Gene_Dict(tss)
tss.close()

outputPrefix=sys.argv[4]
outputDir=sys.argv[5]
version=sys.argv[6]

if not os.path.exists(outputDir + '/' + 'toBeDeleted/'): os.makedirs(outputDir + '/' + 'toBeDeleted/')  

cvList = ["cv-" + sys.argv[7]]
gini = sys.argv[8]
perm = sys.argv[9]

trainFeat, trainLab, cvGroups, =Create_Selected_Feature_Array(trainingArray, \
    SelectedSignals, geneDict)

Run_Model(trainFeat, trainLab, outputPrefix, cvList, cvGroups, header, \
	outputDir, version, gini, perm)

print("@@@@       All done !!! " + time.asctime(time.localtime(time.time())) + "       @@@@")
