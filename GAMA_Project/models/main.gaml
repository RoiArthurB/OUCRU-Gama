/***
* Name: main
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model main

import "src/building.gaml"
import "src/road.gaml"
import "src/people.gaml"

global {
	/** 
	 * World parameters
	 */
	geometry shape <- envelope("../includes/bounds.shp");//shape_file_roads);
	
	init{
		/* Map */
		do initBuilding();
		do initRoad();
		
		/* Primary Agents */
		do initPeople();
	}
}


experiment main type: gui {
	/*
	 * PARAMETERS
	 */
	parameter "Shapefile for the buildings:" var: shape_file_buildings category: "GIS" ;
	parameter "Shapefile for the roads:" var: shape_file_roads category: "GIS" ;

	parameter "Number of people agents" var: nb_people category: "People" ;

	/*
	 * Display
	 */
	output {
		display map {
			species Building aspect:geom;
			species Road aspect:geom;
			
			species People aspect:geom;
		}
	}
}