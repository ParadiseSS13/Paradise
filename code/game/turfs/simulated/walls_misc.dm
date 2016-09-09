/turf/simulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult"
	walltype = "cult"
	canSmoothWith = null

/turf/simulated/wall/cult/narsie_act()
	return

/turf/simulated/wall/rust
	name = "rusted wall"
	desc = "A rusted metal wall."
	icon = 'icons/turf/walls/rusty_wall.dmi'
	icon_state = "arust"
	walltype = "arust"

/turf/simulated/wall/r_wall/rust
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon = 'icons/turf/walls/rusty_reinforced_wall.dmi'
	icon_state = "rrust"
	walltype = "rrust"

/turf/simulated/wall/r_wall/coated			//Coated for heat resistance
	name = "coated reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms. It seems to have additional plating to protect against heat."
	icon = 'icons/turf/walls/coated_reinforced_wall.dmi'
	max_temperature = INFINITY