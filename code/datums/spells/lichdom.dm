/datum/spell/lichdom
	name = "Bind Soul"
	desc = "A dark necromantic pact that can forever bind your soul to an item of your choosing. So long as both your body and the item remain intact and on the same plane you can revive from death, though the time between reincarnations grows steadily with use."
	base_cooldown = 10
	clothes_req = FALSE
	centcom_cancast = FALSE
	invocation = "NECREM IMORTIUM!"
	invocation_type = "shout"
	level_max = 0 //cannot be improved
	cooldown_min = 10

	var/marked_item_uid
	var/mob/living/current_body
	var/resurrections = 0

	action_icon_state = "skeleton"

/datum/spell/lichdom/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/lichdom/cast(list/targets, mob/user = usr)
	for(var/mob/M in targets)
		if(stat_allowed)
			attempt_revive(M)
		else if(!marked_item_uid)
			attempt_mark_item(M)

/datum/spell/lichdom/proc/attempt_revive(mob/user)
	// Can only cast when unconscious/dead
	if(user.stat == CONSCIOUS)
		to_chat(user, "<span class='notice'>You aren't dead enough to revive!</span>")
		cooldown_handler.revert_cast()
		return

	// Body was destroyed
	if(QDELETED(current_body))
		to_chat(user, "<span class='warning'>Your body is gone!</span>")
		return

	// Phylactery was destroyed
	var/obj/item/marked_item = locateUID(marked_item_uid)
	if(QDELETED(marked_item))
		to_chat(user, "<span class='warning'>Your phylactery is gone!</span>")
		return

	// Wrong z-level
	var/turf/body_turf = get_turf(current_body)
	var/turf/item_turf = get_turf(marked_item)
	if(body_turf.z != item_turf.z)
		to_chat(user, "<span class='warning'>Your phylactery is out of range!</span>")
		return

	if(isobserver(user))
		var/mob/dead/observer/O = user
		O.reenter_corpse()

	// Clean up the old body
	if(!QDELETED(current_body))
		if(iscarbon(current_body))
			var/mob/living/carbon/C = current_body
			for(var/obj/item/W in C)
				C.drop_item_to_ground(W)

		// Give a hint as to where the body is
		var/wheres_wizdo = dir2text(get_dir(body_turf, item_turf))
		if(wheres_wizdo)
			current_body.visible_message("<span class='warning'>Suddenly [current_body.name]'s corpse falls to pieces! You see a strange energy rise from the remains, and speed off towards the [wheres_wizdo]!</span>")
			body_turf.Beam(item_turf, icon_state = "lichbeam", icon = 'icons/effects/effects.dmi', time = 10 + 10 * resurrections, maxdistance = INFINITY)

		UnregisterSignal(current_body, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_Z_CHANGED))
		current_body.dust()

	var/stun_time = (1 + resurrections++) * 20 SECONDS

	var/mob/living/carbon/human/lich = new /mob/living/carbon/human(item_turf)
	lich.set_species(/datum/species/skeleton/lich)
	lich.real_name = user.mind.name
	lich.Weaken(stun_time)
	user.mind.transfer_to(lich)
	equip_lich(lich)

	current_body = lich
	cooldown_handler.recharge_duration += 1 MINUTES
	to_chat(lich, "<span class='warning'>Your bones clatter and shudder as they're pulled back into this world!</span>")

/datum/spell/lichdom/proc/attempt_mark_item(mob/user)
	var/obj/item/target = user.get_active_hand()
	if(!target)
		to_chat(user, "<span class='warning'>You must hold an item you wish to make your phylactery!</span>")
		return

	if(target.flags & (ABSTRACT|NODROP))
		to_chat(user, "<span class='warning'>[target] cannot be used as your phylactery!</span>")
		return

	if(!do_after(user, 5 SECONDS, target = target))
		to_chat(user, "<span class='warning'>Your soul snaps back to your body as you drop [target]!</span>")
		return

	name = "RISE!"
	desc = "Rise from the dead! You will reform at the location of your phylactery and your old body will crumble away."
	stat_allowed = UNCONSCIOUS
	cooldown_handler.recharge_duration = 3 MINUTES
	cooldown_handler.revert_cast()
	if(action)
		action.name = name
		action.desc = desc
		build_all_button_icons()

	target.name = "ensouled [target.name]"
	target.desc += "<br><span class='warning'>A terrible aura surrounds this item, its very existence is offensive to life itself...</span>"
	target.color = "#003300"
	marked_item_uid = target.UID()

	current_body = user.mind.current
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.set_species(/datum/species/skeleton/lich)
		H.drop_item_to_ground(H.wear_suit)
		H.drop_item_to_ground(H.head)
		H.drop_item_to_ground(H.shoes)
		H.drop_item_to_ground(H.head)
		equip_lich(H)

	to_chat(user, "<span class='userdanger'>With a hideous feeling of emptiness you watch in horrified fascination as skin sloughs off bone! Blood boils, nerves disintegrate, eyes boil in their sockets! As your organs crumble to dust in your fleshless chest you come to terms with your choice. You're a lich!</span>")

/datum/spell/lichdom/proc/is_revive_possible()
	var/obj/item/marked_item = locateUID(marked_item_uid)
	if(QDELETED(marked_item))
		return FALSE
	if(QDELETED(current_body))
		return FALSE
	var/turf/body_turf = get_turf(current_body)
	var/turf/item_turf = get_turf(marked_item)
	if(body_turf.z != item_turf.z)
		return FALSE
	return TRUE

/datum/spell/lichdom/proc/equip_lich(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(H), ITEM_SLOT_OUTER_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(H), ITEM_SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), ITEM_SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(H), ITEM_SLOT_JUMPSUIT)
