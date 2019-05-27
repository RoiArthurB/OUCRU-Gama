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
	float step <- 10 #mn;
	
	/*
	 * GRAPH
	 */	
	int nbrBact <- nbrBacteriaPerPerson * nb_people update: People sum_of each.getTotalBacteria();
	int nbrBactRes update: People sum_of each.bacteriaPopulation[1];
	
	float avgBactPop <- float(nbrBacteriaPerPerson) update: nbrBact / nb_people;
	float avgResBactPop update: nbrBactRes / nb_people; 
	
	int sickPop update: People count each.isSick;
	
	bool pauseSimulation <- true;
	
	/**
	 * Constant
	 */
	date initDate <- current_date;
	
	init{
		/* Map */
		do initBuilding();
		do initRoad();
		
		/* Primary Agents */
		do initPeople();
		
		/* Secondary Agents */
		do initSymptoms();
		do initPills();
	}
	reflex graphUpdate {
		nbrBact <- People sum_of each.getTotalBacteria();
		nbrBactRes <- People sum_of each.bacteriaPopulation[1];
		
		avgBactPop <- nbrBact / nb_people;
		avgResBactPop <- nbrBactRes / nb_people;
		
		sickPop <- People count each.isSick;
	}
	
	// Stop simulation when nbr Resistant Bacteria >= XX %
	reflex stop_simulation when: ((100*nbrBactRes)/nbrBact >= 95) and pauseSimulation {
		do pause ;
	} 
	 
	// Stop simulation after 7 month
	reflex stop_simulation when: current_date >= initDate + 1#year and pauseSimulation {
		do pause ;
	}
}


experiment main type: /* batch until: current_date >= initDate + 7#month {*/ gui {
	/*
	 * PARAMETERS
	 */
	parameter "Shapefile for the buildings:" var: shape_file_buildings category: "GIS" ;
	parameter "Shapefile for the roads:" var: shape_file_roads category: "GIS" ;
	
	parameter "Should pause the simulation " var: pauseSimulation category: "GIS" ;

	// People
	parameter "Number of people agents" var: nb_people category: "People" ;
	parameter "Hour to start work" var: work_start category: "People" min: 2 max: 12;
	parameter "Hour to end work" var: work_end category: "People" min: 12 max: 23;
	parameter "minimal speed" var: min_speed category: "People" min: 0.1 #km/#h ;
	parameter "maximal speed" var: max_speed category: "People" max: 10 #km/#h;
	parameter "Number of people agents" var: nb_people category: "People" ;
	
	parameter "Number of Bacteria / Person" var: nbrBacteriaPerPerson category: "People" init: 1000000;

	// transmission
	parameter "Breath Infection Area (m)" var: paramBreathAreaInfection category: "Transmission";
	
	parameter "Probability Natural Transmission (%)" var: paramProbabilityNaturalTransmission category: "Transmission" min: 0.0 max: 0.5;
	parameter "Time before Natural Transmission (mn)" var: paramTimeBeforeNaturalTransmission category: "Transmission";
	
	parameter "Probability to stay at home when sick (%)" var: paramStayHome category: "Transmission" min: 0.0 max: 1.0;
	
	// Sick
	parameter "Probability Sick Transmission (%)" var: paramProbabilitySickTransmission category: "Sick" min: 0.0 max: 0.5;
	parameter "Time before Sick Transmission (mn)" var: paramTimeBeforeSickTransmission category: "Sick";
	parameter "Probability to sneeze when sick (%)" var: paramProbabilitySneezing category: "Sick" min: 0.0 max: 0.25;
	parameter "Sneeze Infection Area (m)" var: paramSneezeAreaInfection category: "Sick";
	
	// Bacteria
	parameter "[INIT] Probability to have a symptom (%)" var: paramProbaSymptom category: "Bacteria" min: 0.0 max: 0.5;
	parameter "Probability of duplication (%)" var: paramProbaDuplication category: "Bacteria" min: 0.0 max: 0.1;
	parameter "Probability to self mutate (%)" var: paramProbaMutation category: "Bacteria" min: 0.0 max: 0.1;
	
	// Pills
	parameter "Pourcent killed each simulation's tic (%)" var: paramSpeedToKill category: "Pill" min: 0.0 max: 1.0;
	parameter "Solo pick is antibio" var: paramAntibio category: "Pill";

	/*
	 * Display
	 */
	layout #split;
	 
	output {
/*		display map {
			species Building aspect:geom;
			species Road aspect:geom;
			
			species People aspect:geom;
		} */
		display bacteria refresh:every(10#cycle) {
			chart "Bacterias evolution" type: series {
				data "Total Bacteria" value: nbrBact color: #blue;
				data "Total Resistant Bacteria" value: nbrBactRes color: #red;
				data "Total Non-Resistant Bacteria" value: nbrBact - nbrBactRes color: #green;
			}
		}
		display population refresh:every(10#cycle) {
			chart "Dynamic population" type: series {
				data "Number of Person sick" value: sickPop color: #red;
				data "Number of Person non-sick" value: nb_people - sickPop color: #green;
			}
		}
		display antibio refresh:every(30#cycle) {
			chart "Dynamic anti-bacteria" type: series {
				//data "Number of Person sick" value: sickPop color: #red;
				data "Antibio Effect" value: People sum_of each.antibioEffect color: #red;// max: nb_people;
			}
		}
		monitor "% Bacteria R / People" value: (100*nbrBactRes)/nbrBact;
		monitor "Nbr Bacteria R" value: nbrBactRes;
		monitor "% Bacteria NR / People" value: 100-(100*nbrBactRes)/nbrBact;
		monitor "Nbr Bacteria NR" value: nbrBact-nbrBactRes;
		
		monitor "Average Proba Mutation" value: paramProbaMutation * ((avgBactPop-avgResBactPop)/avgBactPop);
	}
}