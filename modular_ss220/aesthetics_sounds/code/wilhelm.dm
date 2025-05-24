/turf/simulated/floor/chasm/straight_down/lava_land_surface/drop(atom/movable/AM)
	if(iscarbon(AM))
		playsound(AM.loc, 'modular_ss220/aesthetics_sounds/sound/wilhelm_scream.ogg', 50)
	. = ..()
