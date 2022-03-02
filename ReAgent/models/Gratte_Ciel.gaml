/**
* Name: HelloWorld
* Based on the internal empty template. 
* Author: arno
* Tags: 
*/


model HelloWorld

import 'TUI.gaml'

/* Insert your model definition here */

global {
	string useCase<-"GratteCiel";
	file shape_file_amenities <- file("../includes/"+useCase+"/generated/amenity_polygon.shp");
	file shape_file_amenities_point <- file("../includes/"+useCase+"/generated/amenity_point.shp");
	file shape_file_buildings <- file("../includes/"+useCase+"/generated/building_polygon.shp");
	file shape_file_leisures <- file("../includes/"+useCase+"/generated/leisure_polygon.shp");
	file shape_file_shops <- file("../includes/"+useCase+"/generated/shop_polygon.shp");
	file shape_file_roads <- file("../includes/"+useCase+"/generated/highway_line.shp");
	file shape_file_bounds <- file("../includes/"+useCase+"/Bounds.shp");
	geometry shape <- envelope(shape_file_bounds);
	graph the_graph;

	
	map<string,rgb> standard_color_per_type <- 
	["road"::#gamablue,"building"::#gamared,"amenity"::#gamaorange,"shop"::#cyan, "leisure"::#darkcyan];
	
	//UI
	bool show_building<-true;
	bool show_road<-true;
	bool show_amenity<-true;
	bool show_shop<-true;
	bool show_leisure<-true;
	bool show_legend<-true;
	bool show_wireframe<-true;
	rgb backgroundColor<-#black;
	rgb textcolor<- (backgroundColor = #white) ? #black : #white;
	
	init {
		create amenities from: shape_file_amenities;
		create building from: shape_file_buildings;
		create leisure from: shape_file_leisures;
		create shop from: shape_file_shops;
		create road from: shape_file_roads ;
		the_graph <- as_edge_graph(road);
		create people number: 10 {
			location <- any_location_in (one_of(building)); 
			color<-rnd_color(255);
			mode<-rnd(2);
		}
		create TUI{
			size<-250#m;
			nbCells<-8;
			location<-{world.shape.width/2,world.shape.height/2};
		}
	}
	}
	
species amenities {
	string type; 
	rgb color <- #yellow  ;
	
	aspect base {
		draw shape color: standard_color_per_type["amenity"] wireframe:show_wireframe width:2;
	}
}

species building {
	string type; 
	rgb color <- #gray  ;
	
	aspect base {
		draw shape color: standard_color_per_type["building"] wireframe:show_wireframe width:2;
	}
}

species leisure {
	string type; 
	rgb color <- #blue  ;
	
	aspect base {
		draw shape color: color wireframe:show_wireframe width:2;
	}
}

species shop {
	string type; 
	rgb color <- #orange  ;
	
	aspect base {
		draw shape color: standard_color_per_type["shop"] wireframe:show_wireframe width:2;
	}
}

species road  {
	rgb color <- #black ;
	aspect base {
		draw shape color: standard_color_per_type["road"] width:2 ;
	}
}



species people skills:[moving] {
    rgb color;
    int mode;
	int type;
	list<point> locs;
	 
	reflex move {
		do wander on:the_graph speed:1#m/#sec;
	}
	
	aspect base {
		draw circle(10) color: color border: #black;
	}
}




experiment GratteCiel type: gui {

	
	output {
		display city_display type: opengl background:backgroundColor fullscreen:1 rotate:90{
			species amenities aspect: base visible:show_amenity;
			species building aspect: base visible:show_building;
			species leisure aspect: base visible: show_leisure;
			species shop aspect: base visible:show_shop;
			species road aspect: base visible:show_road;
			species people aspect: base ;
			species TUI aspect:base;
			
			event["b"] {show_building<-!show_building;}
			event["r"] {show_road<-!show_road;}
			event["a"] {show_amenity<-!show_amenity;}
			event["l"] {show_leisure<-!show_leisure;}
			event["s"] {show_shop<-!show_shop;}
			event["w"] {show_wireframe<-!show_wireframe;}
			
			
			
			overlay position: { 0 , 0 } size: { 0 #px, 0 #px } background: backgroundColor  transparency:0.0 border: backgroundColor rounded: true
            {
            	if(show_legend){
            		
					float y <- 100#px;
					float x<- 100#px;
					
					draw "Type" at: { x, y } color: textcolor font: font("Helvetica", 20, #bold);
					y <- y + 30 #px;
					loop type over: standard_color_per_type.keys
					{
					    draw square(10#px) at: { x - 20#px, y } color: standard_color_per_type[type] border: #white;
					    draw type at: { x, y + 4#px } color: textcolor font: font("Helvetica", 16, #plain);
					    y <- y + 25#px;
					}
	            }
          }
		}
	}
}