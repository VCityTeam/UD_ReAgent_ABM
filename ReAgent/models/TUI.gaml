/**
* Name: CityScope
* Based on the internal empty template. 
* Author: arno
* Tags: 
*/


model TUI

import 'LaunchPad Event Layer.gaml'

/* Insert your model definition here */
global{
	list<image_file> images  <- [image_file('../images/concrete.png'),image_file('../images/metal.png'),image_file('../images/grass.png'),image_file('../images/wood.png'), image_file('../images/glass.png')];
	
	map<string,image_file> cell_to_texture <-[buttonColors[0]::images[0],buttonColors[1]::images[1],buttonColors[2]::images[2],buttonColors[3]::images[3],buttonColors[4]::images[4]];
	
	init{
		do createBlockFromGrid;
	}
	
	action createBlockFromGrid{
		ask block{
			do die;
		}
		ask cell {		
			create block{
				location<-myself.location;
				color<-myself.color;
				grid_x<-myself.grid_x;
				grid_y<-myself.grid_y;
			}
		}
	}
	reflex updateBlock{
		do createBlockFromGrid;
	}
} 
	
species TUI{
	float size;
	float nbCells;
	
	aspect base{
		draw square(size) color:#black;
		loop i from:0 to:nbCells-1{
			loop j from: 0 to:nbCells-1{
				//draw square(size/nbCells) color:rnd_color(255)  at:{location.x-(size/2)+(size/nbCells/2)+i*(size/nbCells),location.y-(size/2)+(size/nbCells/2)+j*(size/nbCells)} wireframe:false depth:rnd(5#m);
				draw images at (rnd(4)) size:{size/nbCells*0.95,size/nbCells*0.95} /*color:#white*/  at:{location.x-(size/2)+(size/nbCells/2)+i*(size/nbCells),location.y-(size/2)+(size/nbCells/2)+j*(size/nbCells)} wireframe:false depth:rnd(5#m);
			}
		}
	}
}

species block{
	string color_type;
	rgb color;
	int grid_x;
	int grid_y;
	aspect base{
		//draw square(10) color:color;
		draw cell_to_texture[string(color)] size:10;
	}
}

experiment CityScope type: gui
{
	output
	{
		display View_change_color toolbar:false background:#black
		{
			//grid cell border: #black;
			//species TUI aspect:base;
			species block aspect:base;
			event "pad_down" type: "launchpad" action: updateGrid;
		}
	}
}