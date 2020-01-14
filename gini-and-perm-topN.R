# Aim:
# 	Generate matrices of Top N from giniFI and permFI
# Parameters:
# 	1. Features matrices of all features
# 	2. Features rank from FI_gini
# 	3. Features rank from FI_perm
# 	4. Top N
# 	5. Matrices of Top N from FI_gini
# 	6. Matrices of Top N from FI_perm

args <- commandArgs(T)
data <- read.table(args[1], header = T, sep = "\t")
gini_sorted_file = args[2]
perm_sorted_file = args[3]
topN = args[4]
#
gini_selected_feature <- as.character(read.table(gini_sorted_file)$V1)[1:topN]
perm_selected_feature <- as.character(read.table(perm_sorted_file)$V1)[1:topN]
#
gini_selected <- data[, c("window_ID", gini_selected_feature)]
perm_selected <- data[, c("window_ID", perm_selected_feature)]
#
write.table(gini_selected, args[5], col.names = T, row.names = F, sep = "\t", quote = F)
write.table(gini_selected, args[6], col.names = T, row.names = F, sep = "\t", quote = F)
