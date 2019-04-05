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
	
	float probabilityCure <- 0.5;
	list<Symptom> curedSymptoms;
	
	/*
	 * ACTION
	 */
	action use(People p){
		
		int nonRes <- p.bacteriaPopulation[0];
		
		p.bacteriaPopulation[0] <- nonRes - int( nonRes * self.effectivnessNR );

	}
	action cure(People p){
		// Not automatic cured
		if flip(self.probabilityCure){
			
			// Browse p.symptoms
			loop symp over: p.symptoms{
				// del match on p.symptoms
				if self.curedSymptoms contains symp{
					remove symp from: p.symptoms;	
				}
			}
			
		}
	}
}












