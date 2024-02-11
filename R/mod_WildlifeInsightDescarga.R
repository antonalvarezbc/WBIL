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
  ns <- NS(id)
  tagList(
    fluidPage(
      titlePanel("Subir Archivo y Seleccionar Datos"),
      sidebarLayout(
        sidebarPanel(
          fileInput("fileUpload", "Subir Archivo CSV", accept = ".csv"),
          selectInput("columnSelect", "Seleccionar Valor", choices = NULL)
        ),
        mainPanel(
          DTOutput("table")
        )
      )
    )

  )
}

#' WildlifeInsightDescarga Server Functions
#' @import DT
#' @noRd
mod_WildlifeInsightDescarga_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Reactive para almacenar el dataframe leído
    data <- reactiveVal(data.frame())

    # Observa la carga de archivos
    observeEvent(input$fileUpload, {
      req(input$fileUpload)
      df <- read.csv(input$fileUpload$datapath) # Asegúrate de usar read.csv o read_csv según tus necesidades
      data(df) # Almacena el dataframe en el reactivo

      # Suponiendo que deseas actualizar un selectInput basado en una columna específica
      uniqueValues <- unique(df$Columna1)
      updateSelectInput(session, ns("columnSelect"), choices = uniqueValues)
    })

    # Opción para renderizar una tabla con los datos cargados
    output$table <- renderDT({
      req(data())
      datatable(data())
    })

    # Manejador de descargas para descargar los datos procesados
    output$downloadWildlife <- downloadHandler(
      filename = function() {
        paste("datos-procesados-", Sys.Date(), ".csv", sep = "")
      },
      content = function(file) {
        req(data())
        write.csv(data(), file, row.names = FALSE)
      }
    )
  })
}


## To be copied in the UI
# mod_WildlifeInsightDescarga_ui("WildlifeInsightDescarga_1")

## To be copied in the server
# mod_WildlifeInsightDescarga_server("WildlifeInsightDescarga_1")
