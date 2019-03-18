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
	action initBacteria {
		create Bacteria number: 1 {
			isResistant <- flip(probaResistant);
			probaDuplication <- paramProbaDuplication;
			probaSymptom <- paramProbaSymptom;
			
			probaSelfMutation <- paramProbaSelfMutation;
			probaGiveMutation<- paramProbaGiveMutation;
		}
	}
}

species Bacteria{
	string name;
	bool isResistant;
	float probaDuplication;
	float probaSymptom;
	
	float probaSelfMutation;
	float probaGiveMutation;
	
	list<Symptom> listSymptoms;
	
	reflex duplicate /* when: [TIME] */ {
		if flip(self.probaDuplication) {
			// Duplicate bacteria
			create Bacteria {
				isResistant <- self.isResistant;
				probaDuplication <- self.probaDuplication;
				probaSymptom <- self.probaSymptom;
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
