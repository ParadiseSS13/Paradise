/mob/living/simple_animal/lizard
	name = "lizard"
	desc = "A cute tiny lizard."
	icon = 'icons/mob/critter.dmi'
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard-dead"
	speak_emote = list("hisses")
	health = 5
	maxHealth = 5
	attacktext = "bites"
	obj_damage = 0
	melee_damage_lower = 1
	melee_damage_upper = 2
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	faction = list("neutral", "jungle")
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	can_hide = TRUE
	pass_door_while_hidden = TRUE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 1)
	can_collar = TRUE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST | MOB_REPTILE
	gold_core_spawnable = FRIENDLY_SPAWN
	var/eating_sound = 'sound/weapons/bite.ogg'
	/// Lizards start with a tail
	var/has_tail = TRUE

/mob/living/simple_animal/lizard/handle_automated_action()
	if(!stat && !buckled)
		if(prob(1))
			custom_emote(EMOTE_VISIBLE, pick("sticks out its tongue.", "wags its tail.", "lies down."))

	if(!isturf(loc))
		return
	var/list/lizard_view = view(1, src)
	for(var/mob/living/M in lizard_view)
		if(M.stat == CONSCIOUS && Adjacent(M) && HAS_TRAIT(M, TRAIT_EDIBLE_BUG))
			custom_emote(EMOTE_VISIBLE, "eats \the [M]!")
			playsound(loc, eating_sound, 20, 1)
			M.death()
			break
	for(var/obj/structure/spider/spiderling/spider in lizard_view)
		if(Adjacent(spider) && HAS_TRAIT(spider, TRAIT_EDIBLE_BUG))
			if(prob(90)) // Slippery things aren't they?
				visible_message("<span class='notice'>The spiderling skitters away from the [src]!</span>")
				spider.random_skitter()
				return
			else
				custom_emote(EMOTE_VISIBLE, "eats \the [spider]!")
				playsound(loc, eating_sound, 20, 1)
				qdel(spider)
				break

/mob/living/simple_animal/lizard/verb/lose_tail()
	set name = "Lose tail"
	set desc = "Allows you to lose your tail and escape a sticky situation. Takes 5 minutes for your tail to grow back."
	set category = "Animal"

	if(stat != CONSCIOUS)
		return
	if(!has_tail)
		to_chat(usr, "<span class='warning'>You have no tail to shed!</span>")
		return
	for(var/obj/item/grab/G in usr.grabbed_by)
		var/mob/living/carbon/M = G.assailant
		usr.visible_message("<span class='warning'>[usr] suddenly sheds their tail and slips out of [M]'s grasp!</span>")
		M.KnockDown(3 SECONDS) // FUCK I TRIPPED
		playsound(usr.loc, "sound/misc/slip.ogg", 75, 1)
		has_tail = FALSE
		addtimer(CALLBACK(src, PROC_REF(new_tail)), 5 MINUTES)

/mob/living/simple_animal/lizard/proc/new_tail()
	has_tail = TRUE
	to_chat(src, "<span class='notice'>You regrow your tail!</span>")

/mob/living/simple_animal/lizard/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!isdrone(user))
		user.visible_message("<span class='notice'>[user] sucks [src] into its decompiler. There's a horrible crunching noise.</span>", \
		"<span class='warning'>It's a bit of a struggle, but you manage to suck [src] into your decompiler. It makes a series of visceral crunching noises.</span>")
		new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
		C.stored_comms["metal"] += 2 // having more metal than glass because blood has iron in it
		C.stored_comms["glass"] += 1
		qdel(src)
		return TRUE
	return ..()
