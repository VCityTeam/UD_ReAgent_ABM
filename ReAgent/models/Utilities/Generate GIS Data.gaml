/**
* Name: generate_environment
* Author: Patrick Taillandier
* Description: Demonstrates how to import data from OSM, Bing and google map to generate geographical data. More precisely, the model allows from a shapefile giving the area of the study area to download all the OSM data on this area, to vectorize the buildings and the points of interest from google map data and to download a Bing satellite image of the area.
* Tags: data_loading, OSM, Google Map, Bing, shapefile
*/
model generate_environment

global {

/* ------------------------------------------------------------------ 
	 * 
	 *             MANDATORY PARAMETERS
	 * 
	 * ------------------------------------------------------------------
	 */
	 
	 

	//path of the folder
	string folder_path <- "../../includes/GratteCiel/";
	
	//define the bounds of the studied area
	file data_file <-shape_file(folder_path + "Bounds.shp");
	
	//path where to export the created shapefiles
	string exporting_path <- folder_path + "generated/";
	
	//if true, GAMA is going to use OSM data to create the building file
	bool use_OSM_data <- true;
	
	//if true, GAMA is going to download the background satellite image (Bing image).
	bool do_load_satellite_image <- true;
	
	//image to display as background if there is no satellite image
	string default_background_image <- "../../includes/white.png";
	
	/* ------------------------------------------------------------------ 
	 * 
	 *             OPTIONAL PARAMETERS
	 * 
	 * ------------------------------------------------------------------
	 */
	// --------------- OSM data parameters ------------------------------
	//path to an existing Open Street Map file - if not specified, GAMA is going to directly download to correct data
	string osm_file_path <- folder_path +"map.osm";
	
	//type of feature considered
	map osm_data_to_generate <- ["building"::[], "shop"::[], "historic"::[], "amenity"::[], "sport"::[], "military"::[], "leisure"::[], "office"::[],  "highway"::[]];
	

	
	/* ------------------------------------------------------------------ 
	 * 
	 *              DYNAMIC VARIABLES
	 * 
	 * ------------------------------------------------------------------
	 */
	//geometry of the world
	geometry shape <- envelope(data_file);
	
	
	init {
		write "Start the pre-processing process";
		create Boundary from: data_file;
		
		if use_OSM_data {
			osm_file osmfile;
			if (file_exists(osm_file_path)) {
				osmfile  <- osm_file(osm_file_path, osm_data_to_generate);
			} else {
				point top_left <- CRS_transform({0,0}, "EPSG:4326").location;
				point bottom_right <- CRS_transform({shape.width, shape.height}, "EPSG:4326").location;
				string adress <-"http://overpass.openstreetmap.ru/cgi/xapi_meta?*[bbox="+top_left.x+"," + bottom_right.y + ","+ bottom_right.x + "," + top_left.y+"]";
				write "adress: " + adress;
				osmfile <- osm_file<geometry> (adress, osm_data_to_generate);
			}
			
			write "OSM data retrieved";
			create OSM_agent from: osmfile  where (each != nil);
			loop type over: osm_data_to_generate.keys {
		 		rgb col <- rnd_color(255);
		 		list<OSM_agent> ags <-  OSM_agent where (each.shape.attributes[type] != nil);
		 		ask ags {color <- col;}
		 		list<OSM_agent> pts <- ags where (each.shape.perimeter = 0);
		 		do save_data(pts,type,"point");
		 		
		 		list<OSM_agent> lines <- ags where ((each.shape.perimeter > 0) and (each.shape.area = 0)) ;
		 		do save_data(lines,type,"line");
		 		
		 		list<OSM_agent> polys <- ags where (each.shape.area > 0);
		 		do save_data(polys,type,"polygon");
		 	}
		}	 	
	 	if (do_load_satellite_image) {
	 		do load_satellite_image;
	 	}
	 	
	}
	
	
	
	
	
	action save_data(list<OSM_agent> ags, string type, string geom_type) {
		if (not empty(ags)) {
	 		list<string> atts <-  remove_duplicates(ags accumulate each.shape.attributes.keys);
	 		save (ags collect each.shape) type: shp to: exporting_path + type + "_" + geom_type+".shp" attributes: atts;
	 	}
	}
	
	action load_satellite_image
	{ 
		point top_left <- CRS_transform({0,0}, "EPSG:4326").location;
		point bottom_right <- CRS_transform({shape.width, shape.height}, "EPSG:4326").location;
		int size_x <- 1500;
		int size_y <- 1500;
		
		string rest_link<- "https://dev.virtualearth.net/REST/v1/Imagery/Map/Aerial/?mapArea="+bottom_right.y+"," + top_left.x + ","+ top_left.y + "," + bottom_right.x + "&mapSize="+int(size_x)+","+int(size_y)+ "&key=AvZ5t7w-HChgI2LOFoy_UF4cf77ypi2ctGYxCgWOLGFwMGIGrsiDpCDCjliUliln" ;
		write rest_link;
		image_file static_map_request <- image_file(rest_link);
	
		write "Satellite image retrieved";
		ask cell {		
			color <-rgb( (static_map_request) at {grid_x,1500 - (grid_y + 1) }) ;
		}
		save cell to: exporting_path +"satellite.png" type: image;
		
		string rest_link2<- "https://dev.virtualearth.net/REST/v1/Imagery/Map/Aerial/?mapArea="+bottom_right.y+"," + top_left.x + ","+ top_left.y + "," + bottom_right.x + "&mmd=1&mapSize="+int(size_x)+","+int(size_y)+ "&key=AvZ5t7w-HChgI2LOFoy_UF4cf77ypi2ctGYxCgWOLGFwMGIGrsiDpCDCjliUliln" ;
		file f <- json_file(rest_link2);
		list<string> v <- string(f.contents) split_with ",";
		int id <- 0;
		loop i from: 0 to: length(v) - 1 {
			if ("bbox" in v[i]) {
				id <- i;
				break;
			}
		} 
		float long_min <- float(v[id] replace ("'bbox'::[",""));
		float long_max <- float(v[id+2] replace (" ",""));
		float lat_min <- float(v[id + 1] replace (" ",""));
		float lat_max <- float(v[id +3] replace ("]",""));
		point pt1 <- CRS_transform({lat_min,long_max},"EPSG:4326", "EPSG:3857").location ;
		point pt2 <- CRS_transform({lat_max,long_min},"EPSG:4326","EPSG:3857").location;
		float width <- abs(pt1.x - pt2.x)/1500;
		float height <- (pt2.y - pt1.y)/1500;
			
		string info <- ""  + width +"\n0.0\n0.0\n"+height+"\n"+min(pt1.x,pt2.x)+"\n"+(height < 0 ? max(pt1.y,pt2.y) : min(pt1.y,pt2.y));
	
		save info to: exporting_path +"satellite.pgw";
		
		
		write "Satellite image saved with the right meta-data";
		 
		
	}
}

 
grid cell width: 1500 height:1500 use_individual_shapes: false use_regular_agents: false use_neighbors_cache: false;


species OSM_agent {
	rgb color;
	aspect default {
		if (shape.area > 0) {
			draw shape color: color border: #black;
		} else if shape.perimeter > 0 {
			draw shape color: color;
		} else {
			draw circle(5) color: color;
		}
		
	}	
}

species Boundary {
	aspect default {
		draw shape color: #gray border: #black;
	}
}

experiment generateGISdata type: gui {
	action _init_ {
		bool pref_gis <- gama.pref_gis_auto_crs ;
		int crs <- gama.pref_gis_default_crs;
	
		gama.pref_gis_auto_crs <- false;
		gama.pref_gis_default_crs <- 3857;
		create simulation;
		gama.pref_gis_auto_crs <- pref_gis;
		gama.pref_gis_default_crs <- crs;
	}
	output {
		display map type: opengl draw_env: false{
			image file_exists(exporting_path + "satellite.png")? (exporting_path + "satellite.png") : default_background_image  transparency: 0.2 refresh: false;
			species OSM_agent;
		}
	} 
}
