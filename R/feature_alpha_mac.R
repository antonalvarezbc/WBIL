library(readxl)
library(dplyr)
library(lubridate)
library(stringr)


datos <- read_excel("C:/Users/WWF-POR113/Downloads/prueba_tabla.xlsx")


# Calcular el valor máximo de 'Folder Level'
max_folder_level <- max(datos$`Folder Level`, na.rm = TRUE)

# Filtrar filas que tengan el valor máximo de 'Folder Level'
datos_filtrados <- datos %>% filter(`Folder Level` == max_folder_level)


# Asegurarse de que 'Folder Level' es numérico
datos_filtrados$`Folder Level` <- as.numeric(datos_filtrados$`Folder Level`)

# Convertir 'Created' a datetime
datos_filtrados$Created <- dmy_hms(datos_filtrados$Created)


# Ordenar y agrupar por 'Folder'
datos_filtrados <- datos_filtrados %>%
  arrange(Folder, Created) %>%
  group_by(Folder) %>%
  mutate(
    # Calcular la diferencia en segundos entre filas consecutivas
    diff_seconds = c(NA, diff(Created)),
    # Identificar 'eventos' basados en la diferencia de tiempo
    event = cumsum(diff_seconds > 10 | is.na(diff_seconds))
  ) %>%
  ungroup()

# Filtrar para mantener solo la primera fila de cada 'evento'
datos_filtrados <- datos_filtrados %>%
  group_by(Folder, event) %>%
  filter(row_number() == 1) %>%
  ungroup()

# Eliminar columnas temporales si es necesario
datos_filtrados <- datos_filtrados %>%
  select(-diff_seconds, -event)

datos_filtrados <- datos_filtrados %>%
  rename(Individuo = Folder) %>% # Renombrar la columna Folder a Individuo
  mutate(
    Codigo = str_extract(Path, "[A-Z]{1,3}\\.?\\d{1,2}"), # Crear una nueva columna 'Codigo' extrayendo el patrón deseado de la columna 'Path'
    Fecha = format(ymd_hms(Created), "%d/%m/%Y"), # Añade la columna Fecha en formato dd/mm/yyyy
    Hora = format(ymd_hms(Created), "%H:%M") # Añade la columna Hora en formato hh:mm
  ) %>%
  select(c(Codigo, Individuo, Fecha, Hora))

print(datos_filtrados)
