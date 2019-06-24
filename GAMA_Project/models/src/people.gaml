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

import "../buildingSrc/building.gaml"
import "road.gaml"

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
	float paramBreathAreaInfection;
	
	float paramProbabilityNaturalTransmission;
	float paramTimeBeforeNaturalTransmission;
	
	float paramProbabilitySickTransmission;
	float paramTimeBeforeSickTransmission;
	float paramProbabilitySneezing;
	float paramSickAreaInfection;
	
	float paramStayHome;
	float paramSpeedToKill; // %
	
	//bacterias
	//=================
	int nbrBacteriaPerPerson <- 40;

	float paramProbaSymptom;
	float paramProbaDuplication;
	float paramProbaMutation;
	
	/*
	 * INIT
	 */
	action initPeople {
		// Spawn People in a house 		
		create People number: nb_people {
			/*
			 * Init Agent
			 */
			// Static
			living_place <- one_of (Residential);
			school <- one_of(School) ;
			
			// Moving skill
			speed <- min_speed  + rnd (max_speed - min_speed) ;
			objective <- "resting";
			location <- any_location_in ( living_place );
			
			// Set Bacteria population
			do setBacteria( 0, nbrBacteriaPerPerson );
		}
	}
}

species People skills:[moving] {
	/*
	 * Variables
	 */
	rgb color update: isVaccinate ? #purple : (isSick ? #red : #yellow) ;
	
	// Movement
	Residential living_place <- nil ;
	School school <- nil ;
	string objective ; 
	point the_target <- nil ;
	
	// Human
	int age;
	bool sex;
	bool isSick <- false update: length(self.symptoms) != 0; // Sick if have symptoms
	bool isVaccinate <- false;
	list<Symptom> symptoms;
	
	// Bacterias
	list<int> bacteriaPopulation <- [0, 0];	// [non-resitant, resistant]
	list<float> antibodies <- [0.0, 0.0, 0.0, 0.0]; // Same index than symptoms
	reflex antibodiesUpdate {
		loop i from: 0 to: length(self.antibodies)-1 {
			if self.symptoms contains Symptom[int(i)] {
				self.antibodies[i] <- min(1.0, self.antibodies[i] + (step / 7#day));
			}
			else {
				self.antibodies[i] <- max(0.0, self.antibodies[i] - (step / 7#day));
			}
		}
	}
	
	// Pill related
	list<int> bacteriaToKill <- [0, 0];	// [non-resitant, resistant]
	
	// Pourcentage
	// Reach 0 in 2 days -> Jonathan source
	float antibioEffect <- 0.0 update: max(0.0, self.antibioEffect - (step/2#day)); // val <- [0, 1]
		
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
	
	list<People> getPeopleAround(float distance){
		list<People> peopleInZone <- People at_distance distance;
		
		// Remove people if not in the same building
		if self.the_target = nil and length(peopleInZone) > 0 { // check if is moving or not
			loop p over: peopleInZone{
				
				if self.objective = "resting" { // If at home
					if p.living_place != self.living_place{
						remove p from: peopleInZone;
					}
				} else if self.objective = "working" { // If at school
					if p.school != self.school{
						remove p from: peopleInZone;
					}
				}
				
			}
		}	// End list definition
		
		return peopleInZone;
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
	reflex time_to_go_home when: (current_hour = work_end and 
		(objective = "working" or objective = "healthCare")
	) {
		
		// Vaccination before leaving
		if ( objective = "working" and self.school.vaccinate ){
			self.isVaccinate <- true;
		}
		
		objective <- "resting" ;
		the_target <- any_location_in (living_place);
	}
	
	// current_hour's define in main.gaml
	reflex time_to_work when: (current_hour = work_start and objective = "resting") {
		
		// If self.isSick
		// -> Proba to not go to school
		if !( isSick and flip( paramStayHome ) ){
			objective <- "working" ;
			the_target <- any_location_in (school);
		}else{
			// HealthCare
			switch rnd(3) {
				match 0 { //"Hospital" {
					objective <- "healthCare" ;
					the_target <- any_location_in ( one_of(Hospital) ); 
					
					// If more than 1 symptom
					if( length(self.symptoms) > 1 ){
						self.isVaccinate <- true;
					}
				}
				match 1 { //"Doctor" {
					objective <- "healthCare" ;
					the_target <- any_location_in ( one_of(Doctor) );
				}
				match 2 { //"Pharmacy" {
					objective <- "healthCare" ;
					the_target <- any_location_in ( one_of(Pharmacy) );
				}
				match 3 {} //"AutoMedication" {}
			}
		}
		
	}
	
	 /*	TRANSMISSION */
	reflex sneeze when: self.isSick and flip(paramProbabilitySneezing) {
		
		if !(self.symptoms contains Symptom(3)){ // Hard Breazing
			loop ppl over: agents_at_distance( paramSickAreaInfection ) {
				ask ppl.setBacteria( self.getRandomBacteria() ) target: People;
			}
		}
		
	}
	
	// Breath transmission
	reflex breathBacteriaTransmission
	when: current_hour mod (5 #mn) = 0  { // Every 5 minutes
		
		list<People> peopleInZone <- getPeopleAround(paramBreathAreaInfection);
		
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
	reflex takePill when: isSick and current_hour = 12 /*and flip(0.5)*/ {
		Pill p <- one_of(Pill);
		ask p.use( self );
	}

	reflex antiBodiesHealing when: isSick and current_hour = 20 {
		float delta <- 0.25; // Difficulty to heal
		
		loop i from: 0 to: length(antibodies)-1 {
			if flip( antibodies[i]-delta ){
				remove item: Symptom[i] from: self.symptoms;
			}
		}
	} 	
	
	// Kill slowly bacterias
	reflex pillEffect when: antibioEffect != 0 {
		loop i from: 0 to: length(bacteriaPopulation)-1 {
			int nbrKilled <- round(self.bacteriaToKill[i] * paramSpeedToKill);
			
			if setBacteria(i, - nbrKilled ) {
				self.bacteriaToKill[i] <- self.bacteriaToKill[i] - nbrKilled;
			}
		}
	}
	
	/*
	 * Bacteria
	 */ 	
	reflex duplication /*when: flip(paramProbaDuplication)*/ {
		int value <- 1;
		
		// Lim -> nbrBacteriaPerPerson
		if flip( 
			(self.getTotalBacteria() - nbrBacteriaPerPerson)/nbrBacteriaPerPerson + 0.5
		){
			// Kill a bacteria
			value <- -1;
		}
		
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
	
	// Naturally turn sick
	reflex getNaturalSymptom when: flip(0.0001) /*flip(0.00001) and current_hour mod 1 = 0*/ and !isVaccinate  {
		
		Symptom s <- one_of(Symptom);
		// If don't have enought antibodies -> Turn sick again
		if ( !flip( self.antibodies[int(s)] ) and !(self.symptoms contains s) ){
			add s to: self.symptoms;
		}
	}
	// Turn someone else sick
	reflex giveSymptom when: isSick and current_hour mod 1 = 0 {
		
		if ( length(self.symptoms) != 0 ){

			Symptom s <- one_of(self.symptoms);
			
			list<People> peopleInZone <- getPeopleAround(paramSickAreaInfection);
			
			loop p over: peopleInZone {
				if (
					flip( paramProbabilitySickTransmission )
					and !flip( p.antibodies[int(s)] ) and !(p.symptoms contains s)
					and !p.isVaccinate
				){
					add s to: p.symptoms;
				}
			}
			
		}

	}
		

	/*
	 * Display
	 */
	aspect geom {
		draw circle(10) color: color;
	}
}