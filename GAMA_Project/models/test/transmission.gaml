/***
* Name: transmission
* Author: roiarthurb
* Description: A model dedicated to run unit tests
* Tags: Tag1, Tag2, TagN
***/

model test

import "../src/people.gaml"

global{ 
	float probaResistant <- 0.5;
	
	int nb_people <- 2;
	float paramProbabilityNaturalTransmission <- 1.0;
	float paramBreathAreaInfection <- 1000#km;
	
	init{
		do initPeople();
//		ask one_of(People).transmission();
		
	}
}

experiment transmissionGUI type:gui {	
		
	setup {
		/** Insert any initialization to run before each of the tests */
	}
	
	test "My First Test" {
	/** Insert here any assertion you need to test */
		//ask People[0].transmission();
		
		loop p over: People{
			write( p.getTotalBacteria() );	
		}
	}
	output{
		display map{
			species People aspect:geom;
		}
	}
}

experiment transmissionBatch type:batch repeat: 1 until: ( time > 1 ) {	
	output {}
}
