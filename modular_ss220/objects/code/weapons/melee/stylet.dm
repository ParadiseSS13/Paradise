/obj/item/melee/stylet
	name = "stylet"
	desc = "Маленький складной нож скрытого ношения. \
	Нож в итальянском стиле, который исторически стал предметом споров и даже запретов \
	Его лезвие практически мгновенно выбрасывается при нажатии кнопки-качельки."
	slot_flags = SLOT_FLAG_BELT
	w_class = WEIGHT_CLASS_TINY

	var/on = FALSE
	force = 2
	var/force_on = 8

	lefthand_file = 'modular_ss220/objects/icons/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/melee_righthand.dmi'
	icon = 'modular_ss220/objects/icons/melee.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	item_state = "stylet_0"
	var/item_state_on = "stylet_1"
	icon_state = "stylet_0"
	var/icon_state_on = "stylet_1"
	var/extend_sound = 'modular_ss220/objects/sound/weapons/styletext.ogg'
	attack_verb = list("hit", "poked")
	sharp = TRUE
	var/list/attack_verb_on = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/melee/stylet/update_icon_state()
	. = ..()
	if(on)
		icon_state = "stylet_1"
	else
		icon_state = "stylet_0"

/obj/item/melee/stylet/attack_self(mob/user)
	on = !on

	if(on)
		to_chat(user, span_userdanger("Вы разложили [name]."))
		item_state = item_state_on
		update_icon(UPDATE_ICON_STATE)
		w_class = WEIGHT_CLASS_SMALL
		force = force_on
		attack_verb = attack_verb_on
	else
		to_chat(user, span_notice("Вы сложили [name]."))
		item_state = initial(item_state)
		update_icon(UPDATE_ICON_STATE)
		w_class = initial(w_class)
		force = initial(force)
		attack_verb = initial(attack_verb)

	// Update mob hand visuals
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	playsound(loc, extend_sound, 50, TRUE)
	add_fingerprint(user)
