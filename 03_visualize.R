source('03_visualize/src/visualize_harvey_map.R')
source('03_visualize/src/visualize_hydrographs.R')

p3 <- list(
  tar_target(
    p3_leaflet_map,
    create_map(p2_harvey_pts, p1_site_info)
  ),
  tar_target(
    p3_leaflet_map_html,
    save_map(p3_leaflet_map, out_dir = '03_visualize/out', out_file = "leaflet_map.html"),
    format = "file"
  ),
  tar_target(
    p3_hydrograph_plot,
    plot_hydrographs(p2_stage_flooding_data)
  ),  
  tar_target(
    p3_hydrograph_plot_svg,
    save_hydrographs(p3_hydrograph_plot, out_dir = '03_visualize/out', out_file = "hydrograph_plot.svg"),
    format = "file"
  )
)
