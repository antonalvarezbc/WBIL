#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @noRd
# library(stringr)
# library(shiny)
# library(dplyr)
# library(writexl)
# library(DT)
# library(readxl)
# library(lubridate)
# library(shinydashboard)
# library(shinyFiles)


app_ui <- function(request) {
  dashboardPage(
    skin = "green",
    dashboardHeader(title = "WBIL Shiny"),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Wildlife Insight", tabName = "wildlifeInsight", icon = icon("eye")),
        menuItem("FilelistCreator Revisiones", tabName = "deployment", icon = icon("upload")),
        menuItem("FilelistCreator Catálogos", tabName = "catalog", icon = icon("book")),
        menuItem("Filelist Personalizada", tabName = "Custom1", icon = icon("camera")),
        menuItem("Creditos", tabName = "widownload", icon = icon("copyright"))

        # Puedes agregar más ítems aquí si es necesario
      )
    ),
    dashboardBody(
      tabItems(
        # Primer tabItem
        tabItem(tabName = "wildlifeInsight",
                mod_WildlifeInsight_ui("wildlifeInsightModuleId")
        ),
        # Segundo tabItem
        tabItem(tabName = "deployment",
                mod_Deployment_ui("DeploymentModuleId")
        ),
        # Tercer tabItem
        tabItem(tabName = "catalog",
                mod_Catalog_ui("CatalogModuleId")
        ),
        tabItem(tabName = "Custom1",
                mod_Custom1_ui("Custom1ModuleId")
        ),
        tabItem(tabName = "widownload",
                mod_WildlifeInsightDescarga_ui("WildlifeInsightDescargaModuleId")
        )
        # Puedes agregar más tabItems aquí si es necesario
      ),
      # Incluye cualquier recurso externo: CSS, JavaScript, etc.
      golem_add_external_resources()
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
