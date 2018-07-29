/obj/effect/proc_holder/spell/targeted/lichdom
	name = "Bind Soul"
	desc = "A dark necromantic pact that can forever bind your soul to an item of your choosing. So long as both your body and the item remain intact and on the same plane you can revive from death, though the time between reincarnations grows steadily with use."
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

	var/obj/marked_item
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
		var/list/hand_items = list()
		if(iscarbon(M))
			hand_items = list(M.get_active_hand(),M.get_inactive_hand())

		if(marked_item && !stat_allowed) //sanity, shouldn't happen without badminry
			marked_item = null
			return

		if(stat_allowed) //Death is not my end!
			if(M.stat == CONSCIOUS && iscarbon(M))
				to_chat(M, "<span class='notice'>You aren't dead enough to revive!</span>")//Usually a good problem to have

				charge_counter = charge_max
				return

			if(!marked_item || QDELETED(marked_item)) //Wait nevermind
				to_chat(M, "<span class='warning'>Your phylactery is gone!</span>")
				return

			var/turf/user_turf = get_turf(M)
			var/turf/item_turf = get_turf(marked_item)

			if(user_turf.z != item_turf.z)
				to_chat(M, "<span class='warning'>Your phylactery is out of range!</span>")
				return

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
			lich.Weaken(10+10*resurrections)
			++resurrections
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
					body_turf.Beam(item_turf,icon_state="lichbeam",icon='icons/effects/effects.dmi',time=10+10*resurrections,maxdistance=INFINITY)
				old_body.dust()

		if(!marked_item) //linking item to the spell
			message = "<span class='warning'>"
			for(var/obj/item in hand_items)
				if(ABSTRACT in item.flags || NODROP in item.flags)
					continue
				marked_item = item
				to_chat(M, "<span class='warning'>You begin to focus your very being into the [item.name]...</span>")
				break

			if(!marked_item)
				to_chat(M, "<span class='caution'>You must hold an item you wish to make your phylactery...</span>")
				return

			spawn(50)
				if(marked_item.loc != M) //I changed my mind I don't want to put my soul in a cheeseburger!
					to_chat(M, "<span class='warning'>Your soul snaps back to your body as you drop the [marked_item.name]!</span>")
					marked_item = null
					return
				name = "RISE!"
				desc = "Rise from the dead! You will reform at the location of your phylactery and your old body will crumble away."
				charge_max = 1800 //3 minute cooldown, if you rise in sight of someone and killed again, you're probably screwed.
				charge_counter = 1800
				stat_allowed = 1
				marked_item.name = "Ensouled [marked_item.name]"
				marked_item.desc = "A terrible aura surrounds this item, its very existence is offensive to life itself..."
				marked_item.color = "#003300"
				to_chat(M, "<span class='userdanger'>With a hideous feeling of emptiness you watch in horrified fascination as skin sloughs off bone! Blood boils, nerves disintegrate, eyes boil in their sockets! As your organs crumble to dust in your fleshless chest you come to terms with your choice. You're a lich!</span>")
				current_body = M.mind.current
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.set_species(/datum/species/skeleton)
					H.unEquip(H.wear_suit)
					H.unEquip(H.head)
					H.unEquip(H.shoes)
					H.unEquip(H.head)
					H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(H), slot_wear_suit)
					H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(H), slot_head)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)
					H.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(H), slot_w_uniform)