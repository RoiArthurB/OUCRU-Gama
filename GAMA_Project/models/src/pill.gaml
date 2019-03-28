/***
* Name: pill
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model pill

import "bacteria.gaml"

global {
	/** Insert the global definitions, variables and actions here */
	init{
		create Pill number: 1 {
			effectivness <- rnd(1.0);
		}
	}
}

species Pill{
	bool isAntibio <- true;
	
	float effectivness; // %
	
	list<Bacteria> use(list<Bacteria> pop){
		int nbrToKill <- int( length(pop) * self.effectivness );
		
		loop times: nbrToKill {
			remove rnd(length(pop)) from: pop;
		}
		
		return pop;
	}
}












