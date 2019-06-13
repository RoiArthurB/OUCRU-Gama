/***
* Name: building
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model building

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
	
	/*
	 * Display
	 */
	aspect geom {
		draw shape color: color;
	}
	
	action vaccination{
		write("cot");
		write(self);
	}
}