/***
* Name: bacteria
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model bacteria

global {
	/*
	 * PARAMETERS
	 */
	float probaResistant <- 50.0 min: 0.0 max: 100.0;
	float paramProbaDuplication<- 50.0 min: 0.0 max: 100.0;
	float paramProbaSymptom <- 50.0 min: 0.0 max: 100.0;
	
	/*
	 * INIT
	 */
	action initBacteria {
		create Bacteria number: 1 {
			isResistant <- flip(probaResistant);
			probaDuplication <- paramProbaDuplication;
			probaSymptom <- paramProbaSymptom;
		}
	}
}

species Bacteria{
	string name;
	bool isResistant;
	float probaDuplication;
	float probaSymptom;
	
	//list<Symptom> listSymptoms;
}
