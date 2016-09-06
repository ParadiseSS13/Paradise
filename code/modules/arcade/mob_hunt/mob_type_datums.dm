
/datum/mob_type
	var/name = "Typeless"
	var/list/weakness = list()
	var/list/resistance = list()
	var/list/immunity = list()

//Type defines, to avoid spelling mistakes
/datum/mob_type/fire
	name = "Fire"
	weakness = list(/datum/mob_type/water,
					/datum/mob_type/rock,
					/datum/mob_type/ground)
	resistance = list(/datum/mob_type/bug,
					/datum/mob_type/fire,
					/datum/mob_type/grass,
					/datum/mob_type/ice,
					/datum/mob_type/steel)

/datum/mob_type/water
	name = "Water"
	weakness = list(/datum/mob_type/electric,
					/datum/mob_type/grass)
	resistance = list(/datum/mob_type/fire,
					/datum/mob_type/ice,
					/datum/mob_type/steel,
					/datum/mob_type/water)

/datum/mob_type/grass
	name = "Grass"
	weakness = list(/datum/mob_type/fire,
					/datum/mob_type/bug,
					/datum/mob_type/poison,
					/datum/mob_type/ice,
					/datum/mob_type/flying)
	resistance = list(/datum/mob_type/water,
					/datum/mob_type/grass,
					/datum/mob_type/electric,
					/datum/mob_type/ground)

/datum/mob_type/electric
	name = "Electric"
	weakness = list(/datum/mob_type/ground)
	resistance = list(/datum/mob_type/electric,
					/datum/mob_type/flying,
					/datum/mob_type/steel)

/datum/mob_type/ground
	name = "Ground"
	weakness = list(/datum/mob_type/water,
					/datum/mob_type/grass,
					/datum/mob_type/ice)
	resistance = list(/datum/mob_type/rock,
					/datum/mob_type/poison)
	immunity = list(/datum/mob_type/electric)

/datum/mob_type/rock
	name = "Rock"
	weakness = list(/datum/mob_type/water,
					/datum/mob_type/grass,
					/datum/mob_type/ground,
					/datum/mob_type/fighting,
					/datum/mob_type/steel)
	resistance = list(/datum/mob_type/fire,
					/datum/mob_type/grass,
					/datum/mob_type/poison,
					/datum/mob_type/normal)

/datum/mob_type/bug
	name = "Bug"
	weakness = list(/datum/mob_type/fire,
					/datum/mob_type/rock,
					/datum/mob_type/flying)
	resistance = list(/datum/mob_type/grass,
					/datum/mob_type/ground,
					/datum/mob_type/fighting)

/datum/mob_type/poison
	name = "Poison"
	weakness = list(/datum/mob_type/ground,
					/datum/mob_type/psychic)
	resistance = list(/datum/mob_type/grass,
					/datum/mob_type/bug,
					/datum/mob_type/fighting)

/datum/mob_type/normal
	name = "Normal"
	weakness = list(/datum/mob_type/fighting)
	immunity = list(/datum/mob_type/ghost)

/datum/mob_type/fighting
	name = "Fighting"
	weakness = list(/datum/mob_type/psychic,
					/datum/mob_type/flying)
	resistance = list(/datum/mob_type/rock,
					/datum/mob_type/bug,
					/datum/mob_type/dark)

/datum/mob_type/psychic
	name = "Psychic"
	weakness = list(/datum/mob_type/bug,
					/datum/mob_type/ghost,
					/datum/mob_type/dark)
	resistance = list(/datum/mob_type/fighting,
					/datum/mob_type/psychic)

/datum/mob_type/ghost
	name = "Ghost"
	weakness = list(/datum/mob_type/ghost,
					/datum/mob_type/dark)
	resistance = list(/datum/mob_type/bug,
					/datum/mob_type/poison)
	immunity = list(/datum/mob_type/normal,
					/datum/mob_type/fighting)

/datum/mob_type/ice
	name = "Ice"
	weakness = list(/datum/mob_type/fire,
					/datum/mob_type/rock,
					/datum/mob_type/fighting,
					/datum/mob_type/steel)
	resistance = list(/datum/mob_type/ice)

/datum/mob_type/flying
	name = "Flying"
	weakness = list(/datum/mob_type/electric,
					/datum/mob_type/rock,
					/datum/mob_type/ice)
	resistance = list(/datum/mob_type/grass,
					/datum/mob_type/bug,
					/datum/mob_type/fighting)
	immunity = list(/datum/mob_type/ground)

/datum/mob_type/bluespace
	name = "Bluespace"
	weakness = list(/datum/mob_type/ice,
					/datum/mob_type/bluespace)
	resistance = list(/datum/mob_type/fire,
					/datum/mob_type/water,
					/datum/mob_type/grass,
					/datum/mob_type/electric)

/datum/mob_type/dark
	name = "Dark"
	weakness = list(/datum/mob_type/bug,
					/datum/mob_type/fighting)
	resistance = list(/datum/mob_type/ghost,
					/datum/mob_type/dark)
	immunity = list(/datum/mob_type/psychic)

/datum/mob_type/steel
	name = "Steel"
	weakness = list(/datum/mob_type/fire,
					/datum/mob_type/ground,
					/datum/mob_type/fighting)
	resistance = list(/datum/mob_type/grass,
					/datum/mob_type/rock,
					/datum/mob_type/bug,
					/datum/mob_type/normal,
					/datum/mob_type/psychic,
					/datum/mob_type/ice,
					/datum/mob_type/flying,
					/datum/mob_type/bluespace,
					/datum/mob_type/steel)
	immunity = list(/datum/mob_type/poison)