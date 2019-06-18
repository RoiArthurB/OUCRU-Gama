/***
* Name: school
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model school 

import "building.gaml"

global {
	/*
	 * INIT
	 */
	action initSchool {
		create School from: shape_file_buildings with: [type::string(read ("NATURE"))]{
			if type != "School" {
				do die;
			}
		}
	}
}

species School parent: Building {
	
	rgb color <- #blue;
	
	string iconPath update: vaccinate ? "../../includes/syringe.png" : "";
	
	bool vaccinate <- false update: (current_hour = 0) ? false : vaccinate;
	
	/*
	 * Display
	 */
	aspect geom {
		draw shape color: color;
		draw image_file(iconPath) at: self.location size: 50;
	}
	
	action vaccination {
		write(self);
		self.vaccinate <- true;
	}
}

