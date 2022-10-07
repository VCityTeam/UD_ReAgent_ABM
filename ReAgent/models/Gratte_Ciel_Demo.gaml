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
		
	list<image_file> image_files <- (list<image_file>(image_file("../includes/"+useCase+"/images/heatmap.jpg"),
		image_file("../includes/"+useCase+"/images/plu.jpg"),image_file("../includes/"+useCase+"/images/Groupe_1_3.png"),
		image_file("../includes/"+useCase+"/images/densite_arbres.jpg"),image_file("../includes/"+useCase+"/images/occsol.jpg"),image_file("../includes/"+useCase+"/images/plantabilite_exoDev.png")
		
	));
	//list<gif_file> gif_files <- [gif_file("../includes/"+useCase+"/images/Group_4_05_HD.gif"),gif_file("../includes/"+useCase+"/images/Groupe3.gif")];
	geometry shape <- envelope(shape_file_buildings);
	graph the_graph;
		
	map<string,rgb> standard_color_per_type <- 
	["road"::#gray,"building"::#gamared,"amenity"::#gamaorange,"shop"::#cyan, "leisure"::#darkcyan];
	
	map<string,rgb> color_per_energyclass <- 
	["A"::rgb("#2b83ba"),"B"::rgb("#6bb0af"),"C"::rgb("#abdda4"),"D"::rgb("#d5eeb2"), 
	"E"::rgb("#ffffbf"), "F"::rgb("#fed790"),"G"::rgb("#fdae61"),"N"::rgb("#ea633e"),nil::#lightgray];
	
	map<int,rgb> color_per_mode <- [0::rgb(52,152,219), 1::rgb(161,196,90),2::rgb(192,57,43)];
	map<int,string> mode_per_mode <- [0::"pedestrian", 1::"bike", 2::"car"];
	map<int,rgb> color_per_material <- [0::#green, 1::#gray,2::#red];
	map<int,string> mode_per_material <- [0::"food", 1::"construction", 2::"goods"];
	
	
	map<string,rgb> color_per_building_type <- 
	["Appartement"::rgb("#d7191c"),"Centres commerciaux"::rgb("#f69053"),"Logements collectifs"::rgb("#ffdf9a"),"Maison"::rgb("#def2b4"), 
	"Non résidentiel"::rgb("#91cba9"),nil::#lightgray];
	
	map<string,rgb> color_per_road_type <- 
	["footway"::rgb("#d5340f"),"lving_street"::rgb("#21ca87"),"pedestrian"::rgb("#1039de"),"primary"::rgb("#e7ce72"), 
	"residential"::rgb("#6e24e5"),"service"::rgb("#94ce3c"),"steps"::rgb("#c737c9"),"tertiary"::rgb("#d2226c"),"unclassified"::rgb("#52e652"),nil::#lightgray];
	
	
	map<int,rgb> project_color_per_phase <- 
	[1::#green,2::#blue,3::#red];
	
	
	//UI
	bool show_building<-true;
	bool show_building_type<-false;
	bool show_projet<-false;
	bool show_gratte_ciel<-true;
	bool show_road<-true;
	bool show_people<-true;
	bool show_material<-true;
	bool show_legend<-true;
	bool show_scenario_as_texture<-false;
	bool show_gif<-false;
	bool show_tree<-false;
	bool show_wireframe<-false;
	bool show_trace<-true;
	bool show_heatmap<-false;
	int curEpisode<-0;
	rgb backgroundColor<-#white;
	rgb textcolor<- (backgroundColor = #black) ? #white : #black;
	
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
	int size <- 100;
	field heatmap <- field(size, size);
	reflex updateHeatmap {
		ask people {
			heatmap[location] <- heatmap[location] + 10;
		}	
	}
	
	reflex updatePop when: (cycle mod 100 = 0){
		int newComer <-rnd(2);
		ask newComer among people{
			do die;
		}
		do initPop(rnd(2));
		int newMat <-rnd(2);
		ask newMat among materials{
			do die;
		}
		do initMat(rnd(2));
		
	}
	
	action initPop (int nbPeople){
		create people number: nbPeople {
			location <- any_location_in (one_of(building)); 
			color<-rnd_color(255);
			if(flip(0.1)){
				my_speed<-0.1#m/#sec;
				type<-"car";
				mode<-2;
			}else{
				if(flip(0.25)){
				my_speed<-0.05#m/#sec;	
				type<-"bike";
				mode<-1;
				}else{
				my_speed<-0.01#m/#sec;
				type<-"pedestrian";
				mode<-0;		
				}
			}
			my_speed<-my_speed*10;
			if(fuzzAgent){
			 val <- rnd(-max_dev,max_dev);	
			}
		}
	}
	
	action initMat (int nbMat){
		create materials number: nbMat {
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
	}
	
	init {
		create building from: shape_file_buildings with: [type:string(read ("adedpe202006_logtype_type_batiment")),
			class:string(read ("adedpe202006_logtype_classe_estim_ges"))
		];
		create trees from: shape_file_trees with: 
		[radius_cm:int(read ("circonference_cm")),height_m:int(read ("hauteurtotale_m")),couronne_m:int(read ("diametrecouronne_m")),genre:string(read ("genre"))];		
		create projet from: shape_file_projet with: [phase:int(read ("phase"))];
		create existant from: shape_file_existant;
		create road from: shape_file_roads with: [class:string(read ("fclass"))];
		the_graph <- as_edge_graph(road);
		
		do initPop(200);
		do initMat(100);

		//save people to:"../results/people_in.geojson" type: "json" attributes: ["ID"::name, "TYPE"::self.type];
		

		
		/*create TUI{
			size<-125#m;
			nbCells<-8;
			location<-{world.shape.width*0.2,world.shape.height*0.5};
		}*/
		
		create legend{
			location<-{world.shape.width*0.15, world.shape.height*0.85};
			shape<-shape rotated_by 90;
		}
		
		create texture{
			location<-{world.shape.width/2, world.shape.height/2};
		}
		/*create gif{
			location<-{world.shape.width/2, world.shape.height/2};
		}*/
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
		
	    draw shape color: #lightgray  width:2 border:#black wireframe:true;
		
		if(show_building){
		  draw shape color: color_per_energyclass[class] wireframe:show_wireframe width:2 border:#black;	
		}
		if(show_building_type){
		  draw shape color: color_per_building_type[type] wireframe:show_wireframe width:2 border:#black;	
		}
		
	}
}

species projet{
	string nom; 
	int phase;
	string lot; 

	
	aspect base {
		if(phase!=0){
		  draw shape color: project_color_per_phase[phase] border: project_color_per_phase[phase] wireframe:show_wireframe width:5;	
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
	string class;
	aspect base {
		if(show_road){
		  draw shape color: color_per_road_type[class] width:2 ;	
		}
		
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
		draw circle(2#m) color: color_per_mode[mode] border: #black;
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
		draw rectangle(3#m,9#m) rotate:heading+90 color: color_per_material[mode] border: #black;
	}
}

species texture{	
	aspect base{
		draw image_file(image_files[curEpisode]) size:{world.shape.width, world.shape.height};
	}
}

/*species gif{
	aspect base{
		//draw image_file(plu_image) size:{world.shape.width, world.shape.height};
		draw gif_files[1] size:{world.shape.height, world.shape.width} rotate: 90 ;
	}
}*/


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
		display city_display type: opengl background:backgroundColor fullscreen:true synchronized:false 
		//keystone: [{-0.13461307306143822,-0.27263252266269256,0.0},{-0.12039927031582047,1.0656775054594707,0.0},{1.0284276054912351,1.0307125025529897,0.0},{1.0706509607061578,-0.25751252140583614,0.0}]
		{
			rotation angle:90;
			camera 'default' location: {192.9253,499.1944,886.6691} target: {192.9253,499.1807,0.0};
			
			mesh heatmap scale: 0 color: palette([ #black, #yellow, #yellow, #orange, #orange, #red, #red]) smooth: 3 visible:show_heatmap;
			species texture aspect: base visible:show_scenario_as_texture position:{0,0,0.0};
			//species gif aspect: base visible:show_gif;
			species trees aspect: base visible:show_tree;
			species building aspect: base visible:show_building;
			species projet aspect: base visible:show_projet;
			species existant aspect: base visible:show_gratte_ciel;
			species road aspect: base visible:show_road;
			species people aspect: base visible:show_people trace:(show_trace ? 10 : 0) fading:true;
			species materials aspect: base visible:show_material;
			//species legend aspect:base;

	
			event["b"] {show_building<-!show_building;}
			//event["t"] {show_building_type<-!show_building_type;}
			event["f"] {show_projet<-!show_projet;}
			event["e"] {show_gratte_ciel<-!show_gratte_ciel;}
			event["r"] {show_road<-!show_road;}
			event["p"] {show_people<-!show_people;}
			event["m"] {show_material<-!show_material;}
			event["a"] {show_tree<-!show_tree;}
			event["w"] {show_wireframe<-!show_wireframe;}
			event["s"] {show_scenario_as_texture<-!show_scenario_as_texture;}
			event["g"] {show_gif<-!show_gif;}
			event["h"] {show_heatmap<-!show_heatmap;}
			
			
			event["1"] {curEpisode<-0;}
			event["2"] {curEpisode<-1;}
			event["3"] {curEpisode<-2;}
			event["4"] {curEpisode<-3;}
			event["5"] {curEpisode<-4;}
			event["6"] {curEpisode<-5;}
			
			
			event["t"] {show_trace<-!show_trace;}
					
			overlay position: {500#px, 700#px } size: { 1000#px, 200#px } background: #white rounded: true visible:show_legend
            { 
            	if(show_legend){
            		
					float y <- 50#px;
					float x<- 50#px;
					float textSize<-15.0#px;
					float gapBetweenColum<-150#px;

					draw string("(p)eople" + string (length (people))) at: { x - 20#px, y + 4#px } color:  show_people ? textcolor : #gray font: font("Helvetica", textSize*1.5, #bold);
					y <- y + 25#px;
					loop mode over: color_per_mode.keys
					{
					    draw circle(10#px) at: { x - 20#px, y } color: color_per_mode[mode] border: #white;
					    draw string(mode_per_mode[mode] + ": "+ length(people where (each.mode=mode))) at: { x, y } color: textcolor font: font("Helvetica", textSize, #plain);
					    y <- y + 25#px;
					}
					y<-y-25*4#px;
					x<-x+gapBetweenColum;
					draw string("(m)aterial" + string(length (materials))) at: { x - 20#px, y + 4#px } color: show_material ? textcolor : #gray  font: font("Helvetica", textSize*1.5, #bold);
					y <- y + 25#px;
					loop mode over: color_per_mode.keys
					{
					    draw rectangle(9#m,3#m) at: { x - 20#px, y } color: color_per_material[mode] border: #white;
					    draw string(mode_per_material[mode] + ": "+ length(materials where (each.mode=mode))) at: { x, y } color: textcolor font: font("Helvetica", textSize, #plain);
					    y <- y + 25#px;
					}
									
					
					y <- 50#px;
					x<-x+gapBetweenColum;
					
					draw string("(b)uilding" + string(length (building))) at: { x, y } color: show_building ? textcolor : #gray font: font("Helvetica", textSize*1.5, #bold);
					y <- y + 25 #px;
					int curClass<-0;
					loop class over: color_per_energyclass.keys
					{
					    draw rectangle(9#m,3#m) at: { x - 20#px + (curClass>4 ? 100#px:0), y+ (curClass>4 ? -125#px:0) } color: color_per_energyclass[class] border: #white;
					    draw string(class + ": "+ length(building where (each.class=class))) at: { x + (curClass>4 ? 100#px:0), y + (curClass>4 ? -125#px:0) } color: textcolor font: font("Helvetica", textSize, #plain);
					    y <- y + 25#px;
					    curClass<-curClass+1;
					}
					y <- 50#px;
					x<-x+gapBetweenColum;

					
					
					draw string("(r)oad" + string(length (road))) at: { x, y } color: show_road ? textcolor : #gray font: font("Helvetica", textSize*1.5, #bold);
					y <- y + 25 #px;
				    curClass<-0;
					loop class over: color_per_road_type.keys
					{
					    draw rectangle(9#m,3#m) at: { x - 20#px + (curClass>4 ? 200#px:0), y+ (curClass>4 ? -125#px:0) } color: color_per_road_type[class] border: #white;
					    draw string(class + ": "+ length(road where (each.class=class))) at: { x + (curClass>4 ? 200#px:0), y + (curClass>4 ? -125#px:0) } color: textcolor font: font("Helvetica", textSize, #plain);
					    y <- y + 25#px;
					    curClass<-curClass+1;
					}
					y <- 50#px;
					x<-x+gapBetweenColum*2;
					
					draw "Projet" at: { x, y } color: textcolor font: font("Helvetica", textSize*1.5, #bold);
					y <- y + 25#px;
					draw "(f)utur (" + show_projet + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					draw "(e)xistant (" + show_gratte_ciel + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					draw "(a)bres (" + show_tree + ")"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					y <- 50#px;
					x<-x+gapBetweenColum;
					draw "(s)cenario" at: { x, y } color: show_scenario_as_texture ? textcolor : #gray font: font("Helvetica", textSize*1.5, #bold);
					y <- y + 25 #px;
					draw "(1) Vegetale density"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					draw "(2) PLU"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					draw "(3) Vegetalisation"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					draw "(4) Densité Arbres"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					draw "(5) Occupation des Sols"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					draw "(6) Plantabilité"  at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
					y <- y + 25#px;
					
					
					

					
					x<-x+2*gapBetweenColum;
					if (show_projet){
						y<-50#px;
						draw "Phase" at: { x, y } color: textcolor font: font("Helvetica", textSize*1.5, #bold);
						y <- y + 30 #px;
						loop phase over: project_color_per_phase.keys
						{
						    draw square(10#px) at: { x - 20#px, y } color: project_color_per_phase[phase] border: #white;
						    draw string(phase) at: { x, y + 4#px } color: textcolor font: font("Helvetica", textSize, #plain);
						    y <- y + 25#px;
						}
					
					y <- 50#px;
					x<-x+gapBetweenColum;
					}
					

					
					y <- y + 300#px;
					draw image_file('../images/logo_table_white.png') at: { x+300#px, y } size:{1200#px,215#px};
	            }
          }
		}
	}
}