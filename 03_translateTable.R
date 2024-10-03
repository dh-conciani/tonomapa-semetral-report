## translate to no mapa report tables
## dhemerson.costa@ipam.org.br

## read libraries
library(dplyr)
library(sf)

## avoid sci notations
options(scipen=9e3)

## read table
data <- read.csv('./table/2024-10-01-REPORT_v3.csv') %>%
  subset(select=-c(system.index, .geo)) %>%
  mutate(condition = case_when(
    condition == 1 ~ "Dentro",
    condition == 2 ~ "Entorno",
    TRUE ~ as.character(condition)
  ))

## read shapefile
vector <- read_sf('./vector/01-10-2024.shp')
vector$id <- as.numeric(vector$id)

## join
data <- left_join(data, vector, by= c('objectid' = 'id')) %>%
  as.data.frame()

## read lcluc dictionary
dict <- read.csv2('./dict/mapbiomas-dict-ptbr.csv', sep=';', fileEncoding = 'latin2')

## translate lulc
data <- left_join(data, dict, by= c('class_id' = 'id'))

## export 
write.table(x= data,
            file= './2024-10-01-TNM-REPORT_v3.csv', 
            fileEncoding='UTF-8',
            row.names= FALSE,
            sep='\t',
            dec=',',
            col.names= TRUE)
