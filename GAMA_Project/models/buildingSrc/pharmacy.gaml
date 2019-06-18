/***
* Name: pharmacy
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model pharmacy

import "building.gaml"

global {
	/*
	 * INIT
	 */
	action initPharmacy {
		create Pharmacy from: shape_file_buildings with: [type::string(read ("NATURE"))] {
			if type != "Pharmacy" {
				do die;
			}
		}
	}
}

species Pharmacy parent: Building {
	rgb color <- #lightgreen;
}

