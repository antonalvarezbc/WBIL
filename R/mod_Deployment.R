#' Deployment UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_Deployment_ui <- function(id){
  ns <- NS(id)
  tagList(
      titlePanel("Ejemplo de Selección de Directorio y Lectura de Imágenes"),
      sidebarLayout(
        sidebarPanel(
          shinyFilesButton('dirBtn', 'Choose a directory', 'Please select a directory', FALSE)
        ),
        mainPanel(
          "image_info" # Para mostrar la información de las imágenes
        )
      )
    )


}

#' Deployment Server Functions
#'
#' @noRd
mod_Deployment_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    server <- function(input, output, session) {
      roots <- list(
        Home = fs::path_expand("~"),
        Data = "/path/to/data/directory",
        Projects = "/path/to/projects/directory"
      )

      observe({
        shinyDirChoose(input, 'dirBtn', roots = roots, session = session)
        dir <- parseDirPath(input$dirBtn)
        if (!is.null(dir)) {
          print(dir)
        }
      })

      # Reactivo para listar imágenes y obtener sus fechas de modificación
      imageInfo <- reactive({
        # Asegurarse de que se haya seleccionado un directorio
        req(selectedDir())

        # Lista todos los archivos de imagen en el directorio
        files <- list.files(selectedDir(), pattern = "\\.(jpg|jpeg|png)$", full.names = TRUE)

        # Obtener información de cada archivo
        info <- sapply(files, function(file) {
          modification_time <- file.info(file)$mtime
          list(name = basename(file), modification_date = modification_time)
        }, simplify = FALSE, USE.NAMES = FALSE)

        info
      })

      # Mostrar la información de las imágenes en la UI
      output$image_info <- renderTable({
        info <- imageInfo() # Obtener la información reactiva
        if (is.null(info)) {
          return()
        }

        # Convertir la lista de información en un dataframe para mostrarlo como una tabla
        do.call(rbind, lapply(info, function(x) data.frame(Name = x$name, ModificationDate = x$modification_date)))
      })
    }

  })
}

## To be copied in the UI
# mod_Deployment_ui("Deployment_1")

## To be copied in the server
# mod_Deployment_server("Deployment_1")
