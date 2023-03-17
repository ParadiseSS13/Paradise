/datum/species/kidan
	name = "Kidan"
	name_plural = "Kidan"
	icobase = 'icons/mob/human_races/r_kidan.dmi'
	language = "Chittin"
	unarmed_type = /datum/unarmed_attack/claws

	brute_mod = 0.8
	hunger_drain = 0.15
	tox_mod = 1.7

	species_traits = list(NO_HAIR)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_HEAD_ACCESSORY | HAS_HEAD_MARKINGS | HAS_BODY_MARKINGS | HAS_BODYACC_COLOR | SHAVED
	eyes = "kidan_eyes_s"
	dietflags = DIET_HERB
	flesh_color = "#ba7814"
	blood_color = "#FB9800"
	reagent_tag = PROCESS_ORG
	//Default styles for created mobs.
	default_headacc = "Normal Antennae"
	butt_sprite = "kidan"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/kidan,
		"lungs" =    /obj/item/organ/internal/lungs/kidan,
		"liver" =    /obj/item/organ/internal/liver/kidan,
		"kidneys" =  /obj/item/organ/internal/kidneys/kidan,
		"brain" =    /obj/item/organ/internal/brain/kidan,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/kidan,
		"lantern" =  /obj/item/organ/internal/lantern
		)

	allowed_consumed_mobs = list(/mob/living/simple_animal/diona)

	suicide_messages = list(
		"is attempting to bite their antenna off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is cracking their exoskeleton!",
		"is stabbing themselves with their mandibles!",
		"is holding their breath!")

/datum/species/kidan/get_species_runechat_color(mob/living/carbon/human/H)
	var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
	return E.eye_color

// They receive a HUD for seeing and an action to create pheromones
/datum/species/kidan/on_species_gain(mob/living/carbon/human/H)
	..()
	// HUD for detecting pheromones
	var/datum/atom_hud/kidan_hud = GLOB.huds[DATA_HUD_KIDAN_PHEROMONES]
	kidan_hud.add_hud_to(H)

	// Action for creating pheromones
	var/datum/action/innate/produce_pheromones/produce_pheromones = new()
	produce_pheromones.Grant(H)

/datum/species/kidan/on_species_loss(mob/living/carbon/human/H)
	..()
	// Removing the HUD for detecting pheromones
	var/datum/atom_hud/kidan_hud = GLOB.huds[DATA_HUD_KIDAN_PHEROMONES]
	kidan_hud.remove_hud_from(H)

	// Removing the action for creating pheromones
	for(var/datum/action/innate/produce_pheromones/action in H.actions)
		action.Remove(H)

/// Pheromones spawnable by kida, only perceivable by other kida
/obj/effect/kidan_pheromones
	name = "kidan pheromones"
	desc = "Special pheromones secreted by a kidan."
	gender = PLURAL
	hud_possible = list(KIDAN_PHEROMONES_HUD)

	// This is to make it visible for observers and mappers at the same time
	invisibility = INVISIBILITY_OBSERVER
	icon_state = "kidan_pheromones"
	alpha = 220

	/// The message added by its creator, visible upon examine
	var/encoded_message
	/// Delete self after this timer is up
	var/lifespan = 15 MINUTES

/obj/effect/kidan_pheromones/Initialize(mapload)
	. = ..()

	// Add itself to the kidan hud
	prepare_huds()
	for(var/datum/atom_hud/kidan_pheromones/kidan_hud in GLOB.huds)
		kidan_hud.add_to_hud(src)
	var/image/holder = hud_list[KIDAN_PHEROMONES_HUD]
	holder.icon = icon
	holder.icon_state = icon_state
	holder.alpha = 220

	// Delete itself after some time if it is not permanent variant
	if(lifespan)
		QDEL_IN(src, lifespan)

/obj/effect/kidan_pheromones/examine(mob/user)
	. = ..()
	if(encoded_message)
		. += "It has the following message: \"[encoded_message]\""
	// Failsafe for mappers/adminspawns if they forgot to add a message
	else
		. += "Its meaning is incomprehensible."

// For mappers/adminspawns, this one does not self-delete
/obj/effect/kidan_pheromones/permanent
	lifespan = null

