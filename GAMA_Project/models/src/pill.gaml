/***
* Name: pill
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model pill

import "people.gaml"

global {

	bool paramAntibio <- true;

	action initPills{
		create Pill number: 1 {
			effectivenessNR <- 0.25;//rnd(0.5);
			effectivenessR <- 0.0;
			
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
	bool isAntibio <- paramAntibio;
	
	// Non-Resistant
	float effectivenessNR; // %
	// Resistant
	float effectivenessR; // %
	
	list<Symptom> curedSymptoms;
	
	/*
	 * ACTION
	 */
	action use(People p){
		
		list<int> nbrDeleted <- [int(p.bacteriaPopulation[0] * self.effectivenessNR), 
									int(p.bacteriaPopulation[1] * self.effectivenessR)	];
									
		p.bacteriaToKill[0] <- p.bacteriaToKill[0] + nbrDeleted[0];
		p.bacteriaToKill[1] <- p.bacteriaToKill[1] + nbrDeleted[1];
		
		if self.isAntibio {
			p.antibioEffect <- 1.0;
		}

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












