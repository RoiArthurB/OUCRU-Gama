/***
* Name: doctor
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model doctor

import "healthCare.gaml"

global {
	/*
	 * INIT
	 */
	action initDoctor {
		create Doctor from: shape_file_buildings with: [type::string(read ("NATURE"))] {
			if type != "Doctor" {
				do die;
			}
		}
	}	
}

species Doctor parent: HealthCare {
	rgb color <- #green;
}