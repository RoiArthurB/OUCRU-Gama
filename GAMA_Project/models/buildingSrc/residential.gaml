/***
* Name: residential
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model residential

import "building.gaml"

global {
	/*
	 * INIT
	 */
	action initResidential {
		create Residential from: shape_file_buildings with: [type::string(read ("NATURE"))] {
			if type != "Residential" {
				do die;
			}
		}
	}
}

species Residential parent: Building {
//	list<int> stockPill <- list_with(length(Pill),0);
}