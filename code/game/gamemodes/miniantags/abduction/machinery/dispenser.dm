/obj/machinery/abductor/gland_dispenser
	name = "Replacement Organ Storage"
	desc = "A tank filled with replacement organs."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "dispenser"
	density = TRUE
	anchored = TRUE
	var/list/gland_types
	var/list/gland_colors
	var/list/amounts
	var/list/color_pool = list(
		"#700b08",
		"#b87411",
		"#8e8004",
		"#2d7248",
		"#095da2",
		"#4d238e",
		"#661553",
		"#a70b03",
		"#576402",
		"#204a77",
		"#994225",
		"#663f36",
		"#bd3675",
		"#b9723c",
		"#e76a68",
		"#206e16"
	)

/obj/machinery/abductor/gland_dispenser/Initialize(mapload)
	. = ..()
	gland_types = subtypesof(/obj/item/organ/internal/heart/gland)
	gland_types = shuffle(gland_types)
	gland_colors = new /list(length(gland_types))
	amounts = new /list(length(gland_types))
	var/list/colors = shuffle(color_pool)
	for(var/i in 1 to length(gland_types))
		gland_colors[i] = pick_n_take(colors)
		amounts[i] = rand(1,5)
		if(!length(colors))
			colors = shuffle(color_pool)

/obj/machinery/abductor/gland_dispenser/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/abductor/gland_dispenser/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GlandDispenser", name)
		ui.open()

/obj/machinery/abductor/gland_dispenser/ui_data(mob/user)
	var/list/data = list()
	data["glands"] = list()
	for(var/gland_number in 1 to length(gland_colors))
		var/list/gland_information = list(
			"color" = gland_colors[gland_number],
			"amount" = amounts[gland_number],
			"id" = gland_number,
		)
		data["glands"] += list(gland_information)
	return data

/obj/machinery/abductor/gland_dispenser/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(!isabductor(ui.user))
		return

	switch(action)
		if("dispense")
			var/gland_id = text2num(params["gland_id"])
			if(!ISINDEXSAFE(amounts, gland_id))
				return
			Dispense(gland_id)
			return TRUE

/obj/machinery/abductor/gland_dispenser/attack_hand(mob/user)
	if(!isabductor(user))
		to_chat(user, "<span class='warning'>You don't understand any of the alien writing!</span>")
		return
	ui_interact(user)

/obj/machinery/abductor/gland_dispenser/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/organ/internal/heart/gland))
		if(!user.drop_item())
			return ITEM_INTERACT_COMPLETE
		used.forceMove(src)
		for(var/i in 1 to length(gland_colors))
			if(gland_types[i] == used.type)
				amounts[i]++
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/abductor/gland_dispenser/proc/Dispense(count)
	if(amounts[count]>0)
		amounts[count]--
		var/T = gland_types[count]
		new T(get_turf(src))
