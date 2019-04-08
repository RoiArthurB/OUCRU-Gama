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
	
	list<Symptom> curedSymptoms;
	
	/*
	 * ACTION
	 */
	action use(People p){
		
		int nonRes <- p.bacteriaPopulation[0];
		int nbrDeleted <- int( nonRes * self.effectivnessNR );
		
		p.bacteriaPopulation[0] <- nonRes - nbrDeleted;
		
		// Not automatic cured
		// Depending on effectiveness of the pill usage
		if flip(nbrDeleted/p.getTotalBacteria()){
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












