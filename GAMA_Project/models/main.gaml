/***
* Name: main
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model main

import "src/bacteria.gaml"
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

	//transmission
	parameter "Breath Infection Area (m)" var: paramBreathAreaInfection category: "People";
	
	parameter "Probability Natural Transmission (%)" var: paramProbabilityNaturalTransmission category: "People" min: 0.0 max: 100.0;
	parameter "Time before Natural Transmission (mn)" var: paramTimeBeforeNaturalTransmission category: "People";
	
	parameter "Probability Seek Transmission (%)" var: paramProbabilitySeekTransmission category: "People" min: 0.0 max: 100.0;
	parameter "Time before Seek Transmission (mn)" var: paramTimeBeforeSeekTransmission category: "People";
	parameter "Probability to sneeze when seek (%)" var: paramProbabilitySneezing category: "People" min: 0.0 max: 100.0;
	parameter "Sneeze Infection Area (m)" var: paramSneezeAreaInfection category: "People";
	
	// Bacteria
	parameter "[INIT] Probability Bacteria is resistant  (%)" var: probaResistant category: "Bacteria" min: 0.0 max: 100.0;
	parameter "Probability of duplication (%)" var: paramProbaDuplication category: "Bacteria" min: 0.0 max: 100.0;
	parameter "Probability to give symptoms (%)" var: paramProbaSymptom category: "Bacteria" min: 0.0 max: 100.0;
	parameter "Probability to self mutate (%)" var: paramProbaSelfMutation category: "Bacteria" min: 0.0 max: 100.0;
	parameter "Probability to give a mutation (%)" var: paramProbaGiveMutation category: "Bacteria" min: 0.0 max: 100.0;

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