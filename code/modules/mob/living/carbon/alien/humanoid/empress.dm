/mob/living/carbon/alien/humanoid/empress
	name = "alien empress"
	caste = "q"
	maxHealth = 700
	health = 700
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	mob_size = MOB_SIZE_LARGE
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
	create_reagents(100)

	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/empress/E in GLOB.living_mob_list)
		if(E == src)		continue
		if(E.stat == DEAD)	continue
		if(E.client)
			name = "alien grand princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/queen
	alien_organs += new /obj/item/organ/internal/xenos/acidgland
	alien_organs += new /obj/item/organ/internal/xenos/eggsac
	alien_organs += new /obj/item/organ/internal/xenos/resinspinner
	alien_organs += new /obj/item/organ/internal/xenos/neurotoxin
	..()

/mob/living/carbon/alien/humanoid/empress

	handle_regular_hud_updates()

		..() //-Yvarov

		if(src.healths)
			if(src.stat != 2)
				switch(health)
					if(250 to INFINITY)
						src.healths.icon_state = "health0"
					if(175 to 250)
						src.healths.icon_state = "health1"
					if(100 to 175)
						src.healths.icon_state = "health2"
					if(50 to 100)
						src.healths.icon_state = "health3"
					if(0 to 50)
						src.healths.icon_state = "health4"
					else
						src.healths.icon_state = "health5"
			else
				src.healths.icon_state = "health6"

/mob/living/carbon/alien/humanoid/empress/verb/lay_egg()
	set name = "Lay Egg (250)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"

	if(locate(/obj/structure/alien/egg) in get_turf(src))
		to_chat(src, "<span class='noticealien'>There's already an egg here.</span>")
		return

	if(powerc(250,1))//Can't plant eggs on spess tiles. That's silly.
		adjustPlasma(-250)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<span class=notice'><B>[src] has laid an egg!</B></span>"), 1)
		new /obj/structure/alien/egg(loc)
	return
