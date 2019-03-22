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
	
	float paramProbabilitySickTransmission <- 0.5;
	float paramTimeBeforeSickTransmission <- 2#mn;
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
			probabilitySickTransmission <- paramProbabilitySickTransmission;
			timeBeforeSickTransmission <- paramTimeBeforeSickTransmission;
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
	bool isSick update: length(self.symptoms) != 0 ? true : false;
	list<int> symptoms; // type gonna change
	
	// Transmission
	list<Bacteria> bacterias;	// type gonna change
	float breathAreaInfection <- 2 #m;		// Scientific Article
	
	float probabilityNaturalTransmission <- 25.0; //%
	float timeBeforeNaturalTransmission <- 10 #mn;
	
	float probabilitySickTransmission <- 50.0; //%
	float timeBeforeSickTransmission <- 2 #mn;
	float probabilitySneezing <- 50.0; //%
	float sneezeAreaInfection <- 2 #m;		// Scientific Article
		
	/*
	 * Actions
	 */ 
		
	/*	GET / SET	*/
	action setBacteriaPop(list<Bacteria> pop){
		bacterias <- pop;
	}
	
	action setBacteria(Bacteria b){
		add b to: bacterias;
	}
	
	Bacteria getRandomBacteria {
		return one_of(bacterias);
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
	reflex sneeze when: (self.isSick and flip(self.probabilitySneezing)) {
		
		loop ppl over: agents_at_distance( self.sneezeAreaInfection ) {
			ask ppl.setBacteria( self.getRandomBacteria() ) target: People;
		}
		
	}
	
	// Breath transmission
	reflex transmission /* when: timeBeforeNaturalTransmission = 0 */ {
		
		ask People at_distance self.breathAreaInfection {
			if self.isSick {	// Transmission if sick
				if flip(self.probabilitySickTransmission){
					// Give bacteria
					do setBacteria( self.getRandomBacteria() );
				}
			}else{				// Transmission if not sick
				if flip(self.probabilityNaturalTransmission){
					// Give bacteria
					do setBacteria( self.getRandomBacteria() );
				}
			}
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