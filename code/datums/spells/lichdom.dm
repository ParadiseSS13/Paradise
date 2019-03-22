/obj/effect/proc_holder/spell/targeted/lichdom
	name = "Bind Soul"
	desc = "A dark necromantic pact that can forever bind your soul to your own heart, creating a phylactery. So long as the phylactery and your body remains intact, you can revive from death, though the time between reincarnations grows steadily with use. The phylactery will snap back to you if you are too far away (off station). If the phylactery is destroyed, you will die!"
	school = "necromancy"
	charge_max = 10
	clothes_req = 0
	centcom_cancast = 0
	invocation = "NECREM IMORTIUM!"
	invocation_type = "shout"
	range = -1
	level_max = 0 //cannot be improved
	cooldown_min = 10
	include_user = 1

	var/obj/item/phylactery/linked_phylactery
	var/mob/living/current_body
	var/resurrections = 0
	var/existence_stops_round_end = 0

	action_icon_state = "skeleton"

/obj/effect/proc_holder/spell/targeted/lichdom/Destroy()
	for(var/datum/mind/M in ticker.mode.wizards) //Make sure no other bones are about
		for(var/obj/effect/proc_holder/spell/S in M.spell_list)
			if(istype(S,/obj/effect/proc_holder/spell/targeted/lichdom) && S != src)
				return ..()
	if(existence_stops_round_end)
		config.continuous_rounds = 0
	return ..()

/obj/effect/proc_holder/spell/targeted/lichdom/cast(list/targets,mob/user = usr)
	if(!config.continuous_rounds)
		existence_stops_round_end = 1
		config.continuous_rounds = 1

	for(var/mob/M in targets)
		if(linked_phylactery && !stat_allowed) //sanity, shouldn't happen without badminry
			linked_phylactery = null
			return

		if(stat_allowed) //Death is not my end!
			if(M.stat == CONSCIOUS && iscarbon(M))
				to_chat(M, "<span class='notice'>You aren't dead enough to revive!</span>")//Usually a good problem to have

				charge_counter = charge_max
				return

			if(!linked_phylactery || QDELETED(linked_phylactery)) //Shouldnt happen but sanity.
				to_chat(M, "<span class='warning'>Your phylactery is gone!</span>")
				return

			var/turf/item_turf = get_turf(linked_phylactery)

			if(isobserver(M))
				var/mob/dead/observer/O = M
				O.reenter_corpse()

			var/mob/living/carbon/human/lich = new /mob/living/carbon/human(item_turf)

			lich.real_name = M.mind.name
			M.mind.transfer_to(lich)
			lich.set_species(/datum/species/skeleton)
			to_chat(lich, "<span class='warning'>Your bones clatter and shutter as they're pulled back into this world!</span>")
			charge_max += 600
			var/mob/old_body = current_body
			var/turf/body_turf = get_turf(old_body)
			current_body = lich
			lich.Weaken(10 + 10 * resurrections)
			++resurrections
			linked_phylactery.linked_lich = lich
			lich.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(lich), slot_shoes)
			lich.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(lich), slot_w_uniform)
			lich.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(lich), slot_wear_suit)
			lich.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(lich), slot_head)
			if(old_body && old_body.loc)
				if(iscarbon(old_body))
					var/mob/living/carbon/C = old_body
					for(var/obj/item/W in C)
						C.unEquip(W)
				var/wheres_wizdo = dir2text(get_dir(body_turf, item_turf))
				if(wheres_wizdo)
					old_body.visible_message("<span class='warning'>Suddenly [old_body.name]'s corpse falls to pieces! You see a strange energy rise from the remains, and speed off towards the [wheres_wizdo]!</span>")
					body_turf.Beam(item_turf, icon_state =" lichbeam", icon = 'icons/effects/effects.dmi', time = 10 + 10 * resurrections, maxdistance = INFINITY)
				old_body.dust()

		if(!linked_phylactery) //becoming a lich
			message = "<span class='warning'>"
			to_chat(M, "<span class='warning'>You begin the ritual. You feel your heart being pulled out of your chest...</span>")
			if(do_after(M, 50, target = M))
				name = "RISE!"
				desc = "Rise from the dead! You will reform at the location of your phylactery and your old body will crumble away."
				charge_max = 1800 //3 minute cooldown, if you rise in sight of someone and killed again, you're probably screwed.
				charge_counter = 1800
				stat_allowed = 1
				to_chat(M, "<span class='userdanger'>Clutching your heart in your hand, you watch in horrified fascination as skin sloughs off bone! Blood boils, nerves disintegrate, eyes boil in their sockets! As your organs crumble to dust in your fleshless chest you come to terms with your choice. You're a lich!</span>")
				current_body = M.mind.current
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.set_species(/datum/species/skeleton)
					linked_phylactery = new /obj/item/phylactery(get_turf(H))
					linked_phylactery.linked_lich = H
					H.put_in_hands(linked_phylactery)
					H.unEquip(H.wear_suit)
					H.unEquip(H.head)
					H.unEquip(H.shoes)
					H.unEquip(H.head)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(H), slot_wear_suit)
					H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(H), slot_head)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)
					H.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(H), slot_w_uniform)


/obj/item/phylactery
	name = "lich phylactery"
	desc = "It's still beating."
	color = "#003300" //dark evil green
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart-on"
	origin_tech = "biotech=6"
	throwforce = 0
	force = 1
	w_class = WEIGHT_CLASS_SMALL

	var/mob/living/carbon/human/linked_lich //set when becoming a lich/reviving

/obj/item/phylactery/New()
	..()
	processing_objects.Add(src)
	GLOB.poi_list |= src

/obj/item/phylactery/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(user == linked_lich)
			if(H != user)
				to_chat(user, "<span class='warning'>You attempt to force feed [src] to [H] but fail to do so. Probably for the best.</span>")
			else
				to_chat(user, "<span class='notice'>Studying the effects of eating your own soul will have to wait. You have a station to destroy.</span>")
		else
			if(H != user)
				to_chat(user, "<span class='warning'>An unknown force prevents you from force feeding [src] to [H]!</span>")
			else
				to_chat(user, "<span class='warning'>An unknown force prevents you from eating [src]!</span>")
		return
	..()

/obj/item/phylactery/process()
	if(!linked_lich || QDELETED(linked_lich)) //If lich is gibbed/deleted and the phylactery is still intact it goes dead
		desc = "It seems dead."
		icon_state = "heart-off"
		update_icon()
		GLOB.poi_list.Remove(src)
		processing_objects.Remove(src)
		return

	var/turf/phyl_turf = get_turf(src)
	var/turf/lich_turf = get_turf(linked_lich)
	if(phyl_turf.z != lich_turf.z)
		forceMove(lich_turf)
		to_chat(linked_lich,  "<span class='userdanger'>You feel your soul snap back to you, your phylactery drops on the floor!</span>")

/obj/item/phylactery/Destroy()
	if(linked_lich)
		to_chat(linked_lich,  "<span class='userdanger'>Your phylactery was destroyed. Your inanimate bones drop to the floor.</span>")
		linked_lich.dust()
	GLOB.poi_list.Remove(src)
	processing_objects.Remove(src)
	return ..()