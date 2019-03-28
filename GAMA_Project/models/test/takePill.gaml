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
		ask one_of(People).takePill();
	}	
}

experiment takePillGUI type:gui {
	/** Insert here the definition of the inputs and outputs of the model */
	
	/** Parameters can be used to input values to the model **/
	// parameter "First parameter" var: an_attribute_of_the_model <- an_expression;
	
	output {
		/** monitors can be used to output values, either in the UI or in a file **/
		// monitor "m1" value: an_expression;
	}
}

experiment takePillBatch type:batch repeat: 1 until: ( time > 1 ) {
	/** Insert here the definition of the inputs and outputs of the model */
	
	/** Parameters can be used to input values to the model **/
	// parameter "First parameter" var: an_attribute_of_the_model <- an_expression;
	
	output {
		/** monitors can be used to output values, either in the UI or in a file **/
		// monitor "m1" value: an_expression;
	}
}
