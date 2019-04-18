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
			effectivnessNR <- rnd(0.5);
			effectivnessR <- 0.0;
			
			// Effective on all symptoms
			loop s over: Symptom{
				add s to:curedSymptoms;
			}
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
	
	list<Symptom> curedSymptoms;
	
	/*
	 * ACTION
	 */
	action use(People p){
		
		list<int> nbrDeleted <- [int(p.bacteriaPopulation[0] * self.effectivnessNR), 
									int(p.bacteriaPopulation[1] * self.effectivnessR)	];
									
		p.bacteriaToKill[0] <- p.bacteriaToKill[0] + nbrDeleted[0];
		p.bacteriaToKill[1] <- p.bacteriaToKill[1] + nbrDeleted[1];
		
		/*
		int nonRes <- p.bacteriaPopulation[0];
		int nbrDeleted <- int( nonRes * self.effectivnessNR );
		
		p.bacteriaPopulation[0] <- nonRes - nbrDeleted;
		*/
		// Not automatic cured
		// Depending on effectiveness of the pill usage
		if flip( (nbrDeleted[0] + nbrDeleted[1]) /p.getTotalBacteria()){
			p.symptoms <- cure(p.symptoms);
		}
	}
	list<Symptom> cure(list<Symptom> symptoms){
		// Browse self.curedSymptoms
		loop symp over: self.curedSymptoms{
			// del match on p.symptoms
			if (!empty(symptoms) and (symptoms contains symp)){
				remove symp from: symptoms;	
			}
		}
		return symptoms;
	}
}












