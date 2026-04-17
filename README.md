# Análise de Série Histórica de Precipitação (2015-2025) - RN, Brasil

### Historical Precipitation Series Analysis - Rio Grande do Norte, Brazil

---

## 🗺️ Visualização do Mapa / Map Visualization
<img width="3507" height="2480" alt="Mapa_RN_janeiro_jenks" src="https://github.com/user-attachments/assets/72da9f9f-3e02-41e2-956d-c6fcb24dbfb6" />

---

## 📋 Descrição / Description

Este projeto realiza uma análise espacial da precipitação no estado do Rio Grande do Norte, cobrindo uma série histórica de 10 anos (2015-2025) do mês de janeiro. O objetivo é identificar padrões climáticos e anomalias na região.

*This project performs a spatial analysis of precipitation in the state of Rio Grande do Norte, Brazil, covering a 10-year historical series (2015-2025). The goal is to identify climate patterns and anomalies in the region.*

### 🛠️ Tecnologias e Metodologias / Technologies & Methodologies

* **Geoprocessamento / GIS:** QGIS (validação), Processamento de Dados Raster.
* **Análise de Dados / Data Analysis:** Linguagem R / Python (processamento da série histórica).
* **Visualização / Visualization:** Cartografia Temática, Escalas Sequenciais de Cores (CSS-style para web dashboards).

---

## 🚀 Como Utilizar / How to Use

Para reproduzir esta análise, você precisará dos seguintes dados brutos (não incluídos neste repositório por questões de tamanho):
1.  [Link para a fonte dos dados de precipitação, https://meteorologia.emparn.rn.gov.br/relatorios/relatorios-pluviometricos]
2.  [Link para o Shapefile do Rio Grande do Norte, https://www.ibge.gov.br/geociencias/organizacao-do-territorio/malhas-territoriais/15774-malhas.html?=&t=downloads]

## 📦 Dados Espaciais (Shapefiles)

Os dados vetoriais utilizados nesta análise de precipitação estão disponíveis para fins de auditoria e estudos acadêmicos:

* **[Clique aqui para baixar o Shapefile do projeto](./REGIÕES DE SAÚDE.zip)**: Contém os polígonos das regiões de saúde do RN processados.


**Nota Técnica:** Os dados originais foram obtidos via [Emparn/IBGE/Sesap] e processados utilizando o datum SIRGAS 2000.

## 💻 Script de Processamento

O código utilizado para a geração das análises e do mapa de precipitação pode ser encontrado no link abaixo:

* **[Script de Análise (R/Python)](./scripts/analise_precipitacao.R)** - *Contém a lógica de tratamento dos dados brutos.*
---

*Este projeto demonstra a união de Geoprocessamento Sênior com Desenvolvimento de Sistemas para análise climática.*
*This project demonstrates the union of Senior Geoprocessation with Systems Development for climate analysis.*
