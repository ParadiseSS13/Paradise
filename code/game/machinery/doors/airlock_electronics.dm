/obj/item/airlock_electronics
	name = "airlock electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	origin_tech = "engineering=2;programming=1"
	req_access = list(ACCESS_ENGINE)
	usesound = 'sound/items/deconstruct.ogg'
	/// List of accesses currently set
	var/list/selected_accesses = list()
	/// Is the door access using req_one_access (TRUE) or req_access (FALSE)
	var/one_access = FALSE
	/// An associative list containing all station accesses. Includes their name and access number.
	var/static/list/door_accesses_list = list()
	/// Maximum brain damage a mob can have until it can't use the electronics
	var/const/max_brain_damage = 60
	/// Which direction has unrestricted access to the airlock (e.g. medbay doors from the inside)
	var/unres_access_from = null
	/// Is this electronic installed in a door?
	var/is_installed = FALSE

	new_attack_chain = TRUE

/obj/item/airlock_electronics/Initialize(mapload)
	. = ..()
	if(!length(door_accesses_list))
		for(var/access in get_all_accesses())
			door_accesses_list += list(list(
				"name" = get_access_desc(access),
				"id" = access))

/obj/item/airlock_electronics/activate_self(mob/user)
	if(..() || (!ishuman(user) && !isrobot(user)))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= max_brain_damage)
			to_chat(user, "<span class='warning'>You forget how to use [src].</span>")
			return
	ui_interact(user)

// tgui\packages\tgui\interfaces\AirlockElectronics.js
/obj/item/airlock_electronics/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/airlock_electronics/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockElectronics", name)
		ui.open()

/obj/item/airlock_electronics/ui_data(mob/user)
	var/list/data = list()
	data["selected_accesses"] = selected_accesses
	data["one_access"] = one_access
	data["unrestricted_dir"] = unres_access_from
	return data

/obj/item/airlock_electronics/ui_static_data(mob/user)
	var/list/data = list()
	data["regions"] = get_accesslist_static_data(REGION_GENERAL, REGION_COMMAND)
	data["door_access_list"] = door_accesses_list
	return data

/obj/item/airlock_electronics/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	// Mostly taken from the RCD code
	switch(action)
		if("unrestricted_access")
			var/direction = text2num(params["unres_dir"])
			unres_access_from ^= direction

		if("set_one_access")
			one_access = params["access"] == "one" ? TRUE : FALSE

		if("set")
			var/access = text2num(params["access"])
			if(isnull(access))
				return FALSE
			if(access in selected_accesses)
				selected_accesses -= access
			else
				selected_accesses |= access

		if("grant_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < REGION_GENERAL || region > REGION_COMMAND)
				return FALSE
			selected_accesses |= get_region_accesses(region)

		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region) || region < REGION_GENERAL || region > REGION_COMMAND)
				return FALSE
			selected_accesses -= get_region_accesses(region)

		if("grant_all")
			selected_accesses = get_all_accesses()

		if("clear_all")
			selected_accesses = list()

/obj/item/airlock_electronics/destroyed
	name = "burned-out airlock electronics"
	icon_state = "door_electronics_smoked"

/obj/item/airlock_electronics/destroyed/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ACTIVATE_SELF, TYPE_PROC_REF(/datum, signal_cancel_activate_self))

/obj/item/airlock_electronics/destroyed/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["metal"] += 1
	C.stored_comms["glass"] += 1
	qdel(src)
	return TRUE
