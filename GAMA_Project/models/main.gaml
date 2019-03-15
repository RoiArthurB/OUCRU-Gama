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
	/** 
	 * World parameters
	 */
	geometry shape <- envelope("../includes/bounds.shp");//shape_file_roads);
}


experiment main type: gui {
	/*
	 * PARAMETERS
	 */
	parameter "Shapefile for the buildings:" var: shape_file_buildings category: "GIS" ;
	parameter "Shapefile for the roads:" var: shape_file_roads category: "GIS" ;

	output {
		display map {
			species building aspect:geom;
			species road aspect:geom;
		}
	}
}