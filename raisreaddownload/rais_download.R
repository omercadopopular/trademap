## downloading RAIS data

## use command line wget
## mkdir /rais/rais_data/2015
## cd /rais/rais_data/2015
##  wget -rcv -nd ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/2015/
## mkdir /rais/rais_data/2014
## cd /rais/rais_data/2014
##  wget -rcv -nd ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/2014/



## extract 7z
fnames <- dir("/rais/rais_data/2013", full.names = TRUE, recursive = TRUE)
sapply(fnames, function(fname) system(paste0("7z e ", fname, " -o", "/rais/rais_data_txt/")))


