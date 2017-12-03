library(sqldf)

setwd("d:/optimization/stats")
t_availability <- read.csv("tbl_2G_availability.csv")

db <- dbConnect(SQLite(), dbname="kpi_south.sqlite")
dbWriteTable(conn = db, name = "t_availability", value = t_availability, row.names = FALSE, header = TRUE, append = TRUE)

dbDisconnect(db)            # Close connection
#rm(list = c("t_availability"))   # Remove data frames

