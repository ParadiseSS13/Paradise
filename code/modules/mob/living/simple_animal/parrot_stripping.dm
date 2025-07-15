GLOBAL_LIST_INIT(strippable_parrot_items, create_strippable_list(list(
	/datum/strippable_item/parrot_headset,
)))

/datum/strippable_item/parrot_headset
	key = STRIPPABLE_ITEM_PARROT_HEADSET

/datum/strippable_item/parrot_headset/get_item(atom/source)
	var/mob/living/simple_animal/parrot/parrot_source = source
	return istype(parrot_source) ? parrot_source.ears : null

/datum/strippable_item/parrot_headset/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!istype(equipping, /obj/item/radio/headset))
		to_chat(user, "<span class='warning'>[equipping] won't fit!</span>")
		return FALSE

	return TRUE

/datum/strippable_item/parrot_headset/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/obj/item/radio/headset/radio = equipping
	if(!istype(radio))
		return

	var/mob/living/simple_animal/parrot/parrot_source = source
	if(!istype(parrot_source))
		return

	INVOKE_ASYNC(equipping, TYPE_PROC_REF(/atom/movable, forceMove), parrot_source)
	parrot_source.ears = radio
	parrot_source.update_available_channels()
	parrot_source.update_speak()

	to_chat(user, "<span class='notice'>You fit [radio] onto [source].</span>")

/datum/strippable_item/parrot_headset/start_unequip(atom/source, mob/user)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/simple_animal/parrot/parrot_source = source
	if(!istype(parrot_source))
		return

	if(parrot_source.stat == CONSCIOUS) // DEAD PARROTS TELL NO TALES (Finally moved this out of topic, thank god)
		parrot_source.say("[length(parrot_source.available_channels) ? "[pick(parrot_source.available_channels)] " : null]BAWWWWWK LEAVE THE HEADSET BAWKKKKK!")

	return TRUE

/datum/strippable_item/parrot_headset/finish_unequip(atom/source, mob/user)
	var/mob/living/simple_animal/parrot/parrot_source = source
	if(!istype(parrot_source))
		return

	INVOKE_ASYNC(parrot_source.ears, TYPE_PROC_REF(/atom/movable, forceMove), parrot_source.drop_location())
	parrot_source.ears = null
	parrot_source.update_available_channels()
	parrot_source.update_speak()
