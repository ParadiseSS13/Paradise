/obj/structure/plast_barrel
	name = "barrel"
	desc = "A large plasteel barrel where you can hold liquids inside. Open tap to put liquids in, close tap to take liquids out. Use a wrench to move, dismantle with a crowbar."
	icon = 'icons/hispania/obj/miscellaneous.dmi'
	icon_state = "barrel"
	density = TRUE
	anchored = TRUE
	container_type = DRAINABLE | AMOUNT_VISIBLE
	pressure_resistance = 2 * ONE_ATMOSPHERE
	max_integrity = 500
	var/material = /obj/item/stack/sheet/plasteel
	var/cantidad = 500
	var/open = FALSE

/obj/structure/plast_barrel/New()
	create_reagents(cantidad)
	. = ..()

/obj/structure/plast_barrel/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is currently [open ? "open, letting you pour liquids in." : "closed, letting you draw liquids from the tap."] </span>"

/obj/structure/plast_barrel/attack_hand(mob/user)
	open = !open
	if(open)
		container_type = REFILLABLE | AMOUNT_VISIBLE
		to_chat(user, "<span class='notice'>You open [src], letting you fill it.</span>")
	else
		container_type = DRAINABLE | AMOUNT_VISIBLE
		to_chat(user, "<span class='notice'>You close [src], letting you draw from its tap.</span>")
	update_icon()

/obj/structure/plast_barrel/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, time = 20)

/obj/structure/plast_barrel/update_icon()
	..()
	if(open)
		icon_state = "barrel_open"
	else
		icon_state = "barrel"

/obj/structure/plast_barrel/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(disassembled = TRUE)

/obj/structure/plast_barrel/deconstruct(disassembled = FALSE)
	var/mat_drop = 2
	if(disassembled)
		mat_drop = 5
	new material(drop_location(), mat_drop)
	..()
