## translate to no mapa report tables
## dhemerson.costa@ipam.org.br

## read libraries
library(dplyr)
library(sf)

## avoid sci notations
options(scipen=9e3)

## read table
data <- read.csv('./table/2025-01-15-REPORT_v5.csv') %>%
  subset(select=-c(system.index, .geo)) %>%
  mutate(condition = case_when(
    condition == 1 ~ "Dentro",
    condition == 2 ~ "Entorno",
    TRUE ~ as.character(condition)
  ))

## read shapefile
vector <- read_sf('./vector/15-01-2025.shp')
vector$ID_unico <- as.numeric(vector$ID_un)

## join
data <- left_join(data, vector, by= c('objectid' = 'ID_un')) %>%
  as.data.frame() %>%
  select(-c(geometry, ha))

## read lcluc dictionary
#dict <- read.csv2('./dict/mapbiomas-dict-ptbr.csv', sep=';', fileEncoding = 'latin2')

## translate lulc
#data <- left_join(data, dict, by= c('class_id' = 'id'))

## export 
write.table(x= data,
            file= './2025-01-15-TNM-REPORT_v5.csv', 
            fileEncoding='UTF-8',
            row.names= FALSE,
            sep='\t',
            dec='.',
            col.names= TRUE)
