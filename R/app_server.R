#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
# library(shiny)
# library(golem)
# library(DT)

app_server <- function(input, output, session) {
  # Llama al servidor del módulo con el mismo ID usado en la UI
  mod_WildlifeInsight_server("wildlifeInsightModuleId")
  mod_Deployment_server("DeploymentModuleId")
  mod_Catalog_server("CatalogModuleId")
  mod_Custom1_server("Custom1ModuleId")
  mod_creditos_server("creditos")
  # Aquí puedes añadir más lógica de servidor o llamar a otros módulos si es necesario
}

