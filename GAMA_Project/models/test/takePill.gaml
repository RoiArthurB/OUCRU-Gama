/***
* Name: takePill
* Author: roiarthurb
* Description: This wizard creates a new experiment file.
* Tags: Tag1, Tag2, TagN
***/

model test

import "../src/pill.gaml"
import "../src/people.gaml"

global{ 
	int nb_people <- 1;
	init{
		do initPills();
		do initPeople();
		//ask one_of(People).takePill();
	}	
}

experiment takePillGUI type:gui {	
	
	test "My First Test" {
	/** Insert here any assertion you need to test */
		//do one_of(People).takePill();
		loop p over: People{
			write( p.getTotalBacteria() );	
		}
	}
	output {}
}

experiment takePillBatch type:batch repeat: 1 until: ( time > 1 ) {	
	output {}
}
