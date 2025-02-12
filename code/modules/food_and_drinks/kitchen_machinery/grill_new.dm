
/obj/machinery/kitchen_machine/grill
	name = "гриль"
	desc = "Гриль на заднем дворе, В КОСМОСЕ."
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

/obj/machinery/kitchen_machine/grill/special_attack_shove(mob/user, mob/living/carbon/target)
	target.visible_message(
		"<span class='danger'>[user] shoves [target] onto [src], the active grill surface searing [user.p_them()]!</span>",
		"<span class='userdanger'>[user] shoves you onto [src], and the hot surface sears you!</span>",
	)
	target.adjustFireLoss(15)

/obj/machinery/kitchen_machine/grill/special_attack(mob/user, mob/living/carbon/target, from_grab)
	target.visible_message(
		"<span class='danger'>[user] forces [target] onto [src]'s hot cooking surface, searing [target]'s body!</span>",
		"<span class='userdanger'>[user] forces you onto [src]! HOT HOT HOT!</span>",
		"<span class='warning'>You hear some meat being put on to cook.</span>"
	)

	target.emote("scream")
	playsound(src, "sound/machines/kitchen/grill_mid.ogg", 100)
	target.adjustFireLoss(30)
	target.forceMove(get_turf(src))
	target.Weaken(2 SECONDS)
	add_attack_logs(user, target, "Burned with [src]")
	return TRUE
