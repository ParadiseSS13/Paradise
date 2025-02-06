/datum/cooking_surface/deepfryer_basin
	cooker_id = COOKER_SURFACE_DEEPFRYER

// TODO: add back special attack for deep fryer for v2
// Yes, that's a v2 thing, I'm not doing it right now
/obj/machinery/cooking/deepfryer
	name = "deep fryer"
	desc = "A deep fryer that can hold two baskets."
	icon_state = "deep_fryer"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	cooking = FALSE
	allowed_containers = list(
		/obj/item/reagent_containers/cooking/deep_basket,
	)

/obj/machinery/cooking/deepfryer/Initialize(mapload)
	. = ..()

	component_parts = list()
	component_parts += new /obj/item/circuitboard/cooking/stove(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)

	for(var/i in 1 to 2)
		surfaces += new/datum/cooking_surface/deepfryer_basin(src)

	RefreshParts()

/obj/machinery/cooking/deepfryer/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Ctrl-Click</b> on a basket to set its timer.</span>"
	. += "<span class='notice'><b>Ctrl-Shift-Click</b> on a basket to toggle it on or off.</span>"

#define ICON_SPLIT_X 16
#define ICON_SPLIT_Y 16

/obj/machinery/cooking/deepfryer/clickpos_to_surface(modifiers)
	var/icon_x = text2num(modifiers["icon-x"])
	var/icon_y = text2num(modifiers["icon-y"])
	if(icon_y <= ICON_SPLIT_Y)
		return

	if(icon_x <= ICON_SPLIT_X)
		return 1
	else if(icon_x > ICON_SPLIT_X)
		return 2

#undef ICON_SPLIT_X
#undef ICON_SPLIT_Y

/obj/machinery/cooking/deepfryer/attack_hand(mob/user, params)
	var/input = clickpos_to_surface(params2list(params))
	var/datum/cooking_surface/surface = surfaces[input]
	if(surface.placed_item)
		if(surface.on)
			surface.handle_cooking(user)
			var/mob/living/carbon/human/burn_victim = user
			if(istype(burn_victim) && !burn_victim.gloves)
				var/which_hand = "l_hand"
				if(!burn_victim.hand)
					which_hand = "r_hand"

				burn_victim.adjustFireLossByPart(20, which_hand)
				to_chat(burn_victim, "<span class='danger'>You burn your hand a little taking the [surface.placed_item] off of \the [src].</span>")

		user.put_in_hands(surface.placed_item)
		surface.placed_item = null
		update_appearance(UPDATE_ICON)

/obj/machinery/cooking/deepfryer/update_icon()
	..()

	cut_overlays()

	for(var/i in 1 to 2)
		var/datum/cooking_surface/surface = surfaces[i]
		if(!surface.placed_item)
			continue

		if(surface.on)
			add_overlay(image(icon, icon_state = "fryer_basket_on_[i]"))
		else
			add_overlay(image(icon, icon_state = "fryer_basket_[i]"))

/obj/machinery/cooking/deepfryer/AltShiftClick(mob/user, modifiers)
	// No temperature changing on the deep fryer.
	return
