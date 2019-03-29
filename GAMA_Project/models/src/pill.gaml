/***
* Name: pill
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model pill

import "people.gaml"

global {
	/** Insert the global definitions, variables and actions here */
	action initPills{
		create Pill number: 1 {
			effectivnessNR <- rnd(1.0);//rnd(0.0, 1.0, 0.01);
			effectivnessR <- rnd(1.0);
		}
	}
	init{
		if length(Pill) = 0 {
			do initPills();	
		}
	}
}

species Pill{
	/*
	 * VAR
	 */
	bool isAntibio <- true;
	
	// Non-Resistant
	float effectivnessNR; // %
	// Resistant
	float effectivnessR; // %
	
	
	/*
	 * ACTION
	 */
	action use(People p){
		
		int nonRes <- p.bacteriaPopulation[0];
		int res <- p.bacteriaPopulation[1];
		
		p.bacteriaPopulation[0] <- nonRes - int( nonRes * self.effectivnessNR );
		p.bacteriaPopulation[1] <- res - int( res * self.effectivnessR );

	}/**/
}












