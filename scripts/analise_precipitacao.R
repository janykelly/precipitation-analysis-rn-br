# PROJETO: Análise de Precipitação Rio Grande do Norte (2015-2025)
# AUTORA: Jany Kelly (Bacharela em Geografia / Esp. Geoprocessamento)
# DESCRIÇÃO: Script desenvolvido para processamento de séries históricas e 
# geração de cartografia temática com foco em climatologia.

# pacotes instalados
library(tidyverse)
library(sf)
library(gstat)
library(ggspatial)
library(ggh4x) 
library(ggplot2)
library(classInt)
library(RColorBrewer)


# 1. LEITURA E LIMPEZA
caminho_janeiro <- "C:/Users/jany.araujo/Documents/GEO SUVAM/VIGIDESASTRES/PRECIPITACAO/JANEIRO/janeiro de 2015 a 2025.csv"

# Leitura flexível (tenta ; depois tenta ,)
dados_raw <- read.table(caminho_janeiro, sep = ";", header = TRUE, dec = ",", 
                        fill = TRUE, fileEncoding = "Latin1", check.names = FALSE, quote = "")

if (ncol(dados_raw) < 2) {
  dados_raw <- read.table(caminho_janeiro, sep = ",", header = TRUE, dec = ".", 
                          fill = TRUE, fileEncoding = "Latin1", check.names = FALSE, quote = "")
}

dados <- dados_raw %>%
  setNames(c("ano_v", "mes_v", "mun_v", "lat_v", "lon_v", "chuva_v")) %>%
  mutate(
    ano   = as.numeric(gsub("[^0-9]", "", as.character(ano_v))),
    lat   = as.numeric(gsub(",", ".", gsub('[^0-9.,-]', '', as.character(lat_v)))),
    lon   = as.numeric(gsub(",", ".", gsub('[^0-9.,-]', '', as.character(lon_v)))),
    chuva = as.numeric(gsub(",", ".", gsub('[^0-9.,-]', '', as.character(chuva_v))))
  ) %>%
  drop_na(ano, lat, lon, chuva) %>%
  filter(lat < 0, lon < 0) %>%
  as.data.frame()

# 2. SHAPEFILES E GRID
rn_limite <- st_read("C:/Users/jany.araujo/Documents/GEO SUVAM/BASE CARTOGRÁFICA/RN 2023/RN_UF_2023/RN_UF_2023.shp") %>%
  st_transform(4674) %>% st_make_valid()

regioes_saude <- st_read("C:/Users/jany.araujo/Documents/GEO SUVAM/BASE CARTOGRÁFICA/REGIÕES DE SAÚDE/REGIÕES DE SAÚDE/REGIÕES DE SAÚDE.shp") %>%
  st_transform(4674) %>% st_make_valid()

sf_use_s2(FALSE)

# CRIAR GRID
grid_base <- expand.grid(
  lon = seq(-38.6, -34.8, length.out = 150),
  lat = seq(-7.1, -4.7, length.out = 150)
)
grid_sf <- st_as_sf(grid_base, coords = c("lon", "lat"), crs = 4674)
grid_rn <- st_intersection(grid_sf, st_union(rn_limite)) 

grid_coords <- as.data.frame(st_coordinates(grid_rn))
names(grid_coords) <- c("lon", "lat")

# 3. FUNÇÃO DE INTERPOLAÇÃO (IDW)
interpolar_por_ano <- function(ano_escolhido) {
  d_sub <- dados[dados$ano == ano_escolhido, c("lon", "lat", "chuva")]
  if(nrow(d_sub) < 3) return(NULL)
  
  tryCatch({
    modelo <- gstat(formula = chuva ~ 1, locations = ~lon + lat, data = d_sub)
    pred <- predict(modelo, grid_coords, debug.level = 0)
    pred$ano <- ano_escolhido 
    return(as.data.frame(pred))
  }, error = function(e) return(NULL))
}

dados_finais <- map_df(sort(unique(dados$ano)), interpolar_por_ano)

# --- AJUSTE PARA O MÁXIMO DA PLANILHA (619 mm) ---
n_classes <- 6

# 1. Calculamos as quebras iniciais com Fisher
calc_breaks <- classIntervals(dados_finais$var1.pred, n = n_classes, style = "fisher", unique = TRUE)
quebras <- calc_breaks$brks

# 2. Pegamos o valor máximo real da sua planilha original
max_real <- max(dados$chuva, na.rm = TRUE)

# 3. Substituímos o último valor das quebras pelo máximo da planilha (se ele for maior)
if(max_real > max(quebras)) {
  quebras[length(quebras)] <- max_real
}

# 4. Criamos os rótulos atualizados
rotulos_legenda <- c()
for(i in 1:(length(quebras)-1)){
  rotulos_legenda[i] <- paste0(round(quebras[i], 1), " - ", round(quebras[i+1], 1))
}

# 4. APLICAÇÃO DAS CLASSES E MAPA FINAL
dados_finais <- dados_finais %>%
  mutate(
    classe = cut(
      var1.pred,
      breaks = quebras,
      labels = rotulos_legenda,
      include.lowest = TRUE,
      right = FALSE
    )
  )

p_final <- ggplot(dados_finais, aes(x = lon, y = lat)) +
  geom_tile(aes(fill = classe)) +
  # Adicionamos os limites das regiões e do estado
  geom_sf(data = regioes_saude, fill = "transparent", color = "black", linewidth = 0.1, inherit.aes = FALSE) +
  geom_sf(data = rn_limite, fill = "transparent", color = "black", linewidth = 0.5, inherit.aes = FALSE) +
  
  facet_wrap2(~ano, ncol = 4, axes = "all") +
  
  scale_fill_brewer(
    palette = "YlGnBu", 
    name = "Chuva (mm)",
    drop = FALSE, # Importante para manter todas as classes na legenda
    guide = guide_legend(
      reverse = TRUE, 
      keyheight = unit(0.8, "cm")
    )
  ) +
  
  coord_sf(xlim = c(-38.6, -34.8), ylim = c(-7.1, -4.7), expand = FALSE) +
  annotation_scale(location = "bl", width_hint = 0.15, text_cex = 0.4) +
  annotation_north_arrow(location = "br", which_north = "true",
                         height = unit(0.5, "cm"), width = unit(0.6, "cm"),
                         style = north_arrow_minimal(text_size = 6)) +
  
  labs(title = "Precipitação Mensal no Rio Grande do Norte - Janeiro",
       subtitle = paste0("Série Histórica: ", min(dados$ano), " a ", max(dados$ano), " (Método Fisher-Jenks)"),
       x = "Longitude", y = "Latitude") +
  
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    axis.text.x = element_text(size = 5, angle = 45, vjust = 1, hjust = 1),
    axis.text.y = element_text(size = 5),
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 8),
    strip.background = element_rect(fill = "lightgray"),
    strip.text = element_text(face = "bold")
  )

# Visualizar o mapa
print(p_final)
# SALVAR
ggsave("Mapa_RN_agosto_jenks.png", plot = p_final, width = 297, height = 210, units = "mm", dpi = 300)
