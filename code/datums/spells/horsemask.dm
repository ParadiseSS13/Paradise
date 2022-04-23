/obj/effect/proc_holder/spell/horsemask
	name = "Curse of the Horseman"
	desc = "This spell triggers a curse on a target, causing them to wield an unremovable horse head mask. They will speak like a horse! Any masks they are wearing will be disintegrated. This spell does not require robes."
	school = "transmutation"
	charge_type = "recharge"
	charge_max = 150
	charge_counter = 0
	clothes_req = FALSE
	stat_allowed = FALSE
	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = "shout"
	cooldown_min = 30 //30 deciseconds reduction per rank

	selection_activated_message = "<span class='notice'>You start to quietly neigh an incantation. Click on or near a target to cast the spell.</span>"
	selection_deactivated_message = "<span class='notice'>You stop neighing to yourself.</span>"

	action_icon_state = "barn"
	sound = 'sound/magic/HorseHead_curse.ogg'

/obj/effect/proc_holder/spell/horsemask/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.selection_type = SPELL_SELECTION_RANGE
	return T


/obj/effect/proc_holder/spell/horsemask/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/carbon/human/target = targets[1]

	var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
	magichead.flags |= NODROP | DROPDEL	//curses!
	magichead.flags_inv = null	//so you can still see their face
	magichead.voicechange = TRUE	//NEEEEIIGHH
	target.visible_message(	"<span class='danger'>[target]'s face  lights up in fire, and after the event a horse's head takes its place!</span>", \
							"<span class='danger'>Your face burns up, and shortly after the fire you realise you have the face of a horse!</span>")
	if(!target.unEquip(target.wear_mask))
		qdel(target.wear_mask)
	target.equip_to_slot_if_possible(magichead, slot_wear_mask, TRUE, TRUE)

	target.flash_eyes()
