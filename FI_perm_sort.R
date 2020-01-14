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
# perm
options(scipen=200)
#
data <- read.table(paste("/data/tusers/lixiangr/BENGI/", cell, "/Output/", data_source, "/Predictions/", benchmark, "/FI_perm_rep", as.character(repetition), "_full_", data_class, "_cv-", as.character(cv_group), ".", version, ".txt", sep = ""), header = T, sep = "\t")
data[,1] <- c(as.character(data[, 1]))
data_combine <- data[, c(1, 2)]
#
for (repetition in 1:4){
    data_new <- read.table(paste("/data/tusers/lixiangr/BENGI/", cell, "/Output/", data_source, "/Predictions/", benchmark, "/FI_perm_rep", as.character(repetition), "_full_", data_class, "_cv-", as.character(cv_group), ".", version, ".txt", sep = ""), header = T, sep = "\t")
    data_new[,1] <- c(as.character(data_new[, 1]))    
    data_combine <- as.data.frame(cbind(data_combine, data_new[match(data[,1],data_new[,1]), 2]))
}
for (cv_group in 1:11){
	for (repetition in 0:4){
	    data_new <- read.table(paste("/data/tusers/lixiangr/BENGI/", cell, "/Output/", data_source, "/Predictions/", benchmark, "/FI_perm_rep", as.character(repetition), "_full_", data_class, "_cv-", as.character(cv_group), ".", version, ".txt", sep = ""), header = T, sep = "\t")
	    data_new[,1] <- c(as.character(data_new[, 1]))    
	    data_combine <- as.data.frame(cbind(data_combine, data_new[match(data[,1],data_new[,1]), 2]))
	}
}
mean_col <- data_combine[, c(2:ncol(data_combine))]
mean_value <- apply(mean_col, 1, mean)
data_combine$mean <- mean_value
data_combine_new <- data_combine[order(as.numeric(data_combine[, "mean"]), decreasing = TRUE), ]
data_sorted <- data_combine_new[, c(1, ncol(data_combine_new))]
write.table(data_sorted, paste("/data/tusers/lixiangr/BENGI/", cell, "/Output/", data_source, "/Predictions/", benchmark, "/FI_perm_full_", data_class, "_sorted.", version, ".txt", sep = ""), sep = "\t", quote = F, col.names = F, row.names = F)
print(paste("/data/tusers/lixiangr/BENGI/", cell, "/Output/", data_source, "/Predictions/", benchmark, "/FI_perm_full_", data_class, "_sorted.", version, ".txt", sep = ""))
