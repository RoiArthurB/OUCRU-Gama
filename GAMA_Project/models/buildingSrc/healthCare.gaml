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
	
	bool cprTest(People p){
		bool result <- false;
		if flip(0.5){
			result <- true;
		}
		return result;
	}
	
	action prescription(People p){
		bool antibio <- flip(paramAntibio);
		
		if doCPR {
			antibio <- self.cprTest(p);
		}
		
		p.usagePill <- list_with(length(Symptom), 0);
		p.currentCure <- Pill[int(int(one_of(p.symptoms))/2) + int(antibio) * int(length(Pill)/2)];
	}
}
