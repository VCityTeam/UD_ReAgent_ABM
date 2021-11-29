/**
* Name: CityScope
* Based on the internal empty template. 
* Author: arno
* Tags: 
*/


model CityScope

/* Insert your model definition here */

species TUI{
	float size;
	float nbCells;
	
	
	aspect base{
		draw square(size) color:#red wireframe:true;
		loop i from:0 to:nbCells-1{
			loop j from: 0 to:nbCells-1{
				draw square(size/nbCells) color:rnd_color(255)  at:{location.x-(size/2)+(size/nbCells/2)+i*(size/nbCells),location.y-(size/2)+(size/nbCells/2)+j*(size/nbCells)} wireframe:false depth:rnd(5#m);
			}
		}
		
	}
}