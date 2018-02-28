# clear workspace
rm(list=ls())

# load packages
if(!require(pacman)) {
  install.packages("pacman")
}
pacman::p_load(sqldf, ggplot2, plotly, BreakoutDetection, zoo, xts, dplyr, changepoint, changepoint.np)

# setup environment, database, etc.
setwd("d:/optimization/stats")
db <- dbConnect(SQLite(), dbname="kpi_south.sqlite")

# constants
OBS_DAYS = 10
OBS_SECS = 3600 * 24 * OBS_DAYS

max_date = dbGetQuery(db, "SELECT max(\"Start.Time\") from t_kpi_deviation")
max_date = as.POSIXct(max_date[,c(1)], tz="GMT", format="%Y-%m-%d %H:%M:%S")
max_date = max_date - OBS_SECS * 4
#max_date = as.POSIXlt(max_date)
s_qry = paste("SELECT * FROM t_kpi_deviation WHERE \"BTS.NAME\" IS NOT NULL AND \"Start.Time\" > '", as.character(max_date), "'", sep="")
#s_qry = paste("SELECT * FROM t_kpi_deviation WHERE \"BTS.NAME\" IS NOT NULL AND Start.Time > %2018-01-17%")
df_kpi_all = dbGetQuery(db, s_qry)

# delete sectors where observation counts are less than changepoint analysis segment length
observation_counts = df_kpi_all %>% group_by(BTS.NAME) %>% summarize(count=n())
observation_counts = observation_counts %>% filter(count < OBS_DAYS * 2) %>% select(BTS.NAME)
str_sectors_delete = paste(as.vector(unlist(observation_counts[1])),sep="|", collapse="|")
df_sectors = df_kpi_all %>% select(BTS.NAME) %>% distinct() %>% filter(!grepl(str_sectors_delete, BTS.NAME)) %>% arrange(BTS.NAME)

# initializations
v_sectors = df_sectors$BTS.NAME
#v_penatly = c(50, 100, 150, 200) # traffic
v_penatly = c(30, 40, 50, 80) # mpd
df = data.frame(sector=character(),priority=character(),changedate=character())
approx_iterations = as.integer(nrow(df_sectors) * (.001 + 0.01 + 0.06 + 0.03 + 1 + .3))
pb = txtProgressBar(min = 0, max = approx_iterations, style = 3)
pb_count = 0

#df_reduced <- df_kpi_all %>% select("Start.Time", "BTS.NAME", SHH_TCH_Traffic)

for ( k in 1:length(v_penatly) ) {
  vec <- vector()
  priority <- vector()

  for ( i in 1:length(v_sectors) ) {
    pb_count = pb_count + 1
    setTxtProgressBar(pb, pb_count)

    #df_reduced <- df_kpi_all %>% filter(df_kpi_all$BTS.NAME == v_sectors[i]) %>% select("Start.Time", SHH_TCH_Traffic) # traffic
    df_reduced <- df_kpi_all %>% filter(df_kpi_all$BTS.NAME == v_sectors[i]) %>% select("Start.Time", SHH_MPD) # mpd
    colnames(df_reduced) <- c("timestamp", "count")
    df_reduced[[1]] <- as.POSIXct(df_reduced[,c(1)], tz="GMT", format="%Y-%m-%d %H:%M:%S")

    tsz_reduced = zoo(df_reduced[,c("count")], order.by=as.Date(as.character(df_reduced[,c("timestamp")]), format='%Y-%m-%d'))
    ts_reduced = ts(tsz_reduced)

    res.cptmean = cpt.meanvar(ts_reduced,penalty="Manual",pen.value=v_penatly[k],method="AMOC",Q=5,test.stat="Normal",class=TRUE,param.estimates=TRUE,minseglen=OBS_DAYS)

    if (length(param.est(res.cptmean)$mean) > 1) {
      if ( param.est(res.cptmean)$mean[2] < param.est(res.cptmean)$mean[1] ) {
        vec <- c(vec, v_sectors[i])
        priority <- c(priority, v_penatly[k])

        if (v_sectors[i] %in% df$sector) {
          #df <- within(df, priority[sector==v_sectors[i]] <- v_penatly[k])
          index <- df$sector == v_sectors[i]
          df$priority[index] = v_penatly[k]
        } else {
          df_temp = data.frame(v_sectors[i], v_penatly[k], df_reduced[cpts(res.cptmean),1])
          names(df_temp) = c("sector", "priority", "changedate")
          df = rbind(df, df_temp)
        }

        #plot(res.cptmean)
      }
    }
  } # end sectors for loop

  v_sectors = vec

} # end penalty for loop

setTxtProgressBar(pb, approx_iterations)

fn = paste("d:/optimization/stats/kpi_dev_output_", format(Sys.time(), "%Y%m%d%H%M%S"), ".csv", sep="")
write.csv(df, file = fn)
