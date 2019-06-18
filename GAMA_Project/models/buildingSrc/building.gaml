/***
* Name: building
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model building

import "residential.gaml"
import "doctor.gaml"
import "hospital.gaml"
import "pharmacy.gaml"
import "school.gaml"

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
		
		do initResidential();
		
		do initSchool();
		do initHospital();
		do initDoctor();
		do initPharmacy();
	}
}

species Building {
	/*
	 * Variables
	 */
	string type;
	rgb color <- #gray;
	
	string iconPath update: vaccinate ? "../../includes/syringe.png" : "";
	
	bool vaccinate <- false update: (current_hour = 0) ? false : vaccinate;
	
	/*
	 * Display
	 */
	aspect geom {
		draw shape color: color;
	}
	
	action vaccination {
		write(self);
		self.vaccinate <- true;
	}
}