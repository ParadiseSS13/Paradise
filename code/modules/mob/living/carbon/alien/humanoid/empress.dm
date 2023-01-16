/mob/living/carbon/alien/humanoid/empress
	name = "alien empress"
	caste = "q"
	maxHealth = 900
	health = 900
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	mob_size = MOB_SIZE_LARGE
	bubble_icon = "alienroyal"
	large = 1
	ventcrawler = 0

/mob/living/carbon/alien/humanoid/empress/large
	name = "alien empress"
	caste = "e"
	icon = 'icons/mob/alienhuge.dmi'
	icon_state = "empress_s"
	pixel_x = -32

/mob/living/carbon/alien/humanoid/empress/large/update_icons()
	overlays.Cut()

	if(stat == DEAD)
		icon_state = "empress_dead"
	else if(stat == UNCONSCIOUS || lying || resting)
		icon_state = "empress_sleep"
	else
		icon_state = "empress_s"

	for(var/image/I in overlays_standing)
		overlays += I

/mob/living/carbon/alien/humanoid/empress/New()
	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/empress/E in GLOB.alive_mob_list)
		if(E == src)
			continue
		if(E.stat == DEAD)
			continue
		if(E.client)
			name = "alien grand princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = name
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/queen
	alien_organs += new /obj/item/organ/internal/xenos/acidgland
	alien_organs += new /obj/item/organ/internal/xenos/eggsac
	alien_organs += new /obj/item/organ/internal/xenos/resinspinner
	alien_organs += new /obj/item/organ/internal/xenos/neurotoxin
	..()

/datum/action/innate/xeno_action/lay_egg
	name = "Lay Egg (250)"
	desc = "Lay an egg to produce huggers to impregnate prey with."
	button_icon_state = "alien_egg"

/datum/action/innate/xeno_action/lay_egg/Activate()
	var/mob/living/carbon/alien/humanoid/empress/host = owner

	if(locate(/obj/structure/alien/egg) in get_turf(owner))
		to_chat(owner, "<span class='noticealien'>There's already an egg here.</span>")
		return

	if(plasmacheck(250,1))//Can't plant eggs on spess tiles. That's silly.
		host.adjustPlasma(-250)
		for(var/mob/O in viewers(owner, null))
			O.show_message(text("<span class=notice'><B>[src] has laid an egg!</B></span>"), 1)
		new /obj/structure/alien/egg(owner.loc)
	return
