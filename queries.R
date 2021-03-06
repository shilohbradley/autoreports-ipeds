########################################
# A script for writing SQL queries     #
# to an Access database that contains  #
# IPEDS data.                          #
########################################

## Set working directory -----
setwd("C:/Users/iadsshared/Desktop/autoreports/")

## Functions -----
R_vector_to_SQL_vector <- function(v)
{
  my_str <- paste0("(", v[1])
  
  for (i in v[2:length(v)]) {
    my_str <- paste(my_str, i, sep = ",")
  }
  my_str <- paste0(my_str, ")")
  
  return(my_str)
}

flexible_query <- function(metric, tablename, instnm_table = "HD2016")
{
  my_q <- paste0("select a.UNITID,a.INSTNM as Institution,b.", metric, " as y ",
               "from ", instnm_table, " a ",
               "inner join ", tablename, " b on a.UNITID = b.UNITID ",
               "where a.UNITID in ", R_vector_to_SQL_vector(id_vec), " ")
  my_r <- sqlQuery(channel = ipeds, my_q)
  
  return(my_r)
}

## Load sources -----
## Locate Access file
ipeds <- odbcConnectAccess2007("IPEDS201617.accdb")

## Load Peer Institutions
my_peers <- read.csv("report_peers.csv", header = TRUE, stringsAsFactors = FALSE)
id_vec <- as.numeric(my_peers[ ,1])

id_self <- id_vec[1]

## Load Report Metrics from csv file
my_report_metrics <- read.csv("report_metrics.csv", header = TRUE, stringsAsFactors = FALSE)

if (((my_report_metrics$Report_Name[1] == "Institution Names") & (my_report_metrics$Metric[1] == "INSTNM") & (length(grep("HD20[0-9][0-9]", my_report_metrics$Table[1])) > 0))) {
  report_list <- list()
  
  ## Query metrics from Database -----
  for (i in 2:nrow(my_report_metrics)) {
    i_r <- flexible_query(metric = trimws(my_report_metrics$Metric[i], which = "both"),
                          tablename = trimws(my_report_metrics$Table[i], which = "both"),
                          instnm_table = trimws(my_report_metrics$Table[1], which = "both"))
    
    i_r <- i_r[match(id_vec,as.numeric(as.character(i_r$UNITID))), ]
    report_list[[i]] <- i_r
  }  
} else {
  stop("Do not remove HD20XY from row 2.  Custom reports begin on row 3 of the report_metrics.csv file.")
}











