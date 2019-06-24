/***
* Name: pill
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model pill

import "people.gaml"

global {

	bool paramAntibio;

	action initPills{
		// Effective on all symptoms
		loop s over: Symptom{
			// No magick pill for general sickness
			if s.name != "Sick" {
				create Pill number: 1 {
					effectivenessNR <- paramAntibio ? 0.01 /* rnd(0.5) */: 0.0;
					
					add s to:curedSymptoms;
				}	
			}
		}
	}
}

species Pill{	
	// Non-Resistant
	float effectivenessNR; // %
	
	list<Symptom> curedSymptoms;
	
	/*
	 * ACTION
	 */
	action use(People p){
		
		int nbrDeleted <- int(p.bacteriaPopulation[0] * self.effectivenessNR);
									
		p.bacteriaToKill[0] <- p.bacteriaToKill[0] + nbrDeleted;
		
		if paramAntibio {
			// Add overflow if too much antibiotics
			// Don't let RBact decrease too quickly
			p.antibioEffect <- 1.0 + p.antibioEffect;//min(1.5, 1.0 + p.antibioEffect);
		}

		// Not automatic cured
		// Depending on effectiveness of the pill usage
		if flip( nbrDeleted/p.getTotalBacteria()){
			p.symptoms <- cure(p);
		}
	}
	list<Symptom> cure(People p){
		list<Symptom> symptoms <- p.symptoms;
		
		// Browse self.curedSymptoms
		loop symp over: self.curedSymptoms{
			// del match on p.symptoms
			if (!empty(symptoms) and (symptoms contains symp)){
				remove symp from: symptoms;	
				p.antibodies[int(symp)] <- 1.0;
			}
		}
		return symptoms;
	}
}












