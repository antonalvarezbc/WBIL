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

      imagenes <- read.csv(input$imagenes$datapath)
      deployments <- read.csv(input$deployments$datapath)

      data <- imagenes %>%
        filter(common_name == "Iberian Lynx") %>%
        inner_join(deployments, by = "deployment_id") %>%
        select(location, timestamp, deployment_id, longitude, latitude) %>%
        mutate(
          EncounterMediaAsset1 = basename(location),
          fecha = ymd_hms(timestamp),
          Encounter.verbatimLocality = deployment_id,
          Encounter.submitterID = input$submitterIDWI,
          Encounter.locationID = input$locationIDWI,
          Encounter.country = input$countryWI,
          Encounter.day = day(fecha),
          Encounter.month = month(fecha),
          Encounter.year = year(fecha),
          Encounter.hour = hour(fecha),
          Encounter.minutes = minute(fecha),
          Encounter.genus = "Lynx",
          Encounter.specificEpithet = "pardinus"
        ) %>%
        rename(Encounter.decimalLatitud = latitude, Encounter.decimalLongitude =longitude) %>%
        select(-location, -timestamp, -fecha, -deployment_id)

      processedData(data)  # Actualiza el valor reactivo
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

        # Usar writexl para escribir los datos a un archivo Excel
        writexl::write_xlsx(processedData(), file)
      }
    )
  })
}


## To be copied in the UI
# mod_WildlifeInsight_ui("WildlifeInsight_1")

## To be copied in the server
# mod_WildlifeInsight_server("WildlifeInsight_1")
