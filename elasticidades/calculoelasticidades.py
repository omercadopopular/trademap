# -*- coding: utf-8 -*-
"""

PROJETO: "Uma Estratégia De Antecipação Dos Impactos Regionais E Setoriais
Da Abertura Comercial Brasileira Sobre O Emprego E Requalificação Da População Afetada"

EQUIPE DO PROJETO: Carlos Góes (SAE), Eduardo Leoni (SAE),
Luís Montes (SAE) e Alexandre Messa (Núcleo Econômico da CAMEX).

AUTOR DESTE CÓDIGO: Carlos Góes, SAE/Presidência da República

DATA: 30/05/2017

"""

import pandas as pd
import statsmodels.formula.api as smf
import matplotlib.mlab as mlab
import matplotlib.pyplot as plt
import numpy as np
import os

# Importar dados

datapath = "K:\\Notas Técnicas\\Abertura\\Econometria\\data\\cnae_mun.csv"
resultspath = "K:\\Notas Técnicas\\Abertura\\Econometria\\results"
pwd = os.getcwd()
os.chdir(os.path.dirname(datapath))
df = pd.read_csv(os.path.basename(datapath), low_memory=False)
os.chdir(pwd)

# Criar lista de CNAE e Estados

tcnaelist = df['cnae_2_0_subclasse'].unique()
statelist = df['UFSigla'].unique()
munlist = df['mun_trab'].unique()
gtaplist = [i+1 for i in range(57)]

# Gerar tabela agregado por GTAP, nacionalmente, para cada ano

consolidate = (df
               .groupby(['AnoRais','gtap']).sum()
               .rename(columns={"n": "nacional"})
               )

# Gerar tabela agregado por GTAP, por estado

statesum = (df
           .groupby(['UFSigla','gtap']).sum()
           .reset_index(drop=False)
           .sort_values(by=['UFSigla','gtap'])
           .drop(['AnoRais'], axis=1)
           )

# Gerar tabela agregado por GTAP, por estado, para cada ano

statedf = (df
           .groupby(['UFSigla','AnoRais','gtap']).sum()
           .reset_index(drop=False)
           .sort_values(by=['UFSigla','AnoRais','gtap'])
           )

# Rodar loop para calcular elasticidades de cada setor GTAP para cada estado

## Criar lista vazia com elasticidades
elasticities = []

# Loop
for state in statelist:
    # Reduzir base de dados para cada estado
    dfmin = statedf[statedf['UFSigla'] == state]
    # Adicionar dados nacionais consolidados por ano ao dataframe
    dfmin = (consolidate
             .join(dfmin.set_index(['AnoRais','gtap']), how='inner')
             .reset_index(drop=False)
            )

    # Criar lista de GTAPs disponíveis no município
    gtaplistm = np.sort(dfmin['gtap'].unique())
        
    for gtap in gtaplistm:
        # Criar dataframe para a regressão
        regset = dfmin[ dfmin['gtap'] == gtap ]
        
        # Define o indexador temporal
        regset = regset.set_index('AnoRais')
        
        # Roda o modelo
        result = smf.ols(formula="np.log(n) ~ np.log(nacional)", data=regset).fit()
        
        # Armazena a elasticidade
        elasticities.append(result.params[1])
        
# Adiciona as elasticidades à tabela agregado por GTAP, por estado      
statesum['elasticities'] = pd.Series(elasticities)

# Exporta as elasticidades para um CVS
elasticitiesdf = (statesum
                  .drop('n', axis=1)
                  .set_index(['UFSigla','gtap'])
                  )

elasticitiesdf.to_csv(resultspath + "\\elasticities.csv", sep=";", header=True)

# Grafica histograma das elasticidades
n, bins, patches = plt.hist(elasticities,
                            bins=250,
                            normed=True,
                            facecolor='grey', 
                            alpha=0.75,
                            label="population") 


# Linha de distribuição normal
#y = mlab.normpdf(bins, np.mean(elasticities), np.std(elasticities))
#l = plt.plot(bins, y, 'r--', linewidth=2)
         
plt.axis([-10,10,0,0.45])
plt.xlabel('Elasticity') 
plt.ylabel('Probability of Each Value')  
plt.title('Histogram of elasticities')
plt.show()

# Cálculo de percentis
pctiles = pd.Series(
            list(map(lambda i: np.percentile(elasticities, i),np.linspace(10,90, num=5))),
                index = np.linspace(10,90, num=5))
print(pctiles)
# 