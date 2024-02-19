#' Deployment UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_Deployment_ui <- function(id) {
  ns <- NS(id)
  tabPanel("FilelistCreator Revisión/deployment",
           sidebarLayout(
             sidebarPanel(
               "",
               fileInput(ns("file1"), "Elija el archivo Excel creado con FileList", accept = c(".xlsx")),
               selectInput(ns("submitterID"), "Selecciona quien lo envía:", choices = usuarios),
               selectInput(ns("locationID"), "Selecciona donde estás:", choices = locationID),
               selectInput(ns("country"), "País:", choices = paises),
               textInput(ns("verbatimLocality"), "Localización"),
               textInput(ns("decimalLatitude"), "Latitud"),
               textInput(ns("decimalLongitude"), "Longitud"),
               actionButton(ns("btn1"), "Actualizar datos"),  # Asegúrate de namespaciar el ID aquí
               downloadButton(ns("download1"), "Descargar Excel para Wildbook") # Botón de descarga
             ),
             mainPanel(
               DTOutput(ns("table"))
             )
           ))
}


#' Deployment Server Functions
#'
#' @noRd
#' @importFrom lubridate dmy_hms

mod_Deployment_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Reactive para almacenar los datos procesados
    processedDataFL <- reactiveVal(data.frame())  # Inicializa como data.frame vacío

    observeEvent(input$file1, {
      shiny::showNotification("Archivo cargado con éxito.", type = "message", duration = 3) # Notificación de carga exitosa
    }, ignoreNULL = TRUE)

    # Usar observeEvent para procesar datos y actualizar processedData
    observeEvent(input$btn1, {
      req(input$file1)  # Asegúrate de que los archivos estén cargados

      tryCatch({
        df1 <- read_excel(input$file1$datapath)
        df <- df1 %>%
          select(Name, Created) %>%
          mutate(
            Encounter.genus = "Lynx",
            Encounter.specificEpithet = "pardinus",
            Encounter.mediaAsset1 = Name,
            fecha = lubridate::dmy_hms(Created),
            Encounter.day = lubridate::day(fecha),
            Encounter.month = lubridate::month(fecha),
            Encounter.year = lubridate::year(fecha),
            Encounter.hour = lubridate::hour(fecha),
            Encounter.minutes = lubridate::minute(fecha),
            Encounter.submitterID = input$submitterID,
            Encounter.locationID = input$locationID,
            Encounter.verbatimLocality = input$verbatimLocality,
            Encounter.decimalLatitude = input$decimalLatitude,
            Encounter.decimalLongitude = input$decimalLongitude,
            Encounter.country = input$country) %>%
          select(-fecha, -Created, -Name)

        processedDataFL(df)  # Actualiza el valor reactivo
        shiny::showNotification("Datos procesados con éxito.", type = "message", duration = 3) # Notificación de éxito en procesamiento
      }, error = function(e) {
        shiny::showNotification(paste("Error al procesar los datos:", e$message), type = "error", duration = 5) # Notificación de error
      })
    }, ignoreNULL = FALSE)

    # Renderiza la tabla DT usando el valor reactivo
    output$table <- renderDT({
      req(processedDataFL())  # Asegúrate de que los datos estén disponibles
      datatable(processedDataFL(),    options = list(
        autoWidth = TRUE,  # Ajusta automáticamente el ancho de las columnas
        scrollX = TRUE,    # Habilita el desplazamiento horizontal
        pageLength = 15    # Número de filas a mostrar por página
      ))
    })

    output$download1 <- downloadHandler(
      filename = function() {
        paste("FL-WB-", Sys.Date(), ".xlsx", sep = "")
      },
      content = function(file) {
        req(processedDataFL())  # Asegura que processedData esté disponible
        writexl::write_xlsx(processedDataFL(), file)
      }
    )
  })
}


## To be copied in the UI
# mod_Deployment_ui("Deployment_1")

## To be copied in the server
# mod_Deployment_server("Deployment_1")

