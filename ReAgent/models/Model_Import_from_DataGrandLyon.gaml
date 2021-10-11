/**
* Name: ReAgent https://download.data.grandlyon.com/wms/grandlyon
* Author:  Arnaud Grignard
* Description: Initialize a set of district from a GEOJSON FIle. 
* Tags:  l
*/

model lyon_reagent   

global {
	file district_file <- geojson_file("https://download.data.grandlyon.com/wfs/grandlyon?SERVICE=WFS&VERSION=2.0.0&request=GetFeature&typename=adr_voie_lieu.adrarrond&outputFormat=application/json;%20subtype=geojson&SRSNAME=EPSG:4171");
    file metro_file <- geojson_file("https://download.data.grandlyon.com/wfs/rdata?SERVICE=WFS&VERSION=2.0.0&request=GetFeature&typename=tcl_sytral.tcllignemf_2_0_0&outputFormat=application/json;%20subtype=geojson&SRSNAME=EPSG:4171");
    graph the_graph;

	geometry shape <- envelope(district_file);
	init {
		create district from: district_file with: [name::read("nom")];
		create metroLine from: metro_file with: [name::read("ligne")];
		the_graph <- as_edge_graph(metroLine);
		create people number: 100{
			location<-any_location_in(one_of(metroLine));
		}
	}
} 

species district {
	rgb color <- rnd_color(255);
	
	aspect default {
		draw shape color: color border:color.darker ;
		draw name font: font("Helvetica", 12, #bold) color: color.brighter at: location + {0,0,0.01};
	}
}

species metroLine {
	rgb color <- rnd_color(255);
	
	aspect default {
		draw shape color: color border:color.darker width:4 ;
		draw name font: font("Helvetica", 12, #bold) color: metro_file at: location + {0,0,0.01};
	}
}

species people skills:[moving] {

	reflex move {
		do wander  speed:0.001 ; 
	}
	
	aspect default {
		draw circle(world.shape.width*0.001) color: color border: #black;
	}
}




experiment Display  type: gui {
	output {
		display Lyon type: opengl{	
			species district;	
			species metroLine;	
			species people;
		}
	}
}
