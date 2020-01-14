# Aim: 
#     Generate both of raw and log feature matrix with colnames and without the last column of label
# Parameters:
#     1. Benchmark
#     2. Colnames are extracted from *Enhancer-Feature-Matrix.txt, such as "${featureDir}/${data}-extracted-colnames.txt"
#     3. Feature matrix without colnames and with the last column of label, such as "${featureDir}/${data}-AllPeakFeature-Matrix-Dis.txt"
#     4. Raw feature matrix, such as "${featureDir}/${data}-draw.txt", in order to calculate AUPR of full model
#     5. Log feature matrix, such as "${featureDir}/${data}-dlog.txt", in order to calculate AUPR of full model

args<-commandArgs(T)

benchmark = args[1]
extracted_colnames = args[2]
feature_matrix = args[3]

all_features <- read.table(extracted_colnames, header = T)[, 1]
all_colnames <- c("window_ID", paste(all_features, "enh", sep = "_"), paste(all_features, "pro", sep = "_"), paste(all_features, "win", sep = "_"), "distance", "label")

feature_matrix = read.table(feature_matrix, header = F)
colnames(feature_matrix) <- all_colnames

raw_feature_matrix <- feature_matrix[, 1:(ncol(feature_matrix) - 1)]
log_feature_matrix <- cbind(feature_matrix[, 1], log10(feature_matrix[, 2:(ncol(feature_matrix) - 1)] + 1e-5))
colnames(log_feature_matrix) <- c(colnames(raw_feature_matrix)[1], colnames(log_feature_matrix)[2:ncol(log_feature_matrix)])

write.table(raw_feature_matrix, args[4], sep="\t", quote=F, row.names = F, col.names = T)
write.table(log_feature_matrix, args[5], sep="\t", quote=F, row.names = F, col.names = T)
