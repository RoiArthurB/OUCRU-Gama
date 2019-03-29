/***
* Name: pill
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model pill

global {
	/** Insert the global definitions, variables and actions here */
	action initPills{
		create Pill number: 1 {
			effectivness <- rnd(1.0);//rnd(0.0, 1.0, 0.01);
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
	
	float effectivness; // %
	
	
	/*
	 * ACTION
	 * /
	list<Bacteria> use(list<Bacteria> pop){
		
		int nbrToKill <- int( length(pop) * self.effectivness );
		
		loop times: nbrToKill {
			remove index:rnd(length(pop)-1) from: pop;
		}
		
		return pop;
	}*/
}












