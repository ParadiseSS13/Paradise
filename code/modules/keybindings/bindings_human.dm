/mob/living/carbon/human/key_down(_key, client/user)
	if(_key == "H")
		var/obj/item/clothing/accessory/holster/H = null
		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/S = w_uniform
			if(S.accessories.len)
				H = locate() in S.accessories
		if (!H)
			return	
		if(!H.holstered)
			if(!istype(get_active_hand(), /obj/item/gun))
				to_chat(usr, "<span class='warning'>You need your gun equiped to holster it.</span>")
				return
			var/obj/item/gun/W = get_active_hand()
			H.holster(W, usr)
		else
			H.unholster(usr)
	if(client.keys_held["Shift"])
		switch(_key)
			if("E") // Put held thing in belt or take out most recent thing from belt
				quick_equip() // Implementing the storage component is going to take way too long
				// var/obj/item/thing = get_active_hand()
				// var/obj/item/equipped_belt = get_item_by_slot(slot_belt)
				// if(!equipped_belt) // We also let you equip a belt like this
				// 	if(!thing)
				// 		to_chat(user, "<span class='notice'>You have no belt to take something out of.</span>")
				// 		return
				// 	if(equip_to_slot_if_possible(thing, slot_belt))
				// 		update_inv_r_hand()
				// 		update_inv_l_hand()
				// 	return
				// if(!SEND_SIGNAL(equipped_belt, COMSIG_CONTAINS_STORAGE)) // not a storage item
				// 	if(!thing)
				// 		equipped_belt.attack_hand(src)
				// 	else
				// 		to_chat(user, "<span class='notice'>You can't fit anything in.</span>")
				// 	return
				// if(thing) // put thing in belt
				// 	if(!SEND_SIGNAL(equipped_belt, COMSIG_TRY_STORAGE_INSERT, thing, user.mob))
				// 		to_chat(user, "<span class='notice'>You can't fit anything in.</span>")
				// 	return
				// if(!equipped_belt.contents.len) // nothing to take out
				// 	to_chat(user, "<span class='notice'>There's nothing in your belt to take out.</span>")
				// 	return
				// var/obj/item/stored = equipped_belt.contents[equipped_belt.contents.len]
				// if(!stored || stored.on_found(src))
				// 	return
				// stored.attack_hand(src) // take out thing from belt
				// return

			/* if("B") // Put held thing in backpack or take out most recent thing from backpack
				var/obj/item/thing = get_active_hand()
				var/obj/item/equipped_back = get_item_by_slot(slot_back)
				if(!equipped_back) // We also let you equip a backpack like this
					if(!thing)
						to_chat(user, "<span class='notice'>You have no backpack to take something out of.</span>")
						return
					if(equip_to_slot_if_possible(thing, slot_back))
						update_inv_r_hand()
						update_inv_l_hand()
					return
				if(!SEND_SIGNAL(equipped_back, COMSIG_CONTAINS_STORAGE)) // not a storage item
					if(!thing)
						equipped_back.attack_hand(src)
					else
						to_chat(user, "<span class='notice'>You can't fit anything in.</span>")
					return
				if(thing) // put thing in backpack
					if(!SEND_SIGNAL(equipped_back, COMSIG_TRY_STORAGE_INSERT, thing, user.mob))
						to_chat(user, "<span class='notice'>You can't fit anything in.</span>")
					return
				if(!equipped_back.contents.len) // nothing to take out
					to_chat(user, "<span class='notice'>There's nothing in your backpack to take out.</span>")
					return
				var/obj/item/stored = equipped_back.contents[equipped_back.contents.len]
				if(!stored || stored.on_found(src))
					return
				stored.attack_hand(src) // take out thing from backpack
				return */
	return ..()