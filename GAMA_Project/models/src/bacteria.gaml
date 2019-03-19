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
	float probaResistant <- 0.5;
	float paramProbaDuplication<- 0.5;
	float paramProbaSymptom <- 0.5;
	float paramProbaSelfMutation <- 0.5;
	float paramProbaGiveMutation <- 0.5;
	
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
