/***
* Name: symptom
* Author: roiarthurb
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model symptom

/* Insert your model definition here */
global{
	action initSymptoms{
		/*
		 * https://doi.org/10.1038/s41579-018-0001-8
		 */
		 
		// Transmission
		create Symptom {
			name <- "Sneezing";
		}
		
		// Pneumonia
		create Symptom {
			name <- "Cough";
		}
		create Symptom {
			name <- "Difficulty breathing";
		}
		
		// Internal symptoms
		//	-> No transmission (headache, fever, etc...)
		create Symptom {
			name <- "Sick";
		}
		
		/*
		create Symptom {
			name <- "Fever";
		}
		
		// Meningitis
		create Symptom {
			name <- "Headache";
		}
		
		// Otitis media
		create Symptom {
			name <- "Ear pain";
		}
		*/
	}
}

species Symptom{
	string name;
}

