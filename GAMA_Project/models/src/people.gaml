/***
* Name: people
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model people

import "building.gaml"
import "road.gaml"

global {
	/*
	 * PARAMETERS
	 */
	int nb_people <- 100;
	
	/*
	 * INIT
	 */
	action initPeople {
		// Spawn People in a house 
		list<Building> residential_buildings <- Building where (each.type="Residential");
		
		create People number: nb_people {
			location <- any_location_in (one_of (residential_buildings));
		}		
	}
}

species People {
	/*
	 * Variables
	 */
	rgb color <- #yellow ;
		
	/*
	 * Display
	 */
	aspect geom {
		draw circle(10) color: color;
	}
}