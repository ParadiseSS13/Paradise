/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 250
	health = 250
	icon_state = "aliens_s"
	var/datum/action/innate/xeno_action/plant/plant_action = new

/mob/living/carbon/alien/humanoid/sentinel/GrantAlienActions()
	. = ..()
	plant_action.Grant(src)

/mob/living/carbon/alien/humanoid/sentinel/large
	name = "alien praetorian"
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "prat_s"
	pixel_x = -16
	maxHealth = 300
	health = 300
	large = 1

/mob/living/carbon/alien/humanoid/sentinel/praetorian
	name = "alien praetorian"
	maxHealth = 300
	health = 300
	large = 1

/mob/living/carbon/alien/humanoid/sentinel/large/update_icons()
	overlays.Cut()
	if(stat == DEAD)
		icon_state = "prat_dead"
	else if(stat == UNCONSCIOUS || lying || resting)
		icon_state = "prat_sleep"
	else
		icon_state = "prat_s"

	for(var/image/I in overlays_standing)
		overlays += I

/mob/living/carbon/alien/humanoid/sentinel/New()
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/sentinel
	alien_organs += new /obj/item/organ/internal/xenos/acidgland
	alien_organs += new /obj/item/organ/internal/xenos/neurotoxin
	..()

/*
/mob/living/carbon/alien/humanoid/sentinel/verb/evolve() // -- TLE
	set name = "Evolve (250)"
	set desc = "Become a Praetorian, Royal Guard to the Queen."
	set category = "Alien"

	if(plasmacheck(250))
		adjustToxLoss(-250)
		to_chat(src, "<span class=notice'>You begin to evolve!</span>")
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span class='alertalien'>[src] begins to twist and contort!</span>"), 1)
		var/mob/living/carbon/alien/humanoid/sentinel/praetorian/new_xeno = new(loc)
		if(mind)
			mind.transfer_to(new_xeno)
		else
			new_xeno.key = key
		new_xeno.mind.name = new_xeno.name
		qdel(src)
	return
*/
