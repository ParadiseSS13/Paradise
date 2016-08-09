/obj/effect/proc_holder/spell/targeted/horsemask
	name = "Curse of the Horseman"
	desc = "This spell triggers a curse on a target, causing them to wield an unremovable horse head mask. They will speak like a horse! Any masks they are wearing will be disintegrated. This spell does not require robes."
	school = "transmutation"
	charge_type = "recharge"
	charge_max = 150
	charge_counter = 0
	clothes_req = 0
	stat_allowed = 0
	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = "shout"
	range = 7
	cooldown_min = 30 //30 deciseconds reduction per rank
	selection_type = "range"

	action_icon_state = "barn"

/obj/effect/proc_holder/spell/targeted/horsemask/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/carbon/target = targets[1]

	if(!target)
		return


	if(!ishuman(target))
		to_chat(user, "<span class='notice'>It'd be stupid to curse [target] with a horse's head!</span>")
		return

	if(!(target in oview(range)))//If they are not  in overview after selection.
		to_chat(user, "<span class='notice'>They are too far away!</span>")
		return

	var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
	magichead.flags |= NODROP		//curses!
	magichead.flags_inv = null	//so you can still see their face
	magichead.voicechange = 1	//NEEEEIIGHH
	target.visible_message(	"<span class='danger'>[target]'s face  lights up in fire, and after the event a horse's head takes its place!</span>", \
							"<span class='danger'>Your face burns up, and shortly after the fire you realise you have the face of a horse!</span>")
	if(!target.unEquip(target.wear_mask))
		qdel(target.wear_mask)
	target.equip_to_slot_if_possible(magichead, slot_wear_mask, 1, 1)

	target.flash_eyes()
