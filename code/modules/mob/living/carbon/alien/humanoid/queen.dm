/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 640
	health = 640
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	heal_rate = 5
	large = 1
	ventcrawler = 0
	pressure_resistance = 200 //Because big, stompy xenos should not be blown around like paper.
	tts_seed = "Queen"

/mob/living/carbon/alien/humanoid/queen/New()
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in GLOB.alive_mob_list)
		if(Q == src)
			continue
		if(Q.stat == DEAD)
			continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	grant_all_babel_languages()
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/queen
	alien_organs += new /obj/item/organ/internal/xenos/acidgland
	alien_organs += new /obj/item/organ/internal/xenos/eggsac
	alien_organs += new /obj/item/organ/internal/xenos/resinspinner
	alien_organs += new /obj/item/organ/internal/xenos/neurotoxin
	..()

/mob/living/carbon/alien/humanoid/queen/movement_delay()
	. = ..()
	. += 3

/mob/living/carbon/alien/humanoid/queen/can_inject(mob/user, error_msg, target_zone, penetrate_thick)
	return FALSE

//Queen verbs
/datum/action/innate/xeno_action/lay_egg_queen
	name = "Lay Egg (75)"
	desc = "Lay an egg to produce huggers to impregnate prey with."
	button_icon_state = "alien_egg"

/datum/action/innate/xeno_action/lay_egg_queen/Activate()
	var/mob/living/carbon/alien/humanoid/queen/host = owner

	if(locate(/obj/structure/alien/egg) in get_turf(owner))
		to_chat(host, "<span class='noticealien'>There's already an egg here.</span>")
		return

	if(plasmacheck(75,1))//Can't plant eggs on spess tiles. That's silly.
		host.adjustPlasma(-75)
		for(var/mob/O in viewers(host, null))
			O.show_message(text("<span class=notice'><B>[host] has laid an egg!</B></span>"), 1)
		new /obj/structure/alien/egg(host.loc)
	return

/mob/living/carbon/alien/humanoid/queen/large
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "queen_s"
	pixel_x = -16
	large = 1

/mob/living/carbon/alien/humanoid/queen/large/update_icons()
	overlays.Cut()

	if(stat == DEAD)
		icon_state = "queen_dead"
	else if(stat == UNCONSCIOUS || lying || resting)
		icon_state = "queen_sleep"
	else
		icon_state = "queen_s"

	for(var/image/I in overlays_standing)
		overlays += I
