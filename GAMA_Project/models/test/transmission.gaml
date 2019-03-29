/***
* Name: transmission
* Author: roiarthurb
* Description: A model dedicated to run unit tests
* Tags: Tag1, Tag2, TagN
***/

model test

import "../src/people.gaml"

global{ 
	int nb_people <- 2;
	float paramProbabilityNaturalTransmission <- 1.0;
	float paramBreathAreaInfection <- 1000#km;
	
	init{
		do initPeople();
		ask one_of(People).transmission();
		
	}
}

experiment transmissionGUI type:gui {	
	output {
		
	}
}

experiment transmissionBatch type:batch repeat: 1 until: ( time > 1 ) {	
	output {}
}
