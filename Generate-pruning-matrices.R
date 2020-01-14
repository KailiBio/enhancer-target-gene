# Aim: 
#     Generate feature matrix with colnames and without the last column of label
# Parameters:
#     1. Raw feature matrix, such as "${featureDir}/${data}-draw.txt", in order to calculate AUPR of full model
#     2. Log feature matrix, such as "${featureDir}/${data}-dlog.txt", in order to calculate AUPR of full model
#     3. Correlation cut-off, such 0.6, 0.7, 0.8, 0.9
#     4. File prefix, such as ${featureDir}/${data}/${data}
#	  5. Colnames are extracted from *Enhancer-Feature-Matrix.txt, such as "${featureDir}/${data}-extracted-colnames.txt"
# Output files:
#     Feature matrix of draw_0.9_praw, such as "${featureDir}/${data}-draw-0.9-praw.txt"
#     Feature matrix of dlog_0.9_praw, such as "${featureDir}/${data}-dlog-0.9-praw.txt"
#     Feature matrix of dlog_0.9_plog, such as "${featureDir}/${data}-dlog-0.9-praw.txt"
#     Feature matrix of draw_0.9_plog, such as "${featureDir}/${data}-draw-0.9-plog.txt"

library(mlbench) 
library(caret)

args<-commandArgs(T)

raw_feature_matrix <- args[1]
log_feature_matrix <- args[2]
file_prefix <- args[3]
extracted_colnames = args[4]

all_features <- read.table(extracted_colnames, header = T)[, 1]
all_colnames <- c("window_ID", paste(all_features, "enh", sep = "_"), paste(all_features, "pro", sep = "_"), paste(all_features, "win", sep = "_"), "distance")

raw_feature_matrix <- read.table(raw_feature_matrix, header = T)
log_feature_matrix <- read.table(log_feature_matrix, header = T)

colnames(raw_feature_matrix) <- all_colnames
colnames(log_feature_matrix) <- all_colnames
## which colnames are all of 0
# raw
raw_zero_columns = c()
for (i in 2:ncol(raw_feature_matrix)){
    if (sd(raw_feature_matrix[, i]) == 0){
        raw_zero_columns = append(raw_zero_columns, i)
    }
}
# log
log_zero_columns = c()
for (i in 2:ncol(log_feature_matrix)){
    if (sd(log_feature_matrix[, i]) == 0){
        log_zero_columns = append(log_zero_columns, i)
    }
}

# Remove rows of which all the number are the same
# raw
if (! is.null(raw_zero_columns)){
    feature_raw <- raw_feature_matrix[, c(-1, -raw_zero_columns)]
    colnames_raw_1 <- all_colnames[c(-raw_zero_columns)]
} else {
    feature_raw <- raw_feature_matrix[, c(-1)]
    colnames_raw_1 <- all_colnames
}
# log
if (! is.null(log_zero_columns)){
    feature_log <- log_feature_matrix[, c(-1, -log_zero_columns)]
    colnames_log_1 <- all_colnames[c(-log_zero_columns)]
} else {
    feature_log <- log_feature_matrix[, c(-1)]
    colnames_log_1 <- all_colnames
}

for (cut_off in c(0.6, 0.7, 0.8, 0.9)){
    # find features of which correlation > cot-off
    raw_cor <- cor(feature_raw)
    raw_highCor <- findCorrelation(na.omit(raw_cor), cutoff = cut_off, verbose = TRUE, exact=T)
    log_cor <- cor(feature_log)
    log_highCor <- findCorrelation(na.omit(log_cor), cutoff = cut_off, verbose = TRUE, exact=T)

    # Remove these features from raw and log in both of the raw and log matrices
    # praw
    if (length(raw_highCor) != 0){
        draw_praw <- cbind(raw_feature_matrix[, 1], feature_raw[, -raw_highCor])
        dlog_praw <- cbind(log_feature_matrix[, 1], feature_log[, -raw_highCor])
        colnames_raw_2 <- colnames_raw_1[-(raw_highCor + 1)]
    } else {
        draw_praw <- cbind(raw_feature_matrix[, 1], feature_raw)
        dlog_praw <- cbind(log_feature_matrix[, 1], feature_log)
        colnames_raw_2 <- colnames_raw_1
    }
    # plog
    if (length(log_highCor) != 0){
        dlog_plog <- cbind(log_feature_matrix[, 1], feature_log[, -log_highCor])
        draw_plog <- cbind(raw_feature_matrix[, 1], feature_raw[, -log_highCor])
        colnames_log_2 <- colnames_log_1[-(log_highCor + 1)]
    } else {
        dlog_plog <- cbind(log_feature_matrix[, 1], feature_log)
        draw_plog <- cbind(raw_feature_matrix[, 1], feature_raw)
        colnames_log_2 <- colnames_log_1 
    }

    colnames(dlog_plog) <- colnames_log_2
    colnames(draw_plog) <- colnames_log_2
    colnames(draw_praw) <- colnames_raw_2
    colnames(dlog_praw) <- colnames_raw_2

    dlog_praw_test <- log_feature_matrix[, match(colnames(draw_praw), colnames(log_feature_matrix))]
    draw_plog_test <- raw_feature_matrix[, match(colnames(dlog_plog), colnames(raw_feature_matrix))]

    write.table(draw_praw, paste(file_prefix, "-draw-", cut_off, "-praw.txt", sep = ""), sep="\t", quote=F, row.names = F, col.names = T)
    write.table(dlog_praw, paste(file_prefix, "-dlog-", cut_off, "-praw.txt", sep = ""), sep="\t", quote=F, row.names = F, col.names = T)
    write.table(dlog_plog, paste(file_prefix, "-dlog-", cut_off, "-plog.txt", sep = ""), sep="\t", quote=F, row.names = F, col.names = T)
    write.table(draw_plog, paste(file_prefix, "-draw-", cut_off, "-plog.txt", sep = ""), sep="\t", quote=F, row.names = F, col.names = T)
}
