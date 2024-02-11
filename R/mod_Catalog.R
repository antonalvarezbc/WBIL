#' Catalog UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#' @import DT
#' @importFrom shiny NS tagList tabPanel sidebarLayout sidebarPanel fileInput selectInput textInput downloadButton mainPanel
mod_Catalog_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tabPanel("FilelistCreator Catálogo",
             sidebarLayout(
               sidebarPanel(
                 "Usa FileList para crear un archivo .xlsx con las columnas Name para obtener el nombre de la imagen.",
                 fileInput(ns("FileListCatalogo"), "Elija el archivo Excel creado con FileList", accept = c(".xlsx")),
                 selectInput(ns("submitterIDC"), "Selecciona quien lo envía:", choices = c("Andujar_admin", "JEX_admin", "CdM_admin")),
                 selectInput(ns("locationIDC"), "Selecciona donde estás:", choices = locationID),
                 selectInput(ns("countryC"), "País:", choices =  paises),
                 selectInput(ns("sufijoC"), "Subfijo:", choices = c("_And", "_CdM")),
                 textInput(ns("verbatimLocalityC"), "Localización"),
                 actionButton(ns("updateData"), "Actualizar Datos"), # Botón para actualizar los datos
                 downloadButton(ns("download3"), "Descargar Excel para Wildbook")
               ),
               mainPanel(
                 DTOutput(ns("tableFLC"))
               )
             )
    )
  )
}

#' Catalog Server Functions
#'
#' This function defines server logic for the Catalog module in a Shiny application.
#' It handles file input and data processing for catalog entries.
#'
#' @param id A unique identifier for the shiny module.
#'
#' @importFrom shiny moduleServer
#' @importFrom dplyr select mutate rename
#' @importFrom readxl read_excel
#' @importFrom writexl write_xlsx
#' @importFrom DT datatable
#' @importFrom DT renderDT
#' @export
#' @import DT
mod_Catalog_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Reactive para almacenar los datos procesados
    processedDataFLC <- reactiveVal(data.frame())  # Inicializa como data.frame vacío

    # Usar observeEvent para reaccionar al botón de acción y procesar datos
    observeEvent(input$updateData, {
      req(input$FileListCatalogo)  # Asegúrate de que se haya subido un archivo

      tryCatch({
        tablafile1 <- read_excel(input$FileListCatalogo$datapath)
        tablafile2 <- tablafile1 %>%
          select(Name) %>%
          mutate(
            Encounter.individualID = str_extract(Name, "^[^ _]+") %>% str_to_lower() %>% str_to_title(),
            MarkedIndividual.nickname = paste(Encounter.individualID, input$sufijoC, sep = ""),
            Encounter.verbatimLocality = input$verbatimLocalityC,
            Encounter.submitterID = input$submitterIDC,
            Encounter.locationID = input$locationIDC,
            Encounter.country = input$countryC,
            Encounter.genus = "Lynx",
            Encounter.specificEpithet = "pardinus"
          ) %>%
          rename(Encounter.mediaAsset1 = Name)

        processedDataFLC(tablafile2)  # Actualiza el valor reactivo
        shiny::showNotification("Datos actualizados con éxito.", type = "message", duration = 3)
      }, error = function(e) {
        shiny::showNotification(paste("Error al actualizar los datos:", e$message), type = "error", duration = 5)
      })
    }, ignoreNULL = FALSE)

    # Renderiza la tabla DT usando el valor reactivo
    output$tableFLC <- renderDT({
      req(processedDataFLC())
      datatable(processedDataFLC(),     options = list(
        autoWidth = TRUE,  # Ajusta automáticamente el ancho de las columnas
        scrollX = TRUE,    # Habilita el desplazamiento horizontal
        pageLength = 15    # Número de filas a mostrar por página
      ))
    })

    output$download3 <- downloadHandler(
      filename = function() {
        paste("WildbookCatalogo", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        req(processedDataFLC())
        writexl::write_xlsx(processedDataFLC(), file)
      }
    )
  })
}

## To be copied in the UI
# mod_Catalog_ui("Catalog_1")

## To be copied in the server
# mod_Catalog_server("Catalog_1")
