/***
* Name: main
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model main

import "src/pill.gaml"

import "src/building.gaml"
import "src/road.gaml"
import "src/people.gaml"

global {
	/** 
	 * World parameters
	 */
	geometry shape <- envelope("../includes/bounds.shp");//shape_file_roads);
	//int current_hour update: (time / #hour) mod 24;
	float step <- 60 #mn;
	
	/*
	 * GRAPH
	 */	
	int nbrBact <- nbrBacteriaPerPerson * nb_people update: People sum_of each.getTotalBacteria();
	int nbrBactRes update: People sum_of each.bacteriasPopulation[1];
	
	float avgBactPop update: nbrBact / nb_people;
	float avgResBactPop update: nbrBactRes / nb_people; 
	
	
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
	parameter "maximal speed" var: max_speed category: "People" max: 10 #km/#h;
	parameter "Number of people agents" var: nb_people category: "People" ;

	//transmission
	parameter "Breath Infection Area (m)" var: paramBreathAreaInfection category: "People";
	
	parameter "Probability Natural Transmission (%)" var: paramProbabilityNaturalTransmission category: "People" min: 0.0 max: 1.0;
	parameter "Time before Natural Transmission (mn)" var: paramTimeBeforeNaturalTransmission category: "People";
	
	parameter "Probability Sick Transmission (%)" var: paramProbabilitySickTransmission category: "People" min: 0.0 max: 1.0;
	parameter "Time before Sick Transmission (mn)" var: paramTimeBeforeSickTransmission category: "People";
	parameter "Probability to sneeze when sick (%)" var: paramProbabilitySneezing category: "People" min: 0.0 max: 1.0;
	parameter "Sneeze Infection Area (m)" var: paramSneezeAreaInfection category: "People";
	
	parameter "Number of Bacteria / Person" var: nbrBacteriaPerPerson category: "People";
	
	// Bacteria
	parameter "[INIT] Probability Bacteria is resistant  (%)" var: probaResistant category: "Bacteria" min: 0.0 max: 1.0;
	parameter "[INIT] Probability to have a symptom (%)" var: paramProbaSymptom category: "Bacteria" min: 0.0 max: 1.0;
	parameter "Probability of duplication (%)" var: paramProbaDuplication category: "Bacteria" min: 0.0 max: 1.0;
	parameter "Probability to self mutate (%)" var: paramProbaSelfMutation category: "Bacteria" min: 0.0 max: 1.0;
	parameter "Probability to give a mutation (%)" var: paramProbaGiveMutation category: "Bacteria" min: 0.0 max: 1.0;

	/*
	 * Display
	 */
	layout #split;
	 
	output {
		display map {
			species Building aspect:geom;
			species Road aspect:geom;
			
			species People aspect:geom;
		}
		display total refresh:every(10#cycle) {
			chart "Bacterias evolution" type: series {
				data "Total Bacteria" value: nbrBact color: #green;
				data "Total Resistant Bacteria" value: nbrBactRes color: #red;
			}
		}
		display average refresh:every(10#cycle) {
			chart "Average evolution" type: histogram background: rgb("white") {
				data "Average Bacteria / Person" value: avgBactPop color: #green;
				data "Average Resistant Bacteria / Person" value: avgResBactPop color: #red;
			}	
		}
	}
}