/***
* Name: bacteria
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model bacteria

import "symptom.gaml"

global {
	/*
	 * PARAMETERS
	 */
	float probaResistant <- 50.0 min: 0.0 max: 100.0;
	float paramProbaDuplication<- 50.0 min: 0.0 max: 100.0;
	float paramProbaSymptom <- 50.0 min: 0.0 max: 100.0;
	float paramProbaSelfMutation <- 50.0 min: 0.0 max: 100.0;
	float paramProbaGiveMutation <- 50.0 min: 0.0 max: 100.0;
	
	/*
	 * INIT
	 */
	list<Bacteria> initBacteriaPopulation(int nbr) {
		create Bacteria number: nbr returns: returnList {
			isResistant <- flip(probaResistant);
			probaDuplication <- paramProbaDuplication;
			
			probaSelfMutation <- paramProbaSelfMutation;
			probaGiveMutation<- paramProbaGiveMutation;
			
			if flip(paramProbaSymptom){
				add one_of(Symptom) to: self.listSymptoms;
			}
		}
		
		return returnList;
	}
}

species Bacteria{
	string name;
	bool isResistant;
	float probaDuplication;
	
	float probaSelfMutation;
	float probaGiveMutation;
	
	list<Symptom> listSymptoms;
	
	reflex duplicate /* when: [TIME] */ {
		if flip(self.probaDuplication) {
			// Duplicate bacteria
			create Bacteria {
				isResistant <- self.isResistant;
				probaDuplication <- self.probaDuplication;
			
				probaSelfMutation <- paramProbaSelfMutation;
				probaGiveMutation<- paramProbaGiveMutation;
			}
		}
	}

	action addSymptom {
		// Pick random symptom new
		add Symptom to: self.listSymptoms;
	}
	action addSymptom(Symptom s) {
		add s to: self.listSymptoms;
	}

	reflex selfMutation /* when: [TIME] */ {
		if flip(self.probaSelfMutation) {
			do addSymptom;
		}
	}
	reflex giveMutation /* when: [TIME] */ {
		if flip(self.probaGiveMutation){
			ask one_of(Bacteria) { // in same person
				do addSymptom( one_of(self.listSymptoms) );
			}
		}
	}
}
