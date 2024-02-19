#' WildlifeInsightDescarga UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import DT
mod_WildlifeInsightDescarga_ui <- function(id){
  ns <- NS(id)  # Define ns para namespacing
  tagList(
    titlePanel("Creditos"),
    mainPanel(
      # Uso de HTML para definir diferentes tamaños de texto
      HTML("
          <p><span style='font-size: 14px;'>App hecha con cariño por AAB.</span></p>
          <p><span style='font-size: 20px;'> Posible App web de la acción A8 del Life+ Lynxconnect .</span></p>
          <p><span style='font-size: 26px;'> ¿Quien le da a creditos? .</span></p>
        ")
    )
    # fluidPage(
    #   titlePanel("Subir Archivo y Seleccionar Datos"),
    #   sidebarLayout(
    #     sidebarPanel(
    #       fileInput(ns("file2"), "Subir Archivo CSV", accept = ".csv"),
    #       # Asegúrate de usar ns para todos los inputs y outputs
    #       selectInput(ns("filterValue"), "Valores para Filtrar", choices = NULL, multiple = TRUE),
    #       actionButton(ns("btnActualizar"), "Actualizar datos"),
    #       downloadButton(ns("downloadWildlife"), "Descargar")
    #     ),
    #     mainPanel(
    #       DTOutput(ns("table3"))  # Namespaced output ID
      #   )
      # )
    # )
  )
}

#' WildlifeInsightDescarga Server Functions
#' @import DT
#' @noRd
mod_WildlifeInsightDescarga_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns  # session$ns() para aplicar namespacing

    originalData <- reactiveVal(data.frame())

    observeEvent(input$file2, {
      req(input$file2)
      df <- read.csv(input$file2$datapath)
      originalData(df)
      # Usar ns() con updateSelectInput() para asegurar el namespacing correcto
      updateSelectInput(session, ns("filterValue"), choices = unique(df$nombreColumna))
    })

    observeEvent(input$btnActualizar, {
      req(originalData())
      filterValues <- input$filterValue
      filteredData <- originalData()[originalData()[['deployment_id']] %in% filterValues, ]
      output$table3 <- renderDT({
        datatable(filteredData)
      }, server = FALSE)  # Asegúrate de usar server = FALSE si esperas un gran volumen de datos
    })

    output$downloadWildlife <- downloadHandler(
      filename = function() {
        paste("datos-procesados-", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        req(originalData())
        write.csv(originalData(), file, row.names = FALSE)
      }
    )
  })
}


## To be copied in the UI
# mod_WildlifeInsightDescarga_ui("WildlifeInsightDescarga_1")

## To be copied in the server
# mod_WildlifeInsightDescarga_server("WildlifeInsightDescarga_1")
