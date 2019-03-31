/turf/simulated/floor/indestructible
	unacidable = TRUE

/turf/simulated/floor/indestructible/ex_act(severity)
	return

/turf/simulated/floor/indestructible/blob_act()
	return

/turf/simulated/floor/indestructible/singularity_act()
	return

/turf/simulated/floor/indestructible/singularity_pull(S, current_size)
	return

/turf/simulated/floor/indestructible/narsie_act()
	return

/turf/simulated/floor/indestructible/ratvar_act(force, ignore_mobs)
	return

/turf/simulated/floor/indestructible/burn_down()
	return

/turf/simulated/floor/indestructible/attackby(obj/item/I, mob/user, params)
	return 

/turf/simulated/floor/indestructible/attack_hand(mob/user)
	return 

/turf/simulated/floor/indestructible/attack_hulk(mob/user, does_attack_animation = FALSE)
	return

/turf/simulated/floor/indestructible/attack_animal(mob/living/simple_animal/M)
	return
	
/turf/simulated/floor/indestructible/mech_melee_attack(obj/mecha/M)
	return

/turf/simulated/floor/indestructible/necropolis
	name = "necropolis floor"
	desc = "It's regarding you suspiciously."
	icon = 'icons/turf/floors.dmi'
	icon_state = "necro1"
	baseturf = /turf/simulated/floor/indestructible/necropolis
	oxygen = 14
	nitrogen = 23
	temperature = 300

/turf/simulated/floor/indestructible/necropolis/Initialize()
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/simulated/floor/indestructible/necropolis/air
	oxygen = 0
	nitrogen = 0
	temperature = T20C

/turf/simulated/floor/indestructible/boss //you put stone tiles on this and use it as a base
	name = "necropolis floor"
	icon = 'icons/turf/floors/boss_floors.dmi'
	icon_state = "boss"
	baseturf = /turf/simulated/floor/indestructible/boss
	oxygen = 14
	nitrogen = 23
	temperature = 300

/turf/simulated/floor/indestructible/boss/air
	oxygen = 0
	nitrogen = 0
	temperature = T20C

/turf/simulated/floor/indestructible/hierophant
	icon_state = "hierophant1"
	oxygen = 14
	nitrogen = 23
	temperature = 300
	desc = "A floor with a square pattern. It's faintly cool to the touch."

/turf/simulated/floor/indestructible/hierophant/two
	icon_state = "hierophant2"
