/***
* Name: healthCare
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model healthCare

import "building.gaml"

global {
	/*
	 * INIT
	 */
	action initHealthCare {
		do initHospital();
		do initDoctor();
		do initPharmacy();
	}
}

species HealthCare parent: Building {
	
	bool doCPR;
	
	action cprTest(People p){
		// Exact needed pill
		p.currentCure <- Pill[int(one_of(p.symptoms))];
	}
	
	action prescription(People p){		
		// Reset traitement
		p.usagePill <- list_with(length(Symptom), 0);
		
		if doCPR {
			ask self { do cprTest(p); }
		} else {
			// int(int(one_of(p.symptoms))/2)	Will cure the good symptom with the good drug
			// int(flip(paramAntibio))			1 if true / 0 if false
			// * int(length(Pill)/2) 			proba to use antibio
			p.currentCure <- Pill[int(int(one_of(p.symptoms))/2) + int(flip(paramAntibio)) * int(length(Pill)/2)];
		}
		// Proba wear a mask
		if flip(paramProbabilityMaskSick){
			p.mask <- true;
		}
	}
}
