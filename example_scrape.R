# Necessary packages
library(data.table)
library(rvest)
library(xml2)

# Website to scrape
url <- "https://www.numberfire.com/nfl/fantasy/fantasy-football-projections"

# Read in data
page <- rvest::html_table(xml2::read_html(url)
                          , header = TRUE
                          , fill = TRUE)
                          
# Combine and reshape files
projections1 <- data.table::data.table(page[[1]])
projections2 <- data.table::data.table(page[[2]])
projections_dfs <- cbind(projections1, projections2)
colnames(projections_dfs) <- c("v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8", "v9", "v10", "v11", "v12", "v13", "v14", "v15", "v16", "v17", "v18", "v19", "v20", "v21", "v22", "v23", "v24")
projections_dfs <- projections_dfs[-1, ]
projections_dfs <- projections_dfs[, gsub1 := gsub("\t", "", v1), by = v1][, gsub2 := gsub("\n", "_", gsub1), by = gsub1]
projections_dfs <- projections_dfs[, c("v25", "v26", "v27") := tstrsplit(gsub2, "_", fixed = TRUE)]
projections_dfs <- projections_dfs[, .(PLAYER = v25
                                       , POSITION = substr(gsub(".*\\((.*)\\).*", "\\1", v27), 1, 2)
                                       , TEAM = trimws(substr(gsub(".*\\((.*)\\).*", "\\1", v27), 4, nchar(gsub(".*\\((.*)\\).*", "\\1", v27))))
                                       , POINTS_DK = as.numeric(gsub("[\\$,]","", v19))
                                       , SALARY_DK = as.numeric(gsub("[\\$,]","", v20)))]

# Second website to scrape
url <- "https://www.numberfire.com/nfl/fantasy/fantasy-football-projections/d"

# Read in data
page <- rvest::html_table(xml2::read_html(url)
                          , header = TRUE
                          , fill = TRUE)

# Combine and reshape files
projections1 <- data.table::data.table(page[[1]])
projections2 <- data.table::data.table(page[[2]])
projections_dst <- cbind(projections1, projections2)
colnames(projections_dst) <- c("v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8", "v9", "v10", "v11", "v12", "v13", "v14", "v15", "v16", "v17", "v18", "v19", "v20", "v21")
projections_dst <- projections_dst[-1, ]
projections_dst <- projections_dst[, gsub1 := gsub("\t", "", v1), by = v1][, gsub2 := gsub("\n", "_", gsub1), by = gsub1]
projections_dst <- projections_dst[, c("v22", "v23", "v24") := tstrsplit(gsub2, "_", fixed = TRUE)]
projections_dst <- projections_dst[, .(PLAYER = v22
                                       , POSITION = "DST"
                                       , TEAM = trimws(substr(gsub(".*\\((.*)\\).*", "\\1", v24), 4, nchar(gsub(".*\\((.*)\\).*", "\\1", v24))))
                                       , POINTS_DK = as.numeric(gsub("[\\$,]","", v16))
                                       , SALARY_DK = as.numeric(gsub("[\\$,]","", v17)))]

df_merge <- data.table::rbindlist(list(projections_dfs, projections_dst))
                                       
# Export data 
data.table::fwrite(df_merge, "Output/example_scrape_output.csv")                                  
