/***
* Name: people
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model people

import "symptom.gaml"
import "pill.gaml"

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
	//=================
	int nbrBacteriaPerPerson <- 100;
	// PARAMETERS
	float probaResistant <- 0.5;
	float paramProbaDuplication<- 0.5;
	float paramProbaSymptom <- 0.5;
	float paramProbaSelfMutation <- 0.5;
	float paramProbaGiveMutation <- 0.5;
	
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
			
			// Set Bacteria population
			loop times: nbrBacteriaPerPerson{
				do setBacteria( int(flip(probaResistant)) );
			}
		}
	}
}

species People skills:[moving] {
	/*
	 * Variables
	 */
	rgb color update: isSick ? #red : #yellow ;
	
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
	bool isSick <- false;// update: length(self.symptoms) != 0 ? true : false;
	list<Symptom> symptoms;
	
	// Transmission
	float breathAreaInfection <- 2 #m;		// Scientific Article ?
	
	float probabilityNaturalTransmission <- 25.0; //%
	float timeBeforeNaturalTransmission <- 10 #mn;
	
	float probabilitySickTransmission <- 50.0; //%
	float timeBeforeSickTransmission <- 2 #mn;
	float probabilitySneezing <- 50.0; //%
	float sneezeAreaInfection <- 2 #m;		// Scientific Article ?
	
	// Bacterias
	list<int> bacteriaPopulation <- [0, 0];	// [non-resitant, resistant]
		
	/*
	 * Actions
	 */ 
		
	/*	GET / SET	*/
	// Input 0 for Non-Resistant
	// Input 1 for Resistant
	action setBacteria(int index){
		self.bacteriaPopulation[index] <- int(self.bacteriaPopulation[index] + 1);
	}
	
	int getTotalBacteria{
		return self.bacteriaPopulation[0]+self.bacteriaPopulation[1];
	}
	
	// Return 0 for Non-Resistant
	// Return 1 for Resistant
	int getRandomBacteria {
		return int( flip( self.bacteriaPopulation[1]/self.getTotalBacteria() ) );
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
		
		loop p over: People at_distance self.breathAreaInfection {
			// Get probability depending if sick
			// Flip to see if resistant or not
			if( flip( self.isSick ? self.probabilitySickTransmission : self.probabilityNaturalTransmission ) ){
				ask p.setBacteria( self.getRandomBacteria() );
			}
		}
		
		//Reset time before transmission
	}
	
	/* HEAL */
	reflex takePill when: isSick {
		Pill p <- one_of(Pill);
		ask p.use( self );
	}
		
	reflex duplication when: flip(paramProbaDuplication){
		ask self.setBacteria( self.getRandomBacteria() );
	}
		
	/*
	 * Display
	 */
	aspect geom {
		draw circle(10) color: color;
	}
}