
/obj/machinery/kitchen_machine/grill
	name = "grill"
	desc = "Backyard grilling, IN SPACE."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "grill_off"
	cook_verbs = list("Grilling", "Searing", "Frying")
	recipe_type = RECIPE_GRILL
	off_icon = "grill_off"
	on_icon = "grill_on"
	dirty_icon = "grill_dirty"
	open_icon = "grill_open"
	soundloop_type = /datum/looping_sound/kitchen/grill

// see code/modules/food/recipes_grill.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/grill/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/grill(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/grill/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/grill(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/grill/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	efficiency = round((E/2), 1) // There's 2 lasers, so halve the effect on the efficiency to keep it balanced

/obj/machinery/kitchen_machine/grill/special_attack(mob/user, mob/living/carbon/target, from_grab)
	target.visible_message(
		"<span class='danger'>[user] [from_grab ? "forces" : "shoves"] [target] onto [src], searing [target]'s body!</span>",
		"<span class='userdanger'>[user] [from_grab ? "forces" : "shoves"] you onto [src]! It burns!</span>"
	)

	target.emote("scream")
	playsound(src, "sound/machines/kitchen/grill_mid.ogg", 100)
	target.adjustFireLoss(from_grab ? 30 : 20)
	add_attack_logs(user, target, "Burned with [src]")
	return TRUE
