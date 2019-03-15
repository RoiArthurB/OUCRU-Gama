/***
* Name: road
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model road

global {
	/*
	 * PARAMETERS
	 */
	file shape_file_roads <- file("../../includes/road.shp");

	/*
	 * INIT
	 */
	action initRoad {
		create Road from: shape_file_roads;
	}
}

species Road {
	/*
	 * Variables
	 */
	rgb color <- #black ;
	
	/*
	 * Display
	 */
	aspect geom {
		draw shape color: color;
	}
}
