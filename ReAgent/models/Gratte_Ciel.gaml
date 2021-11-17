/**
* Name: HelloWorld
* Based on the internal empty template. 
* Author: arno
* Tags: 
*/


model HelloWorld

/* Insert your model definition here */

global {
	string useCase<-"GratteCiel";
	file shape_file_buildings <- file("../includes/"+useCase+"/generated/building_polygon.shp");
	file shape_file_roads <- file("../includes/"+useCase+"/generated/highway_line.shp");
	file shape_file_bounds <- file("../includes/"+useCase+"/Bounds.shp");
	geometry shape <- envelope(shape_file_bounds);
	graph the_graph;

	
	
	init {
		create building from: shape_file_buildings;
		create road from: shape_file_roads ;
		the_graph <- as_edge_graph(road);
		create people number: 10 {
			location <- any_location_in (one_of(building)); 
			color<-rnd_color(255);
			mode<-rnd(2);
		}
	}
	}
	

species building {
	string type; 
	rgb color <- #gray  ;
	
	aspect base {
		draw shape color: color ;
	}
}

species road  {
	rgb color <- #black ;
	aspect base {
		draw shape color: color ;
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


experiment road_traffic type: gui {

	
	output {
		display city_display type: opengl {
			species building aspect: base ;
			species road aspect: base ;
			species people aspect: base ;
		}
	}
}