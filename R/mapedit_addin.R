


#' @title MapEdit Addin
#'
#' @return
#' @importFrom miniUI miniPage miniContentPanel gadgetTitleBar
#' @import mapedit
#' @importFrom shiny callModule paneViewer observeEvent stopApp runGadget
#' @importFrom mapview mapview
#' @importFrom sf write_sf
#' @importFrom rstudioapi getActiveDocumentContext
#' @export
#'
#' @examples
mapeditAddin <- function() {

  ui <- miniPage(
    gadgetTitleBar("Edit Map"),
    miniContentPanel(
      editModUI("editor")
    )
  )

  server <- function(input, output, session) {


    ct <- getActiveDocumentContext()

    TEXT <<- ct$selection[[1]]$text
    OBJECTNAME <- ifelse(TEXT == '', 'geom', TEXT)
    FILENAME <- ifelse(TEXT == '', 'saved_geometry.geojson', paste0(TEXT, '.geojson'))
    SF_OBJECT <- NULL

    try(SF_OBJECT <- get(TEXT, silent = TRUE))

    if (class(SF_OBJECT) == 'sf') {
      geo <- callModule(editMod, "editor", mapview(SF_OBJECT)@map)
    } else {
      geo <- callModule(editMod, "editor", mapview()@map)
    }



    observeEvent(input$done, {
      geom <- geo()$finished

      if (!is.null(geom) & !is.null(SF_OBJECT)) geom <- st_intersection(SF_OBJECT, geom)

      if (!is.null(geom)) {
        assign(OBJECTNAME, geom, envir = .GlobalEnv)
        sf::write_sf(geom, FILENAME, update = TRUE)
      }

      stopApp()
    })

  }

  viewer <- paneViewer(600)
  runGadget(ui, server, viewer = viewer)

}

