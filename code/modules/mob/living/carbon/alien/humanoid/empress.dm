/mob/living/carbon/alien/humanoid/empress
	name = "alien empress"
	caste = "q"
	maxHealth = 700
	health = 700
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	loudspeaker = TRUE
	mob_size = MOB_SIZE_LARGE
	bubble_icon = "alienroyal"
	large = 1
	ventcrawler = 0
	move_resist = MOVE_FORCE_STRONG //Yes, big benos is huge and heavy
	alien_disarm_damage = 60 //Empress do higher disarm stamina damage than normal aliens
	alien_slash_damage = 30 //Empress do higher slashing damage to people

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
	else if(stat == UNCONSCIOUS || IS_HORIZONTAL(src))
		icon_state = "empress_sleep"
	else
		icon_state = "empress_s"

	for(var/image/I in overlays_standing)
		overlays += I

/mob/living/carbon/alien/humanoid/empress/Initialize(mapload)
	. = ..()
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

/mob/living/carbon/alien/humanoid/empress/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/queen,
		/obj/item/organ/internal/xenos/acidgland,
		/obj/item/organ/internal/xenos/eggsac,
		/obj/item/organ/internal/xenos/resinspinner,
		/obj/item/organ/internal/xenos/neurotoxin,
	)

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
