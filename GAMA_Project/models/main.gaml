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
	//int current_hour update: (time / #hour) mod 24;
	//float step <- 10 #mn;
	
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

	// People
	parameter "Number of people agents" var: nb_people category: "People" ;
	parameter "Hour to start work" var: work_start category: "People" min: 2 max: 12;
	parameter "Hour to end work" var: work_end category: "People" min: 12 max: 23;
	parameter "minimal speed" var: min_speed category: "People" min: 0.1 #km/#h ;
	parameter "maximal speed" var: max_speed category: "People" max: 10 #km/#h;parameter "Number of people agents" var: nb_people category: "People" ;

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