/obj/item/picket_sign
	name = "blank picket sign"
	desc = "It's blank"
	icon_state = "picket"
	item_state = "picket"
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bashed","smacked")
	resistance_flags = FLAMMABLE
	var/label = ""
	COOLDOWN_DECLARE(picket_sign_cooldown)

/obj/item/picket_sign/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen) || istype(I, /obj/item/toy/crayon))
		var/txt = stripped_input(user, "What would you like to write on the sign?", "Sign Label", null, 30)
		if(txt)
			name = "[txt] sign"
			desc = "It reads: [txt]"
			label = txt
	..()

/obj/item/picket_sign/attack_self(mob/living/carbon/human/user)
	if(!COOLDOWN_FINISHED(src, picket_sign_cooldown))
		to_chat(user, "<span class='warning'>Your arm is too tired to do that again so soon!</span>")
		return

	COOLDOWN_START(src, picket_sign_cooldown, 5 SECONDS)
	if(label)
		user.visible_message("<span class='notice'>[user] waves around \the \"[label]\" sign.</span>")
	else
		user.visible_message("<span class='notice'>[user] waves around [src].</span>")
	user.changeNext_move(CLICK_CD_MELEE)

/datum/crafting_recipe/picket_sign
	name = "Picket Sign"
	result = list(/obj/item/picket_sign)
	reqs = list(/obj/item/stack/rods = 1,
				/obj/item/stack/sheet/cardboard = 2)
	time = 80
	category = CAT_MISC
