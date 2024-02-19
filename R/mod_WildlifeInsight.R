#' WildlifeInsight UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import DT
mod_WildlifeInsight_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tabPanel("Wildlife Insight Fincas (Alpha)",
             sidebarLayout(
               sidebarPanel(
                 fileInput(ns("deployments"), "Selecciona el CSV de deployments", accept = ".csv"),
                 fileInput(ns("imagenes"), "Selecciona el CSV de imágenes", accept = ".csv"),
                 selectInput(ns("submitterIDWI"), "Selecciona quien lo envía:", choices = usuarios),
                 selectInput(ns("locationIDWI"), "Selecciona donde estás:", choices = locationID),
                 selectInput(ns("countryWI"), "País:", choices = paises),
                 textInput(ns("directorio"), "Directorio de descarga de las imágenes"),
                 actionButton(ns("btn"), "Actualizar datos"),  # Asegúrate de namespaciar el ID aquí
                 downloadButton(ns("downloadExcel"), "Descargar Excel para Wildbook")
               ),
               mainPanel(
                 DT::DTOutput(ns("dataWI_B"))
               )
             )
    )
  )
}

#' WildlifeInsight Server Functions
#' @import DT
#' @noRd
mod_WildlifeInsight_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Reactive para almacenar los datos procesados
    processedData <- reactiveVal(data.frame())  # Inicializa como data.frame vacío

    # Usar observeEvent para procesar datos y actualizar processedData
    observeEvent(input$btn, {
      req(input$imagenes, input$deployments)  # Asegúrate de que los archivos estén cargados

      # tryCatch para manejar errores durante el procesamiento
      tryCatch({
        imagenes <- read.csv(input$imagenes$datapath)
        deployments <- read.csv(input$deployments$datapath)

        # Procesamiento de datos
        data <- imagenes %>%
          filter(common_name == "Iberian Lynx") %>%
          inner_join(deployments, by = "deployment_id") %>%
          select(location, timestamp, deployment_id, longitude, latitude) %>%
          mutate(
            EncounterMediaAsset1 = location %>% stringr::str_replace_all("\\.[a-zA-Z0-9]+$", ".JPG") %>% basename(),
            fecha = lubridate::ymd_hms(timestamp),
            Encounter.verbatimLocality = deployment_id,
            Encounter.submitterID = input$submitterIDWI,
            Encounter.locationID = input$locationIDWI,
            Encounter.country = input$countryWI,
            Encounter.day = lubridate::day(fecha),
            Encounter.month = lubridate::month(fecha),
            Encounter.year = lubridate::year(fecha),
            Encounter.hour = lubridate::hour(fecha),
            Encounter.minutes = lubridate::minute(fecha),
            Encounter.genus = "Lynx",
            Encounter.specificEpithet = "pardinus",
            Codigo.descarga = paste("gsutil -m cp -r  ", basename(location), input$directorio)
          ) %>%
          rename(Encounter.decimalLatitud = latitude, Encounter.decimalLongitude =longitude) %>%
          select(-location, -timestamp, -fecha, -deployment_id)

        processedData(data)  # Actualiza el valor reactivo
      }, error = function(e) {
        # Manejo de errores, como mostrar un mensaje al usuario
        showNotification("Error procesando los datos: ", e$message, type = "error")
        # Opcionalmente, puedes registrar el error o tomar otras medidas
      })
    }, ignoreNULL = FALSE)

    # Renderiza la tabla DT usando el valor reactivo
    output$dataWI_B <- renderDT({
      datatable(processedData(),     options = list(
        autoWidth = TRUE,  # Ajusta automáticamente el ancho de las columnas
        scrollX = TRUE,    # Habilita el desplazamiento horizontal
        pageLength = 15    # Número de filas a mostrar por página
      ))
    })
    output$downloadExcel <- downloadHandler(
      filename = function() {
        paste("WI-WB-", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        # Asegura que processedData esté disponible
        req(processedData())

        # tryCatch para manejar errores al escribir el archivo Excel
        tryCatch({
          writexl::write_xlsx(processedData(), file)
        }, error = function(e) {
          # Manejo de errores, como notificar al usuario
          showNotification("Error al escribir el archivo Excel: ", e$message, type = "error")
        })
      }
    )
  })
}



## To be copied in the UI
# mod_WildlifeInsight_ui("WildlifeInsight_1")

## To be copied in the server
# mod_WildlifeInsight_server("WildlifeInsight_1")
