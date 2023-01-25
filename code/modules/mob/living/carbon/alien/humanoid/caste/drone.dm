/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 180
	health = 180
	icon_state = "aliend_s"

	var/datum/action/innate/xeno_action/evolve_to_queen/evolve_to_queen_action = new

/mob/living/carbon/alien/humanoid/drone/New()
	if(src.name == "alien drone")
		src.name = text("alien drone ([rand(1, 1000)])")
	src.real_name = src.name
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/drone
	alien_organs += new /obj/item/organ/internal/xenos/acidgland
	alien_organs += new /obj/item/organ/internal/xenos/resinspinner
	..()

/mob/living/carbon/alien/humanoid/drone/GrantAlienActions()
	. = ..()
	evolve_to_queen_action.Grant(src)

//Drones use the same base as generic humanoids.
//Drone verbs

/datum/action/innate/xeno_action/evolve_to_queen // -- TLE
	name = "Evolve (500)"
	desc = "Produce an interal egg sac capable of spawning children. Only one queen can exist at a time."
	button_icon_state = "alien_evolve_drone"

/datum/action/innate/xeno_action/evolve_to_queen/Activate()
	var/mob/living/carbon/alien/humanoid/drone/drone_host = owner

	if(plasmacheck(500))
		// Queen check
		var/no_queen = 1
		for(var/mob/living/carbon/alien/humanoid/queen/Q in GLOB.alive_mob_list)
			if(!Q.key && Q.get_int_organ(/obj/item/organ/internal/brain/))
				continue
			no_queen = 0

		if(drone_host.has_brain_worms())
			to_chat(drone_host, "<span class='warning'>We cannot perform this ability at the present time!</span>")
			return
		if(no_queen)
			drone_host.adjustPlasma(-500)
			to_chat(drone_host, "<span class='noticealien'>You begin to evolve!</span>")
			for(var/mob/O in viewers(drone_host, null))
				O.show_message(text("<span class='alertalien'>[drone_host] begins to twist and contort!</span>"), 1)
			var/mob/living/carbon/alien/humanoid/queen/new_xeno = new(drone_host.loc)
			drone_host.mind.transfer_to(new_xeno)
			new_xeno.mind.name = new_xeno.name
			qdel(drone_host)
		else
			to_chat(drone_host, "<span class='notice'>We already have an alive queen.</span>")
	return

/mob/living/carbon/alien/humanoid/drone/no_queen
	name = "alien drone"

/mob/living/carbon/alien/humanoid/drone/no_queen/GrantAlienActions()
	. = ..()
	evolve_to_queen_action.Remove(src)
