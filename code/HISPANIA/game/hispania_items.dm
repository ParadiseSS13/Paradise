//BORIS SHOTGUN GOES STARTS HERE//
/obj/item/gun/projectile/revolver/doublebarrel/boris
	name = "Boris Shotgun"
	desc = "A double barreled shotgun with an engraved boar on it. It reads 'Boris - The Gulag Maker'"
	icon_state = "borisshotgun"  //EL ICONO DE BACK.DMI Y EL DE HISPANIA_CUSTOM_ITEMS.DMI DEBE TENER EL MISMO NOMBRE
	item_state = "borisshotgun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags = CONDUCT
	slot_flags = SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	unique_rename = 0
	unique_reskin = 0
	hispania_icon = TRUE

// BORIS SHOTGUN ENDS HERE//

//DIOSDADO STUNBATON STARTS HERE//
/obj/item/melee/classic_baton/telescopic/diosdado
	name = "El Expropiador"
	desc = "When simply stunnning your target isn't enough"
	icon_state = "expropiador0"
	item_state = null
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	needs_permit = 0
	force = 0
	on = 0
	hispania_icon = TRUE

/obj/item/melee/classic_baton/telescopic/diosdado/attack_self(mob/user as mob)
	on = !on
	if(on)
		to_chat(user, "<span class ='warning'>Listo para expropiar.</span>")
		icon_state = "expropiador1"
		item_state = "expropiador"
		w_class = WEIGHT_CLASS_BULKY //doesnt fit in backpack when its on for balance
		force = 10 //stunbaton damage
		attack_verb = list("expropió a")
	else
		to_chat(user, "<span class ='notice'>No más expropiaciones por ahora.</span>")
		icon_state = "expropiador0"
		item_state = null //no sprite for concealment even when in hand
		slot_flags = SLOT_BELT
		w_class = WEIGHT_CLASS_SMALL
		force = 0 //not so robust now
		attack_verb = list("hit", "poked")
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	add_fingerprint(user)

/obj/item/melee/classic_baton/telescopic/diosdado/attack(mob/target as mob, mob/living/user as mob)
	if(on)
		add_fingerprint(user)
		if((CLUMSY in user.mutations) && prob(50))
			to_chat(user, "<span class ='danger'>Se expropió a si mismo.</span>")
			user.Weaken(3 * force)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2*force, BRUTE, "head")
			else
				user.take_organ_damage(2*force)
			return
		if(isrobot(target))
			..()
			return
		if(!isliving(target))
			return
		if(user.a_intent == INTENT_HARM)
			if(!..()) return
			if(!isrobot(target)) return
		else
			if(cooldown <= 0)
				if(ishuman(target))
					var/mob/living/carbon/human/H = target
					if(H.check_shields(0, "[user]'s [name]", src, MELEE_ATTACK))
						return 0
				playsound(get_turf(src), 'sound/effects/expropiesestun.ogg', 75)
				target.Weaken(3)
				add_attack_logs(user, target, "Stunned with [src]")
				add_fingerprint(user)
				target.visible_message("<span class ='danger'>[user] ha expropiado a [target] !</span>", \
					"<span class ='userdanger'>[user] ha expropiado a [target] !</span>")
				if(!iscarbon(user))
					target.LAssailant = null
				else
					target.LAssailant = user
				cooldown = 1
				spawn(40)
					cooldown = 0
		return
	else
		return ..()

//DIOSDADO STUNBATON ENDS HERE//

//KOTIRO DEFIB STARTS HERE//

/obj/item/defibrillator/compact/kotiro
	name = "De-Clown-Fibrillator"
	desc = "A modified belt-equipped defibrillator that can be rapidly deployed. Seems it doesn't like clowns too much"
	icon_state = "kdefibcompact"
	item_state = "kdefibcompact"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = SLOT_BELT
	origin_tech = "biotech=5"
	hispania_icon = TRUE

/obj/item/defibrillator/compact/kotiro/loaded/New()
	..()
	paddles = make_paddles_custom()
	bcell = new(src)
	update_icon()
	return

/obj/item/defibrillator/proc/make_paddles_custom()
		return new /obj/item/twohanded/shockpaddles/kotiro(src)

/obj/item/twohanded/shockpaddles/kotiro
	name = "defibrillator paddles"
	desc = "A pair of plastic-gripped paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon_state = "kdefibpaddles0"
	item_state = "kdefibpaddles0"
	hispania_icon = TRUE
	icon = 'icons/hispania/obj/items.dmi'
	force = 0
	throwforce = 6
	w_class = WEIGHT_CLASS_BULKY
	toolspeed = 1
	revivecost = 1000
	cooldown = 0
	busy = 0
	obj/item/defibrillator/compact/kotiro
	custom = 1

