/***
* Name: main
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model main

import "src/building.gaml"
import "src/road.gaml"

global {
	/** Insert the global definitions, variables and actions here */

	geometry shape <- envelope(shape_file_roads);
}


experiment main type: gui {
	/** Insert here the definition of the input and output of the model */
/*
	output {
		display map {
			species building aspect:geom;
			species road aspect:geom;
		}
	} */
}