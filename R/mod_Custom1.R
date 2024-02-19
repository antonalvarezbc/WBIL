#' Custom1 UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_Custom1_ui <- function(id){
  ns <- NS(id)
  tabPanel("Personalizado 1",
           sidebarLayout(
             sidebarPanel(
               "",
               fileInput(ns("file2"), "Elija el archivo Excel creado con FileList", accept = c(".xlsx")),
               actionButton(ns("btn2"), "Actualizar datos"),  # Asegúrate de namespaciar el ID aquí
               downloadButton(ns("download1"), "Descargar Excel para CLM") # Botón de descarga
             ),
             mainPanel(
               DTOutput(ns("tableC1"))
             )
           ))
}

#' Custom1 Server Functions
#'
#' @noRd
mod_Custom1_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    processedDataFLC1 <- reactiveVal(data.frame())  # Inicializa como data.frame vacío

    observeEvent(input$file2, {
      shiny::showNotification("Archivo cargado con éxito.", type = "message", duration = 3) # Notificación de carga exitosa
    }, ignoreNULL = TRUE)
    # Usar observeEvent para procesar datos y actualizar processedData
    observeEvent(input$btn2, {
      req(input$file2)  # Asegúrate de que los archivos estén cargados

      tryCatch({
        df2 <- readxl::read_excel(input$file2$datapath)

        df <- df2 %>%
        filter(`Folder Level` == max(`Folder Level`, na.rm = TRUE)) %>%
          mutate(
            `Folder Level` = as.numeric(`Folder Level`), # Asegurarse de que 'Folder Level' es numérico
            Created = dmy_hms(Created) # Convertir 'Created' a datetime
          ) %>%
          arrange(Folder, Created) %>%
          group_by(Folder) %>%
          mutate(
            diff_seconds = c(NA, diff(Created)), # Calcular la diferencia en segundos entre filas consecutivas
            event = cumsum(diff_seconds > 60 | is.na(diff_seconds)) # Identificar 'eventos' basados en la diferencia de tiempo
          ) %>%
          ungroup() %>%
          group_by(Folder, event) %>%
          filter(row_number() == 1) %>% # Mantener solo la primera fila de cada 'evento'
          ungroup() %>%
          select(-diff_seconds, -event) %>%
          rename(Individuo = Folder) %>% # Renombrar la columna 'Folder' a 'Individuo'
          mutate(
            Individuo = toupper(Individuo),  # Converts the 'Individuo' column values to uppercase
            Codigo = str_extract(Path, "[A-Z]{1,3}\\.?\\d{1,2}"), # Extraer 'Codigo' de 'Path'
            Fecha = format(Created, "%d/%m/%Y"), # Formatear 'Created' a 'Fecha'
            Hora = format(Created, "%H:%M") # Formatear 'Created' a 'Hora'
          ) %>%
          select(Codigo, Individuo, Fecha, Hora)

        processedDataFLC1(df)  # Actualiza el valor reactivo
        shiny::showNotification("Datos procesados con éxito.", type = "message", duration = 3) # Notificación de éxito en procesamiento
      }, error = function(e) {
        shiny::showNotification(paste("Error al procesar los datos:", e$message), type = "error", duration = 5) # Notificación de error
      })
    }, ignoreNULL = FALSE)

    # Renderiza la tabla DT usando el valor reactivo
    output$tableC1 <- renderDT({
      req(processedDataFLC1())  # Asegúrate de que los datos estén disponibles
      datatable(processedDataFLC1(),    options = list(
        autoWidth = TRUE,  # Ajusta automáticamente el ancho de las columnas
        scrollX = TRUE,    # Habilita el desplazamiento horizontal
        pageLength = 15    # Número de filas a mostrar por página
      ))
    })

    output$download1 <- downloadHandler(
      filename = function() {
        paste("FL-CLM-", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        req(processedDataFLC1())  # Asegura que processedData esté disponible
        writexl::write_xlsx(processedDataFLC1(), file)
      }
    )
  })
}

## To be copied in the UI
# mod_Custom1_ui("Custom1_1")

## To be copied in the server
# mod_Custom1_server("Custom1_1")