/obj/item/twohanded/shockpaddles/kotiro/update_icon()
	icon_state = "kdefibpaddles1[wielded]"
	item_state = "kdefibpaddles1[wielded]"
	if(cooldown)
		icon_state = "kdefibpaddles1[wielded]_cooldown"

//KOTIRO DEFIB ENDS HERE

//YACKER MASK STARTS HERE

/obj/item/clothing/mask/breath/weathered
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "weatheredmask"
	item_state = "weatheredmask"
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	hispania_icon = TRUE

//YACKER MASK ENDS HERE

//DRAGONC305 HOODIE STARTS HERE

/obj/item/clothing/suit/storage/labcoat/killerhoodie
	name = "blue hoodie"
	desc = "It's just a plain sky blue hoodie."
	icon_state = "killerhoodie_open"
	item_state = "killerhoodie_open"
	adjust_flavour = "unhoodie"
	body_parts_covered = HEAD
	hispania_icon = TRUE
	flags_inv = HIDEEARS

//DRAGONC305 HOODIE ENDS HERE

//GOD.TITAN HALO STARTS HERE

/obj/item/clothing/head/hardhat/halo
	name = "holy halo"
	desc = "A holy halo of light."
	icon_state = "hardhat0_halo"
	item_state = "hardhat0_halo"
	item_color = "halo"
	hispania_icon = TRUE

//GOD.TITAN HALO ENDS HERE

//HARMONY HAT STARTS HERE

/obj/item/clothing/head/helmet/propeller
	name = "propeller hat"
	desc = "A colorful, childish and silly-looking hat."
	icon_state = "propellerhat"
	item_state = "propellerhat"
	toggle_message = "You stop spinning the propeller on"
	alt_toggle_message = "You spin the propeller on"
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)
	can_toggle = 1
	toggle_cooldown = 20
	species_restricted = list("Grey")
	hispania_icon = TRUE


//HARMONY HAT ENDS HERE

//RYZOR BLOB CORE STARTS HERE

/obj/item/organ/internal/brain/blob
	name = "defective core"
	desc = "It seems to be the defective core of a slime."
	icon_state = "defective slime core"
	mmi_icon_state = "slime_mmi"
	hispania_icon = TRUE

//RYZOR BLOB CORE ENDS HERE

//RYZOR CUSTOM HAND TELE

/obj/item/hand_tele/ryzor
	name = "RyzorCo. Experimental Hand tele"
	desc = "An experimental portable item using blue-space technology. It has a grumpy face."
	icon_state = "hand_tele_ry"
	item_state = "electronic"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(MAT_METAL=10000)
	origin_tech = "magnets=3;bluespace=4"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 30, bio = 0, rad = 0)
	hispania_icon = TRUE

//RYZOR CUSTOM HAND TELE ENDS HERE

//ASDFLYY TOASTER BRAIN STARTS HERE

/obj/item/organ/internal/brain/toaster
	name = "modified positronic brain"
	desc = "A strange positronic brain. A human brain should be here instead."
	icon_state = "toasterbrain"
	mmi_icon_state = "toaster_mmi"
	hispania_icon = TRUE

//ASDFLYY TOASTER BRAIN ENDS HERE


//MELTYAS LENNOX SUITS START HERE

/obj/item/clothing/under/lennoxsuit
	name = "Lennox Captain Suit"
	desc = "High tech protective suit made for NT operatives on the field. Adapted for Lennox to be used as an uniform"
	icon_state = "lennoxsuit"
	item_state = "lennoxsuit"
	item_color = "lennoxsuit"
	armor = list(melee = 50, bullet = 40, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	hispania_icon = TRUE

//MELTYAS LENNOX SUITS ENDS HERE

// Funci?n de mierda que detecta cuando un pj entra a la estaci?n
/mob/new_player/proc/start_player(mob/user)
	var/mob/living/carbon/human/target = user
	var/obj/item/organ/internal/organ

    //                    BLOB
	if(isslimeperson(target) && target.real_name == "Blob Bob" && target.ckey == "alfred987")
		organ = new/obj/item/organ/internal/brain/blob
		organ.insert(target)
		organ.dna = target.dna
		return
	//                    ---

	//                    TOASTER
	if(ishuman(target) && target.real_name == "Toaster" && target.ckey == "asdflyy")
		organ = new/obj/item/organ/internal/brain/toaster
		organ.insert(target)
		organ.dna = target.dna
		return
	//                    ---

	return
