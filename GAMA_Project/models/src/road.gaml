/***
* Name: road
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model road

global {
	/** Insert the global definitions, variables and actions here */   
	file shape_file_roads <- file("../../includes/road.shp");
	init {
		create road from: shape_file_roads;
	}
}

species road {
	aspect geom {
		draw shape color: #black;
	}
}

experiment main type: gui {
	/** Insert here the definition of the input and output of the model */
	parameter "Shapefile for the roads:" var: shape_file_roads category: "GIS" ;

	output {
		display map {
			species road aspect:geom;
		}
	}
}
