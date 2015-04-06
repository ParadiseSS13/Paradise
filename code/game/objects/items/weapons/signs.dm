/obj/item/weapon/picket_sign
	icon_state = "picket"
	item_state = "picket"
	icon_override = 'icons/mob/in-hand/tools.dmi'
	name = "blank picket sign"
	desc = "It's blank"
	force = 5
	w_class = 4.0
	attack_verb = list("bashed","smacked")

	var/label = ""

/obj/item/weapon/picket_sign/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/toy/crayon))
		var/txt = stripped_input(user, "What would you like to write on the sign?", "Sign Label", null , 30)
		if(txt)
			label = txt
			src.name = "[label] sign"
			desc =	"It reads: [label]"
	..()

/obj/item/weapon/picket_sign/attack_self(mob/living/carbon/human/user)
	if(label)
		user.visible_message("<span class='warning'>[user] waves around \the \"[label]\" sign.</span>")
	else
		user.visible_message("<span class='warning'>[user] waves around blank sign.</span>")
	user.changeNext_move(CLICK_CD_MELEE)

/datum/table_recipe/picket_sign
	name = "Picket Sign"
	result = /obj/item/weapon/picket_sign
	reqs = list(/obj/item/stack/rods = 1,
				/obj/item/stack/sheet/cardboard = 2)
	time = 80