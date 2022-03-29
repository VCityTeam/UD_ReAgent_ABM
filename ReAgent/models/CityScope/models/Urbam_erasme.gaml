/***
* Name: Urbam
* Author: Arno, Pat et Tri
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Urbam
	

import "common model.gaml"
global{
	int population_level <- 10 parameter: 'Population level' min: 0 max: 300 category: "General";
	bool blackMirror parameter: 'Dark Room' category: 'Aspect' <- true;
	
	
	//SPATIAL PARAMETERS  
	int grid_height <- 8;
	int grid_width <- 8;
	float environment_height <- 5000.0;
	float environment_width <- 5000.0;
	
	
	bool load_grid_file_from_cityIO <-false; //parameter: 'Online Grid:' category: 'Simulation' <- false;
	bool load_grid_file <- false;// parameter: 'Offline Grid:' category: 'Simulation'; 
	bool udpScannerReader <- true; 
	bool udpSliderReader <- false; 
	bool editionMode <-false;
	bool launchpad<-false;
	
	bool show_cells parameter: 'Show cells:' category: 'Aspect' <- false;
	bool show_building parameter: 'Show Building:' category: 'Aspect' <- true;
	
	bool on_modification_cells <- false update: show_cells != show_cells_prev;
	
	bool show_cells_prev <- show_cells update: show_cells ;
	bool on_modification_bds <- false update: false;
	
	string cityIOUrl;
	bool projector_reversed<-true;

	
	
	list<building> residentials;
	map<building, float> offices;
	string imageFolder <- "../images/flat/";
	string imageFolderLogo <- "../images/logo/";
	string imageRemploiFolder <- "../images/images_reemploi/";
	string imageErasmeFolder <- "../images/erasme/";
	map<string,map<profile,float>> proportions_per_bd_type;
	int action_type;
	

	int file_cpt <- 1;

	
	//geometry shape <- envelope(nyc_bounds0_shape_file);
	geometry shape<-rectangle(environment_width, environment_height); // one edge is 5000(m)
	//geometry shape<-rectangle(8000, 5000);
	float step <- sqrt(shape.area) /2000.0 ;
	
	
	//image des boutons
	list<file> images <- [
		file(imageFolder +"residential_S.png"),
		file(imageFolder +"office_S.png"),
		file(imageFolder +"eraser.png"),
		file(imageFolder +"residential_M.png"),
		file(imageFolder +"office_M.png"),
		file(imageFolder +"road.png"),
		file(imageFolder +"residential_L.png"),
		file(imageFolder +"office_L.png"),
		file(imageFolder +"empty.png")
	]; 
	
	
	//image des block
	list<file> images_reemploi <- [
		file(imageRemploiFolder +"concrete.png"),
		file(imageRemploiFolder +"glass.png"),
		file(imageRemploiFolder +"grass.png"),
		file(imageRemploiFolder +"metal.png"),
		file(imageRemploiFolder +"wood.png")
	]; 
	
	
	//image erasme
	list<file> images_erasme <- [
		file(imageErasmeFolder +"bench.png"),
		file(imageErasmeFolder +"drop.png"),
		file(imageErasmeFolder +"leaves.png"),
		file(imageErasmeFolder +"picnic-table.png"),
		file(imageErasmeFolder +"road.png"),
		file(imageErasmeFolder +"theater.png")
	];
	map<string,file> picture_per_id <- ["residentialS"::images_erasme[0],"residentialM"::images_erasme[1],"residentialL"::images_erasme[2],"officeS"::images_erasme[3],"officeM"::images_erasme[4],"officeL"::images_erasme[5]];
	map<string,rgb> color_erasme__per_id <- ["residentialS"::#yellow,"residentialM"::#blue,"residentialL"::#green,"officeS"::#orange,"officeM"::#red,"officeL"::#green];
	
	
	
	
	
	//image des block
	list<file> images_logo <- [
		file(imageFolderLogo +"logo_table.png")
	]; 
	
	
	
	
	// Network
	int scaningUDPPort <- 5000;
	int interfaceUDPPort <- 9878;
	string url <- "localhost";
	
	map<string,int> depth_map <- ["S"::500, "M"::250, "L"::100];
	
	
	//TUI
	bool show_legend<-true;
	
	init {
		cityIOUrl <- launchpad ? "https://cityio.media.mit.edu/api/table/launchpad": "https://cityio.media.mit.edu/api/table/urbam";
		list<geometry> lines;
		float cell_w <- first(cell).shape.width;
		float cell_h <- first(cell).shape.height;
		loop i from: 0 to: grid_width {
			lines << line([{i*cell_w,0}, {i*cell_w,environment_height}]);
		}
		loop i from: 0 to: grid_height {
			lines << line([{0, i*cell_h}, {environment_width,i*cell_h}]);
		}
		create road from: split_lines(lines) {
			create road with: [shape:: line(reverse(shape.points))];
		}
		do update_graphs;
		do init_buttons; 
		do load_profiles;
		block_size <- min([first(cell).shape.width,first(cell).shape.height]);
		if(udpScannerReader){
			create NetworkingAgent number: 1 {
			 type <-"scanner";	
		     do connect to: url protocol: "udp_server" port: scaningUDPPort ;
		    }
		}
		if(udpSliderReader){
			create NetworkingAgent number: 1 {
			 type <-"interface";	
		     do connect to: url protocol: "udp_server" port: interfaceUDPPort ;
		    }	   
		}
		create scene{
			location<-{world.shape.width/2,world.shape.height/2};
			shape<-rectangle(1920*4.6,1080*4.6);
		}
		
		}
		

	
	action init_buttons	{
		int inc<-0;
		ask button {
			action_nb<-inc;
			inc<-inc+1;
		}
	}
	
	
	action activate_act {
		button selected_but <- first(button overlapping (circle(1) at_location #user_location));
		ask selected_but {
			ask button {bord_col<-#black;}
			action_type<-action_nb;
			bord_col<-#red;
		}
	}

	
	
	reflex test_load_file_from_cityIO when: load_grid_file_from_cityIO and every(10#cycle) {
		if(launchpad){
	      do load_cityIO_v2(cityIOUrl);
		}else{
		  do load_cityIO_v2_urbam(cityIOUrl);
		}
		
	}
	
	reflex test_load_file when: load_grid_file and every(100#cycle){
		do load_matrix("../includes/6x6_" +file_cpt+".csv");
		file_cpt <- (file_cpt+ 1) mod 5;
	}
	
	reflex randomGridUpdate when:!udpScannerReader and !editionMode and !load_grid_file_from_cityIO and every(1000#cycle){
		do randomGrid;
	} 
		
	
	
	action infrastructure_management {
		if (action_type = 8) {
			do manage_road;
		} else {
			do build_buildings;
		}
		
	}
	
	
	action manage_road{
		road selected_road <- first(road overlapping (circle(sqrt(shape.area)/100.0) at_location #user_location));
		if (selected_road != nil) {
			bool with_car <- "car" in selected_road.allowed_mobility;
			bool with_bike <- "bike" in selected_road.allowed_mobility;
			bool with_pedestrian <- "walk" in selected_road.allowed_mobility;
			map input_values <- user_input(["car allowed"::with_car,"bike allowed"::with_bike,"pedestrian allowed"::with_pedestrian]);
			if (with_car != input_values["car allowed"]) {
				if (with_car) {selected_road.allowed_mobility >> "car";}
				else {selected_road.allowed_mobility << "car";}
				
			}
			if (with_bike != input_values["bike allowed"]) {
				if (with_bike) {selected_road.allowed_mobility >> "bike";}
				else {selected_road.allowed_mobility << "bike";}
			}
			if (with_pedestrian != input_values["pedestrian allowed"]) {
				if (with_pedestrian) {selected_road.allowed_mobility >> "walk";}
				else {selected_road.allowed_mobility << "walk";}
			}
			point pt1 <- first(selected_road.shape.points);
			point pt2 <- last(selected_road.shape.points);
			road reverse_road <- road first_with ((first(each.shape.points) = pt2) and (last(each.shape.points) = pt1));
			if (reverse_road != nil) {
				reverse_road.allowed_mobility <-  selected_road.allowed_mobility;
			}
			do update_graphs;
		}
		
		
	}
	
	action build_buildings {
		cell selected_cell <- first(cell overlapping (circle(sqrt(shape.area)/100.0) at_location #user_location));
		if (selected_cell != nil) and (selected_cell.is_active) {
			if (action_type = 3) {ask selected_cell {do new_residential("S");}} 
			if (action_type = 4) {ask selected_cell {do new_office("S");}} 
			if (action_type = 5) {ask selected_cell {do erase_building;}} 
			if (action_type = 6) {ask selected_cell {do new_residential("M");}} 
			if (action_type = 7) {ask selected_cell {do new_office("M");}} 
			if (action_type = 9) {ask selected_cell {do new_residential("L");}} 
			if (action_type = 10) {ask selected_cell {do new_office("L");}} 
		}
		on_modification_bds <- true;
	}
	
	action createCell(int id, int x, int y){
		list<string> types <- id_to_building_type[id];
		string type <- types[0];
		string size <- types[1];
		cell current_cell <- cell[x,y];
		bool new_building <- true;
		if (current_cell.my_building != nil) {
			building build <- current_cell.my_building;
			new_building <- (build.type != type) or (build.size != size);
		}
		if (new_building) {
			if (type = "residential") {
				ask current_cell {do new_residential(size);}
			} else if (type = "office") {
				ask current_cell {do new_office(size);}
			}
		}
	} 
	action load_matrix(string path_to_file) {
		file my_csv_file <- csv_file(path_to_file,",");
		matrix data <- matrix(my_csv_file);
		loop i from: 0 to: data.rows - 1 {
			loop j from: 0 to: data.columns - 1 {
					int id <- int(data[j, i]);
					if (id > 0) {
                     do createCell(id, j, i);
					}
					cell current_cell <- cell[j,i];
					current_cell.is_active <- id<0?false:true;
					if (id<=0){					
						ask current_cell{ do erase_building;}
					}
			}
		}
	}
	
	
	
   action randomGrid{
   	int id;
   	loop i from: 0 to: grid_width-1 {
			loop j from: 0 to: grid_height-1 {
				    if (flip(1.0)){
				        id <- 1+rnd(5);	
				    }else{
				    	id<--1;
				    }
					
					if (id > 0) {
                     do createCell(id, j, i);
					}
					cell current_cell <- cell[j,i];
					current_cell.is_active <- id<0?false:true;
					if (id<=0){					
						ask current_cell{ do erase_building;}
					}
			}
		}
   }
	
	action load_cityIO_v1(string cityIOUrl_) {
		map<string, unknown> cityMatrixData;
	    list<map<string, int>> cityMatrixCell;	
		try {
			cityMatrixData <- json_file(cityIOUrl_).contents;
		} catch {
			cityMatrixData <- json_file("../includes/cityIO_Kendall.json").contents;
			//write #current_error + "Connection to Internet lost or cityIO is offline - CityMatrix is a local version from cityIO_Kendall.json";
		}
		cityMatrixCell <- cityMatrixData["grid"];	
		loop l over: cityMatrixCell { 
      	  int id <-int(l["type"]);
      	  if(id!=-2 and id !=-1 and id!=6 ){
      	  	do createCell(id+1, l["x"], l["y"]);	
      	  } 
      	  if (id=-1){
		    cell current_cell <- cell[l["x"],l["y"]];
			ask current_cell{ do erase_building;}
		  }     
        }	
	}
	
	
	action load_cityIO_v2(string cityIOUrl_) {
		map<string, unknown> cityMatrixData;
	    list<map<string, int>> cityMatrixCell;
	    	
		try {
			cityMatrixData <- json_file(cityIOUrl_).contents;
		} catch {
			//cityMatrixData <- json_file("../includes/cityIO_gama.json").contents;
			write #current_error + "Connection to Internet lost or cityIO is offline - CityMatrix is a local version from cityIO_gama.json";
		}
		int nbCols <- int(map(map(cityMatrixData["header"])["spatial"])["ncols"]);
		int nbRows <- int(map(map(cityMatrixData["header"])["spatial"])["nrows"]);
		loop i from: 0 to: nbCols-1 {
			loop j from: 0 to: nbRows -1{
				int id <-int(list(list(cityMatrixData["grid"])[j*nbCols+i])[0]);
      	  		if(id!=-2 and id !=-1 and id!=6 ){
      	  			do createCell(id+1, i, j);		
      	  		} 
      	  		if (id=-1){
		    		cell current_cell <- cell[i,j];
					ask current_cell{ do erase_building;}
		  		}   
			}
        } 	
	}
	
	action load_cityIO_v2_urbam(string cityIOUrl_) {
		map<string, unknown> cityMatrixData;
	    list<map<string, int>> cityMatrixCell;	
		try {
			cityMatrixData <- json_file(cityIOUrl_).contents;
		} catch {
			cityMatrixData <- json_file("../includes/cityIO_Urbam.json").contents;
			write #current_error + "Connection to Internet lost or cityIO is offline - CityMatrix is a local version from cityIO_gama.json";
		}
		int ncols <- int(map(map(cityMatrixData["header"])["spatial"])["ncols"]);
		int nrows <- int(map(map(cityMatrixData["header"])["spatial"])["nrows"]);
		int x;
		int y;
		int id;
		loop i from:0 to: (ncols*nrows)-1{ 
			if((i mod nrows) mod 2 = 0 and int(i/ncols) mod 2 = 0){   
				x<- grid_width-1-int((i mod nrows)/2);
			    y<-grid_height-1-int((int(i/ncols))/2);
			    id<-int(list<list>(cityMatrixData["grid"])[i][0]);
			    if(id!=-2 and id !=-1 and id!=6 ){
	      	  		ask world{do createCell(id+1, x, y);}
	      	    } 
	      	    if (id=-1){
			    	cell current_cell <- cell[x,y];
				    ask current_cell{ do erase_building;}
			    }	   
			 } 		
       }	
	}
		
}


species building parent: poi {
	string size <- "S" among: ["S", "M", "L"];
	string type <- "residential" among: ["residential", "office"];
	list<people> inhabitants;
	rgb color;
	int typeId;

	action initialize(cell the_cell, string the_type, string the_size) {
		the_cell.my_building <- self;
		type <- the_type;
		size <- the_size;
		typeId<-rnd(4);
		do define_color;
		shape <- the_cell.shape;
		if (type = "residential") {residentials << self;}
		else if (type = "office") {
			offices[self] <- proba_choose_per_size[size];
		}
		bounds <- the_cell.shape + 0.5 - shape;
			
	}
	
	reflex populate when: (type = "residential"){
		int pop <- int(population_level/100 * nb_people_per_size[size]);
		if length(inhabitants) < pop{
			create people number: 1 with: [location::any_location_in(bounds)] {
				origin <- myself;
				building(origin).inhabitants << self;
				list_of_people << self;
				do reinit_destination;
				map<profile, float> prof_pro <- proportions_per_bd_type[building(origin).size];
				my_profile <- prof_pro.keys[rnd_choice(prof_pro.values)];
			}
		}
		if length(inhabitants) > pop{
			people tmp <- one_of(inhabitants);
			inhabitants >- tmp;
			ask tmp {do die;}
		}
	}
	
	action remove {
		if (type = "office") {
			offices[] >- self;
			ask people {
				do reinit_destination;
			}
		} else {
			ask inhabitants {
				do die;
			}
		}
		cell(location).my_building <- nil;
		do die;
		
	}
	action define_color {
		color <- color_per_id[type+size];
	}
	aspect default {
		if show_building {
			
			draw shape scaled_by 0.75 color: color_erasme__per_id[type+size] /*texture:image_file(picture_per_id[type+size])*/ rotate:90;
			//draw image_file(picture_per_id[type+size]) size:{shape.width,shape.height};
		}
	}
	
	aspect screen {
		if show_building {draw shape scaled_by 0.75 color: color_erasme__per_id[type+size] depth:depth_map[size];}
	}
}


