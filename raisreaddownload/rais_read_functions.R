library(dplyr)
source("~/cnae_gtap/R/cnae20_gtap.R")
#####
clean <- function(x, more=FALSE, encoding=NULL, leave='') {
  ## x <- enc2utf8(x)
  x <- gsub(' +', ' ', x)
  if(is.null(encoding)) {
    enc <- rvest::guess_encoding(x)[,1]
    enc <- enc[!grepl('IBM424', enc)]
    enc <- enc[1]
  } else enc <- encoding
  y <- iconv(x, from=enc)
  ##print(y)
  y <- iconv(x, from=enc, to='ASCII//TRANSLIT')
  if (more) {
    y <- gsub(paste0("[^a-zA-Z0-9", leave, "]+"), "_", y)
    y <- gsub('_$', '', y)
  }
  return(y)
}

library(dplyr)
##modified version of microdadosBrasil
devtools::load_all("/rais/reps/microdadosBrasil/")
#ufnow <- "AC"
read_rais <- function(ufnow="AC", yearnow=2015, recode=TRUE) {
  #rais_names <- c("bairros_sp", "bairros_fortaleza", "bairros_rj", "causa_afastamento_1", "causa_afastamento_2", "causa_afastamento_3", "motivo_desligamento",  "cbo_ocupacao_2002", "cnae_2_0_classe", "cnae_95_classe", "distritos_sp",  "vinculo_ativo_31_12", "faixa_etaria", "faixa_hora_contrat",  "faixa_remun_dezem_sm", "faixa_remun_media_sm", "faixa_tempo_emprego", "escolaridade_apos_2005", "qtd_hora_contr", "idade", "ind_cei_vinculado",  "ind_simples", "mes_admissao", "mes_desligamento", "mun_trab", "municipio", "nacionalidade", "natureza_juridica", "ind_portador_defic",  "qtd_dias_afastamento", "raca_cor", "regioes_adm_df", "vl_remun_dezembro_nom", "vl_remun_dezembro_sm", "vl_remun_media_nom", "vl_remun_media_sm", "cnae_2_0_subclasse", "sexo_trabalhador", "tamanho_estabelecimento", "tempo_emprego", "tipo_admissao", "tipo_estab", "tipo_estab_1", "tipo_defic", "tipo_vinculo", "ibge_subsetor", "vl_rem_janeiro_cc", "vl_rem_fevereiro_cc", "vl_rem_marco_cc", "vl_rem_abril_cc", "vl_rem_maio_cc", "vl_rem_junho_cc", "vl_rem_julho_cc", "vl_rem_agosto_cc","vl_rem_setembro_cc", "vl_rem_outubro_cc", "vl_rem_novembro_cc", "source_file")
  d <- read_RAIS("vinculos", i=yearnow, root_path = datadir, UF=ufnow)
  names(d) <- names(d)%>%iconv(from="latin1")%>%clean(more=TRUE)%>%tolower
  names(d)[grep("tipo_estab", names(d))] <- c("tipo_estab",  "tipo_estab_1")

  if (recode) {
    numvars <- c("vl_remun_dezembro_nom", "vl_remun_dezembro_sm", "vl_remun_media_nom", "vl_remun_media_sm",  "tempo_emprego", "vl_rem_janeiro_cc", "vl_rem_fevereiro_cc", "vl_rem_marco_cc", "vl_rem_abril_cc", "vl_rem_maio_cc", "vl_rem_junho_cc", "vl_rem_julho_cc", "vl_rem_agosto_cc", "vl_rem_setembro_cc", "vl_rem_outubro_cc", "vl_rem_novembro_cc")
    numvars <- intersect(numvars, names(d))
    d <- d%>%mutate_at(.cols = numvars, function(x) type.convert(x,dec=","))
    strvars <- names(d)[sapply(d, is.character)]
    d <- d%>%mutate_at(strvars, function(x) {
      x <- iconv(x,from='latin1')
      x[grepl("\\{", x)] <- NA
      x})
  }
  d
}

agmun_rais <- function(rais) {
  rais <- rais%>%
    filter(motivo_desligamento==0)%>%
    mutate(gtap=cnae20_gtap(cnae_2_0_subclasse))
  rais_mun_trab <- rais%>%count(mun_trab, gtap)
  rais_mun_trab
}

