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

	file shape_file_buildings <- file("../includes/"+useCase+"/Data_cc46/New_Buildings_500_1000_3946.geojson");
	file shape_file_projet <- file("../includes/"+useCase+"/Data_cc46/Zone_projet.geojson");
    file shape_file_existant <- file("../includes/"+useCase+"/Data_cc46/Existants.geojson");
	file shape_file_roads <- file("../includes/"+useCase+"/Data_cc46/Roads_500_1000_3946.geojson");
	file shape_file_bounds <- file("../includes/"+useCase+"/Data_cc46/Bounds_3946.geojson");
	
	image_file background_image <- image_file("../includes/"+useCase+"/images/heatmap.jpg");
	geometry shape <- envelope(shape_file_buildings);
	graph the_graph;
		
	map<string,rgb> standard_color_per_type <- 
	["road"::#gamablue,"building"::#gamared,"amenity"::#gamaorange,"shop"::#cyan, "leisure"::#darkcyan];
	
	
	map<int,rgb> project_color_per_phase <- 
	[1::#green,2::#blue,3::#red];
	
	//UI
	bool show_building<-true;
	bool show_projet<-true;
	bool show_existant<-true;
	bool show_road<-true;
	bool show_people<-true;
	bool show_material<-true;
	bool show_legend<-true;
	bool show_heatmap<-true;
	bool show_wireframe<-false;
	bool show_TUI<-true;
	rgb backgroundColor<-#white;
	rgb textcolor<- (backgroundColor = #white) ? #white : #black;
	
	/*int size <- 100;
	field heatmap <- field(size, size);
	reflex update {
		ask people {
			loop i from: -(size/100) to: size/100 step: 2 {
				loop j from:  -(size/100) to: size/100 step: 2 {
					heatmap[location + {i, j}] <- heatmap[location + {i, j}] + 5 / (abs(i) + 1);
				}
			}
		}
	}*/
	
	init {
		create building from: shape_file_buildings;
		create projet from: shape_file_projet with: [phase:int(read ("phase"))];
		create existant from: shape_file_existant;
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
			location<-{world.shape.width*0.25,world.shape.height*0.75};
		}
		
		create legend{
			location<-{world.shape.width*0.15, world.shape.height*0.85};
			shape<-shape rotated_by 90;
		}
		
		create background{
			location<-{world.shape.width/2, world.shape.height/2};
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

species projet{
	string nom; 
	int phase;
	string lot; 

	
	aspect base {
		if(phase!=0){
		  draw shape color: project_color_per_phase[phase] border: project_color_per_phase[phase] - 75 wireframe:show_wireframe width:5;	
		}
	}
}


species existant{

	aspect base {
		  draw shape color: #gamaorange wireframe:show_wireframe width:5;	
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

species background{
	aspect base{
		draw image_file(background_image) size:{world.shape.width, world.shape.height};
	}
}

species legend{
	
	aspect base{
		float x<-location.x;
		float y<-location.y;
		loop type over: standard_color_per_type.keys
		{
			draw square(10#px) at: { x - 20#px, y } color: standard_color_per_type[type] border: #black;
			draw type at: { x, y + 4#px} color: textcolor font: font("Helvetica", 16, #plain) perspective:true;
			y <- y + 25#px;
		}
		//draw rectangle(150#m,300#m) color:#white border:#black at:{location.x,location.y,location.z-0.1};
	}
}






experiment GratteCielErasme type: gui autorun:true{

	
	output {
		display city_display type: opengl rotate:90 background:backgroundColor fullscreen:1 synchronized:false 
		camera_location: {273.4481,501.1178,812.104} camera_target: {272.953,486.9384,0.0889} camera_orientation: {-0.0349,0.9992,0.0175}
		{
			species background aspect: base visible:show_heatmap;
			species building aspect: base visible:show_building;
			species projet aspect: base visible:show_projet;
			species existant aspect: base visible:show_existant;
			species road aspect: base visible:show_road;
			species people aspect: base visible:show_people;
			species materials aspect: base visible:show_material;
		
			species TUI aspect:base refresh:false visible:show_TUI;	
			event["b"] {show_building<-!show_building;}
			event["f"] {show_projet<-!show_projet;}
			event["e"] {show_existant<-!show_existant;}
			event["r"] {show_road<-!show_road;}
			event["p"] {show_people<-!show_people;}
			event["m"] {show_material<-!show_material;}
			event["t"] {show_TUI<-!show_TUI;}
			event["w"] {show_wireframe<-!show_wireframe;}
			event["h"] {show_heatmap<-!show_heatmap;}
					
			overlay position: { 1500#px, 900#px } size: { 600 #px, 300 #px } background: #black  rounded: true
            {
            	if(show_legend){
            		
					float y <- 50#px;
					float x<- 50#px;
					float textSize<-30.0;
					float gapBetweenColum<-150#px;
					
					draw "Phase" at: { x, y } color: textcolor font: font("Helvetica", textSize*1.5, #bold);
					y <- y + 30 #px;
					loop phase over: project_color_per_phase.keys
					{
					    draw square(10#px) at: { x - 20#px, y } color: project_color_per_phase[phase] border: #white;
					    draw string(phase) at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					    y <- y + 25#px;
					}
					
					
					y <- 50#px;
					x<- x+gapBetweenColum;
					
					draw "Agent" at: { x, y } color: textcolor font: font("Helvetica", textSize*1.5, #bold);
					y <- y + 30 #px;
			
					draw circle(5#px) at: { x - 20#px, y } color: #white border: #white;
					draw "(p)eople (" + show_people + ")" at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					draw square(10#px) at: { x - 20#px, y } color: #white border: #white;
					draw "(m)aterial" at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					
					y <- 50#px;
					x<- x+gapBetweenColum;
					
					draw "Keys" at: { x, y } color: textcolor font: font("Helvetica", textSize*1.5, #bold);
					y <- y + 30 #px;
				
					draw "(b)uilding (" + show_building + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					draw "(f)utur (" + show_projet + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					draw "(e)xistant (" + show_existant + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					draw "(r)oad (" + show_road + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					draw "(T)ui (" + show_TUI + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					draw "(h)eatmap (" + show_heatmap + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
	
				
	            }
          }
		}
	}
}