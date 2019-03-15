/***
* Name: road
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model road

global {
	/*
	 * PARAMETERS
	 */
	file shape_file_roads <- file("../../includes/road.shp");
	graph the_graph;

	/*
	 * INIT
	 */
	action initRoad {
		create Road from: shape_file_roads;
		
		map<Road,float> weights_map <- Road as_map (each:: each.shape.perimeter);
		the_graph <- as_edge_graph(Road) with_weights weights_map;
	}
}

species Road {
	/*
	 * Variables
	 */
	rgb color <- #black ;
	
	/*
	 * Display
	 */
	aspect geom {
		draw shape color: color;
	}
}
