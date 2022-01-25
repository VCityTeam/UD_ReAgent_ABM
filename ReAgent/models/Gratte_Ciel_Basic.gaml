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

	file shape_file_buildings <- file("../includes/"+useCase+"/Data/Data_cc46/New_Buildings_500_1000_3946.geojson");
	file shape_file_roads <- file("../includes/"+useCase+"/Data/Data_cc46/Roads_500_1000_3946.geojson");
	file shape_file_bounds <- file("../includes/"+useCase+"/Data/Data_cc46/Bounds_3946.geojson");
	geometry shape <- envelope(shape_file_buildings);
	graph the_graph;

	
	map<string,rgb> standard_color_per_type <- 
	["road"::#gamablue,"building"::#gamared,"amenity"::#gamaorange,"shop"::#cyan, "leisure"::#darkcyan];
	
	//UI
	bool show_building<-true;
	bool show_road<-true;
	bool show_legend<-false;
	bool show_wireframe<-false;
	rgb backgroundColor<-#white;
	rgb textcolor<- (backgroundColor = #white) ? #black : #white;
	
	init {
		create building from: shape_file_buildings;
		create road from: shape_file_roads ;
		the_graph <- as_edge_graph(road);
		
		
		create people number: 100 {
			location <- any_location_in (one_of(building)); 
			color<-rnd_color(255);
			mode<-rnd(2);
			if(flip(0.25)){
				my_speed<-0.1#m/#sec;
			}else{
				if(flip(0.25)){
				my_speed<-0.05#m/#sec;	
				}else{
				my_speed<-0.01#m/#sec;		
				}
			}
		}
		
		create materials number: 100 {
			location <- any_location_in (one_of(building)); 
			color<-rnd_color(255);
			mode<-rnd(2);
			if(flip(0.25)){
				my_speed<-0.1#m/#sec;
			}else{
				if(flip(0.25)){
				my_speed<-0.05#m/#sec;	
				}else{
				my_speed<-0.01#m/#sec;		
				}
			}
		}
		
		create TUI{
			size<-125#m;
			nbCells<-8;
			location<-{world.shape.width/1.8,world.shape.height/4+25#m};
		}
	}
	}
	


species building {
	string type; 
	rgb color <- #gray  ;
	
	aspect base {
		//draw shape color: standard_color_per_type["building"] wireframe:show_wireframe width:2;
		draw shape color: #gamablue wireframe:show_wireframe width:2;
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
	float my_speed;
	 
	reflex move {
		do wander on:the_graph speed:my_speed;
	}
	
	aspect base {
		draw circle(2#m) color: color border: #black;
	}
}

species materials skills:[moving] {
    rgb color;
    int mode;
	int type;
	list<point> locs;
	float my_speed;
	 
	reflex move {
		do wander on:the_graph speed:my_speed;
	}
	
	aspect base {
		draw square(4#m) color: color border: #black;
	}
}






experiment GratteCielTable type: gui {

	
	output {
		display city_display type: opengl background:backgroundColor rotate:90 fullscreen:true 
		{
			species building aspect: base visible:show_building;
			species road aspect: base visible:show_road;
			species people aspect: base ;
			species materials aspect: base ;
			species TUI aspect:base refresh:false;		
			event["b"] {show_building<-!show_building;}
			event["r"] {show_road<-!show_road;}
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