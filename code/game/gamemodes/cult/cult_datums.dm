//cult datums by FalseIncarnate
/datum/cult_info
	var/name = "Cult of Nar'Sie"
	var/theme = "blood"

	//God Entity
	var/entity_name = "Nar'Sie"
	var/entity_title1 = "The Dark One"
	var/entity_title2 = "The One Who Sees"
	var/entity_title3 = "The Geometer of Blood"
	var/entity_icon_state = ""


	//Builder Construct
	var/artificer_name = "Artificer"
	var/artificer_icon_state = "artificer"
	var/artificer_dead_state = "shade_dead"

	//Behemoth Construct
	var/behemoth_name = "Behemoth"
	var/behemoth_icon_state = "behemoth"
	var/behemoth_dead_state = "shade_dead"

	//Wraith Construct
	var/wraith_name = "Wraith"
	var/wraith_icon_state = "floating"
	var/wraith_dead_state = "shade_dead"

	//Armored Construct
	var/juggernaut_name = "Juggernaut"
	var/juggernaut_icon_state = "armour"
	var/juggernaut_dead_state = "shade_dead"

	//Harvester Construct
	var/harvester_name = "Harvester"
	var/harvester_icon_state = "harvester"
	var/harvester_dead_state = "shade_dead"

	//Shade Spirit
	var/shade_name = "Shade"
	var/shade_icon_state = "shade"
	var/shade_dead_state = "shade_dead"

	//Turfs
	var/cult_floor_icon_state = "cult"
	var/cult_wall_icon_state = "cult"

/datum/cult_info/fire
	name = "Cult of Pyr'Kaeus"
	theme = "fire"

	entity_name = "Pyr'Kaeus"
	entity_title1 = "The Burning One"
	entity_title2 = "The One Who Consumes"
	entity_title3 = "The Harbinger of Fire"

	artificer_name = "Igniting Ember"

	behemoth_name = "Devouring Hatred"

	wraith_name = "Living Flame"

	juggernaut_name = "Pyre Armor"

	harvester_name = "Coal Seeker"

	shade_name = "Charred Soul"

/datum/cult_info/death
	name = "Cult of Mortality"
	theme = "death"

	entity_name = "The Reaper"
	entity_title1 = "The Silent One"
	entity_title2 = "The One Who Beckons"
	entity_title3 = "The Ferryman of Oblivion"

	artificer_name = "Boneshaper"

	behemoth_name = "Draugr"

	wraith_name = "Wraith"

	juggernaut_name = "Wight"

	harvester_name = "Psychopomp"

	shade_name = "Banshee"