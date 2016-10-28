/turf/simulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult"
	builtin_sheet = null
	canSmoothWith = null
	smooth = SMOOTH_FALSE

/turf/simulated/wall/cult/New()
	..()
	if(ticker.mode)//game hasn't started offically don't do shit..
		new /obj/effect/overlay/temp/cult/turf(src)
		icon_state = ticker.mode.cultdat.cult_wall_icon_state

/turf/simulated/wall/cult/artificer
	name = "runed stone wall"
	desc = "A cold stone wall engraved with indecipherable symbols. Studying them causes your head to pound."


/turf/simulated/wall/cult/narsie_act()
	return

/turf/simulated/wall/cult/break_wall()
	new /obj/effect/decal/cleanable/blood(src)
	return (new /obj/structure/cultgirder(src))

/turf/simulated/wall/cult/devastate_wall()
	new /obj/effect/decal/cleanable/blood(src)
	new /obj/effect/decal/remains/human(src)

/turf/simulated/wall/rust
	name = "rusted wall"
	desc = "A rusted metal wall."
	icon = 'icons/turf/walls/rusty_wall.dmi'
	icon_state = "arust"

/turf/simulated/wall/r_wall/rust
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon = 'icons/turf/walls/rusty_reinforced_wall.dmi'
	icon_state = "rrust"

/turf/simulated/wall/r_wall/coated			//Coated for heat resistance
	name = "coated reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms. It seems to have additional plating to protect against heat."
	icon = 'icons/turf/walls/coated_reinforced_wall.dmi'
	max_temperature = INFINITY