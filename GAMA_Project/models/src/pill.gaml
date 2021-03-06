/***
* Name: pill
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model pill

import "people.gaml"

global {

	float paramAntibio;

	action initPills{		
		// Loop first nAntibio
		// -> First indexes
		loop s over: Symptom where !each.isBacterial {
			// One non-antibio Pill for every sickness
			create Pill number: 1 {
				effectivenessNR <- 0.0;
				isAntibio <- false;
				add s to:curedSymptoms;
			}
		}
		loop s over: Symptom where each.isBacterial {
			// No magick pill for general sickness
			create Pill number: 1 {
				effectivenessNR <- 0.01;
				isAntibio <- true;
				add s to:curedSymptoms;
			}
		}
	}
}

species Pill{	
	// Non-Resistant
	float effectivenessNR; // %
	bool isAntibio;
	
	list<Symptom> curedSymptoms;
	
	/*
	 * ACTION
	 */
	bool use(People p){
		
		bool r <- false;
		
		if self.isAntibio {
		
			// Set nbr to kill
			int nbrDeleted <- int(p.bacteriaPopulation[0] * self.effectivenessNR);
			p.bacteriaToKill[0] <- p.bacteriaToKill[0] + nbrDeleted;
			
			// Add overflow if too much antibiotics
			// Don't let RBact decrease too quickly
			p.antibioEffect <- 1.0 + p.antibioEffect;//min(1.5, 1.0 + p.antibioEffect);

			// Not automatic cured
			// Depending on effectiveness of the pill usage
			if flip( nbrDeleted/p.getTotalBacteria() ){
				p.symptoms <- self.cure(p);
				r <- true;
			}
		}
		else {
			int nbrPillUsed <- p.usagePill[int(self)] + 1;
			if flip(nbrPillUsed / 10){
				p.symptoms <- cure(p);
				r <- true;
			}else {
				p.usagePill[int(self)] <- nbrPillUsed; 
			}
		}
		
		return r;
	}
	list<Symptom> cure(People p){
		list<Symptom> symptoms <- p.symptoms;
		
		// Browse self.curedSymptoms
		loop symp over: self.curedSymptoms{
			// del match on p.symptoms
			if (!empty(symptoms) and (symptoms contains symp)){
				remove symp from: symptoms;	
				//p.antibodies[int(symp)] <- 1.0;
			}
		}
		return symptoms;
	}
}












