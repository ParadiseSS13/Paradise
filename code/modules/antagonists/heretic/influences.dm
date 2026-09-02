
/// The number of influences spawned per heretic
#define NUM_INFLUENCES_PER_HERETIC 5

/**
 * #Reality smash tracker
 *
 * A global singleton data that tracks all the heretic
 * influences ("reality smashes") that we've created,
 * and all of the heretics (minds) that can see them.
 *
 * Handles ensuring all minds can see influences, generating
 * new influences for new heretic minds, and allowing heretics
 * to see new influences that are created.
 */
/datum/reality_smash_tracker
	/// The total number of influences that have been drained, for tracking.
	var/num_drained = 0
	/// List of tracked influences (reality smashes)
	var/list/obj/effect/heretic_influence/smashes = list()
	/// List of minds with the ability to see influences
	var/list/datum/mind/tracked_heretics = list()

/datum/reality_smash_tracker/Destroy(force)
	if(GLOB.reality_smash_track == src)
		stack_trace("[type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
		message_admins("The [type] was deleted. Heretics may no longer access any influences. Fix it, or call coder support.")
	QDEL_LIST_CONTENTS(smashes)
	tracked_heretics.Cut()
	return ..()

/**
 * Generates a set amount of reality smashes
 * based on the number of already existing smashes
 * and the number of minds we're tracking.
 */
/datum/reality_smash_tracker/proc/generate_new_influences()
	var/how_many_can_we_make = 0
	for(var/heretic_number in 1 to length(tracked_heretics))
		how_many_can_we_make += max(NUM_INFLUENCES_PER_HERETIC - heretic_number + 1, 1)

	var/location_sanity = 0
	while((length(smashes) + num_drained) < how_many_can_we_make && location_sanity < 100)
		var/turf/chosen_location = get_safe_random_station_turf_equal_weight()

		// We don't want them close to each other - at least 1 tile of separation
		var/list/nearby_things = range(1, chosen_location)
		var/obj/effect/heretic_influence/what_if_i_have_one = locate() in nearby_things
		var/obj/effect/visible_heretic_influence/what_if_i_had_one_but_its_used = locate() in nearby_things
		if(what_if_i_have_one || what_if_i_had_one_but_its_used)
			location_sanity++
			continue

		new /obj/effect/heretic_influence(chosen_location)

/**
 * Adds a mind to the list of people that can see the reality smashes
 *
 * Use this whenever you want to add someone to the list
 */
/datum/reality_smash_tracker/proc/add_tracked_mind(datum/mind/heretic)
	tracked_heretics |= heretic

	// If our heretic's on station, generate some new influences
	if(ishuman(heretic.current) && is_teleport_allowed(heretic.current.z))
		generate_new_influences()

/**
 * Removes a mind from the list of people that can see the reality smashes
 *
 * Use this whenever you want to remove someone from the list
 */
/datum/reality_smash_tracker/proc/remove_tracked_mind(datum/mind/heretic)
	tracked_heretics -= heretic

/obj/effect/visible_heretic_influence
	name = "pierced reality"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "pierced_illusion"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	alpha = 0
	invisibility = INVISIBILITY_LEVEL_TWO

/obj/effect/visible_heretic_influence/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(show_presence)), 15 SECONDS)

	var/image/silicon_image = image('icons/effects/eldritch.dmi', src, null, OBJ_LAYER)
	silicon_image.override = TRUE
	add_alt_appearance("pierced_reality", silicon_image, GLOB.silicon_mob_list)

/obj/effect/visible_heretic_influence/add_filter(name, priority, list/params)
	return

/*
 * Makes the influence fade in after 15 seconds.
 */
/obj/effect/visible_heretic_influence/proc/show_presence()
	invisibility = 0
	animate(src, alpha = 255, time = 15 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(fade_presence)), 15 SECONDS)

/*
 * Makes the influence fade out over 20 minutes.
 */
/obj/effect/visible_heretic_influence/proc/fade_presence()
	animate(src, alpha = 0, time = 20 MINUTES)
	QDEL_IN(src, 20 MINUTES)

/obj/effect/visible_heretic_influence/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return

	if(IS_HERETIC(user))
		to_chat(user, SPAN_BOLDWARNING("You know better than to tempt forces out of your control!"))
		return TRUE

	var/mob/living/carbon/human/human_user = user
	var/dam_zone = pick("l_arm", "r_arm")
	var/obj/item/organ/external/their_poor_arm = human_user.get_organ(dam_zone)
	if(prob(25) && their_poor_arm)
		human_user.visible_message(SPAN_WARNING("An otherwordly presence tears and atomizes [human_user]'s arm as [human_user.p_they(FALSE)] try to reach into the hole in the very fabric of reality!"),SPAN_USERDANGER("An otherwordly presence tears and atomizes your [their_poor_arm.name] as you try to touch the hole in the very fabric of reality!"))
		their_poor_arm.droplimb()
		qdel(their_poor_arm)
		human_user.update_body()
	else
		to_chat(human_user,SPAN_DANGER("You pull your hand away from the hole as the eldritch energy flails, trying to latch onto existence itself!"))
	return TRUE

