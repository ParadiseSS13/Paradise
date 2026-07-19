/obj/item/bee_briefcase
	name = "briefcase"
	desc = "This briefcase has easy-release clasps and smells vaguely of honey and blood..."
	icon = 'icons/obj/storage.dmi'
	icon_state = "briefcase"
	flags = CONDUCT
	hitsound = "swing_hit"
	force = 10
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	var/bees_left = 10
	var/list/blood_list = list()
	var/sound_file = 'sound/misc/briefcase_bees.ogg'
	new_attack_chain = TRUE
	COOLDOWN_DECLARE(bee_sound_cooldown)

/obj/item/bee_briefcase/Destroy()
	blood_list.Cut()
	return ..()

/obj/item/bee_briefcase/examine(mob/user)
	. = ..()
	if(loc == user)
		if(bees_left)
			. += SPAN_WARNING("There are [bees_left] bees still inside in briefcase!")
		else
			. += SPAN_DANGER("The bees are gone... Colony collapse disorder?")
	if(isAntag(user))
		. += SPAN_WARNING("A briefcase filled with deadly bees, you should inject this with a syringe of your own blood before opening it. Exotic blood cannot be used.")

/obj/item/bee_briefcase/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/reagent_containers/spray/pestspray))
		bees_left = max(0, (bees_left - 6))
		to_chat(user, "You spray [used] into [src].")
		playsound(loc, 'sound/effects/spray3.ogg', 50, TRUE, -6)
		return ITEM_INTERACT_COMPLETE

	if(!istype(used, /obj/item/reagent_containers/syringe))
		return ..()

	var/obj/item/reagent_containers/syringe/syringe = used
	if(!bees_left)
		to_chat(user, SPAN_WARNING("[src] is empty, so there is no point in injecting something into it!"))
		return ITEM_INTERACT_COMPLETE

	if(!syringe.reagents || !syringe.reagents.total_volume)
		to_chat(user, SPAN_WARNING("[syringe] is empty!"))
		return ITEM_INTERACT_COMPLETE

	to_chat(user, SPAN_NOTICE("You inject [src] with [syringe]."))
	for(var/datum/reagent/each_reagent in syringe.reagents.reagent_list)
		if(each_reagent.id == "blood")
			if(!(each_reagent.data["donor"] in blood_list))
				blood_list += each_reagent.data["donor"]
		if(each_reagent.id == "lazarus_reagent")		// RELOAD THE BEES (1 bee per 1 unit, max 15 bees).
			if(bees_left < 15)
				bees_left = min(15, round((bees_left + each_reagent.volume), 1))	// No partial bees, max 15 bees in case at any given time.
				to_chat(user, SPAN_WARNING("The buzzing inside [src] intensifies as new bees form inside."))
			else
				to_chat(user, SPAN_WARNING("The buzzing inside [src] swells momentarily, then returns to normal. Guess it was too cramped..."))
		syringe.reagents.clear_reagents()
		syringe.update_icon()
	add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE

/obj/item/bee_briefcase/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(!bees_left)
		to_chat(user, SPAN_DANGER("The lack of all and any bees at this event has been somewhat of a let-down..."))
		return ITEM_INTERACT_COMPLETE

	if(COOLDOWN_FINISHED(src, bee_sound_cooldown))		// This cooldown doesn't prevent us from releasing bees, just stops the sound.
		playsound(loc, sound_file, 35)
		COOLDOWN_START(src, bee_sound_cooldown, 90 SECONDS)

	var/bees_released
	// Release up to 5 bees per use. Without using Lazarus Reagent, that means two uses. WITH Lazarus Reagent, you can get more if you don't release the last bee.
	for(var/bee = min(5, bees_left), bee > 0, bee--)
		var/mob/living/basic/bee/syndi/B = new /mob/living/basic/bee/syndi(get_turf(user)) // RELEASE THE BEES!
		for(var/mob/living/fren in blood_list)
			B.befriend(fren)
		bees_released++
	bees_left -= bees_released
	add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE
