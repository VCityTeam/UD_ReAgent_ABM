/***
* Name: Urbam
* Author: Arno, Pat et Tri
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Urbam
	

//import "common model.gaml"
global{
	bool blackMirror parameter: 'Dark Room' category: 'Aspect' <- true;
	
	//SPATIAL PARAMETERS  
	int scan_step <- 30;
	int people_change_per_step <- 1;
	int people_change_time_interval <- 3;
	float people_speed <- 20.0;
	float transport_proba <- 0.1;
	int grid_height <- 8;
	int grid_width <- 8;
	int nb_ids <- 4;
	float environment_height <- 5000.0;
	float environment_width <- 5000.0;
	float cell_scale_factor <- 0.5;
	float material_flow_per_cycle <- 0.1;
	float recycle_probability <- 0.9;
	int transport_time <- 20;
	float line_width <- 20.0;
	
	bool load_grid_file_from_cityIO <-false; //parameter: 'Online Grid:' category: 'Simulation' <- false;
	bool load_grid_file <- false;// parameter: 'Offline Grid:' category: 'Simulation'; 
	bool udpScannerReader <- false; 
	bool editionMode <-false;

	
	bool show_cells parameter: 'Show cells:' category: 'Aspect' <- true;

	bool on_modification_cells <- false update: show_cells != show_cells_prev;
	
	bool show_cells_prev <- show_cells update: show_cells ;
	bool on_modification_bds <- false update: false;
	
	string cityIOUrl;

	map<string, rgb> building_colors <- ["R1"::rgb(100,255,100),"R2"::rgb(0,255,0),"C1"::rgb(100,100,255),"C2"::rgb(0,0,255)];
	
	map<string,rgb> materials <- [];
	map<string,int> null_map <- [];
	matrix<int> id_matrix <- matrix_with({grid_height,grid_width},0);
	matrix<int> old_id_matrix <- matrix_with({grid_height,grid_width},0);
	matrix<int> rot_matrix <- matrix_with({grid_height,grid_width},0);
	matrix<int> old_rot_matrix <- matrix_with({grid_height,grid_width},0);
	list<point> exits <- [];
	graph the_graph;
	stock the_stock;
	int current_material <- 0;
	

//	string imageFolder <- "../images/flat/";
	string imageRemploiFolder <- "../images/images_reemploi/";
	file materials_file <- csv_file("../includes/materials.csv",",");
	file buildings_info_file <- csv_file("../includes/buildings_info.txt"," ");
	
	float cell_w;
	float cell_h;

	int file_cpt <- 1;


	geometry shape<-rectangle(environment_width, environment_height); // one edge is 5000(m)


	
	// Network
	int scaningUDPPort <- 5000;
	int interfaceUDPPort <- 9878;
	string url <- "localhost";
	
	init {
		cityIOUrl <- "https://cityio.media.mit.edu/api/table/urbam";
		do load_materials;
		do load_buildings_info;
		do randomGridInit;
		
		list<geometry> lines;
		cell_w <- first(cell).shape.width;
		cell_h <- first(cell).shape.height;
		loop i from: 0 to: grid_width {
			lines << line([{i*cell_w,0}, {i*cell_w,environment_height}]);
		}
		loop i from: 0 to: grid_height {
			lines << line([{0, i*cell_h}, {environment_width,i*cell_h}]);
		}
		float scale <- (1 - cell_scale_factor)/2;
		loop i from: 0 to: grid_width-1 {
			loop j from: 0 to: grid_height-1 {
				lines << line([{(i+0.5)*cell_w,j*cell_h}, {(i+0.5)*cell_w,(j+scale)*cell_h}]);
				lines << line([{(i+0.5)*cell_w,(j+1)*cell_h}, {(i+0.5)*cell_w,(j+1-scale)*cell_h}]);
				lines << line([{i*cell_w,(j+0.5)*cell_h}, {(i+scale)*cell_w,(j+0.5)*cell_h}]);
				lines << line([{(i+1)*cell_w,(j+0.5)*cell_h}, {(i+1-scale)*cell_w,(j+0.5)*cell_h}]);
			}
		}
		exits <- (lines accumulate(each.points)) where (each.x = 0 or each.y=0 or each.x = environment_width or each.y=environment_height) ;
//		loop l over: lines {
//			do split_line_in(l,2);
//		}
		list<geometry> lines2 <- split_lines(lines) accumulate (split_line_in(each,2));
		ask cell{
		//	list<point> tmp <- lines accumulate(each.points);
			exits <- lines accumulate(each.points) where (sqrt((self.location.x-each.location.x)^2+(self.location.y-each.location.y)^2) < cell_w/2);
		}

		create legend;
		create stock;
		the_stock <- first(stock);
		
		
		
//		create road from: split_lines(lines);
		create road from: lines2;
		the_graph <- as_edge_graph(road);

		if(udpScannerReader){
			create NetworkingAgent number: 1 {
				 type <-"scanner";	
			     do connect to: url protocol: "udp_server" port: scaningUDPPort ;
			    }
			}
		}
	
	action load_materials {
		matrix data <- matrix(materials_file);
		loop i from: 0 to: data.rows -1{
			materials << data[0,i]::rgb(data[1,i],data[2,i],data[3,i]);
		}
		loop m over: materials.keys{
			null_map << m::0;
		}	 
	}
	
	action load_buildings_info {
		matrix data <- matrix(buildings_info_file);
		int i <-0;
		loop while: i<data.rows -1{
			if data[0,i] = "<building>"{
				i<-i+1;
				create buildings_info returns: bi;
				loop while: data[0,i] != "</building>"{
					switch data[0,i] {
						match "type" {bi[0].type <- data[1,i];}
						match "color" {bi[0].color <- rgb(data[1,i],data[2,i],data[3,i]);}
						match "pop" {bi[0].pop <- int(data[1,i]);}
						default {
							if data[0,i] in materials.keys {
								bi[0].materials_use << data[0,i]::int(data[1,i]);	
							} else {
								write "Warning, material "+data[0,i]+" not in material list. Should be among: "+materials.keys;	
							}
						}
					}
					i <-i+1;
				}
				loop m over: materials.keys{
					if m in bi[0].materials_use.keys = false{
						bi[0].materials_use <- bi[0].materials_use + map(m::0);
					} 
				}
			}
			i<-i+1;
		}
//		create buildings_info returns: bi;
//		bi[0].type <- "WIP";
//		bi[0].pop <- 0;
	}
	
	list<geometry> split_line_in(geometry l, int i){
		point p1 <- l.points[0];
		point p2 <- l.points[1];
		return [line([p1,(p1+p2)/2]),line([p2,(p1+p2)/2])];
	}
	
	buildings_info get_buildings_info(string s){
		return first(buildings_info where (each.type = s));
	}
	
	reflex randomGridUpdate when: cycle> 0 and !udpScannerReader and !editionMode and !load_grid_file_from_cityIO and every(scan_step#cycle){
		do randomGrid;
	} 
	
	action randomGridInit{
   		int id;
   		if !udpScannerReader{
   			loop i from: 0 to: grid_width-1 {
				loop j from: 0 to: grid_height-1 {
					id_matrix[j,i] <- rnd(nb_ids-1);
					rot_matrix[j,i] <- rnd(3);
				}
			}
   		}else{
   			ask first(NetworkingAgent){
   				do read_scanner;
   			}
   		}
		
		loop i from: 0 to: grid_width-1 {
			loop j from: 0 to: grid_height-1 {		
				string type <- buildings_info[id_matrix[j,i]].type;
				cell[j,i].type <- type;
				cell[j,i].pop <- get_buildings_info(type).pop;
				cell[j,i].max_pop <- get_buildings_info(type).pop;
				cell[j,i].materials_stock <- copy(get_buildings_info(type).materials_use);
				cell[j,i].max_materials_stock <- copy(get_buildings_info(type).materials_use);
			}
		}
		old_id_matrix <- copy(id_matrix);
		old_rot_matrix <- copy(rot_matrix);
	}
	
	action randomGrid{
		if !udpScannerReader{
			loop times: 5 {
				int i <- rnd(grid_height-1);
				int j <- rnd(grid_width-1);
				id_matrix[i,j] <- rnd(nb_ids-1);
			}
			if flip(0.3){
				int i <- rnd(grid_height-1);
				int j <- rnd(grid_width-1);
				rot_matrix[i,j] <- mod(rot_matrix[i,j]+1,3);
			}
		}
	
		
		loop i from: 0 to: grid_height-1{
			loop j from: 0 to: grid_width-1{
				if id_matrix[i,j] = -1 {
					id_matrix[i,j] <- old_id_matrix[i,j];
				}
				if id_matrix[i,j] != old_id_matrix[i,j]{
					ask cell[i,j] {do changeTo(buildings_info[id_matrix[j,i]].type);}
				}
			}
		}
		
		if old_rot_matrix!=rot_matrix{
			current_material <- mod(current_material+1,length(materials.keys));
			write "Changement de matériau : "+materials.keys[current_material];
		}
		
		old_id_matrix <- copy(id_matrix);
		old_rot_matrix <- copy(rot_matrix);
		//ask 6 among cell {do changeTo(one_of(buildings_info).type);}
	}
	
	action load_cityIO_v2_urbam(string cityIOUrl_) {
		
	}
		
}















species buildings_info {
	string type;
	rgb color <- #black;
	int pop <- 0;
	map<string,int> materials_use <- [];
}

species transport{
	cell origin <- nil;
	cell destination <- nil;
	string status <- "init" among: ["init","transport","end"];
	int timer <- 0;
	string type;
	int creation_time;
	path the_path;
	point po;
	point pd;
	
	action compute_path{
		point origin_location <- origin=nil?the_stock.location:origin.location;
		point destination_location <- destination=nil?the_stock.location:destination.location;
		po <- origin=nil?origin_location:origin.exits closest_to destination_location;
		pd <- destination=nil?destination_location:destination.exits closest_to origin_location;
		the_path <- the_graph path_between(po,pd); 
	}
	
	reflex update {
		timer <- timer+1;
	}
	
	reflex start_transport when: status="init" and timer = transport_time{
		if origin !=nil {
			origin.materials_stock[type] <- origin.materials_stock[type] - 1;
			origin.transports >> self;
		}else{
			put the_stock.materials_in[type]+1 at: type in: the_stock.materials_in;
		}
		status <- "transport";
		timer <- 0;
	}
	
	reflex end_transport when: status="transport" and timer = length(the_path.edges){
		status <- "end";
		timer <- 0;
	}
	
	reflex close when: status="end" and timer = transport_time{
		if destination !=nil {
			destination.materials_stock[type] <- destination.materials_stock[type] + 1;
			destination.transports >> self;
			if origin != nil {
				put the_stock.materials_recycle[type]+1 at: type in: the_stock.materials_recycle;
			}
		}else{
			put the_stock.materials_out[type]+1 at: type in: the_stock.materials_out;
		}
		do die;
	}
	
	
	aspect default{
//		point p1 <- origin=nil?first(stock).location:origin.location;
//		point p2 <- destination=nil?first(stock).location:destination.location;
//		draw line([p1,p2]) color: materials[type];
//		draw circle(20) at: po color: #green;
//		draw circle(20) at: pd color: #red;
		if type = materials.keys[current_material]{
			loop e over: the_path.edges {
				draw e+line_width color: materials[type];
			}
			switch status{
				match "init"{
					draw first(the_path.edges)+line_width color: blend(#white,materials[type], timer/transport_time);
				}
				match "end"{
					draw last(the_path.edges)+line_width color: blend(materials[type],#white, timer/transport_time);
				}	
				match "transport"{
					draw the_path.edges[timer]+line_width color: #white;
				}		
			} 
		}
		
	}
}


grid cell width: grid_width height: grid_height { 
	string type;
	string next_type;
	int pop;
	int max_pop;
	int incoming_people <- 0;
	map<string,int> materials_stock;
	map<string,int> max_materials_stock;
	list<transport> transports <- [];

	list<point> exits <- [];
	string status <- "idle" among: ["idle", "destruction", "construction"];
	int time_counter <- 0;
	
	int material_flow(string m){	
//		return sum(transports where (each.type = m and each.destination = self) collect (each.quantity))-sum(transports where (each.type = m and each.origin = self) collect (each.quantity));
		return transports count (each.type = m and each.destination = self)-transports count (each.type = m and each.origin = self);
	}
	
	reflex end_construction when: status = "construction" and sum(materials.keys collect(abs(materials_stock[each]-max_materials_stock[each]))) = 0{
		status <- "idle";
		max_pop <- world.get_buildings_info(type).pop;
	}
	
	reflex when: status= "construction"{
			loop m over: materials.keys{
			if (materials_stock[m]+material_flow(m)<max_materials_stock[m]) and flip(0.2){
				create transport{
					destination <- myself;
					creation_time <- cycle;
					myself.transports << self;
					type <- m;
					list<cell> possible_sources <-[];
					loop c over: cell{
						if (c.materials_stock[m]+c.material_flow(m) > c.max_materials_stock[m]){
							possible_sources << c;
						}
					}		
				//	list<cell> possible_dest <- cell where (each.materials_stock[m]+each.material_flow(m) < each.max_materials_stock[m]);
				//	list<cell> possible_dest <- cell where (each.materials_stock[m]< each.max_materials_stock[m]);
				//	write "dests "+possible_dest;
					
					if !empty(possible_sources-myself) and flip(recycle_probability){
						try{
						origin <- possible_sources closest_to myself;
						origin.transports << self;
						}catch{
							write "erreur";
							write int(myself);
							write "set: "+possible_sources;
							write "destination: "+destination;
						}
					}
					do compute_path;

				}
			}
			
		}
	}
	
	reflex end_destruction when: status = "destruction" and sum(materials_stock.values) = 0{
		status <- "construction";
		type <- next_type;
		max_materials_stock <- copy(world.get_buildings_info(type).materials_use);
	}
	
	reflex destruct when: status = "destruction" and pop=0{
		loop m over: materials.keys{
			if (materials_stock[m]+material_flow(m)>0) and flip(0.2){
				create transport{
					//write 	myself.materials_stock[m]+myself.material_flow(m);
					origin <- myself;
					creation_time <- cycle;
					myself.transports << self;
					type <- m;
					list<cell> possible_dest <-[];
					loop c over: cell{
						if (c.materials_stock[m]+c.material_flow(m) < c.max_materials_stock[m]){
							possible_dest << c;
						}
					}		
				//	list<cell> possible_dest <- cell where (each.materials_stock[m]+each.material_flow(m) < each.max_materials_stock[m]);
				//	list<cell> possible_dest <- cell where (each.materials_stock[m]< each.max_materials_stock[m]);
				//	write "dests "+possible_dest;
					
					if !empty(possible_dest-myself) and flip(recycle_probability){
						try{
						destination <- possible_dest closest_to myself;
						destination.transports << self;
						}catch{
							write "erreur";
							write int(myself);
							write "set: "+possible_dest;
							write "destination: "+destination;
						}
					}
					do compute_path;

				}
			}
			
		}
	}
	
	reflex elapse_time when: time_counter > 0{
		time_counter <- time_counter - 1;
	}
	
	reflex change_pop when: time_counter = 0{
		if pop+incoming_people > max_pop{
			time_counter <- people_change_time_interval;
			int nb_change <- min(people_change_per_step, pop-max_pop);
			create people number: nb_change{
				myself.pop <- myself.pop - 1;
				location <- one_of(myself.exits);
				list<cell> free_space <- cell where (each.pop+each.incoming_people < each.max_pop);
				if length(free_space)>0 {
					cell_target <- one_of(free_space);
					target <- one_of(cell_target.exits);
					cell_target.incoming_people <- cell_target.incoming_people+1;
				}else{
					target <- exits closest_to self;
				}	
			}
		}else{
			time_counter <- people_change_time_interval;
			int nb_change <- min(people_change_per_step, max_pop-pop-incoming_people);
			create people number: nb_change{
				location <- one_of(exits);
				cell_target <- myself;
				target <- one_of(myself.exits);
				the_stock.people_in <- the_stock.people_in + 1;
			}
		}
	}
	
	action changeTo(string t){
		switch status{
			match "destruction" {
				next_type <- t;
				if type = t{
					status <- "construction";
					max_pop <- pop;
					max_materials_stock <- copy(null_map);
				}
			}
			match "construction" {
				if next_type != t{
					next_type <- t;
					status <- "destruction";
					max_pop <- 0;
					max_materials_stock <- copy(null_map);
				}
			}
			match "idle"{
				if type != t{
					next_type <- t;
					status <- "destruction";
					max_pop <- 0;
					max_materials_stock <- copy(null_map);
				}
			}
		}
	}
	

	
	
	
	aspect default{
		if show_cells {		
			draw shape scaled_by (cell_scale_factor) color: world.get_buildings_info(type).color;
			if status = "destruction" {
				draw line([location-{cell_w/4,cell_h/4}*cell_scale_factor,location+{cell_w/4,cell_h/4}*cell_scale_factor]) color: #red;
				draw line([location+{-cell_w/4,cell_h/4}*cell_scale_factor,location+{cell_w/4,-cell_h/4}*cell_scale_factor]) color: #red;
			}
			if status = "construction" {
				draw polygon([{-20,50}+location, {20,50}+location,{20,-20}+location,{40,-20}+location,{0,-100}+location,{-40,-20}+location,{-20,-20}+location,{-20,50}+location]) color: #blue;
			}
			draw ""+pop  color:#white font:font("SansSerif", 10, #bold) at: location - {140,60.0,0};
			float y_offset <- 80.0;
			//int i <- 0;
			loop i from: 0 to: length(materials.keys) - 1{
				draw ""+materials_stock[materials.keys[i]]  color:materials.values[i] font:font("SansSerif", 10, #bold) at: location + {30,-80.0+i*y_offset,0};
				i <- i+1;
			}
//			loop i from: 0 to: length(materials.keys) - 1{
//				draw ""+(materials_stock[materials.keys[i]]+material_flow(materials.keys[i]))  color:materials.values[i] font:font("SansSerif", 10, #bold) at: location + {100,-80.0+i*y_offset,0};
//				i <- i+1;
//			}
//			loop i over: exits{
//				draw circle(10) at: i.location color: #red;
//			}
		}
		
	}

}

species people skills: [moving]{
	point target;
	cell cell_target;
	float speed <- people_speed;
	
	reflex 	move {
		do goto target: target on: the_graph recompute_path: false;
		if self.location = target {
			if cell_target != nil{
				cell_target.pop <- cell_target.pop + 1;
			} else {
				the_stock.people_out <- the_stock.people_out + 1;
			}
			do die;
		}
	}
	
	aspect default{
		draw circle(10) color: #white;
	}
	
}

species road{	
	aspect default{
//		draw shape color: #grey;
	}
}

species stock{
	point location <- {0,environment_height/2};
	int people_in <-0;
	int people_out <- 0;
	map<string,int> materials_in <- copy(null_map);
	map<string,int> materials_out <- copy(null_map);
	map<string,int> materials_recycle <- copy(null_map);
	
	aspect default{
		//draw circle(50) color: #purple at: location;
	}
}

species legend {
	int total_pop <- 0;
	point location <- {-100,1000};
	float y_offset <- 140.0;
	
	reflex update_legend{
		total_pop <- sum(cell collect each.pop);
	}
	
	aspect default {
		draw "Pop: "+total_pop+" (+"+the_stock.people_in+"/-"+the_stock.people_out+")"  color:#white font:font("SansSerif", 16, #bold) at: location + {-15,0.0,0};
		loop i from: 0 to: length(materials.keys)-1{
			string m <- materials.keys[i];
			draw ""+m+" In: "+the_stock.materials_in[m]+" Out:"+the_stock.materials_out[m]+" Recyc.:"+the_stock.materials_recycle[m]  color:#white font:font("SansSerif", 16, #bold) at: location + {-15,(i+1)*y_offset,0};
			
		}
	//	draw "Bois In: "+the_stock.materials_in["bois"]+" Out:"+the_stock.materials_out["bois"]+" Recyc.:"+the_stock.materials_recycle["bois"]  color:#white font:font("SansSerif", 16, #bold) at: location + {-15,140.0,0};

	}
}


species NetworkingAgent skills:[network] {
	string type;
	string previousMess <-"";
	
	reflex update_landuse when: type = "scanner"{
		do read_scanner;
	}
		
	action read_scanner {
		if has_more_message() { 
			list<list<int>> scan_result <- [];    
		    
		    if (length(mailbox) > 0) {
				message mes <- fetch_message();	
	 			string m <- string(mes.contents);	 			
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
 			
 			}		
		} 
	} 
}


experiment ReUse type: gui autorun: true{
	float minimum_cycle_duration <- 0.05;
	output {
		display map synchronized:true background:blackMirror ? #black :#white toolbar:false type:java2D  draw_env:false {
		species transport transparency: 0.6;
	  	species cell aspect: default;// refresh: on_modification_cells;
	  	species legend aspect: default;
	  	species road aspect: default;
	  	species people aspect: default;
	  	species stock aspect: default;

			
			/*graphics "landuse" {
					point hpos <- {world.shape.width * 1.1, world.shape.height * 1.1};
					float barH <- world.shape.width * 0.01;
					float factor <-  world.shape.width * 0.1;
					loop i from:0 to:length(color_per_id)-1{
						draw square(world.shape.width*0.02) empty:false color: color_per_id.values[i] at: {i*world.shape.width*0.175+world.shape.width*0.05, 75};
						draw fivefoods[i] color: color_per_id.values[i] at: {i*world.shape.width*0.175+world.shape.width*0.025+world.shape.width*0.05, 100} perspective: true font:font("Helvetica", 20 , #bold);
					}
			}*/
		}		
	}
}

