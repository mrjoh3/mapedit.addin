

library(shiny)
library(miniUI)
library(sf)
library(mapview)
library(mapedit)

# We'll wrap our Shiny Gadget in an addin.
# Let's call it 'clockAddin()'.
#' Title
#'
#' @return
#' @importFrom miniUI miniPage miniContentPanel
#' @export
#'
#' @examples
mapeditAddin <- function() {

  # Our ui will be a simple gadget page, which
  # simply displays the time in a 'UI' output.
  ui <- miniPage(
    gadgetTitleBar("Edit Map"),
    miniContentPanel(
      editModUI("editor")
    )
  )

  server <- function(input, output, session) {

    geo <- callModule(editMod, "editor", mapview()@map)


    # Listen for 'done' events. When we're finished, we'll
    # insert the current time, and then stop the gadget.
    observeEvent(input$done, {
      geom <<- geo()$finished

      if (!is.null(geom)) {
        sf::write_sf(geom, 'saved_geometry.geojson')
      }

      stopApp()
    })

  }

  # We'll use a pane viwer, and set the minimum height at
  # 300px to ensure we get enough screen space to display the clock.
  viewer <- paneViewer(600)
  runGadget(ui, server, viewer = viewer)

}

