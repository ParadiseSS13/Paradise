/obj/item/picket_sign
	icon_state = "picket"
	item_state = "picket"
	name = "blank picket sign"
	desc = "It's blank"
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("bashed","smacked")
	resistance_flags = FLAMMABLE

	var/delayed = 0 //used to do delays

	var/label = ""

/obj/item/picket_sign/attackby(obj/item/W, mob/user, params)
	if(is_pen(W) || istype(W, /obj/item/toy/crayon))
		var/txt = tgui_input_text(user, "What would you like to write on the sign?", "Sign Label", max_length = 30)
		if(isnull(txt))
			return
		label = txt
		src.name = "[label] sign"
		desc =	"It reads: [label]"
	..()

/obj/item/picket_sign/attack_self(mob/living/carbon/human/user)
	if(delayed)
		user.show_message("<span class='warning'>Your arm is too tired to do that again so soon!</span>")
		return

	delayed = 1
	if(label)
		user.visible_message("<span class='notice'>[user] waves around \the \"[label]\" sign.</span>")
	else
		user.visible_message("<span class='notice'>[user] waves around blank sign.</span>")
	user.changeNext_move(CLICK_CD_MELEE)

	sleep(8)
	delayed = 0

/datum/crafting_recipe/picket_sign
	name = "Picket Sign"
	result = list(/obj/item/picket_sign)
	reqs = list(/obj/item/stack/rods = 1,
				/obj/item/stack/sheet/cardboard = 2)
	time = 80
	category = CAT_MISC
