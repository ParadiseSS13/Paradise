/obj/item/picket_sign
	name = "blank picket sign"
	desc = "It's blank."
	icon_state = "picket"
	item_state = "picket"
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bashed","smacked")
	resistance_flags = FLAMMABLE

	new_attack_chain = TRUE

	/// The cooldown tracking when we can next wave the sign
	COOLDOWN_DECLARE(wave_cooldown)

	var/label = ""

/obj/item/picket_sign/attack_by(obj/item/attacking, mob/user, params)
	. = ..()
	if(is_pen(attacking) || istype(attacking, /obj/item/toy/crayon))
		var/txt = tgui_input_text(user, "What would you like to write on the sign?", "Sign Label", max_length = 30)
		if(isnull(txt))
			return
		label = txt
		src.name = "[label] sign"
		desc =	"It reads: [label]"
	..()

/obj/item/picket_sign/activate_self(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, wave_cooldown))
		user.show_message("<span class='warning'>Your arm is too tired to do that again so soon!</span>")
		return

	if(label)
		user.visible_message("<span class='notice'>[user] waves around \the \"[label]\" sign.</span>")
	else
		user.visible_message("<span class='notice'>[user] waves around blank sign.</span>")
	user.changeNext_move(CLICK_CD_MELEE)
	COOLDOWN_START(src, wave_cooldown, 8 SECONDS)

/datum/crafting_recipe/picket_sign
	name = "Picket Sign"
	result = list(/obj/item/picket_sign)
	reqs = list(/obj/item/stack/rods = 1,
				/obj/item/stack/sheet/cardboard = 2)
	time = 80
	category = CAT_MISC
