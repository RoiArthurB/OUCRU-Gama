/***
* Name: duplication
* Author: roiarthurb
* Description: A model dedicated to run unit tests
* Tags: Tag1, Tag2, TagN
***/

model test

import "../src/people.gaml"

global {
	/** Insert the global definitions, variables and actions here */
	
	int nb_people <- 1;
	float paramProbaDuplication <- 1.0;
	
	init{
		do initPeople();		
	}
	
}

experiment duplicationGUI type:gui {	
	
	test "My First Test" {
	/** Insert here any assertion you need to test */
		write( People[0].getTotalBacteria() );
		write( People[0].bacteriaPopulation[0] );
		write( People[0].bacteriaPopulation[1] );
		write( "===============" );
	}
/*	output{
		display map{
			species People aspect:geom;
		}
	}*/
}
