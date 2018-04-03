# clear workspace
rm(list=ls())

# load packages
if(!require(pacman)) {
  install.packages("pacman")
}
library(readxl)
library(dplyr)

pacman::p_load(sqldf)

setwd("d:/optimization/stats")

read_excel_allsheets <- function(filename, tibble = FALSE) {
  # I prefer straight data.frames
  # but if you like tidyverse tibbles (the default with read_excel)
  # then just pass tibble = TRUE
  sheets <- readxl::excel_sheets(filename)
  x = vector()
  
  for (s in sheets) {
    if (!(s %in% c("TemplateInfo", "Index"))) {
      myhead = readxl::read_excel(filename, sheet = s, col_names = TRUE, range = cell_rows(c(1, 1)))
      mydata = readxl::read_excel(filename, sheet = s, col_names = FALSE, range = cell_rows(c(6, NA)))
      colnames(mydata) <- colnames(myhead)
      x <- append(x, mydata)
      #print(x)
    }
  }
  
  #x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X, col_names = FALSE, range = cell_rows(c(6, NA))))
  #if(!tibble) x <- lapply(x, as.data.frame)
  #names(x) <- sheets
  x
}

mysheets <- read_excel_allsheets("gsm_dumps.xlsx", TRUE)