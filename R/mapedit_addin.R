


#' @title MapEdit Addin
#' @description Create and save spatial objects within the Rstudio IDE
#'
#' @return
#' @importFrom miniUI miniPage miniContentPanel gadgetTitleBar miniButtonBlock
#' @import mapedit
#' @importFrom shiny callModule paneViewer observeEvent stopApp runGadget textInput updateTextInput div
#' @importFrom shinyWidgets switchInput
#' @importFrom mapview mapview
#' @importFrom sf write_sf
#' @importFrom leaflet setView
#' @importFrom rstudioapi getActiveDocumentContext
#' @export
#'
#' @examples
mapeditAddin <- function() {

  ui <- miniPage(
    gadgetTitleBar("Edit Map"),
    miniContentPanel(
      editModUI("editor"),
      miniButtonBlock(
        div(style="display: inline-block;padding-top:22px;padding-left:30px;width:180px;",
            switchInput('savefile', 'Save', value = FALSE, onStatus = "success", offStatus = "danger")),
        div(style="display: inline-block; width: 400px;",
            textInput('filename', '', value = 'saved_geometry.geojson')),
        div(style="display: inline-block;padding-top:18px;width: 400px;font-size: 10pt;color: #313844;",
            'You can add folders and change output type.',
            'Created geometry will always save to .GlobalEnv')
      )
    )
  )

  server <- function(input, output, session) {

    # get values from rstudio
    ct <- getActiveDocumentContext()

    TEXT <<- ct$selection[[1]]$text
    OBJECTNAME <- ifelse(TEXT == '', 'geom', TEXT)
    FILENAME <- ifelse(TEXT == '', 'saved_geometry.geojson', paste0(TEXT, '.geojson'))
    SF_OBJECT <- NULL

    try(SF_OBJECT <- get(TEXT, silent = TRUE))

    # update UI based on inputs
    updateTextInput(session, 'filename', value = FILENAME)
    if (FILENAME != 'saved_geometry.geojson') {
      updateSwitchInput(session, 'savefile', value = TRUE)
    }


    # load mapedit
    if (class(SF_OBJECT) == 'sf') {
      geo <- callModule(editMod, "editor", mapview(SF_OBJECT)@map)
    } else {
      geo <- callModule(editMod, "editor", setView(mapview()@map, 80, 0, 3))
    }


    # return geometry to file and object in .GlobalEnv
    observeEvent(input$done, {
      geom <- geo()$finished

      if (!is.null(geom) & !is.null(SF_OBJECT)) geom <- st_intersection(SF_OBJECT, geom)

      if (!is.null(geom)) {
        assign(OBJECTNAME, geom, envir = .GlobalEnv)
        if (input$savefile) {
          sf::write_sf(geom, input$filename, update = TRUE)
        }
      }

      stopApp()
    })

  }

  viewer <- paneViewer(600)
  runGadget(ui, server, viewer = viewer)

}

