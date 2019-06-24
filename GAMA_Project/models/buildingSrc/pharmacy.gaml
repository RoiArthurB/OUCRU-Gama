/***
* Name: pharmacy
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model pharmacy

import "healthCare.gaml"

global {
	/*
	 * INIT
	 */
	bool pharmacyCPR;
	
	action initPharmacy {
		create Pharmacy from: shape_file_buildings with: [type::string(read ("NATURE"))] {
			if type != "Pharmacy" {
				do die;
			}
		}
	}
}

species Pharmacy parent: HealthCare {
	rgb color <- #lightgreen;
	bool doCPR update: pharmacyCPR;
}

