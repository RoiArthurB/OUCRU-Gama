/***
* Name: people
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model people

import "bacteria.gaml"

import "building.gaml"
import "road.gaml"

//import "../main.gaml"

global {
	/*
	 * PARAMETERS
	 */
	int current_hour update: (time / #hour) mod 24;
	int nb_people <- 100;
	
	//movement
	float min_speed <- 1.0 #km / #h;
	float max_speed <- 5.0 #km / #h;
	int work_start <- 7;
	int work_end <- 18;
	
	//transmission
	float paramBreathAreaInfection <- 2#m;
	
	float paramProbabilityNaturalTransmission <- 0.25;
	float paramTimeBeforeNaturalTransmission <- 10 #mn;
	
	float paramProbabilitySeekTransmission <- 0.5;
	float paramTimeBeforeSeekTransmission <- 2#mn;
	float paramProbabilitySneezing <- 0.5;
	float paramSneezeAreaInfection <- 2#m;
	
	//bacterias
	int nbrBacteriaPerPerson <- 100;
	
	/*
	 * INIT
	 */
	action initPeople {
		// Spawn People in a house 
		list<Building> residential_buildings <- Building where (each.type="Residential");
		list<Building> listSchools <- Building where (each.type="School");
		
		create People number: nb_people {
			/*
			 * Init Agent
			 */
			// Static
			living_place <- one_of (residential_buildings);
			school <- one_of(listSchools) ;
			
			// Moving skill
			speed <- min_speed  + rnd (max_speed - min_speed) ;
			objective <- "resting";
			location <- any_location_in ( living_place );
			
			// Daily Routine
			start_work <- work_start ;
			end_work <- work_end ;
			
			// Transmission
			breathAreaInfection <- paramBreathAreaInfection;
			probabilityNaturalTransmission <- paramProbabilityNaturalTransmission;
			timeBeforeNaturalTransmission <- paramTimeBeforeNaturalTransmission;
			probabilitySeekTransmission <- paramProbabilitySeekTransmission;
			timeBeforeSeekTransmission <- paramTimeBeforeSeekTransmission;
			probabilitySneezing <- paramProbabilitySneezing;
			sneezeAreaInfection <- paramSneezeAreaInfection;
		}	
			
		// Set Bacteria population
		loop p over: People {
			ask p.setBacteriaPop( initBacteriaPopulation(nbrBacteriaPerPerson) );	
		}	
	}
}

species People skills:[moving] {
	/*
	 * Variables
	 */
	rgb color <- #yellow ;
	
	// Movement
	Building living_place <- nil ;
	Building school <- nil ;
	int start_work ;
	int end_work  ;
	string objective ; 
	point the_target <- nil ;
	
	// Human
	int age;
	bool sex;
	bool isSeek update: length(self.symptoms) != 0 ? true : false;
	list<int> symptoms; // type gonna change
	
	// Transmission
	list<Bacteria> bacterias;	// type gonna change
	float breathAreaInfection <- 2 #m;		// Scientific Article
	
	float probabilityNaturalTransmission <- 25.0; //%
	float timeBeforeNaturalTransmission <- 10 #mn;
	
	float probabilitySeekTransmission <- 50.0; //%
	float timeBeforeSeekTransmission <- 2 #mn;
	float probabilitySneezing <- 50.0; //%
	float sneezeAreaInfection <- 2 #m;		// Scientific Article
		
	/*
	 * Actions
	 */ 
		
	/*	GET / SET	*/
	action setBacteriaPop(list<Bacteria> pop){
		bacterias <- pop;
	}
	 
	/*
	 * Reflexes
	 */ 
	
	 /*	MOVEMENT */
	reflex move when: the_target != nil {
		do goto target: the_target on: the_graph ; 
		if the_target = location {
			the_target <- nil ;
		}
	}
	
	 /*	DAILY ROUTINE */
	// current_hour's define in main.gaml
	reflex time_to_work when: (current_hour = start_work and objective = "resting") {
		objective <- "working" ;
		the_target <- any_location_in (school);
	}
		
	// current_hour's define in main.gaml
	reflex time_to_go_home when: (current_hour = end_work and objective = "working") {
		objective <- "resting" ;
		the_target <- any_location_in (living_place); 
	}
	
	 /*	TRANSMISSION */
	reflex sneeze when: (self.isSeek and flip(self.probabilitySneezing)) {
		loop ppl over: agents_at_distance(sneezeAreaInfection) {
			// transmission
			//ask ppl ...
		}
	}
	
	reflex naturalTransmission when: timeBeforeNaturalTransmission = 0 {
		if flip(self.probabilityNaturalTransmission){
			//give bacteria
		}
		
		//Reset time before transmission
	}
	
	reflex seekTransmission when: (timeBeforeSeekTransmission = 0 and self.isSeek) {
		if flip(self.probabilitySeekTransmission){
			//give bacteria
		}
		
		//Reset time before transmission
	}
		
	/*
	 * Display
	 */
	aspect geom {
		draw circle(10) color: color;
	}
}