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
	bool reverse <- false;
	bool udpScannerReader <- false; 
	int scan_step <- 3;
	int random_step <- 40;
	int nb_rand_changes <- 4;
	float proba_change_mat <- 0.0;
	bool show_all_materials <- false;
		
	//SIM PARAMETERS
	int people_change_per_step <- 1;
	int people_change_time_interval <- 3;
	float people_speed <- 20.0;
	float transport_proba <- 0.1;
	float material_flow_per_cycle <- 0.1;
	float recycle_probability <- 0.9;
	int transport_cooldown <- 30;
	int transport_update_time <- 40;
	int transport_time <- 40;
	int transport_cycles_per_segment <- 2;
	float line_width <- 20.0;
	float cell_scale_factor <- 0.5;
	
	//SPATIAL PARAMETERS  
	int grid_height <- 8;
	int grid_width <- 8;
	int nb_ids <- 4;
	float environment_height <- 5000.0;
	float environment_width <- 5000.0;
	
	bool load_grid_file_from_cityIO <-false; //parameter: 'Online Grid:' category: 'Simulation' <- false;
	bool load_grid_file <- false;// parameter: 'Offline Grid:' category: 'Simulation'; 
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
	bool init_map <- true;
	

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
		if(udpScannerReader){
			create NetworkingAgent number: 1 {
				 type <-"scanner";	
			     do connect to: url protocol: "udp_server" port: scaningUDPPort ;
			    }
		}
		do create_roads;
		do load_materials;
		do load_buildings_info;
		create legend;
		create stock;
		the_stock <- first(stock);
	}
	
	
	action create_roads{
		list<geometry> lines;
		cell_w <- first(cell).shape.width;
		cell_h <- first(cell).shape.height;
		loop i from: 1 to: grid_width {
			lines << line([{i*cell_w,0}, {i*cell_w,environment_height}]);
		}
		loop i from: 0 to: grid_height {
			lines << line([{0, i*cell_h}, {environment_width,i*cell_h}]);
		}
		float scale <- 1.1*(1 - cell_scale_factor)/2;
		loop i from: 0 to: grid_width-1 {
			loop j from: 0 to: grid_height-1 {
				lines << line([{(i+0.5)*cell_w,j*cell_h}, {(i+0.5)*cell_w,(j+scale)*cell_h}]);
				lines << line([{(i+0.5)*cell_w,(j+1)*cell_h}, {(i+0.5)*cell_w,(j+1-scale)*cell_h}]);
				if i != 0 {lines << line([{i*cell_w,(j+0.5)*cell_h}, {(i+scale)*cell_w,(j+0.5)*cell_h}]);}
				lines << line([{(i+1)*cell_w,(j+0.5)*cell_h}, {(i+1-scale)*cell_w,(j+0.5)*cell_h}]);
			}
		}
		exits <- (lines accumulate(each.points)) where (each.x = 0 or each.y=0 or each.x = environment_width or each.y=environment_height) ;
		//list<geometry> lines2 <- split_lines(lines) accumulate (split_line_in(each,2));
		ask cell{
			exits <- lines accumulate(each.points) where (sqrt((self.location.x-each.location.x)^2+(self.location.y-each.location.y)^2) < cell_w/2);
		}
		//list<geometry> lines3 <-[];
		float x_offset <- scale/2*cell_w;
		float y_offset <- scale/2*cell_h;
		loop i from: 1 to: 2*(grid_width) {
			loop j from: 0 to: 2*(grid_height) {
				if not(mod(i,2)=1 and mod(j,2)=1){
					lines << line([{i*cell_w/2,j*cell_h/2-y_offset}, {i*cell_w/2+x_offset,j*cell_h/2}]);
					lines << line([{i*cell_w/2,j*cell_h/2+y_offset}, {i*cell_w/2+x_offset,j*cell_h/2}]);
					lines << line([{i*cell_w/2,j*cell_h/2-y_offset}, {i*cell_w/2-x_offset,j*cell_h/2}]);
					lines << line([{i*cell_w/2,j*cell_h/2+y_offset}, {i*cell_w/2-x_offset,j*cell_h/2}]);
				}
			}
		}
		
		
		//create road from: lines2+lines3;
		create road from: split_lines(lines);
		the_graph <- as_edge_graph(road);
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
	}
	
