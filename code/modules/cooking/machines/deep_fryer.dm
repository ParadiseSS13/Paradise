/datum/cooking_surface/deepfryer_basin
	cooker_id = COOKER_SURFACE_DEEPFRYER
	allow_temp_change = FALSE

// TODO: add back special attack for deep fryer for v2
// Yes, that's a v2 thing, I'm not doing it right now
/obj/machinery/cooking/deepfryer
	name = "deep fryer"
	desc = "A deep fryer that can hold two baskets."
	icon_state = "deep_fryer"
	allowed_containers = list(
		/obj/item/reagent_containers/cooking/deep_basket,
	)

/obj/machinery/cooking/deepfryer/Initialize(mapload)
	. = ..()

	InitializeParts()

	for(var/i in 1 to 2)
		surfaces += new/datum/cooking_surface/deepfryer_basin(src)

/obj/machinery/cooking/deepfryer/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	. = ..()
	if(istype(used, /obj/item/grab))
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/grab/G = used

		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, SPAN_DANGER("Deep frying [G.affecting] might hurt them!"))
			return ITEM_INTERACT_COMPLETE
		if(!G.confirm())
			return ITEM_INTERACT_COMPLETE
		if(!isliving(G.affecting))
			return ITEM_INTERACT_COMPLETE

		var/mob/living/target = G.affecting
		if(G.state < GRAB_AGGRESSIVE)
			to_chat(user, SPAN_WARNING("You need a tighter grip!"))
			return ITEM_INTERACT_COMPLETE
		user.visible_message(SPAN_WARNING("[user] begins to force [target] into the deep frier!"), SPAN_WARNING("You begin to force [target] into the burning hot oil!"))
		while(do_after_once(user, 5 SECONDS, target = target))
			target.visible_message(
				SPAN_DANGER("[user] sears [target]'s face with scalding hot oil!"),
				SPAN_USERDANGER("Your face is seared with scalding hot oil!"),
				SPAN_DANGER("You hear struggling and the sound of scalding hot oil searing something!")
			)
			playsound(src, 'sound/machines/kitchen/deep_fryer_evil.ogg', 50, TRUE)
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				H.emote("scream")
				H.adjustFireLossByPart(rand(20, 30), BODY_ZONE_HEAD)
				H.UpdateDamageIcon()
			else
				target.adjustFireLoss(25)
		user.changeNext_move(CLICK_CD_MELEE)

/obj/machinery/cooking/deepfryer/proc/InitializeParts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cooking/deep_fryer(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/cooking/deepfryer/emag_act(mob/user)
	emagged = TRUE
	visible_message(SPAN_WARNING("Hot oil begins to sputter and boil dangerously inside the fry pit!"), SPAN_WARNING("You hear something begin to boil and sputter angrily!"))
	for(var/datum/cooking_surface/deepfryer_basin/frier in surfaces)
		frier.frier_bypass = TRUE
	do_sparks(5, FALSE, src)

/obj/machinery/cooking/deepfryer/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("<b>Ctrl-Click</b> on a basin to set its timer and toggle it on or off.")
	if(emagged)
		. += SPAN_WARNING("Hot oil sputters and boils angrily inside the fry basins.")

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
	if(!input)
		return

	var/datum/cooking_surface/surface = surfaces[input]
	if(surface && surface.container)
		if(surface.on)
			surface.handle_cooking(user)
			var/mob/living/carbon/human/burn_victim = user
			if(istype(burn_victim) && !burn_victim.gloves)
				var/which_hand = "l_hand"
				if(!burn_victim.hand)
					which_hand = "r_hand"

				burn_victim.adjustFireLossByPart(20, which_hand)
				to_chat(burn_victim, SPAN_DANGER("You burn your hand a little taking [surface.container] off of [src]."))

		user.put_in_hands(surface.container)
		surface.UnregisterSignal(surface.container, COMSIG_PARENT_EXAMINE)
		surface.container.surface = null
		surface.container = null
		update_appearance(UPDATE_ICON)

/obj/machinery/cooking/deepfryer/update_overlays()
	. = ..()

	for(var/i in 1 to length(surfaces))
		var/datum/cooking_surface/surface = surfaces[i]
		if(!surface.container)
			continue

/obj/machinery/cooking/deepfryer/update_surface_icon(surface_idx)
	var/datum/cooking_surface/surface = surfaces[surface_idx]

	if(!surface.container)
		return
	var/obj/item/reagent_containers/cooking/deep_basket/basket = surface.container
	if(surface.on)
		basket.frying = TRUE
		basket.update_icon()
	else
		basket.frying = FALSE
		basket.update_icon()
	switch(surface_idx)
		if(1)
			basket.pixel_x = -6
			basket.pixel_y = 4
		if(2)
			basket.pixel_x = 7
			basket.pixel_y = 4

	add_to_visible(basket, surface_idx)

/obj/machinery/cooking/deepfryer/add_to_visible(obj/item/reagent_containers/cooking/container, surface_idx)
	container.vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	container.make_mini()
	vis_contents += container

/obj/machinery/cooking/deepfryer/loaded/upgraded/InitializeParts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cooking/deep_fryer(null)
	component_parts += new /obj/item/stock_parts/micro_laser/quadultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/quadultra(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/item/circuitboard/cooking/deep_fryer
	board_name = "Deep Fryer"
	build_path = /obj/machinery/cooking/deepfryer
	icon_state = "service"
	board_type = "machine"
	origin_tech = "biotech=1"
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/capacitor = 1,
	)

/obj/machinery/cooking/deepfryer/loaded/Initialize(mapload)
	. = ..()
	for(var/i in 1 to length(surfaces))
		var/datum/cooking_surface/surface = surfaces[i]
		surface.container = new /obj/item/reagent_containers/cooking/deep_basket(src)
		surface.container.surface = surface
	update_appearance()
