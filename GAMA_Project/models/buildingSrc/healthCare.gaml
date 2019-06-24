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
	
	bool crpTest(People p){
		bool result <- false;
		if flip(0.5){
			result <- true;
		}
		return result;
	}
}
