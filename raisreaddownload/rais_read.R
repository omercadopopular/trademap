source('~/cnae_gtap/R/rais_read_functions.R')
datadir <- "/rais/rais_data_txt/"
resultsdir <- "/rais/rais_results/"


#rais <- read_rais("AC", recode = TRUE, yearnow = 2014)

#rais <- read_rais("AC", recode = TRUE, yearnow=2015)

yearnow <- 2013
for (ufnow in c("AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA", "MG", "MS", "MT", "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO", "RR", "RS", "SC", "SE", "SP", "TO")) {
  print(ufnow)
  print(yearnow)
  try(rm(rais))
  gc()
  rais <- read_rais(ufnow, recode = TRUE, yearnow = yearnow)
  fname <- file.path(resultsdir,paste0(ufnow,yearnow,"_all.rds"))
  saveRDS(rais, file=fname)
  gc()
  rais <- rais%>%select(cnae_2_0_subclasse, mun_trab, motivo_desligamento)
  gc()
  rais_mun <- agmun_rais(rais)
  fname <- file.path(resultsdir,paste0(ufnow,yearnow,"_mun.rds"))
  saveRDS(rais_mun, file=fname)
}

stop()


save(rais_mun_all, file="~/cnae_gtap/results/rais_mun.RData")


