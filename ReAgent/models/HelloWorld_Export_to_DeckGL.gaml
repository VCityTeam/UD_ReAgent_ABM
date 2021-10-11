/**
* Name: HelloWorld
* Based on the internal empty template. 
* Author: arno
* Tags: 
*/


model HelloWorld

/* Insert your model definition here */

global {
	file shape_file_buildings <- file("../includes/Lyon/Buildings.shp");
	file shape_file_roads <- file("../includes/Lyon/Roads.shp");
	file shape_file_bounds <- file("../includes/Lyon/Bounds.shp");
	geometry shape <- envelope(shape_file_bounds);
	graph the_graph;
	bool savePedestrian parameter: 'Save Pedestrian' category: "Parameters" <-true;  
   
	
    float step <- 1#sec;
	float saveLocationInterval<-step;
	int totalTimeInSec<-10;//86400; //24hx60minx60sec 1step is 10#sec
	
	
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
	
	reflex save_results when: (cycle mod (totalTimeInSec/step) = 0 and cycle>1)  {
		
		string t;
		map<string, unknown> test;
		save "[" to: "result.json";
		ask people {
			test <+ "mode"::mode;
			test<+"path"::locs;
			test<+locs;
			t <- "{\n\"mode\": ["+ mode + ","+type+    "],\n\"path\": [";
			//t <- "{\n\"mode\": "+mode+"\n\"type\": "+type+ ",\n\"segments\": [";
			int curLoc<-0;
			loop l over: locs {
				point loc <- CRS_transform(l).location;
				if(curLoc<length(locs)-1){
				t <- t + "[" + loc.x + ", " + loc.y + "],\n";	
				}else{
				t <- t + "[" + loc.x + ", " + loc.y + "]\n";	
				}
				curLoc<-curLoc+1;
			}
			t <- t + "]";
			t <- t+",\n\"timestamps\": [";
			curLoc<-0;
			loop l over: locs {
				
				point loc <- CRS_transform(l).location;
				if(curLoc<length(locs)-1){
				t <- t + loc.z + ",\n";	
				}else{
				t <- t +  loc.z + "\n";	
				}
				curLoc<-curLoc+1;
			}
			t <- t + "]";
			
			
			t<- t+ "\n}";
			if (int(self) < (length(people) - 1)) {
				t <- t + ",";
			}
			save t to: "result.json" rewrite: false;
		}

		save "]" to: "result.json" rewrite: false;
		file JsonFileResults <- json_file("./result.json");
        map<string, unknown> c <- JsonFileResults.contents;
        write "saving result in json";
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
			if((time mod saveLocationInterval = 0) and (time mod totalTimeInSec)>1){
		 	locs << {location.x,location.y,time mod totalTimeInSec};
		}
	
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