library(sqldf)
library(ggplot2)
library(plotly)

setwd("d:/optimization/stats")
db <- dbConnect(SQLite(), dbname="kpi_south.sqlite")

s_sector = "KHD5183"
s_qry = paste("SELECT * FROM t_neighbors WHERE sector like ('", s_sector ,"')",sep = "")

df_nbrs <- dbGetQuery(db, s_qry)
v_nbrs <- as.vector(df_nbrs[[2:2]])

s_qry = paste("SELECT * FROM t_availability WHERE \"BTS.NAME\" IN ('", paste(v_nbrs,collapse = "','"),"')",sep = "")

df_result <- dbGetQuery(db, s_qry)

p <- ggplot(df_result, aes(x=Start.Time, y=ifelse(SHH_TCH_Av_Den==0,0,SHH_TCH_Av_Num/SHH_TCH_Av_Den)))

p <- p + geom_line(aes(color = BTS.NAME, group = BTS.NAME))

ggplotly(p)

dbDisconnect(db)            # Close connection
