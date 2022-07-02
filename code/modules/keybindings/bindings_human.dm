/mob/living/carbon/human/key_down(_key, client/user)
	switch(_key)
		if("V")
			if(!client.keys_held["Ctrl"] && !client.keys_held["Shift"])
				rest()
		if("H")
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
				quick_equip()


	return ..()
