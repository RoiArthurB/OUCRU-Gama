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
}