/obj/effect/visible_heretic_influence/attack_tk(mob/user)
	if(!ishuman(user))
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN

	if(IS_HERETIC(user))
		to_chat(user, SPAN_BOLDWARNING("You know better than to tempt forces out of your control!"))
		return

	var/mob/living/carbon/human/human_user = user

	// A very elaborate way to suicide
	to_chat(human_user, SPAN_USERDANGER("Eldritch energy lashes out, piercing your fragile mind, tearing it to pieces!"))
	human_user.ghostize()
	var/obj/item/organ/external/head/head = locate() in human_user.bodyparts
	if(head)
		head.droplimb()
		qdel(head)
	else
		human_user.gib()
	var/datum/effect_system/reagents_explosion/explosion = new()
	explosion.set_up(1, get_turf(human_user), TRUE, 0)
	explosion.start(src)

/obj/effect/visible_heretic_influence/examine(mob/user)
	. = ..()
	if(IS_HERETIC(user) || !ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	to_chat(human_user, SPAN_USERDANGER("Your mind burns as you stare at the tear!"))
	human_user.adjustBrainLoss(10)
	human_user.AdjustConfused(10 SECONDS, 10 SECONDS, 60 SECONDS)

/obj/effect/heretic_influence
	name = "reality smash"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "reality_smash"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_LEVEL_TWO
	hud_possible = list(HERETIC_HUD)
	/// Whether we're currently being drained or not.
	var/being_drained = FALSE

/obj/effect/heretic_influence/Initialize(mapload)
	. = ..()
	GLOB.reality_smash_track.smashes += src
	generate_name()
	prepare_huds()
	var/datum/atom_hud/data/heretic/h_hud = GLOB.huds[DATA_HUD_HERETIC]
	h_hud.add_to_hud(src)
	do_hud_stuff()


/obj/effect/heretic_influence/Destroy()
	GLOB.reality_smash_track.smashes -= src
	return ..()

/obj/effect/heretic_influence/add_fingerprint(mob/living/M, ignoregloves)
	return //No detective you can not scan the fucking influence to find out who touched it


/obj/effect/heretic_influence/attack_hand(mob/user)

	if(!IS_HERETIC(user)) // Shouldn't be able to do this, but just in case
		return

	INVOKE_ASYNC(src, PROC_REF(drain_influence), user, 1)


/obj/effect/heretic_influence/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(..())
		return
	// Using a codex will give you two knowledge points for draining.
	if(drain_influence_with_codex(user, used))
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/effect/heretic_influence/proc/drain_influence_with_codex(mob/user, obj/item/codex_cicatrix/codex)
	if(!istype(codex) || being_drained)
		return FALSE
	if(!codex.book_open)
		codex.activate_self(user) // open booke
	INVOKE_ASYNC(src, PROC_REF(drain_influence), user, 2)
	return TRUE

/**
 * Begin to drain the influence, setting being_drained,
 * registering an examine signal, and beginning a do_after.
 *
 * If successful, the influence is drained and deleted.
 */
/obj/effect/heretic_influence/proc/drain_influence(mob/living/user, knowledge_to_gain)

	being_drained = TRUE
	to_chat(user, SPAN_NOTICE("You begin to drain the influence..."))

	if(!do_after(user, 10 SECONDS, target = src, hidden = TRUE))
		being_drained = FALSE
		return


	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	heretic_datum.knowledge_points += knowledge_to_gain

	// Aaand now we delete it
	after_drain(user)

/**
 * Handle the effects of the drain.
 */
/obj/effect/heretic_influence/proc/after_drain(mob/living/user)
	if(user)
		to_chat(user, SPAN_HIEROPHANT("[pick_list(HERETIC_INFLUENCE_FILE, "drain_message")]"))
		to_chat(user, SPAN_WARNING("[src] begins to fade into reality!"))

	var/obj/effect/visible_heretic_influence/illusion = new /obj/effect/visible_heretic_influence(drop_location())
	illusion.name = "\improper" + pick_list(HERETIC_INFLUENCE_FILE, "drained") + " " + format_text(name)

	GLOB.reality_smash_track.num_drained++
	qdel(src)

/**
 * Generates a random name for the influence.
 */
/obj/effect/heretic_influence/proc/generate_name()
	name = "\improper" + pick_list(HERETIC_INFLUENCE_FILE, "prefix") + " " + pick_list(HERETIC_INFLUENCE_FILE, "postfix")

#undef NUM_INFLUENCES_PER_HERETIC

