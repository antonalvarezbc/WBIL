#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import DT
mod_creditos_ui <- function(id){
  ns <- NS(id)  # Define ns para namespacing
  tagList(
    titlePanel("Créditos"),  # Corrected the accent in "Créditos"
    mainPanel(
      # Uso de HTML para definir diferentes tamaños de texto
      HTML("
          <p><span style='font-size: 14px;'>Alpha App hecha por AAB.</span></p>
          <p><span style='font-size: 20px;'>Posible App web de la acción A8 del Life+ Lynxconnect.</span></p>
          <p><span style='font-size: 26px;'> </span></p>
        ")
    )
  )
}

#' @noRd
mod_creditos_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- NS(id)
  })
}
