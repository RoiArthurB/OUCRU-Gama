/***
* Name: building
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model building

global {
	/** Insert the global definitions, variables and actions here */
	file shape_file_buildings <- file("../../includes/building.shp");
	init {
		create building from: shape_file_buildings;
	}
}

species building {
	aspect geom {
		draw shape color: #gray;
	}
}

experiment main type: gui {
	/** Insert here the definition of the input and output of the model */
	parameter "Shapefile for the buildings:" var: shape_file_buildings category: "GIS" ;

	output {
		display map {
			species building aspect:geom;
		}
	} 
}