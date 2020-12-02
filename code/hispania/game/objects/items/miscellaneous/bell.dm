/obj/item/bell
	name = "Bell"
	icon = 'icons/hispania/obj/miscellaneous.dmi'
	icon_state = "bell_new"
	item_state = "sheet-metal"
	throwforce = 1
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 8
	anchored = TRUE
	var/emagged = 0

/obj/item/bell/cargo
	name = "Cargo Bell"

/obj/item/bell/science
	name = "Science Bell"

/obj/item/bell/medbay
	name = "Medbay Bell"


/obj/item/bell/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(M.restrained() || M.stat || !Adjacent(M))
		return

	if(!anchored)
		if(over_object == M)
			if(!remove_item_from_storage(M))
				M.unEquip(src)
			M.put_in_hands(src)

		else if(istype(over_object, /obj/screen))
			switch(over_object.name)
				if("r_hand")
					if(!remove_item_from_storage(M))
						M.unEquip(src)
					M.put_in_r_hand(src)
				if("l_hand")
					if(!remove_item_from_storage(M))
						M.unEquip(src)
					M.put_in_l_hand(src)
	else
		return
	add_fingerprint(M)

/obj/item/bell/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.bodyparts_by_name["r_hand"]
		if(H.hand)
			temp = H.bodyparts_by_name["l_hand"]
		if(temp && !temp.is_usable())
			to_chat(H, "<span class='notice'>You try to move your [temp.name], but cannot!</span>")
			return
	if(anchored)
		playsound(src, 'sound/misc/ding.ogg', 60)
		if(emagged)
			var/mob/living/carbon/S = user
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(12, 1, src)
			S.electrocute_act(110, usr, 1)
			s.start()
	add_fingerprint(user)
	return

/obj/item/bell/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/wrench))
		add_fingerprint(user)
		to_chat(user, "<span class='notice'>Now [anchored ? "un" : ""]securing [name].</span>")
		if(anchored)
			to_chat(user, "<span class='notice'>You've [anchored ? "un" : ""]secured [name].</span>")
		anchored = !anchored

		playsound(src.loc, W.usesound, 50, 1)
	return

/obj/item/bell/emag_act(mob/user)
	visible_message("<span class='warning'>The bell sparks!</span>")
	add_fingerprint(user)
	emagged = 1
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(5, 1, src)
	sparks.start()
