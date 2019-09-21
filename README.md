# OUCRU / GAMA Project

[![Language](http://img.shields.io/badge/language-GAML-brightgreen.svg)](https://gama-platform.github.io/wiki/StartWithGAML)
![GitHub](https://img.shields.io/github/license/RoiArthurB/OUCRU-Gama.svg)

[![GitHub issues](https://img.shields.io/github/issues/RoiArthurB/OUCRU-Gama.svg)](https://github.com/RoiArthurB/OUCRU-Gama/issues)
![GitHub last commit](https://img.shields.io/github/last-commit/RoiArthurB/OUCRU-Gama.svg)
![Maintenance](https://img.shields.io/maintenance/yes/2019.svg)

## Background

### OUCRU

The Oxford University Clinical Research Unit (OUCRU) in Hanoi is a small research group split across two sites – The National Hospital for Tropical Diseases (NHTD), and the National Institute for Hygiene and Epidemiology (NIHE). The group is involved with a range of research activities, mainly related to infectious diseases, with a particular focus on antibiotic resistance, vaccine-preventable diseases and influenza. It is also largely involved in translating research results into actionable policies, together with the Ministry of Health.

## Description

Our group is involved in a lot of population-based research around antibiotic use and antibiotic resistance. Levels of antibiotic use in Vietnam are very high, leading to the emergence and spread of bacterial strains that are resistant to antibiotic therapy.

_Streptococcus pneumoniae_ is a bacteria that is commonly found inside the nose and throat, and usually does no harm. When this bacteria gets into the wrong places it can cause a clinical infection, such as pneumonia. If the strain of bacteria responsible for this infection is resistant to antibiotic therapy, the infection can become very difficult to treat. 

### Agent-Based Modeling 

We would like to develop an agent-based model to explore the emergence and transmission of resistant strains of _S. pneumoniae_ in the community, and how this is related to current patterns of antibiotic use. Further, we would like to explore the potential effect of introducing public health interventions that may target the emergence of resistant strains (e.g. behavior-change interventions targeting unnecessary antibiotic use), or the transmission of resistant strains (e.g. vaccination, hand hygiene). 

To do so, we will use the _[GAMA Platform](https://gama-platform.github.io/)_. _GAMA_ (_GIS Agent-based Modeling Architecture_) is an open-source software which has been developed with a very general approach, and can be used for many applications domains. _GAML_ is the language used in GAMA, coded in Java. It is an agent-based language, that provides you the possibility to build your model with several paradigms of modeling. It is developed by several teams under the umbrella of the IRD/UPMC international research unit [UMMISCO](http://www.ummisco.ird.fr/).

## Usage

### Prerequisites

* A working _GAMA Platform_ version above _GAMA 1.8 RC 2_ installed
* A clone of this repository unziped on your computer

### Launching the project in GAMA

You should start GAMA and set the root of the project (`/path/to/OUCRU-Gama`) as the workspace :

![Exemple workspace window](https://i.imgur.com/Dr5dacJ.png)

And start GAMA normaly with this.

### Starting the simulation

In the main view, open the `main.gaml` file from the explorer on the left panel and press the green button `main` on top of the text editor

![view of the main view of GAMA with main.gaml open](https://i.imgur.com/jQfNQy8.png)

This will change the view from the _editor view_ to the _simulation view_ :

![Simulation view](https://i.imgur.com/lDwNOoA.png)

And from this view, you just have to press the green play button ( ▶️ ) to start the simulation and use the model

## Built With

* [GAMA Platform _1.8.0_](https://gama-platform.github.io/) - GAMA is a modeling and simulation development environment for building spatially explicit agent-based simulations.
* [_GAMA Language_ (_GAML_)](https://gama-platform.github.io/wiki/StartWithGAML) - Custom high level language to create models with _GAMA_.
* [OpenJDK 8](https://openjdk.java.net/) _or_ [Oracle JDK 8](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) - The Java Development Kit is an implementation of either one of the Java Platform released by Oracle Corporation in the form of a binary product.

## Support

Please post issues about that project here:  

    https://github.com/RoiArthurB/OUCRU-Gama/issues

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Authors

* **Arthur Brugiere** - *Initial work* - [RoiArthurB](https://github.com/RoiArthurB)

See also the list of [contributors](https://github.com/RoiArthurB/OUCRU-Gama/contributors) who participated in this project.

## License

This project is licensed under the GPL3 License - see the [LICENSE.md](LICENSE.md) file for details

<!--- ## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc -->
