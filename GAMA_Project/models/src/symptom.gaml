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
		bool bacterial <- false;
		
		loop times: 2 {
			bacterial <- !bacterial;
			loop s over:["Sneezing", "Cough", "Difficulty breathing"] {
				
				// Transmission
				create Symptom {
					name <- s;
					isBacterial <- bacterial;
				}
			}
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
	bool isBacterial;
}

