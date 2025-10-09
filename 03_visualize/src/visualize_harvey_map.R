#' @title Create Interactive Leaflet Map of Hurricane Track and USGS Sites
#' @description This function generates a static-view Leaflet map showing the track of Hurricane Harvey (color-coded by time) and the locations of the selected USGS gage sites with popups. It returns the Leaflet map object.
#'
#' @param harvey_data An `sf` object (simple features data frame) containing the processed Hurricane Harvey track points with date/time information.
#' @param site_info An `sf` object containing the location and names of the USGS gage sites.
#'
#' @return A **`leaflet` map object** that can be displayed or saved.
#'
create_map <- function(harvey_data, site_info) {
  
  # color palette for hurricane track based on date
  # Note: The 'brewer.pal' function is not available by default and should be assumed 
  # to be available (e.g., from the 'RColorBrewer' package).
  time_colors <- colorRampPalette(brewer.pal(9, "YlGnBu"))(nrow(harvey_data)) 
  harvey_data$Color <- time_colors[rank(harvey_data$Date)]
  # color for usgs gages
  usgs_gage_color <- "orange"
  
  # create an sf object for hurricane track and gage locations
  # Note: 'st_as_sf' assumes harvey_data is already a data frame with LON/LAT
  harvey_sf <- st_as_sf(harvey_data, coords = c("LON", "LAT"), crs = 4326)
  gage_sf <- site_info %>% mutate(
    popup=paste0("<b>Site ID: </b>", monitoring_location_id,"<br>",
                 "<b>Station Name: </b> ", monitoring_location_name
    ))
  
  # get boundaries of US states and territories using rnaturalearth instead of tigris 
  # due to issues with accessing census data during US gov't shutdown
  states_boundaries <- ne_states(country = "United States of America", returnclass = "sf") %>%
    # exclude territories and get only the 50 states + DC
    subset(iso_3166_2 %in% c(paste0("US-", state.abb), "US-DC"))
  
  # attempt to fix the initial ROI and zoom for map based on hurricane track
  center_lon <- mean(harvey_data$LON)
  center_lat <- mean(harvey_data$LAT)
  initial_zoom_level <- 7
  
  # create leaflet map, set initial view and disable zoom and panning
  m <- leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron) %>% 
    setView(lng = center_lon, lat = center_lat, zoom = initial_zoom_level)
  
  # add state boundaries layer
  m <- m %>%
    addPolygons(
      data = states_boundaries,
      color = "#444444",      
      weight = 1,              
      smoothFactor = 0.5,
      opacity = 1.0,
      fillOpacity = 0.2,      
      fillColor = "#CCCCCC"  
    )
  
  # add hurricane track changing color with time
  for (i in 1:(nrow(harvey_data) - 1)) {
    m <- m %>%
      addPolylines(
        lng = c(harvey_data$LON[i], harvey_data$LON[i+1]), 
        lat = c(harvey_data$LAT[i], harvey_data$LAT[i+1]),  
        color = harvey_data$Color[i], 
        weight = 10, 
        opacity = 1 
      )
  }
  
  # add usgs gage site markers
  m <- m %>%
    addCircleMarkers(
      data = gage_sf,
      radius = 8,
      stroke=FALSE,
      color = usgs_gage_color,
      fillOpacity = 1,
      popup = ~popup,
      labelOptions = labelOptions(
        noHide = FALSE,
        direction = 'auto',
        textsize = "10px",
        style = list(
          "box-shadow" = "3px 3px rgba(0,0,0,0.2)",
          "border-color" = "rgba(0,0,0,0.5)"
        ),
        html = TRUE
      )
    )
  
  # create legend for hurricane track colors (time)
  legend_dates_indices <- round(seq(1, nrow(harvey_data), length.out = 5))
  legend_labels <- format(harvey_data$Date[legend_dates_indices], "%Y-%b-%d")
  legend_colors_for_display <- harvey_data$Color[legend_dates_indices]
  
  m <- m %>% addLegend(
    "bottomright",
    colors = legend_colors_for_display,
    labels = legend_labels,
    title = "Hurricane Track Time",
    opacity = 1
  )
  
  # add custom legend for usgs gage sites
  # Note: 'add_gage_site_legend' is assumed to be defined elsewhere
  m <- add_gage_site_legend(m, color = usgs_gage_color, label = "USGS Gage Sites", position = "bottomright")
  
  return(m)
}

#' @title Add USGS Gage Site Legend to Leaflet Map
#' @description This is a helper function to create and add a custom HTML legend for the USGS gage sites to a Leaflet map object.
#'
#' @param map A Leaflet map object to which the legend will be added.
#' @param color A character string representing the color of the circle marker in the legend (e.g., "orange").
#' @param label A character string for the text label associated with the legend symbol (e.g., "USGS Gage Sites").
#' @param position A character string for the position of the legend on the map. Defaults to "bottomright".
#'
#' @return A Leaflet map object with the custom gage site legend added.
#'
add_gage_site_legend <- function(map, color, label, position = "bottomright") {
  # create an HTML snippet for the circle symbol
  circle_html <- paste0(
    "<div style='display: inline-block; width: 15px; height: 15px; ",
    "border-radius: 50%; background-color: ", color, "; margin-right: 5px; vertical-align: middle;'></div>",
    "<span style='vertical-align: middle;'>", label, "</span>"
  )
  
  legend_content <- htmltools::HTML(
    circle_html
  )
  
  map %>%
    addControl(
      html = legend_content,
      position = position
    )
}

#' @title Save Interactive Leaflet Map to HTML
#' @description This function takes a Leaflet map object and saves it as a self-contained HTML file. It uses `htmlwidgets::saveWidget` and handles the directory structure.
#'
#' @param map_object A **`leaflet` map object** generated by `create_map`.
#' @param out_dir A character string for the directory path where the HTML map will be saved.
#' @param out_file A character string for the filename of the HTML map to be saved (e.g., `"harvey_map.html"`).
#'
#' @return A **character string** representing the full file path to the saved HTML map.
#'
save_map <- function(map_object, out_dir, out_file) {
  
  # define full output filepath
  out_path <- file.path(out_dir, out_file)
  
  # need to use withr::with_dir to get saveWidget to work reliably: 
  # ensures the saving operation happens relative to the output directory
  # Note: 'with_dir' requires the 'withr' package to be loaded
  with_dir(out_dir, saveWidget(map_object, file = out_file, selfcontained = FALSE))
  
  print(paste0('Leaflet map saved to ', out_path))
  
  return(out_path)
}