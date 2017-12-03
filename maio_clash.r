library(sqldf)
library(data.table)

setwd("d:/optimization/dumps")

#gGsmCell <- read.csv.sql("GGsmCell.csv",
#                    sql = "SELECT MOI, SubNetwork, GBtsSiteManager, GGsmCell, userLabel from file",
#                    sep = ',', quote = TRUE)

gGsmCell <- fread("GGsmCell.csv", select = c("MOI", "SubNetwork", "GBtsSiteManager", "GGsmCell", "userLabel"))
gHoppingFrequency <- fread("GHoppingFrequency.csv", select = c("MOI", "SubNetwork", "GBtsSiteManager", "GGsmCell", "HSN", "MaArfcnList"))
gTrx <- fread("GTrx.csv", select = c("MOI", "SubNetwork", "GBtsSiteManager", "GGsmCell", "refGHoppingFrequency", "maio"))
gTrx <- gTrx[ refGHoppingFrequency != ""]

# set the ON clause as keys of the tables:
setkey(gHoppingFrequency, MOI)
setkey(gTrx, refGHoppingFrequency)

# perform the join, eliminating not matched rows from Right
#Result <- gTrx[gHoppingFrequency, nomatch=0]
#Result <- merge(gTrx, gHoppingFrequency)

df1 <- sqldf("select a.*, b.HSN, b.MaArfcnList from gTrx as a inner join gHoppingFrequency as b on a.refGHoppingFrequency = b.MOI")
#df2 <- sqldf("select c.*, d.userLabel from df1 as c inner join gGsmCell as d on d.MOI + '%' like c.MOI")
df2 <- sqldf("select c.*, d.userLabel from df1 as c inner join gGsmCell as d on d.MOI = substr(c.MOI,0,length(d.MOI)+1)")

#df_co_maio <- sqldf("select MOI, userLabel, SubNetwork, GBtsSiteManager, HSN, MaArfcnList, maio from df2 as t1 where exists (select SubNetwork, GBtsSiteManager, HSN, MaArfcnList from df2 t2 where t1.SubNetwork = t2.SubNetwork and t1.GBtsSiteManager = t2.GBtsSiteManager and t1.HSN = t2.HSN and t1.MaArfcnList = t2.MaArfcnList and t1.maio = t2.maio group by SubNetwork, GBtsSiteManager, HSN, MaArfcnList having count(userLabel) > 1)")
#df3 <- sqldf("select MOI, userLabel, SubNetwork, GBtsSiteManager, HSN, MaArfcnList, maio from df2 as t1 where exists (select SubNetwork, GBtsSiteManager, HSN, MaArfcnList from df2 t2 where t1.SubNetwork = t2.SubNetwork and t1.GBtsSiteManager = t2.GBtsSiteManager and t1.HSN = t2.HSN and t1.MaArfcnList = t2.MaArfcnList group by SubNetwork, GBtsSiteManager, HSN, MaArfcnList having count(userLabel) > 1)")

#select MOI, userLabel, SubNetwork, GBtsSiteManager, HSN, MaArfcnList, maio from df2 as t1
#where exists (select SubNetwork, GBtsSiteManager, HSN, MaArfcnList
#              from df2 t2
#              where t1.SubNetwork = t2.SubNetwork
#                and t1.GBtsSiteManager = t2.GBtsSiteManager
#                and t1.HSN = t2.HSN
#                and t1.MaArfcnList = t2.MaArfcnList
#                and t1.maio = t2.maio
#              group by SubNetwork, GBtsSiteManager, HSN, MaArfcnList
#              having count(userLabel) > 1)

df_co_maio <- sqldf("select MOI, userLabel, SubNetwork, GBtsSiteManager, HSN, MaArfcnList, maio from df2 as t1 where exists (select SubNetwork, GBtsSiteManager, HSN, MaArfcnList from df2 t2 where t1.SubNetwork = t2.SubNetwork and t1.GBtsSiteManager = t2.GBtsSiteManager and t1.HSN = t2.HSN and t1.MaArfcnList = t2.MaArfcnList and t1.maio = t2.maio group by SubNetwork, GBtsSiteManager, HSN, MaArfcnList having count(userLabel) > 1)")
df_adjacent_maio <- sqldf("select MOI, userLabel, SubNetwork, GBtsSiteManager, HSN, MaArfcnList, maio from df2 as t1 where exists (select SubNetwork, GBtsSiteManager, HSN, MaArfcnList from df2 t2 where t1.SubNetwork = t2.SubNetwork and t1.GBtsSiteManager = t2.GBtsSiteManager and t1.HSN = t2.HSN and t1.MaArfcnList = t2.MaArfcnList and abs(t1.maio - t2.maio) = 1 group by SubNetwork, GBtsSiteManager, HSN, MaArfcnList having count(userLabel) > 1)")

write.csv(df_co_maio,"df_co_maio.csv")
write.csv(df_adjacent_maio,"df_adjacent_maio.csv")
