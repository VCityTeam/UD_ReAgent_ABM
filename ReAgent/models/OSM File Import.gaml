/**
* Name: OSM file to Agents
* Author:  Arnaud Grignard
* Description: 
* Tags:  
*/
model OSMLoading


global
{

	map filtering <- map(["highway"::["primary", "secondary", "tertiary", "motorway", "living_street", "residential", "unclassified"], "building"::["yes"]]);
	
	map<string,rgb> standard_color_per_type <- 
	["road"::#gamablue,"building"::#gamared,"amenity"::#gamaorange,"natural"::#green, "shop"::#cyan];
	//OSM file to load
	file<geometry> osmfile;

	//compute the size of the environment from the envelope of the OSM file
	geometry shape <- envelope(osmfile);
	
	//UI
	bool show_building<-true;
	bool show_road<-true;
	bool show_amenity<-true;
	bool show_shop<-true;
	bool show_natural<-true;
	bool show_TUI<-true;
	bool show_legend<-true;
	rgb backgroundColor<-#black;
	rgb textcolor<- (backgroundColor = #white) ? #black : #white;
	init
	{
	    //possibility to load all of the attibutes of the OSM data: for an exhaustive list, see: http://wiki.openstreetmap.org/wiki/Map_Features
		create osm_agent from: osmfile with: [highway_str::string(read("highway")), building_str::string(read("building")),amenity_str::string(read("amenity")),natural_str::string(read("natural")),shop_str::string(read("shop"))];

		//from the created generic agents, creation of the selected agents
		ask osm_agent
		{
			if (length(shape.points) = 1 and highway_str != nil)
			{
				create node_agent with: [shape::shape, type::highway_str];
			} else
			{
				if (highway_str != nil)
				{
				    create road with: [shape::shape, type::highway_str];
				} else if (building_str != nil)
				{
					create building with: [shape::shape,type::building_str];
				}
				else if (amenity_str != nil)
				{
					create amenity with: [shape::shape,type::amenity_str];
				}
				else if (natural_str != nil)
				{
					create natural with: [shape::shape,type::natural_str];
				}
				else if (shop_str != nil)
				{
					create shop with: [shape::shape,type::shop_str];
				}

			}
			//do the generic agent die
			do die;
		}
		create TUI{
			location<-{world.shape.width/3,world.shape.height/2};
		}

	}

}

species osm_agent
{
	string highway_str;
	string building_str;
	string amenity_str;
	string natural_str;
	string shop_str;
	string colour;
	
	aspect default
	{
		draw shape color: #gray;
	}
}

species road
{
	rgb color <- rnd_color(255);
	string type;
	aspect default
	{
		draw shape color: standard_color_per_type["road"] width:2;
	}

}

species node_agent
{
	string type;
	aspect default
	{
		draw square(3) color: # red;
	}

}

species building
{   string type;
	aspect default
	{
		draw shape color: standard_color_per_type["building"] border:standard_color_per_type["building"]-100;
	}

}

species amenity
{   string type;
	aspect default
	{
		draw square(10#m) color: standard_color_per_type["amenity"] border: standard_color_per_type["amenity"]-100;
	}

}
species shop
{   string type;
	aspect default
	{
		draw square(10#m) color: standard_color_per_type["shop"] border:standard_color_per_type["shop"]-100;
	}

}

species natural
{   string type;
	aspect default
	{
		draw circle(4#m) color: #green;
	}
}

species TUI{
	
	aspect default
	{
		draw square(750#m) color: #black  wireframe:true border:#black width:4;
	}
}

experiment "Load OSM" type: gui
{
	parameter "File:" var: osmfile <- file<geometry> (osm_file("../includes/map.osm"));
	output
	{
		display map type: opengl background:backgroundColor
		{
			species osm_agent;
			species building visible:show_building;
			species road visible:show_road;
			species amenity visible:show_amenity;
			species shop visible:show_shop;
			species natural visible:show_natural;
			species TUI visible:show_TUI;
			//species node_agent refresh: false;
			event["b"] {show_building<-!show_building;}
			event["r"] {show_road<-!show_road;}
			event["a"] {show_amenity<-!show_amenity;}
			event["s"] {show_shop<-!show_shop;}
			event["n"] {show_natural<-!show_natural;}
			event["t"] {show_TUI<-!show_TUI;}
			graphics 'legend'{
               
			}
			overlay position: { 0 , 0 } size: { 0 #px, 0 #px } background: backgroundColor  transparency:0.0 border: backgroundColor rounded: true
            {
            	if(show_legend){
            		
					float y <- 100#px;
					float x<- 100#px;
					draw "Layers" at: { x, y } color: textcolor font: font("Helvetica", 20, #bold);
					y <- y + 20 #px;
					draw " building(b): " + show_building + " road(r): " + show_road + " amenity(a): " + show_amenity + " shop(s): " + show_shop + " natural(n): " + show_natural + " TUI(t): " + show_TUI  
	            	at: { x, y} color: textcolor font: font("Helvetica", 18, #plain);
	            	y <- y + 30 #px;
					draw "Allowed type" at: { x, y } color: textcolor font: font("Helvetica", 20, #bold);
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


