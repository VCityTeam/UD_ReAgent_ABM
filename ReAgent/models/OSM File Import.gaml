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
		draw shape color: standard_color_per_type["road"];
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
		draw shape color: standard_color_per_type["building"];
	}

}

species amenity
{   string type;
	aspect default
	{
		draw shape color: standard_color_per_type["amenity"];
	}

}
species shop
{   string type;
	aspect default
	{
		draw shape color: standard_color_per_type["shop"];
	}

}

species natural
{   string type;
	aspect default
	{
		draw circle(1#m) color: #green;
	}
}

experiment "Load OSM" type: gui
{
	parameter "File:" var: osmfile <- file<geometry> (osm_file("../includes/map.osm"));
	output
	{
		display map type: opengl background:#black
		{
			//species osm_agent;
			species building refresh: false;
			species road refresh: false;
			species amenity refresh:false;
			species shop refresh:false;
			species natural refresh:false;
			//species node_agent refresh: false;
			graphics 'legend'{
			  rgb text_color<-#black;
                float y <- 30#px;
                float x<- -150#px;
                
                draw "Allowed type" at: { x, y } color: text_color font: font("Helvetica", 20, #bold);
                y <- y + 30 #px;
                loop type over: standard_color_per_type.keys
                {
                    draw square(10#px) at: { x - 20#px, y } color: standard_color_per_type[type] border: #white;
                    draw type at: { x, y + 4#px } color: text_color font: font("Helvetica", 16, #plain);
                    y <- y + 25#px;
                }
			}
		}

	}

}


