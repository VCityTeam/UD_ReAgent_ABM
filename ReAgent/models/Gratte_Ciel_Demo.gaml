/**
* Name: HelloWorld
* Based on the internal empty template. 
* Author: arno
* Tags: 
*/


model HelloWorld

//import 'TUI.gaml'

/* Insert your model definition here */

global {
	string useCase<-"GratteCiel";

	file shape_file_buildings <- file("../includes/"+useCase+"/Data_cc46/bat_cstb_3946.geojson");
	file shape_file_trees <- file("../includes/"+useCase+"/Data_cc46/arbres_align_3946.geojson");
	file shape_file_projet <- file("../includes/"+useCase+"/Data_cc46/Zone_projet.geojson");
    file shape_file_existant <- file("../includes/"+useCase+"/Data_cc46/Existants.geojson");
	file shape_file_roads <- file("../includes/"+useCase+"/Data_cc46/Roads_500_1000_3946.geojson");
	file shape_file_bounds <- file("../includes/"+useCase+"/Data_cc46/Bounds_3946.geojson");
	
	image_file heatmap_image <- image_file("../includes/"+useCase+"/images/heatmap.jpg");
	image_file plu_image <- image_file("../includes/"+useCase+"/images/plu.jpg");
	geometry shape <- envelope(shape_file_buildings);
	graph the_graph;
		
	map<string,rgb> standard_color_per_type <- 
	["road"::#gamablue,"building"::#gamared,"amenity"::#gamaorange,"shop"::#cyan, "leisure"::#darkcyan];
	
	map<string,rgb> color_per_class <- 
	["A"::rgb("#2b83ba"),"B"::rgb("#6bb0af"),"C"::rgb("#abdda4"),"D"::rgb("#d5eeb2"), 
	"E"::rgb("#ffffbf"), "F"::rgb("#fed790"),"G"::rgb("#fdae61"),"N"::rgb("#ea633e"),nil::#lightgray];
	
	
	map<int,rgb> project_color_per_phase <- 
	[1::#green,2::#blue,3::#red];
	
	//UI
	bool show_building<-true;
	bool show_projet<-false;
	bool show_existant<-false;
	bool show_road<-true;
	bool show_people<-true;
	bool show_material<-true;
	bool show_legend<-true;
	bool show_heatmap<-false;
	bool show_plu<-false;
	bool show_tree<-false;
	bool show_wireframe<-false;
	bool show_TUI<-true;
	rgb backgroundColor<-#white;
	rgb textcolor<- (backgroundColor = #white) ? #white : #black;
	
	int curSnap<-0;
	
	bool fuzzAgent<-false;
	float max_dev <- 1.0;
	float fuzzyness <- 0.5;
	
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
		create building from: shape_file_buildings with: [class:string(read ("adedpe202006_logtype_classe_estim_ges"))];
		create trees from: shape_file_trees with: 
		[radius_cm:int(read ("circonference_cm")),height_m:int(read ("hauteurtotale_m")),couronne_m:int(read ("diametrecouronne_m")),genre:string(read ("genre"))];		
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
				type<-"car";
			}else{
				if(flip(0.25)){
				my_speed<-0.05#m/#sec;	
				type<-"bike";
				}else{
				my_speed<-0.01#m/#sec;
				type<-"pedestrian";		
				}
			}
			my_speed<-my_speed*10;
			if(fuzzAgent){
			 val <- rnd(-max_dev,max_dev);	
			}
		}
		//save people to:"../results/people_in.geojson" type: "json" attributes: ["ID"::name, "TYPE"::self.type];
		
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
		
		/*create TUI{
			size<-125#m;
			nbCells<-8;
			location<-{world.shape.width*0.2,world.shape.height*0.5};
		}*/
		
		create legend{
			location<-{world.shape.width*0.15, world.shape.height*0.85};
			shape<-shape rotated_by 90;
		}
		
		create heatmap{
			location<-{world.shape.width/2, world.shape.height/2};
		}
		create plu{
			location<-{world.shape.width/2, world.shape.height/2};
		}
	}
	/*reflex u{
		if (cycle mod 10 =0){
			save people to:"../results/"+curSnap+".geojson" type: "json" attributes: ["id"::name, "type"::self.type];
			curSnap<-curSnap+1;
		}
	}*/
	}
	


species building {
	string type; 
	rgb color <- #gray  ;
	string class;
	
	aspect base {
		draw shape color: color_per_class[class] wireframe:show_wireframe width:2 border:#black;
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
	string type<-"road";
	aspect base {
		draw shape color: standard_color_per_type["road"] width:2 ;
	}
}



species people skills:[moving] {
    rgb color;
    int mode;
	string type;
	list<point> locs;
	float my_speed;
	geometry shape<-circle(2#m);
	float val;
	reflex move {
		do wander on:the_graph speed:my_speed;
		if(fuzzAgent){
		  float val_pt <- val + rnd(-fuzzyness, fuzzyness);
		  location <- location + {cos(heading + 90) * val_pt, sin(heading + 90) * val_pt};	
		}
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
		draw rectangle(3#m,9#m) rotate:heading+90 color: color border: #black;
	}
}

species heatmap{	
	aspect base{
		draw image_file(heatmap_image) size:{world.shape.width, world.shape.height};
	}
}

species plu{
	aspect base{
		draw image_file(plu_image) size:{world.shape.width, world.shape.height};
	}
}


species trees{
	int radius_cm;
	int height_m;
	int couronne_m;
	string genre;
	aspect base{
		draw circle(radius_cm#cm) color:#green depth:height_m;
		draw sphere(couronne_m) color:#green at:{location.x,location.y,height_m};
	}
}

species legend{
	
	aspect base{
		float x<-location.x;
		float y<-location.y;
		loop type over: standard_color_per_type.keys
		{
			draw square(10#px) at: { x - 20#px, y } color: standard_color_per_type[type] border: #black;
			draw type at: { x, y + 4#px} color: #black font: font("Helvetica", 16, #plain) perspective:true;
			y <- y + 25#px;
		}
		//draw rectangle(260#px*1.8,30#px*1.8) rotated_by 90 texture:image_file("./../images/logo_table_white.png") color:#yellow border:#black at:{location.x-110#px,location.y};
	}
}






experiment Demo type: gui autorun:true{

	float minimum_cycle_duration<-0.01;
	output {
		display city_display type: opengl background:backgroundColor fullscreen:1 synchronized:false 

		{
			rotation angle:90;
			camera 'default' location: {321.5273,579.0176,1196.2332} target: {321.5273,578.9992,0.0};
			species heatmap aspect: base visible:show_heatmap;
			species plu aspect: base visible:show_plu;
			species trees aspect: base visible:show_tree;
			species building aspect: base visible:show_building;
			species projet aspect: base visible:show_projet;
			species existant aspect: base visible:show_existant;
			species road aspect: base visible:show_road;
			species people aspect: base visible:show_people trace:0 fading:true;
			species materials aspect: base visible:show_material trace:0 fading:true;
			//species legend aspect:base;

			//species TUI aspect:base refresh:false visible:show_TUI;	
			event["b"] {show_building<-!show_building;}
			event["f"] {show_projet<-!show_projet;}
			event["e"] {show_existant<-!show_existant;}
			event["r"] {show_road<-!show_road;}
			event["p"] {show_people<-!show_people;}
			event["m"] {show_material<-!show_material;}
			event["t"] {show_tree<-!show_tree;}
			event["w"] {show_wireframe<-!show_wireframe;}
			event["h"] {show_heatmap<-!show_heatmap;}
			event["l"] {show_plu<-!show_plu;}
					
			overlay position: { 500#px, 625#px } size: { 250 #px, 200 #px } background: #blue  rounded: true visible:show_legend
            { 
            	if(show_legend){
            		
					float y <- 50#px;
					float x<- 50#px;
					float textSize<-15.0#px;
					float gapBetweenColum<-250#px;
					
					draw "Phase" at: { x, y } color: textcolor font: font("Helvetica", textSize*1.5, #bold);
					y <- y + 30 #px;
					loop phase over: project_color_per_phase.keys
					{
					    draw square(10#px) at: { x - 20#px, y } color: project_color_per_phase[phase] border: #white;
					    draw string(phase) at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					    y <- y + 25#px;
					}
					
					
					y <- 50#px;
					x<-200#px;
					//x<- x+gapBetweenColum;
					
					draw "Keys" at: { x, y } color: textcolor font: font("Helvetica", textSize*1.5, #bold);
					y <- y + 30 #px;
			
					//draw circle(5#px) at: { x - 20#px, y } color: #white border: #white;
					draw "(p)eople (" + show_people + ")" at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					//draw square(10#px) at: { x - 20#px, y } color: #white border: #white;
					draw "(m)aterial(" + show_material + ")" at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 30 #px;
					draw "(b)uilding (" + show_building + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					draw "(r)oad (" + show_road + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					
					x<-x+100#px;
					y<-y-105#px;
					
					draw "(f)utur (" + show_projet + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					draw "(e)xistant (" + show_existant + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					
					draw "(h)eatmap (" + show_heatmap + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					draw "(t)ree (" + show_tree + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					draw "(l)anduse (" + show_tree + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;

					
					y <- y + 300#px;
					//draw image_file('../images/logo_table_white.png') at: { x+300#px, y } size:{1200#px,215#px};
	
				
	            }
          }
		}
	}
}