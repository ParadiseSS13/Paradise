/turf/simulated/floor/mineral
	name = "mineral floor"
	icon_state = ""
	var/list/icons = list()



/turf/simulated/floor/mineral/New()
	..()
	broken_states = list("[initial(icon_state)]_dam")

/turf/simulated/floor/mineral/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		if( !(icon_state in icons) )
			icon_state = initial(icon_state)

// ALIEN ALLOY
/turf/simulated/floor/mineral/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	floor_tile = /obj/item/stack/tile/mineral/abductor
	icons = list("alienpod1", "alienpod2", "alienpod3", "alienpod4", "alienpod5", "alienpod6", "alienpod7", "alienpod8", "alienpod9")

/turf/simulated/floor/mineral/New()
	..()
	icon_state = "alienpod[rand(1,9)]"

/turf/simulated/floor/mineral/break_tile()
	return //unbreakable

/turf/simulated/floor/mineral/abductor/burn_tile()
	return //unburnable

/turf/simulated/floor/mineral/abductor/make_plating()
	return ChangeTurf(/turf/simulated/floor/plating/abductor2)


/turf/simulated/floor/plating/abductor2
	name = "alien plating"
	icon_state = "alienplating"

/turf/simulated/floor/plating/abductor2/break_tile()
	return //unbreakable

/turf/simulated/floor/plating/abductor2/burn_tile()
	return //unburnable