//	list<geometry> split_line_in(geometry l, int i){
//		point p1 <- l.points[0];
//		point p2 <- l.points[1];
//		return [line([p1,(p1+p2)/2]),line([p2,(p1+p2)/2])];
//	}
	
	buildings_info get_buildings_info(string s){
		return first(buildings_info where (each.type = s));
	}
	
	
	reflex gridInit when: init_map{
   		int id;
   		if !udpScannerReader{
   			loop i from: 0 to: grid_width-1 {
				loop j from: 0 to: grid_height-1 {
					id_matrix[j,i] <- rnd(nb_ids-1);
					rot_matrix[j,i] <- rnd(3);
				}
			}
			init_map <- false;
   		}else{
   			ask first(NetworkingAgent){
   				do read_scanner;
   				if id_matrix != old_id_matrix{
   					init_map <- false;
   					write "Table initialisée";
   				}
   			}
   		}
		if !init_map {
			loop i from: 0 to: grid_width-1 {
				loop j from: 0 to: grid_height-1 {	
					if id_matrix[j,i] = -1 {id_matrix[j,i]<-0;}	
					string type <- buildings_info[id_matrix[j,i]].type;
					cell[j,i].type <- type;
					cell[j,i].old_type <- type;
					cell[j,i].pop <- get_buildings_info(type).pop;
					cell[j,i].max_pop <- get_buildings_info(type).pop;
					cell[j,i].materials_stock <- copy(get_buildings_info(type).materials_use);
					cell[j,i].max_materials_stock <- copy(get_buildings_info(type).materials_use);
				}
			}
			old_id_matrix <- copy(id_matrix);
		old_rot_matrix <- copy(rot_matrix);
		}
		
	}
	
	reflex randomGridUpdate when: !udpScannerReader and cycle> 0 and !editionMode and !load_grid_file_from_cityIO and every(random_step#cycle){
		//do randomGrid;
		loop times: rnd(nb_rand_changes) {
			int i <- rnd(grid_height-1);
			int j <- rnd(grid_width-1);
			id_matrix[i,j] <- rnd(nb_ids-1);
		}
		if flip(proba_change_mat){
			int i <- rnd(grid_height-1);
			int j <- rnd(grid_width-1);
			rot_matrix[i,j] <- mod(rot_matrix[i,j]+1,3);
		}
		do gridUpdate;
	} 
	
	reflex scanGrid when: udpScannerReader and !init_map and !editionMode and !load_grid_file_from_cityIO and every(scan_step#cycle){
		do gridUpdate;
	} 
	
	action gridUpdate{
//		write cycle;
//		write id_matrix;	
		loop i from: 0 to: grid_height-1{
			loop j from: 0 to: grid_width-1{
				if id_matrix[i,j] != old_id_matrix[i,j] {
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
	int max_timer;
	path the_path;
	list<point> path_points;
	point po;
	point pd;
	
	
	action compute_path{
		point origin_location <- origin=nil?the_stock.location:origin.location;
		point destination_location <- destination=nil?the_stock.location:destination.location;
		po <- origin=nil?origin_location:origin.exits closest_to destination_location;
		pd <- destination=nil?destination_location:destination.exits closest_to origin_location;
		the_path <- the_graph path_between(po,pd); 
		path_points <- [first(first(the_path.edges).points-the_path.edges[1].points),first(inter(first(the_path.edges).points,the_path.edges[1].points))];
		loop r over: the_path.edges-first(the_path.edges){
			path_points << first(r.points-last(path_points));
		}
		max_timer <- max(transport_update_time,length(the_path.edges)*transport_cycles_per_segment);
	}
	
	reflex update {
		timer <- timer+1;
	}
	
	reflex start_transport when: status="init" and timer = max_timer{
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
	
	reflex close when: status="end" and timer = max_timer{
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
			switch status{
				match "init"{
					draw line(first(1+int(floor(timer/transport_cycles_per_segment)),path_points))+line_width color: materials[type];
				}
				match "end"{
					draw line(last(int(floor((max_timer-timer)/transport_cycles_per_segment)),path_points))+line_width color: materials[type];		
				}	
				match "transport"{
					draw line(path_points)+line_width color: materials[type];
					draw the_path.edges[mod(timer,length(the_path.edges))]+line_width color: rgb(200,200,200);
				}		
			} 
		}	
		if show_all_materials and type != materials.keys[current_material]{
			int offset <- 1+index_of(materials.keys-materials.keys[current_material],type);
			draw line(path_points collect (each+{2,2}+{1,1}*(line_width)*offset)) color: materials[type];
		}
	}
}


grid cell width: grid_width height: grid_height { 
	string type;
	string old_type;
	int pop;
	int max_pop;
	int incoming_people <- 0;
	map<string,int> materials_stock;
	map<string,int> max_materials_stock;
	list<transport> transports <- [];
	int transport_cooldown <- world.transport_cooldown;

	list<point> exits <- [];
	string status <- "idle" among: ["idle", "destruction", "construction"];
	int time_counter <- 0;
	
	int material_flow(string m){	
		return transports count (each.type = m and each.destination = self)-transports count (each.type = m and each.origin = self);
	}
	
	reflex end_construction when: status = "construction" and sum(materials.keys collect(abs(materials_stock[each]-max_materials_stock[each]))) = 0{
		status <- "idle";
		max_pop <- world.get_buildings_info(type).pop;
	}
	
	reflex when: status= "construction"{
		if transport_cooldown >0{
			transport_cooldown <- transport_cooldown - 1;
		}else{
			loop m over: materials.keys{
				if (materials_stock[m]+material_flow(m)<max_materials_stock[m]) and flip(0.2){
					transport_cooldown <- world.transport_cooldown;
					create transport{
						destination <- myself;
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
	}
	
	reflex end_destruction when: status = "destruction" and sum(materials_stock.values) = 0{
		status <- "construction";
		old_type <- type;
		max_materials_stock <- copy(world.get_buildings_info(type).materials_use);
	}
	
	reflex destruct when: status = "destruction" and pop=0 {
		if transport_cooldown >0{
			transport_cooldown <- transport_cooldown - 1;
		}else{
			loop m over: materials.keys{
				if (materials_stock[m]+material_flow(m)>0) and flip(0.2){
			//	if (materials_stock[m]+material_flow(m)>0) {
					transport_cooldown <- world.transport_cooldown;
					create transport{
						//write 	myself.materials_stock[m]+myself.material_flow(m);
						origin <- myself;
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
		if type != t{
			switch status{
				match "destruction" {
					if type = old_type{
						status <- "construction";
						max_pop <- pop;
						max_materials_stock <- copy(null_map);
					}		
				}
				match "construction" {
					old_type <- type;
					status <- "destruction";
					max_pop <- 0;
					max_materials_stock <- copy(null_map);
				}
				match "idle"{
					old_type <- type;
					status <- "destruction";
					max_pop <- 0;
					max_materials_stock <- copy(null_map);
				}
			}
			type <- t;	
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
				draw ""+materials_stock[materials.keys[i]]  color:materials.values[i] font:font("SansSerif", 10, #bold) at: location + {100,-80.0+i*y_offset,0};
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
	
		aspect default3D{
		if show_cells {		
			draw shape scaled_by (cell_scale_factor) color: world.get_buildings_info(type).color depth:pop*70;
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
	rgb color <- #white; //rnd_color(256);
	
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
		draw circle(20) color: color;
		//draw circle(50) color: color at: target;
	}
	
}

species road{	
	aspect default{
		draw shape color: #red;
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
	point location <- {-100,100};
	point location_3D <- {0,3500};	
	point location_reverse <- {6250,3000};
	float y_offset <- 160.0;
	float y_offset_3D <- 10.0;
	
	reflex update_legend{
		total_pop <- sum(cell collect each.pop);
	}
	
	aspect default {
		y_offset <- 160.0;
		draw "Pop: "+total_pop+" (+"+the_stock.people_in+"/-"+the_stock.people_out+")"  color:#white font:font("SansSerif", 16, #bold) at: location + {-15,0.0,0};
		loop i from: 0 to: length(materials.keys)-1{
			string m <- materials.keys[i];
			draw ""+m+" In: "+the_stock.materials_in[m]+" Out:"+the_stock.materials_out[m]+" Recyc.:"+the_stock.materials_recycle[m]  color:#white font:font("SansSerif", 16, #bold) at: location + {-15,(i+1)*y_offset,0};
			
		}
		
	}
	
	
	aspect map3D {
		draw "Pop: "+total_pop+" (+"+the_stock.people_in+"/-"+the_stock.people_out+")"  color:#white font:font("SansSerif", 16, #bold) at: location_3D + {-15,0.0,0} rotate: 90;
		loop i from: 0 to: length(materials.keys)-1{
			string m <- materials.keys[i];
			draw ""+m+" In: "+the_stock.materials_in[m]+" Out:"+the_stock.materials_out[m]+" Recyc.:"+the_stock.materials_recycle[m]  color:#white font:font("SansSerif", 16, #bold) at: location_3D + {-15,0}*(i+1)*y_offset_3D rotate: 90;
			
		}
		
	}
	
	aspect reverse {
		draw "Pop: "+total_pop+" (+"+the_stock.people_in+"/-"+the_stock.people_out+")"  color:#white font:font("SansSerif", 20, #bold) at: location_reverse + {-15,0.0,0} rotate:180;
		loop i from: 0 to: length(materials.keys)-1{
			string m <- materials.keys[i];
			draw ""+m color:#white font: font("SansSerif", 20, #bold) at: location_reverse + {-15,-(2.5*i+1.5)*y_offset,0} rotate:180;
			draw "In: "+the_stock.materials_in[m]+" Out:"+the_stock.materials_out[m]+" Recyc.:"+the_stock.materials_recycle[m]  color:#white font:font("SansSerif", 18, #bold) at: location_reverse + {-15,-(2.5*i+2.5)*y_offset,0} rotate:180;
			
		}
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
	 			
/* 	 			loop i from:0 to:nbrows-1{
	 				loop j from:0 to: nbcols-1{
	 					if (m at (i*(2*nbcols-1)*4+4*j) = 'x'){
	 					  id_matrix[j,i]<-old_id_matrix[j,i];
	 					  rot_matrix[j,i]<-old_rot_matrix[j,i];	
	 					}else{
	 					  id_matrix[j,i]<-int(m at (i*(2*nbcols-1)*4+4*j));
	 					  rot_matrix[j,i]<-int(m at (i*(2*nbcols-1)*4+4*j+1));
	 					 }
	 				} 						
	 			}*/
	 			loop i from:0 to:nbrows-1{
	 				loop j from:0 to: nbcols-1{
	 					int i2 <- reverse?nbrows-1-i:i;
	 					int j2 <- reverse?nbcols-1-j:j;
	 					if (m at (i2*(2*nbcols-1)*4+4*j2) = 'x'){
	 					  id_matrix[j2,i2]<-old_id_matrix[j2,i2];
	 					  rot_matrix[j2,i2]<-old_rot_matrix[j2,i2];	
	 					}else{
	 					  id_matrix[j2,i2]<-int(m at (i*(2*nbcols-1)*4+4*j));
	 					  rot_matrix[j2,i2]<-int(m at (i*(2*nbcols-1)*4+4*j+1));
	 					 }
	 				} 						
	 			}
 			
 			}		
		} 
	} 
}


experiment Screen type: gui autorun: true{
	float minimum_cycle_duration <- 0.05;
	parameter "Show all materials" var: show_all_materials;
	output {
		display map synchronized:true background:blackMirror ? #black :#white toolbar:false type:java2D  draw_env:false {
		species transport transparency: 0.6;
	  	species cell aspect: default;// refresh: on_modification_cells;
	  	species legend aspect: default;
//	  	species road aspect: default;
	//  	species people aspect: default;
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

experiment Table type: gui autorun: true{
	float minimum_cycle_duration <- 0.05;
	output {
		display map synchronized:true background:blackMirror ? #black :#white toolbar:false type:opengl  draw_env:false fullscreen:1 
		keystone: [{0.019187119147278664,0.10842932477222667,0.0},{-0.03837423829455741,0.9626105776647494,0.0},{0.9894470844689967,0.9401769242635991,0.0},{0.925170235325613,0.09098092768244315,0.0}]
		{
		species transport transparency: 0.6;
	  	species cell aspect: default;// refresh: on_modification_cells;
	  	species legend aspect: reverse;
//	  	species road aspect: default;
	  	//species people aspect: default;
	  	species stock aspect: default;
	   
		}	
		display map3D synchronized:true background:blackMirror ? #black :#white toolbar:false type:opengl  draw_env:false fullscreen:0 rotate:90
		camera_location: {-996.391,7152.6832,5502.6118} camera_target: {2365.0787,2691.8624,-281.1955} camera_orientation: {0.4329,0.5745,0.6947}
		{
		species transport transparency: 0.6;
	  	species cell aspect: default3D transparency:0.5;// refresh: on_modification_cells;
	  	species legend aspect: map3D;
//	  	species road aspect: default;
	  	species people aspect: default;
	  	species stock aspect: default;
	   
			
		}	
	}
}



