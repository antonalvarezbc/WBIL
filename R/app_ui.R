#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
library(stringr)
library(shiny)
library(dplyr)
library(writexl)
library(DT)
library(readxl)
library(lubridate)
library(shinydashboard)
library(shinyFiles)


app_ui <- function(request) {
  tagList(
    # Incluye cualquier recurso externo: CSS, JavaScript, etc.
    golem_add_external_resources(),
    # UI principal de la aplicación
    fluidPage(
      # Utiliza tabsetPanel para incluir múltiples tabPanel
      tabsetPanel(
        # Primer tabPanel
        tabPanel("FilelistCreator Revisión/deployment",
                 mod_WildlifeInsight_ui("wildlifeInsightModuleId")
        ),
        # Segundo tabPanel
        tabPanel("FilelistCreator Revisión/deployment",
                 mod_Deployment_ui("Deployment")
        )
        # Puedes agregar más tabPanel aquí si es necesario
      )
    )
  )
}



#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "WBIL"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
