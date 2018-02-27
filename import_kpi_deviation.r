library(sqldf)

setwd("d:/optimization/stats")

#--- import data from file
t_kpi_deviation <- read.csv("tbl_deviation.csv")
db <- dbConnect(SQLite(), dbname="kpi_south.sqlite")
dbWriteTable(conn = db, name = "t_kpi_deviation", value = t_kpi_deviation, row.names = FALSE, header = TRUE, append = TRUE)

#--- delete rows where site is locked
s_qry = paste("DELETE FROM t_kpi_deviation WHERE \"SITE.Name\" LIKE \"%LCK%\"")
dbGetQuery(db, s_qry)

#--- count rows in table
#s_qry = paste("select count(*) from t_availability")
#delme <- dbGetQuery(db, s_qry)

dbDisconnect(db)            # Close connection
#rm(list = c("t_availability"))   # Remove data frames

