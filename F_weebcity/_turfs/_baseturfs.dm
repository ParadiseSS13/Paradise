/*
LAZY ASS TURF DEFINITION
*/
/turf/simulated/floor/plating/desert_sand
	name = "sand"
	icon = 'F_weebcity/icons/turfs/desertsand.dmi'
	icon_state = "sand1"
	gender = PLURAL
	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_LAVA
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	planetary_atmos = TRUE
	baseturf = /turf/simulated/floor/plating/desert_sand //we become ourself

/turf/simulated/floor/plating/desert_sand/Initialize(mapload)
	. = ..()
	if(prob(2))
		icon_state = "sand[rand(2,4)]" //Randomized sand icon

/turf/simulated/floor/plating/desert_sand/ex_act()
	return

/turf/simulated/floor/plating/desert_sand/acid_act(acidpwr, acid_volume)
	return

/turf/simulated/floor/plating/desert_sand/singularity_act()
	return

/turf/simulated/floor/plating/desert_sand/singularity_pull(S, current_size)
	return

/turf/simulated/floor/plating/desert_sand/make_plating()
	return

/turf/simulated/floor/plating/desert_sand/remove_plating()
	return

/turf/simulated/floor/plating/desert_sand/attackby(obj/item/C, mob/user, params)
	return

/turf/simulated/floor/plating/desert_sand/screwdriver_act()
	return

/turf/simulated/floor/plating/desert_sand/welder_act()
	return

/turf/simulated/floor/plating/desert_sand/break_tile()
	return

/turf/simulated/floor/plating/desert_sand/burn_tile()
	return
