/**
* Name: CityScope
* Based on the internal empty template. 
* Author: arno
* Tags: 
*/


model TUI

/* Insert your model definition here */
 
	
species TUI{
	list<image_file> images  <- [image_file('../images/concrete.png'),image_file('../images/metal.png'),image_file('../images/grass.png'),image_file('../images/wood.png'), image_file('../images/glass.png')];
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