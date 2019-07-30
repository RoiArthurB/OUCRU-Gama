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
	
	float paramAveragePeopleSick;
	float paramProbabilitySickTransmission;
	float paramTimeBeforeSickTransmission;
	float paramProbabilitySneezing;
	float paramSickAreaInfection;
	
	float paramProbabilityMaskTravel;
	float paramProbabilityMaskInside;
	float paramProbabilityMaskSick;
	
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
	
	// Accessories
	bool mask <- false;
	
	// Bacterias
	list<int> bacteriaPopulation <- [0, 0];	// [non-resitant, resistant]
	list<float> antibodies <- list_with(length(Symptom), 0.0); // Same index than symptoms
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
	list<int> usagePill <- list_with(length(Symptom),0);
	Pill currentCure <- nil;
	
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
		list<People> peopleToRemove;
		
		// Remove people if not in the same building
		if self.the_target = nil and length(peopleInZone) > 0 { // check if is moving or not
			loop p over: peopleInZone {
				
				if self.objective = "resting" { // If at home
					if p.living_place != self.living_place{
						add p to: peopleToRemove;
					}
				} else if self.objective = "working" { // If at school
					if p.school != self.school{
						add p to: peopleToRemove;
					}
				}
				
			}
		}	// End list definition
		
		remove peopleToRemove from: peopleInZone;
		return peopleInZone;
	}
	 
	/*
	 * Reflexes
	 */ 
	
	 /*	MOVEMENT */
	reflex move when: the_target != nil {
		do goto target: the_target on: the_graph ;
		
		// Probability to walk with a mask 
		if flip(paramProbabilityMaskTravel){
			self.mask <- true;
		}
		
		// When arrived
		if the_target = location {
			// If not sick, can wear a mask
			// if sick => Mask already defined
			if( !self.isSick ){
				// Reset and try if mask inside
				self.mask <- false;
				if flip(paramProbabilityMaskInside){
					self.mask <- true;
				}	
			}
			
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
			HealthCare hc <- nil;
			// HealthCare
			switch rnd(3) {
				match 0 { //"Hospital" {
					hc <- one_of(Hospital);
				}
				match 1 { //"Doctor" {
					hc <- one_of(Doctor);
				}
				match 2 { //"Pharmacy" {
					hc <- one_of(Pharmacy);
				}
				match 3 {} //"AutoMedication" {}
			}
			
			if(hc != nil){ // Debug for AutoMedication case
				objective <- "healthCare" ;
				the_target <- any_location_in ( hc );
				ask hc { do prescription( myself ); }	
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
	when: time mod (5 #mn) = 0  { // Every 5 minutes
		
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
	reflex takePill when: isSick and (time mod 24 #hour) = 12 #hour /*and flip(0.5)*/ {
		// Set Pill cure
		if self.currentCure = nil {
			if flip(paramProbabilityMaskSick){
				self.mask <- true;
			}
			self.usagePill <- list_with(length(Symptom), 0);
			self.currentCure <- flip(paramAntibio) ? 
				one_of(Pill where each.isAntibio) : one_of(Pill where !each.isAntibio);
		}
		// use Pill
		if self.currentCure.use( self ) {
			// If true -> healed -> No more cure
			self.currentCure <- nil;
		}
		if flip(0.5){
			self.currentCure <- nil;
		}
		
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
	reflex getNaturalSymptom when: flip(paramAveragePeopleSick * 0.002) /*flip(0.00001) and current_hour mod 1 = 0*/ and !isVaccinate  {
		
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
		if mask {
			draw image_file("../../includes/mask.png") at: self.location size: 30;	
		}
	}
}