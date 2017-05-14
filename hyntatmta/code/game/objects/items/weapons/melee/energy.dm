/obj/item/weapon/hyntatmta/melee/energy/sword/saber/hos
	name = "Nano Saber"
	desc = "An energised saber. Is it a coal on handle?"
	icon = 'hyntatmta/icons/obj/melee.dmi'
	icon_state = "nano_saber0"
	lefthand_file = 'hyntatmta/icons/mob/items_lefthand.dmi'
	righthand_file = 'hyntatmta/icons/mob/items_righthand.dmi'
	belt_file = 'hyntatmta/icons/mob/belt.dmi'
	slot_flags = SLOT_BELT
	icon_state_on = "nano_saber1"
	force = 15
	force_on = 35
	throwforce = 8
	throwforce_on = 20
	throw_speed = 3
	throw_range = 4
	w_class = 4
	hitsound = "swing_hit"
	armour_penetration = 40
	origin_tech = "combat=4"
	attack_verb = list("attacked", "stabbed")
	attack_verb_on = list()
	sharp = 1
	edge = 1

/obj/item/weapon/hyntatmta/melee/energy/sword/saber/hos/attack_self(mob/living/carbon/user)
	if(user.disabilities & CLUMSY && prob(50))
		to_chat(user, "<span class='warning'>You accidentally cut yourself with [src], like a doofus!</span>")
		user.take_organ_damage(5,5)
	active = !active
	if(active)
		force = force_on
		slot_flags = "null"
		throwforce = throwforce_on
		hitsound = 'sound/weapons/blade1.ogg'
		if(attack_verb_on.len)
			attack_verb = attack_verb_on
		if(!item_color)
			icon_state = icon_state_on
		else
			icon_state = "sword[item_color]"
		w_class = w_class_on
		playsound(user, 'sound/weapons/saberon.ogg', 35, 1) //changed it from 50% volume to 35% because deafness
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = initial(force)
		slot_flags = initial(slot_flags)
		throwforce = initial(throwforce)
		hitsound = initial(hitsound)
		if(attack_verb_on.len)
			attack_verb = list()
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		playsound(user, 'sound/weapons/saberoff.ogg', 35, 1)  //changed it from 50% volume to 35% because deafness
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return

/obj/item/weapon/hyntatmta/melee/energy/sword/saber/hos/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] swings the [src.name] towards /his head! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|FIRELOSS)
