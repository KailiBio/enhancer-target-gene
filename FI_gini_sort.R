# gini
args = commandArgs(T)
cell = args[1]
benchmark = args[2]
Data_collection = args[3]
Data_form = args[4]
data_class = args[5]
#
version = "v3"
#
data_source = paste(Data_collection, Data_form, sep = "-")
repetition = 0
cv_group = 0
#
data <- read.table(paste("/data/tusers/lixiangr/BENGI/", cell, "/Output/", data_source, "/Predictions/", benchmark, "/FI_gini_rep", as.character(repetition), "_full_", data_class, "_cv-", as.character(cv_group), ".", version, ".txt", sep = ""), header = F)
data$V1 <- c(as.character(data$V1))
data_conbine <- data
#
for (repetition in 1:4){
    data_new <- read.table(paste("/data/tusers/lixiangr/BENGI/", cell, "/Output/", data_source, "/Predictions/", benchmark, "/FI_gini_rep", as.character(repetition), "_full_", data_class, "_cv-", as.character(cv_group), ".", version, ".txt", sep = ""), header = F)
    data_new$V1 <- c(as.character(data_new$V1))
    check = data$V1 == data_new[, 1]
    if (length(check[which(check == TRUE)])){
    	data_conbine <- as.data.frame(cbind(data_conbine, data_new[, 2]))
	}
}
#
for (cv_group in 1:11){
	for (repetition in 0:4){
	    data_new <- read.table(paste("/data/tusers/lixiangr/BENGI/", cell, "/Output/", data_source, "/Predictions/", benchmark, "/FI_gini_rep", as.character(repetition), "_full_", data_class, "_cv-", as.character(cv_group), ".", version, ".txt", sep = ""), header = F)
	    data_new$V1 <- c(as.character(data_new$V1))
	    check = data$V1 == data_new[, 1]
	    if (length(check[which(check == TRUE)])){
	    	data_conbine <- as.data.frame(cbind(data_conbine, data_new[, 2]))
		}
	}
}
#
mean_col <-data_conbine[, 2:ncol(data_conbine)]
mean_value <- apply(mean_col, 1, mean)
data_conbine$mean <- mean_value    
data_conbine_new <- data_conbine[order(as.numeric(data_conbine[, "mean"]), decreasing = TRUE), ]
data_sorted <- data_conbine_new[, c(1,ncol(data_conbine_new))]
# data_unsorted <- data_conbine[, c(1,ncol(data_conbine_new))]
write.table(data_sorted, paste("/data/tusers/lixiangr/BENGI/", cell, "/Output/", data_source, "/Predictions/", benchmark, "/FI_gini_full_", data_class, "_sorted.", version, ".txt", sep = ""), sep = "\t", quote = F, col.names = F, row.names = F)
print(paste("/data/tusers/lixiangr/BENGI/", cell, "/Output/", data_source, "/Predictions/", benchmark, "/FI_gini_full_", data_class, "_sorted.", version, ".txt", sep = ""))
