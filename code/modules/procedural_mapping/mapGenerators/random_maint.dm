/*
	Bxil's absolutely shitty Random Maintenance Generator. Please curse me repeatedly while working with this.
*/

//The actual thing you should call in order to generate stuff.
//Don't change the order of the modules unless you know what you are doing!
/datum/mapGenerator/maint
		modules = list(/datum/mapGeneratorModule/bottomLayer/maintFloor,
					   /datum/mapGeneratorModule/space_adjacent/maintWall,
					   /datum/mapGeneratorModule/maintWall,
					   /datum/mapGeneratorModule/maintDoor,
					   /datum/mapGeneratorModule/conditional/maintConditionalFurniture,
					   /datum/mapGeneratorModule/maintFurniture,
					   /datum/mapGeneratorModule/maintWindow,
					   /datum/mapGeneratorModule/bottomLayer/repressurize)