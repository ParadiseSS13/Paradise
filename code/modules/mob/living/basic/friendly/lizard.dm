/mob/living/basic/lizard
	name = "lizard"
	desc = "A cute tiny lizard."
	icon = 'icons/mob/critter.dmi'
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard-dead"
	speak_emote = list("hisses")
	health = 10
	maxHealth = 10
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/effects/bite.ogg'
	melee_damage_lower = 1
	melee_damage_upper = 2
	ai_controller = /datum/ai_controller/basic_controller/lizard
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"
	faction = list("neutral", "jungle")
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	can_hide = TRUE
	pass_door_while_hidden = TRUE
	butcher_results = list(/obj/item/food/meat = 1)
	mob_biotypes = MOB_ORGANIC | MOB_BEAST | MOB_REPTILE
	gold_core_spawnable = FRIENDLY_SPAWN
	/// List of stuff that we want to eat
	var/static/list/edibles = list(
		/mob/living/basic/butterfly,
		/mob/living/basic/cockroach,
		/obj/structure/spider/spiderling
	)
	/// Lizards start with a tail
	var/has_tail = TRUE

/mob/living/basic/lizard/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/basic_eating, heal_amt_ = 5, food_types_ = edibles)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(edibles))

/datum/ai_controller/basic_controller/lizard
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = AI_FLAG_STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/random_speech/lizard,
	)

/datum/ai_planning_subtree/random_speech/lizard // all of these have to be three words long or i'm killing you. you're dead.
	speech_chance = 3
	emote_hear = list("stamps around some.", "hisses a bit.")
	emote_see = list("blehs the tongue.", "tilts the head.", "does a spin.")

/mob/living/basic/lizard/verb/lose_tail()
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

/mob/living/basic/lizard/proc/new_tail()
	has_tail = TRUE
	to_chat(src, "<span class='notice'>You regrow your tail!</span>")

/mob/living/basic/lizard/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!isdrone(user))
		user.visible_message("<span class='notice'>[user] sucks [src] into its decompiler. There's a horrible crunching noise.</span>", \
		"<span class='warning'>It's a bit of a struggle, but you manage to suck [src] into your decompiler. It makes a series of visceral crunching noises.</span>")
		new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
		C.stored_comms["metal"] += 2 // having more metal than glass because blood has iron in it
		C.stored_comms["glass"] += 1
		qdel(src)
		return TRUE
	return ..()

/mob/living/basic/lizard/wags_his_tail
	name = "Wags-His-Tail"
	real_name = "Wags-His-Tail"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/lizard/wags_his_tail/update_desc()
	. = ..()
	desc = "The official mascot of Janitalia."