species people parent: basic_people skills: [moving]{
	action reinit_destination {
		dest <- empty(offices) ? nil : offices.keys[rnd_choice(offices.values)];
		target <- nil;
	}
}

species scene{
	aspect base{
	  draw shape color: #white texture:image_file(imageErasmeFolder+"/screen/plan.png");	
	}	
}

grid cell width: grid_width height: grid_height { 
	building my_building;
	bool is_active <- true;
	//rgb color <- #white;
	action new_residential(string the_size) {
		if (my_building != nil and (my_building.type = "residential") and (my_building.size = the_size)) {
			return;
		} else {
			if (my_building != nil ) {ask my_building {do remove;}}
			create building returns: bds{
				do initialize(myself, "residential", the_size);
			}
		}
		
	}
	action new_office (string the_size) {
		if (my_building != nil and (my_building.type = "office") and (my_building.size = the_size)) {
			return;
		} else {
			if (my_building != nil) {ask my_building {do remove;}}
			create building returns: bds{
				do initialize(myself, "office",the_size);
			}
			ask people {
				do reinit_destination;
			}
		}
	}
	action erase_building {
		if (my_building != nil) {ask my_building {do remove;}}
	}
	
	aspect default{
		if show_cells {draw shape scaled_by (0.5) color: rgb(100,100,100) ;}
	}

}

