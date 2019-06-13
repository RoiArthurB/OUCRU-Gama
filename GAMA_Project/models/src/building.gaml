/***
* Name: building
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model building

import "../main.gaml"

global {
	/*
	 * PARAMETERS
	 */
	file shape_file_buildings <- file("../../includes/building.shp");

	/*
	 * INIT
	 */
	action initBuilding {
		create Building from: shape_file_buildings with: [type::string(read ("NATURE"))] {
			switch type{
				match "School" { color <- #blue ; }
				match "Hospital" { color <- #orange; }
				match "Doctor" { color <- #green; }
				match "Pharmacy" { color <- #lightgreen; }
			}
		}
	}
}

species Building {
	/*
	 * Variables
	 */
	string type;
	rgb color <- #gray  ;
	
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
		
		vaccinate <- true;
	}
}