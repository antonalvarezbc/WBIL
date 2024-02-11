library(readxl)
library(dplyr)
library(lubridate)
library(stringr)


##datos <- read_excel("C:/Users/WWF-POR113/Downloads/prueba_tabla.xlsx")

#
# datos_filtrados <- datos %>%
#   filter(`Folder Level` == max(`Folder Level`, na.rm = TRUE)) %>%
#   mutate(
#     `Folder Level` = as.numeric(`Folder Level`), # Asegurarse de que 'Folder Level' es numérico
#     Created = dmy_hms(Created) # Convertir 'Created' a datetime
#   ) %>%
#   arrange(Folder, Created) %>%
#   group_by(Folder) %>%
#   mutate(
#     diff_seconds = c(NA, diff(Created)), # Calcular la diferencia en segundos entre filas consecutivas
#     event = cumsum(diff_seconds > 10 | is.na(diff_seconds)) # Identificar 'eventos' basados en la diferencia de tiempo
#   ) %>%
#   ungroup() %>%
#   group_by(Folder, event) %>%
#   filter(row_number() == 1) %>% # Mantener solo la primera fila de cada 'evento'
#   ungroup() %>%
#   select(-diff_seconds, -event) %>%
#   rename(Individuo = Folder) %>% # Renombrar la columna 'Folder' a 'Individuo'
#   mutate(
#     Codigo = str_extract(Path, "[A-Z]{1,3}\\.?\\d{1,2}"), # Extraer 'Codigo' de 'Path'
#     Fecha = format(Created, "%d/%m/%Y"), # Formatear 'Created' a 'Fecha'
#     Hora = format(Created, "%H:%M") # Formatear 'Created' a 'Hora'
#   ) %>%
#   select(Codigo, Individuo, Fecha, Hora)
