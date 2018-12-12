


#' @title MapEdit Addin
#'
#' @return
#' @importFrom miniUI miniPage miniContentPanel gadgetTitleBar
#' @import mapedit
#' @importFrom shiny callModule paneViewer observeEvent stopApp runGadget
#' @importFrom mapview mapview
#' @importFrom sf write_sf
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

    geo <- callModule(editMod, "editor", mapview()@map)

    observeEvent(input$done, {
      geom <<- geo()$finished

      if (!is.null(geom)) {
        sf::write_sf(geom, 'saved_geometry.geojson')
      }

      stopApp()
    })

  }

  viewer <- paneViewer(600)
  runGadget(ui, server, viewer = viewer)

}

