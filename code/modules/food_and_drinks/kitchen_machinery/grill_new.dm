
/obj/machinery/kitchen_machine/grill
	name = "grill"
	desc = "Backyard grilling, IN SPACE."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "grill_off"
	cook_verbs = list("Grilling", "Searing", "Frying")
	recipe_type = RECIPE_GRILL
	off_icon = "grill_off"
	on_icon = "grill_on"
	broken_icon = "grill_broke"
	dirty_icon = "grill_dirty"
	open_icon = "grill_open"

// see code/modules/food/recipes_grill.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/grill/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/grill(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/grill/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/grill(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/grill/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	efficiency = round((E/2), 1) // There's 2 lasers, so halve the effect on the efficiency to keep it balanced

/obj/machinery/kitchen_machine/grill/special_attack(obj/item/grab/G, mob/user)
	if(ishuman(G.affecting))
		if(G.state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return 0
		var/mob/living/carbon/human/C = G.affecting
		C.visible_message("<span class='danger'>[user] forces [C] onto [src], searing [C]'s body!</span>", \
						"<span class='userdanger'>[user] forces you onto [src]! It burns!</span>")
		C.emote("scream")
		user.changeNext_move(CLICK_CD_MELEE)
		C.adjustFireLoss(30)
		add_attack_logs(user, G.affecting, "Burned with [src]")
		qdel(G) //Removes the grip to prevent rapid sears and give you a chance to run
		return 0
	return 0