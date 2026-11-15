#define BUILDING_WALL_ABILITY "building wall ability"

/datum/action/cooldown/mob_cooldown/bot/build_girder
	name = "Build Girder"
	desc = "Use iron rods to build a girder!"
	button_icon = 'icons/obj/structures.dmi'
	button_icon_state = "girder"

/datum/action/cooldown/mob_cooldown/bot/build_girder/IsAvailable(show_message)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/stack/sheet/metal/our_metal = locate() in owner
	if(isnull(our_metal) || our_metal.amount < 2)
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/bot/build_girder/Activate(atom/target)
	var/turf/turf_target = get_turf(target)
	if(turf_target.is_blocked_turf() || isspaceturf(turf_target))
		to_chat(owner, SPAN_WARNING("You cannot build here!"))
		return TRUE
	var/obj/item/stack/sheet/metal/our_metal = locate() in owner
	var/obj/effect/temp_visual/rcd_effect/short/effect = new(turf_target, 3 SECONDS)

	if(!do_after(owner, 3 SECONDS, target = turf_target, interaction_key = BUILDING_WALL_ABILITY) || isnull(turf_target) || turf_target.is_blocked_turf())
		qdel(effect)
		return TRUE

	playsound(turf_target, 'sound/machines/click.ogg', 50, TRUE)
	new /obj/structure/girder(turf_target)
	our_metal.use(2)
	StartCooldown()
	qdel(effect)
	return TRUE

/datum/action/repairbot_resources
	name = "Resources"
	desc = "Manage your resources."
	button_icon = 'icons/obj/stacks/minerals.dmi'
	button_icon_state = "sheet-metal_3"
	background_icon_state = "bg_tech_blue"
	overlay_icon_state = "bg_tech_blue_border"
	///things we arent allowed to eject
	var/static/list/eject_blacklist = typecacheof(list(
		/obj/item/stack/rods,
	))

/datum/action/repairbot_resources/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	ui_interact(owner)

/datum/action/repairbot_resources/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RepairbotResources")
		ui.open()

/datum/action/repairbot_resources/ui_state(mob/user)
	return GLOB.always_state

/datum/action/repairbot_resources/ui_data(mob/user)
	var/list/data = list()
	data["stacks"] = list()
	for(var/obj/item/stack/managed_stack in user.contents)
		data["stacks"] += list(list(
			"stack_reference" = ref(managed_stack),
			"stack_name" = managed_stack.name,
			"stack_amount" = managed_stack.amount,
			"stack_maximum_amount" = managed_stack.max_amount,
			"stack_icon" = managed_stack.icon,
			"stack_icon_state" = managed_stack.icon_state,
		))

	return data

/datum/action/repairbot_resources/ui_static_data(mob/user)
	var/list/data = list()
	data["repairbot_icon_state"] = "repairbot_smile"
	return data


/datum/action/repairbot_resources/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject")
			var/atom/movable/my_sheet = locate(params["item_reference"]) in owner.contents
			if(isnull(my_sheet))
				return
			if(is_type_in_typecache(my_sheet, eject_blacklist))
				to_chat(owner, SPAN_WARNING("You're unable to eject [my_sheet]!"))
				return

			my_sheet.forceMove(owner.drop_location())

#undef BUILDING_WALL_ABILITY