// Innate action for creating pheromones and destroying current ones, owned by all kida
/datum/action/innate/produce_pheromones
	name = "Produce Pheromones"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "kidan_pheromones_static"

	/// How long our message can be (characters)
	var/maximum_message_length = 30

	/// How many active pheromones we can have
	var/active_pheromones_maximum = 3

	/// Which currently existing pheromones belong to us
	var/list/active_pheromones_current

/datum/action/innate/produce_pheromones/Activate()
	var/mob/living/carbon/human/H = owner

	// Do we want to make or destroy them?
	switch(alert(H, "Would you like to produce or destroy nearby pheromones?", "Produce Pheromones", "Produce", "Destroy"))
		// We look for nearby pheromones, if they belong to us, we can destroy them
		if("Destroy")
			var/obj/effect/kidan_pheromones/pheromones_to_destroy = locate(/obj/effect/kidan_pheromones) in range(1, H)
			// No pheromones nearby
			if(!pheromones_to_destroy)
				to_chat(H, "<span class='warning'>You cannot find any pheromones nearby.</span>")
				return
			// These are not ours, do not touch them
			if(!(pheromones_to_destroy in active_pheromones_current))
				to_chat(H, "<span class='warning'>These pheromones were created by someone else, you are unable to dissipate them.</span>")
				return
			// These are ours and we now destroy them
			if(do_after(H, 3 SECONDS, FALSE, pheromones_to_destroy))
				// Log the action
				H.create_log(MISC_LOG, "destroyed pheromones that had the message of \"[pheromones_to_destroy.encoded_message]\"")

				// Destroy it; the pheromones remove themselves from our list via signals
				to_chat(H, "<span class='notice'>You dissipate your old pheromones.</span>")
				qdel(pheromones_to_destroy)

		// We decide to produce new ones
		if("Produce")
			// Can we create more pheromones?
			if(length(active_pheromones_current) >= active_pheromones_maximum)
				to_chat(H, "<span class='warning'>You already have [length(active_pheromones_current)] sets of pheromones active and are unable to produce any more.</span>")
				return

			// Encode the message
			var/message_to_encode = input(H, "What message do you wish to encode? (max. [maximum_message_length] characters) Leave it empty to cancel.", "Produce Pheromones")
			if(!message_to_encode)
				to_chat(H, "<span class='notice'>You decide against producing pheromones.</span>")
				return
			if(length(message_to_encode) > maximum_message_length)
				to_chat(H, "<span class='warning'>Your message was too long, the pheromones instantly dissipate.</span>")
				return
			// Strip the message now so it does not mess with the length
			message_to_encode = strip_html(message_to_encode)

			// One batch of pheromones per tile
			if(locate(/obj/effect/kidan_pheromones) in get_turf(H))
				to_chat(H, "<span class='warning'>There are pheromones here already!</span>")
				return

			// Create the pheromones
			if(do_after(H, 3 SECONDS, FALSE, H))
				to_chat(H, "<span class='notice'>You produce new pheromones with the message of \"[message_to_encode]\".</span>")
				var/obj/effect/kidan_pheromones/pheromones_to_create = new (get_turf(H))
				pheromones_to_create.encoded_message = message_to_encode
				LAZYADD(active_pheromones_current, pheromones_to_create)

				// Add a signal to the new pheromones so it clears its own references when it gets destroyed
				RegisterSignal(pheromones_to_create, COMSIG_PARENT_QDELETING, PROC_REF(remove_pheromones_from_list))

				// Log the action
				H.create_log(MISC_LOG, "produced pheromones with the message of \"[message_to_encode]\"")

// This handles proper GCing whether we destroyed the pheromones or something else did
/datum/action/innate/produce_pheromones/proc/remove_pheromones_from_list(obj/effect/kidan_pheromones/pheromones)
	SIGNAL_HANDLER

	UnregisterSignal(pheromones, COMSIG_PARENT_QDELETING)
	LAZYREMOVE(active_pheromones_current, pheromones)

// Clear references if the holder gets destroyed
/datum/action/innate/produce_pheromones/Destroy()
	active_pheromones_current = null
	..()
