library(PRROC)
args <- commandArgs(T)
file <- args[1]
pre <- read.table(args[1], header = F)
fg <- pre[,2][pre$V1 == 1]
bg <- pre[,2][pre$V1 == 0]
pr <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve = T)
print(pr$auc.integral)
