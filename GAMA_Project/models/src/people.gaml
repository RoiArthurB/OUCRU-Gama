/***
* Name: people
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model people

import "building.gaml"
import "road.gaml"
//import "../main.gaml"

global {
	/*
	 * PARAMETERS
	 */
	int nb_people <- 100;
	
	float min_speed <- 1.0 #km / #h;
	float max_speed <- 5.0 #km / #h;
	int work_start <- 7;
	int work_end <- 18;
	
	
	int current_hour update: (time / #hour) mod 24;
	
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
	list<int> bacteria;	// type gonna change
	float breathAreaInfection <- 2 #m;		// Scientific Article
	float sneezeAreaInfection <- 2 #m;		// Scientific Article
	float probabilityTransmission <- 0.5; //%
	float timeBeforeTransmission <- 10 #mn;
		
	/*
	 * Reflexes
	 */
	// current_hour's define in main.gaml
	reflex time_to_work when: current_hour = start_work and objective = "resting"{
		objective <- "working" ;
		the_target <- any_location_in (school);
	}
		
	// current_hour's define in main.gaml
	reflex time_to_go_home when: current_hour = end_work and objective = "working"{
		objective <- "resting" ;
		the_target <- any_location_in (living_place); 
	} 
	
	reflex move when: the_target != nil {
		do goto target: the_target on: the_graph ; 
		if the_target = location {
			the_target <- nil ;
		}
	}
		
	/*
	 * Display
	 */
	aspect geom {
		draw circle(10) color: color;
	}
}