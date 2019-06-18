/***
* Name: hospital
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model hospital

import "building.gaml"

global {
	/*
	 * INIT
	 */
	action initHospital {
		create Hospital from: shape_file_buildings with: [type::string(read ("NATURE"))] {
			if type != "Hospital" {
				do die;
			}
		}
	}
}

species Hospital parent: Building {
	
	rgb color <- #orange;
}