grid button width:3 height:4 
{
	int action_nb;
	rgb bord_col<-#black;
	aspect normal {
		if (action_nb > 2 and not (action_nb in [11])) {draw rectangle(shape.width * 0.8,shape.height * 0.8).contour + (shape.height * 0.01) color: bord_col;}
		if (action_nb = 0) {draw "Residential"  color:#black font:font("SansSerif", 16, #bold) at: location - {15,-10.0,0};}
		else if (action_nb = 1) {draw "Office"  color:#black font:font("SansSerif", 16, #bold) at: location - {12,-10.0,0};}
		else if (action_nb = 2) {draw "Tools"  color:#black font:font("SansSerif", 16, #bold) at: location - {12,-10.0,0};}
		else {
			draw image_file(images[action_nb - 3]) size:{shape.width * 0.5,shape.height * 0.5} ;
		}
	}
}

species NetworkingAgent skills:[network] {
	string type;
	string previousMess <-"";
	
		reflex update_landuse when: has_more_message() and type = "scanner"{
		list<list<int>> scan_result <- [];    
	    
	    if (length(mailbox) > 0) {
			message mes <- fetch_message();	
 			string m <- string(mes.contents);
 			
 			matrix<int> id_matrix <- {8,8} matrix_with 0;
 			matrix<int> rot_matrix <- {8,8} matrix_with 0;
 			
 			int nbcols<-8;
 			int nbrows<-8;
 			
 			loop i from:0 to:nbrows-1{
 				loop j from:0 to: nbcols-1{
 					if (m at (i*(2*nbcols-1)*4+4*j) = 'x'){
 					  id_matrix[j,i]<--1;
 					  rot_matrix[j,i]<--1;	
 					}else{
 					  id_matrix[j,i]<-int(m at (i*(2*nbcols-1)*4+4*j));
 					  rot_matrix[j,i]<-int(m at (i*(2*nbcols-1)*4+4*j+1));
 					  }
 				} 						
 			}
            loop i from:0 to:nbrows-1{
 				loop j from:0 to: nbcols-1{
 					int i2<-projector_reversed ? nbrows-1-i : i;
 					int j2<-projector_reversed ? nbcols-1-j : j;
 					
 					
 					int id <-id_matrix[i2,j2];
 					if(id!=-2 and id !=-1 and id!=6 ){
	      	  	      ask world{do createCell(id+1, i, j);}	
	      	    	} 
	      	    	if (id=-1){
			      	  cell current_cell <- cell[i,j];
				   	  ask current_cell{ do erase_building;}
			    	}
 				}
 			}			
		} 
	} 
}



experiment CityScopeTable type: gui autorun: true{
	float minimum_cycle_duration <- 0.05;
	output {
		display table synchronized:true background:blackMirror ? #black :#white toolbar:false type:opengl  draw_env:false fullscreen:1 
		keystone: [{0.020146475104642625,0.10718301069438496,0.0},{-0.029740034678281985,0.9850442310658998,0.0},{1.0028780678720919,0.9314527257187073,0.0},{0.9347637948992523,0.08724198544891815,0.0}]
		{
	   species cell aspect:default;// refresh: on_modification_cells;
			//species road ;
			species people;
			species building;// refresh: on_modification_bds;
			
			
			/*graphics "mobilityMode"{
				    draw circle(world.shape.width * 0.01) color: color_per_mode["walk"] at: {world.shape.width * 0.2, world.shape.height*0.985};
					draw "walk" color: color_per_mode["walk"]  at: {world.shape.width * 0.2+world.shape.width * 0.02, world.shape.height*0.995} font:font("Helvetica", 20 , #bold) rotate:180;
					
					draw circle(world.shape.width * 0.01) color: color_per_mode["bike"] at: {world.shape.width * 0.4, world.shape.height*0.985};
					draw "bike" color: color_per_mode["bike"]  at: {world.shape.width * 0.4 + world.shape.width * 0.02, world.shape.height *0.995} font:font("Helvetica", 20 , #bold) rotate:180;
					
					draw circle(world.shape.width * 0.01) color: color_per_mode["car"] at: {world.shape.width * 0.6, world.shape.height*0.985};
					draw "car" color: color_per_mode["car"]  at: {world.shape.width * 0.6 + world.shape.width * 0.02, world.shape.height *0.995} font:font("Helvetica", 20 , #bold) rotate:180;
					
					draw circle(world.shape.width * 0.01) color: color_per_mode["pev"] at: {world.shape.width * 0.8, world.shape.height*0.985};
					draw "pev" color: color_per_mode["pev"]  at: {world.shape.width * 0.8 + world.shape.width * 0.02, world.shape.height *0.995} font:font("Helvetica", 20 , #bold) rotate:180;
			}
			
			graphics "landuse" {
					point hpos <- {world.shape.width * 1.1, world.shape.height * 1.1};
					float barH <- world.shape.width * 0.01;
					float factor <-  world.shape.width * 0.1;
					loop i from:0 to:length(color_per_id)-1{
						draw square(world.shape.width*0.02) empty:false color: color_per_id.values[i] at: {i*world.shape.width*0.175+world.shape.width*0.05, 75};
						draw fivefoods[i] color: color_per_id.values[i] at: {i*world.shape.width*0.175+world.shape.width*0.025+world.shape.width*0.05, 100} perspective: true font:font("Helvetica", 20 , #bold) rotate:180;
					}
			}*/

			
			event["h"] action: {road_aspect<-"hide";};
			event["r"] action: {road_aspect<-"default";};
			event["s"] action: {road_aspect<-"split (5)";};
			event["c"] action: {road_aspect<-"edge color";}; 
			
			event["n"] action: {people_aspect<-"hide";};
			event["m"] action: {people_aspect<-"mode";};
			//event["p"] action: {people_aspect<-"profile";};
			event["a"] action: {people_aspect<-"dynamic_abstract";};
		
			event["w"] action: {blackMirror<-!blackMirror;};
			event["b"] action: {show_building<-!show_building;};
			 
			event["g"] action: {show_cells<-!show_cells;}; 
			
			event["o"] action: {weight_car<-weight_car-0.1;}; 
			event["p"] action: {weight_car<-weight_car+0.1;};
			
			event["u"] action: {weight_bike<-weight_bike-0.1;}; 
			event["i"] action: {weight_bike<-weight_bike+0.1;};
			
			event["t"] action: {weight_pev<-weight_pev-0.1;}; 
			event["y"] action: {weight_pev<-weight_pev+0.1;};
			
		}	
		
		display map3D synchronized:true background:blackMirror ? #black :#white toolbar:false type:opengl  draw_env:false fullscreen:0 
		//camera_location: {2500.0,7842.7613,3338.3981} camera_target: {2500.0,2500.0,0.0} camera_orientation: {0.0,0.5299,0.8481}
		{
	        /*species cell aspect:default;
			species road ;
			species people;
			species building aspect:screen transparency:0.75;*/
			species scene aspect:base;
			/*overlay position: {150#px, 525#px } size: { 200 #px, 200 #px } background: #black  rounded: true
            {
            	if(show_legend){
            		
					float y <- 0#px;
					float x<- 0#px;
					float textSize<-10.0;
					float gapBetweenColum<-150#px;	
					draw "Bio Inspired WorkShop - Lyon - Erasme - 2022" at: { x+1400#px, y } color: #white font: font("Helvetica", textSize, #bold);
					float x_logo_offset<-50#px;
					draw image_file(images_logo[0]) at: { x, y } size:{1000#px/4,115#px/4};
	            }
            }*/
            
            chart "Biodiversité" background:#white type: pie style:ring size: {0.25,0.25} position: {world.shape.width*1,world.shape.height*0.75} color: #black axes: #white title_font: 'Helvetica' title_font_size: 12.0 
			tick_font: 'Monospaced' tick_font_size: 10 tick_font_style: 'bold' label_font: 'Arial' label_font_size: 32 label_font_style: 'bold' x_label: 'Nice Xlabel' y_label:'Nice Ylabel'
			{
				
				  data "biodiversitré" value: 75 color:rgb(0,255,0);
				  data "" value: 25 color:#white;
				
			}
			
			chart "Bien-Etre" background:#white type: pie style:ring size: {0.25,0.25} position: {world.shape.width*0,world.shape.height*0.75} color: #black axes: #white title_font: 'Helvetica' title_font_size: 12.0 
			tick_font: 'Monospaced' tick_font_size: 10 tick_font_style: 'bold' label_font: 'Arial' label_font_size: 32 label_font_style: 'bold' x_label: 'Nice Xlabel' y_label:'Nice Ylabel'
			{
				
				  data "Bien Etre" value: 25 color:rgb(0,255,0);
				  data "" value: 75 color:#white;
				
			}
			
			chart "Lien Social" background:#white type: pie style:ring size: {0.25,0.25} position: {world.shape.width*0.5,world.shape.height*0.75} color: #black axes: #white title_font: 'Helvetica' title_font_size: 12.0 
			tick_font: 'Monospaced' tick_font_size: 10 tick_font_style: 'bold' label_font: 'Arial' label_font_size: 32 label_font_style: 'bold' x_label: 'Nice Xlabel' y_label:'Nice Ylabel' y_tick_values_visible:false
			{
				
				  data "Lien Social" value: 50 color:rgb(0,255,0);
				  data "eco" value: 50 color:#white;
				
			}
			
		}
		
		/*display map3D synchronized:true background:blackMirror ? #black :#white toolbar:false type:opengl  draw_env:false fullscreen:0 rotate:180
		camera_location: {2500.0,7842.7613,3338.3981} camera_target: {2500.0,2500.0,0.0} camera_orientation: {0.0,0.5299,0.8481}
		{
	        species cell aspect:default;
			species road ;
			species people;
			species building aspect:screen transparency:0.75;
			overlay position: {150#px, 525#px } size: { 200 #px, 200 #px } background: #black  rounded: true
            {
            	if(show_legend){
            		
					float y <- 0#px;
					float x<- 0#px;
					float textSize<-10.0;
					float gapBetweenColum<-150#px;	
					draw "Bio Inspired WorkShop - Lyon - Erasme - 2022" at: { x+1400#px, y } color: #white font: font("Helvetica", textSize, #bold);
					float x_logo_offset<-50#px;
					//y<-y+50#px;
					draw image_file(images_logo[0]) at: { x, y } size:{1000#px/4,115#px/4};
	            }
            }
			
		}	*/
	}
}

