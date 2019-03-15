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