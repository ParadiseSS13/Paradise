/datum/spell/horsemask
	name = "Curse of the Horseman"
	desc = "This spell triggers a curse on a target, causing them to wield an unremovable horse head mask. They will speak like a horse! Any masks they are wearing will be disintegrated. This spell does not require robes."
	base_cooldown = 150
	clothes_req = FALSE
	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = "shout"
	cooldown_min = 30 //30 deciseconds reduction per rank

	selection_activated_message = SPAN_NOTICE("You start to quietly neigh an incantation. Click on or near a target to cast the spell.")
	selection_deactivated_message = SPAN_NOTICE("You stop neighing to yourself.")

	action_icon_state = "barn"
	sound = 'sound/magic/HorseHead_curse.ogg'

/datum/spell/horsemask/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	return T


/datum/spell/horsemask/cast(list/targets, mob/user = usr)
	if(!length(targets))
		to_chat(user, SPAN_NOTICE("No target found in range."))
		return

	var/mob/living/carbon/human/target = targets[1]

	if(target.can_block_magic(antimagic_flags))
		target.visible_message(SPAN_DANGER("[target]'s face bursts into flames, which instantly burst outward, leaving [target.p_them()] unharmed!"),
			SPAN_DANGER("Your face starts burning up, but the flames are repulsed by your anti-magic protection!"),
		)
		to_chat(user, SPAN_WARNING("The spell had no effect!"))
		return FALSE

	var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
	magichead.flags |= DROPDEL	//curses!
	magichead.set_nodrop(TRUE)
	magichead.flags_inv = null	//so you can still see their face
	magichead.voicechange = TRUE	//NEEEEIIGHH
	target.visible_message(	SPAN_DANGER("[target]'s face  lights up in fire, and after the event a horse's head takes its place!"), \
							SPAN_DANGER("Your face burns up, and shortly after the fire you realize you have the face of a horse!"))
	if(!target.drop_item_to_ground(target.wear_mask))
		qdel(target.wear_mask)
	target.equip_to_slot_if_possible(magichead, ITEM_SLOT_MASK, TRUE, TRUE)

	target.flash_eyes()
