/***
* Name: people
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model people

import "../main.gaml"

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
	
	
	// Transmission
// NEED SCIENTIFIC PARAMETERS
	float paramBreathAreaInfection <- 2#m;
	
	float paramProbabilityNaturalTransmission <- 0.15;
	float paramTimeBeforeNaturalTransmission <- 10 #mn;
	
	float paramProbabilitySickTransmission <- 0.25;
	float paramTimeBeforeSickTransmission <- 2#mn;
	float paramProbabilitySneezing <- 0.01;
	float paramSneezeAreaInfection <- 2#m;
	
	float paramStayHome <- 0.5;
	float paramSpeedToKill <- 0.01; // %
	
	//bacterias
	//=================
	int nbrBacteriaPerPerson <- 40;

	float paramProbaDuplication<- 0.05;
	float paramProbaSymptom <- 0.01;
	float paramProbaMutation <- 0.01;
	
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
			
			// Set Bacteria population
			do setBacteria( 0, nbrBacteriaPerPerson );
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
	bool isSick <- false update: length(self.symptoms) != 0; // Sick if have symptoms
	list<Symptom> symptoms;
	
	// Bacterias
	list<int> bacteriaPopulation <- [0, 0];	// [non-resitant, resistant]
	list<float> antibodies <- [0.0, 0.0, 0.0, 0.0] update: antibodies collect( max(0.0, each - (10#mn / 7#day)) ); // pourcent // Same index than symptoms
	
	// Pill related
	list<int> bacteriaToKill <- [0, 0];	// [non-resitant, resistant]
	
	// Pourcentage
	// Reach 0 in 2 days -> Jonathan source
	float antibioEffect <- 0.0 update: max(0.0, self.antibioEffect - (10#mn/2#day)); // val <- [0, 1]
		
	/*
	 * Actions
	 */ 
		
	/*	GET / SET	*/
	// Index 0 for Non-Resistant
	// Index 1 for Resistant
	// Return true if success, otherwise return false
	bool setBacteria(int index, int value <- 1){
		int prevNumb <- self.bacteriaPopulation[index];
		
		// Prevent overflow negative set
		self.bacteriaPopulation[index] <- max(0, int(prevNumb + value));

		return (prevNumb != self.bacteriaPopulation[index]);
	}
	
	// Param on true to avoid division by zero
	int getTotalBacteria(bool fake <- false){
		int result <- self.bacteriaPopulation[0]+self.bacteriaPopulation[1];
		return (fake and result = 0) ? 1 : result;
	}
	
	// Return 0 for Non-Resistant
	// Return 1 for Resistant
	int getRandomBacteria {		
		return int( flip( self.bacteriaPopulation[1]/self.getTotalBacteria(true) ) );
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
		
		// If self.isSick
		// -> Proba to not go to school
		if !( isSick and flip( paramStayHome ) ){
			objective <- "working" ;
			the_target <- any_location_in (school);
		}
		
	}
		
	// current_hour's define in main.gaml
	reflex time_to_go_home when: (current_hour = end_work and objective = "working") {
		objective <- "resting" ;
		the_target <- any_location_in (living_place); 
	}
	
	 /*	TRANSMISSION */
	reflex sneeze when: (self.isSick and flip(paramProbabilitySneezing)) {
		
		loop ppl over: agents_at_distance( paramSneezeAreaInfection ) {
			ask ppl.setBacteria( self.getRandomBacteria() ) target: People;
		}
		
	}
	
	// Breath transmission
	reflex transmission /* when: current_hour mod (5 #mn) = 0 */ {
		
		list<People> peopleInZone <- People at_distance paramBreathAreaInfection;
		
		// Remove people if not in the same building
		if self.the_target = nil { // check if is moving or not
			loop p over: peopleInZone{
				
				if self.objective = "resting" { // If at home
					if p.living_place != self.living_place{
						remove p from: peopleInZone;
					}
				}else{ // If at school
					if p.school != self.school{
						remove p from: peopleInZone;
					}
				}
				
			}
		}	// End list definition
		
		loop p over: peopleInZone {
			// Get probability depending if sick
			// Flip to see if resistant or not
			if( flip( self.isSick ? paramProbabilitySickTransmission : paramProbabilityNaturalTransmission ) ){
				int index <- self.getRandomBacteria();
				if p.setBacteria( index ){
					if self.setBacteria(index, -1){}
				}
			}
		}
		
		//Reset time before transmission
	}
	
	/* HEAL */
	reflex takePill when: isSick and current_hour = 20 {
		Pill p <- one_of(Pill);
		ask p.use( self );
	}
	
	// Kill slowly bacterias
	reflex pillEffect {
		loop i from: 0 to: 1 {
			int nbrKilled <- round(self.bacteriaToKill[i] * paramSpeedToKill);
			
			if setBacteria(i, - nbrKilled ) {
				self.bacteriaToKill[i] <- self.bacteriaToKill[i] - nbrKilled;
			}
		}
	}
	
	/*
	 * Bacteria
	 */ 	
	reflex duplication {//when: flip(paramProbaDuplication){
		int value <- 1;
		// Probability for a bacteria to die
		if flip(0.5){
			value <- -1;
		}
		/*
		 * 
			
			// If bacteria to kill
			if self.bacteriaToKill[i] != 0 {
				int nbrKilled <- 0 - round(self.bacteriaToKill[i] * paramSpeedToKill);

				if setBacteria(i, nbrKilled ) {
					self.bacteriaToKill[i] <- self.bacteriaToKill[i] + nbrKilled;
				}else{
					self.bacteriaToKill[i] <- 0; // No more bacteria of type _i_
				} */
		
		if self.setBacteria( self.getRandomBacteria(), value ){}
	} 	
	// Pass NR Bact to R Bact
	reflex mutation when: flip(paramProbaMutation){
		
		// Chance to mutation from NR to R, or reverse
		// Based of if self took an antibio
		// true = NR -> R // false = R -> NR
		list<int> mutation <- flip( self.antibioEffect ) ? [0,1] : [1,0];
		
		// Add bacteria on the other side only if could remove first
		if (self.setBacteria(mutation[0], -1)){
			if self.setBacteria(mutation[1], 1){}
		}	
	}
	
	// Pass NR Bact to R Bact
	reflex giveSymptom when: flip(0.001) and current_hour mod 1 = 0 {
		
		Symptom s <- one_of(Symptom);
		// If don't have enought antibodies -> Turn sick again
		if ! flip( self.antibodies[int(s)] ){
			add s to: self.symptoms;	
		}
		//add one_of(Symptom) to: self.symptoms;
	}
		
	/*
	 * Display
	 */
	aspect geom {
		draw circle(10) color: color;
	}
}