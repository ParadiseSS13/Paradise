/area/owls
	name = "Aviary"
	icon_state = "owls"

/obj/tree1 //simple as fuck.
	name = "Tree"
	desc = "It's a tree."
	icon = 'hyntatmta/icons/effects/96x96.dmi'
	icon_state = "tree"
	anchored = 1
	pixel_x = -20
	density = 1
	opacity = 0
	layer = MOB_LAYER + 0.2

/turf/simulated/floor/grass/aviary
	name = "grass"
	icon = 'hyntatmta/icons/turfs/floors.dmi'
	icon_state = "grass_eh1"
	broken_states = list("sand")

/turf/simulated/floor/grass/aviary/update_icon()
	..()
	if(!(icon_state in list("grass_eh1", "grass_eh2", "grass_eh3", "grass_eh4", "sand")))
		icon_state = "grass_eh[pick("1","2","3","4")]"
