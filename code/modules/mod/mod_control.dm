/// MODsuits, trade-off between armor and utility
/obj/item/mod
	name = "Base MOD"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'

/obj/item/mod/control
	name = "MOD control unit"
	desc = "The control unit of a Modular Outerwear Device, a powered suit that protects against various environments."
	base_icon_state = "control"
	inhand_icon_state = "mod_control"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	strip_delay = 10 SECONDS
	actions_types = list(
		/datum/action/item_action/mod/deploy,
		/datum/action/item_action/mod/activate,
		/datum/action/item_action/mod/panel,
		/datum/action/item_action/mod/module,
	)
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	siemens_coefficient = 0.5
	var/datum/wires/mod/wires

	/// The MOD's theme, decides on some stuff like armor and statistics.
	var/datum/mod_theme/theme = /datum/mod_theme/standard
	/// Looks of the MOD.
	var/skin = "standard"
	/// Theme of the MOD TGUI
	var/ui_theme = "ntos"
	/// If the suit is deployed and turned on.
	var/active = FALSE
	/// If the suit wire/module hatch is open.
	var/open = FALSE
	/// If the suit is ID locked.
	var/locked = FALSE
	/// If the suit is malfunctioning.
	var/malfunctioning = FALSE
	/// If the suit is currently activating/deactivating.
	var/activating = FALSE
	/// How long the MOD is electrified for.
	var/seconds_electrified = 0
	/// If the suit interface is broken.
	var/interface_break = FALSE
	/// How much module complexity can this MOD carry.
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much module complexity this MOD is carrying.
	var/complexity = 0
	/// Power usage of the MOD.
	var/charge_drain = DEFAULT_CHARGE_DRAIN
	/// Slowdown of the MOD when not active.
	var/slowdown_inactive = 1.25
	/// Slowdown of the MOD when active.
	var/slowdown_active = 0.75
	/// How long this MOD takes each part to seal.
	var/activation_step_time = MOD_ACTIVATION_STEP_TIME
	/// Extended description of the theme.
	var/extended_desc
	/// MOD helmet.
	var/obj/item/clothing/head/mod/helmet
	/// MOD chestplate.
	var/obj/item/clothing/suit/mod/chestplate
	/// MOD gauntlets.
	var/obj/item/clothing/gloves/mod/gauntlets
	/// MOD boots.
	var/obj/item/clothing/shoes/mod/boots
	/// MOD core.
	var/obj/item/mod/core/core
	/// Associated list of parts (helmet, chestplate, gauntlets, boots) to their unsealed worn layer.
	var/list/mod_parts = list()
	/// Associated list of parts that can overslot to their overslot (overslot means the part can cover another layer of clothing).
	var/list/overslotting_parts = list()
	/// Modules the MOD currently possesses.
	var/list/modules = list()
	/// Currently used module.
	var/obj/item/mod/module/selected_module
	/// Person wearing the MODsuit.
	var/mob/living/carbon/human/wearer
	/// Internal storage in a modsuit
	var/obj/item/storage/backpack/modstorage/bag
	/// Is it EMP proof?
	var/emp_proof = FALSE
	/// List of overlays the mod has. Needs to be cut onremoval / module deactivation
	var/list/mod_overlays = list()
	/// Cham option for when the cham module is installed.
	var/datum/action/item_action/chameleon_change/modsuit/chameleon_action
	/// Is the control unit disquised?
	var/current_disguise = FALSE
	/// The MODlink datum, letting us call people from the suit.
	var/datum/mod_link/mod_link
	/// The starting MODlink frequency, by default NT to make it easier for everyone to use.
	var/starting_frequency = MODLINK_FREQ_NANOTRASEN

/obj/item/mod/control/serialize()
	var/list/data = ..()
	var/list/modules_list = list()
	for(var/obj/item/mod/module/mod as anything in modules)
		modules_list.Add(list(mod.serialize()))
	data["modules"] = modules_list
	return data

/obj/item/mod/control/deserialize(list/data)
	if(data["modules"])
		for(var/old_mods in modules)
			uninstall(old_mods, deleting = TRUE)
		for(var/obj/item/mod/module/module as anything in data["modules"])
			module = list_to_object(module, src)
			install(module)
	..()

/obj/item/mod/control/Initialize(mapload, datum/mod_theme/new_theme, new_skin, obj/item/mod/core/new_core)
	. = ..()
	if(new_theme)
		theme = new_theme
	theme = GLOB.mod_themes[theme]
	slot_flags = theme.slot_flags
	extended_desc = theme.extended_desc
	slowdown_inactive = theme.slowdown_inactive
	slowdown_active = theme.slowdown_active
	complexity_max = theme.complexity_max
	ui_theme = theme.ui_theme
	charge_drain = theme.charge_drain
	wires = new/datum/wires/mod(src)
	if(length(req_access))
		locked = TRUE
	new_core?.install(src)
	helmet = new /obj/item/clothing/head/mod(src)
	mod_parts += helmet
	chestplate = new /obj/item/clothing/suit/mod(src)
	chestplate.allowed += theme.allowed_suit_storage
	mod_parts += chestplate
	gauntlets = new /obj/item/clothing/gloves/mod(src)
	mod_parts += gauntlets
	boots = new /obj/item/clothing/shoes/mod(src)
	mod_parts += boots
	var/list/all_parts = mod_parts + src
	for(var/obj/item/part as anything in all_parts)
		part.name = "[theme.name] [part.name]"
		part.desc = "[part.desc] [theme.desc]"
		part.armor = part.armor.attachArmor(theme.armor_type_2.armor)
		part.resistance_flags = theme.resistance_flags
		part.flags |= theme.atom_flags //flags like initialization or admin spawning are here, so we cant set, have to add
		part.heat_protection = NONE
		part.cold_protection = NONE
		part.max_heat_protection_temperature = theme.max_heat_protection_temperature
		part.min_cold_protection_temperature = theme.min_cold_protection_temperature
		part.siemens_coefficient = theme.siemens_coefficient
		part.flags_2 = theme.flag_2_flags
	for(var/obj/item/part as anything in mod_parts)
		RegisterSignal(part, COMSIG_OBJ_DECONSTRUCT, PROC_REF(on_part_destruction)) //look into
		RegisterSignal(part, COMSIG_PARENT_QDELETING, PROC_REF(on_part_deletion))
	set_mod_skin(new_skin || theme.default_skin)
	update_speed()
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	for(var/obj/item/mod/module/module as anything in theme.inbuilt_modules)
		module = new module(src)
		install(module)
	ADD_TRAIT(src, TRAIT_ADJACENCY_TRANSPARENT, ROUNDSTART_TRAIT)
	START_PROCESSING(SSobj, src)
	mod_link = new(
		src,
		starting_frequency,
		CALLBACK(src, PROC_REF(get_wearer)),
		CALLBACK(src, PROC_REF(can_call)),
		CALLBACK(src, PROC_REF(make_link_visual)),
		CALLBACK(src, PROC_REF(get_link_visual)),
		CALLBACK(src, PROC_REF(delete_link_visual))
	)

/obj/item/mod/control/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module, deleting = TRUE)
	for(var/obj/item/part as anything in mod_parts)
		overslotting_parts -= part
	if(!QDELETED(helmet))
		mod_parts -= helmet
		QDEL_NULL(helmet)
	if(!QDELETED(chestplate))
		mod_parts -= chestplate
		QDEL_NULL(chestplate)
	if(!QDELETED(gauntlets))
		mod_parts -= gauntlets
		QDEL_NULL(gauntlets)
	if(!QDELETED(boots))
		mod_parts -= boots
		QDEL_NULL(boots)
	if(core)
		QDEL_NULL(core)
	QDEL_NULL(mod_link)
	QDEL_NULL(wires)
	wearer = null
	selected_module = null
	bag = null
	modules = null
	return ..()


/obj/item/mod/control/examine(mob/user)
	. = ..()
	if(active)
		. += "Charge: [core ? "[get_charge_percent()]%" : "No core"]."
		. += "Selected module: [selected_module || "None"]."
	if(!open && !active)
		if(!wearer)
			. += "You could equip it to turn it on."
		. += "You could open the cover with a <b>screwdriver</b>."
	else if(open)
		. += "You could close the cover with a <b>screwdriver</b>."
		. += "You could use <b>modules</b> on it to install them."
		. += "You could remove modules with a <b>crowbar</b>."
		. += "You could update the access lock with an <b>ID</b>."
		. += "You could access the wire panel with a <b>wire tool</b>."
		if(core)
			. += "You could remove [core] with a <b>wrench</b>."
		else
			. += "You could use a <b>MOD core</b> on it to install one."
	. += "You could copy/set link frequency with a <b>multitool</b>."

/obj/item/mod/control/examine_more(mob/user)
	. = ..()
	. += "<i>[extended_desc]</i>"

/obj/item/mod/control/process()
	if(seconds_electrified > 0)
		seconds_electrified--
	if(mod_link.link_call)
		subtract_charge((DEFAULT_CHARGE_DRAIN * 0.25))
	if(!active)
		return
	if(get_charge() <= 10 && active && !activating) //Sometimes we get power being funky, this should fix it.
		power_off()
		return
	var/malfunctioning_charge_drain = 0
	if(malfunctioning)
		malfunctioning_charge_drain = rand(1, 20)
	subtract_charge((charge_drain + malfunctioning_charge_drain))
	update_charge_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		if(malfunctioning && module.active && prob(5))
			module.on_deactivation(display_message = TRUE)
		module.on_process()

/obj/item/mod/control/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_BACK)
		set_wearer(user)
	else if(wearer)
		unset_wearer()


/obj/item/mod/control/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_BACK)
		return TRUE

/obj/item/mod/control/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!wearer || old_loc != wearer || loc == wearer)
		return
	clean_up()
	bag?.update_viewers()

/obj/item/mod/control/MouseDrop(atom/over_object)
	if(iscarbon(usr))
		var/mob/M = usr
		if(!Adjacent(usr, src))
			return

		if(!over_object)
			return

		if(ismecha(M.loc))
			return

		if(ismodcontrol(over_object))
			var/obj/item/mod/control/target = over_object
			bag?.dump_storage(M, target.bag)
			return
		if(isstorage(over_object))
			bag?.dump_storage(M, over_object)
			return

		if(!M.restrained() && !M.stat)
			playsound(loc, "rustle", 50, TRUE, -5)

			if(istype(over_object, /atom/movable/screen/inventory/hand))
				for(var/obj/item/part as anything in mod_parts)
					if(part.loc != src)
						to_chat(wearer, "<span class='warning'>Retract parts first!</span>")
						playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
						return
				if(!M.unequip(src, force = TRUE))
					return
				M.put_in_active_hand(src)
			else
				bag?.open(usr)

			add_fingerprint(M)

/obj/item/mod/control/wirecutter_act(mob/living/user, obj/item/I)
	if(open)
		if(seconds_electrified && get_charge() && shock(user))
			return TRUE
		wires.Interact(user)
		return TRUE
	return ..()

/obj/item/mod/control/wrench_act(mob/living/user, obj/item/wrench)
	if(..())
		return TRUE
	if(seconds_electrified && get_charge() && shock(user))
		return TRUE
	if(open)
		if(!core)
			to_chat(user, "<span class='warning'>There is no core!</span>")
			return TRUE
		wrench.play_tool_sound(src, 100)
		if(!wrench.use_tool(src, user, 3 SECONDS) || !open)
			return TRUE
		if(!core)
			return TRUE
		core.forceMove(drop_location())
		update_charge_alert()
		return TRUE
	return ..()

/obj/item/mod/control/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(open)
		if(seconds_electrified && get_charge() && shock(user))
			return TRUE
		wires.Interact(user)
		return TRUE
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	var/obj/item/linked_thing = locateUID(M.buffer_uid)

	if(!linked_thing)
		to_chat(user, "<span class='notice'>You save the frequency of [src] to the buffer.</span>")
		M.buffer_uid = UID()
		return TRUE
	if(ismodcontrol(linked_thing))
		var/obj/item/mod/control/chosen_control = linked_thing
		var/response = tgui_alert(user, "Would you like to copy the frequency to the multitool or imprint the frequency to [src]?", "MODlink Frequency", list("Copy", "Imprint"))
		if(!user.is_holding(I))
			return FALSE
		switch(response)
			if("Copy")
				to_chat(user, "<span class='notice'>You save the frequency of [src] to the buffer.</span>")
				M.buffer_uid = UID()
				return TRUE
			if("Imprint")
				mod_link.frequency = chosen_control.mod_link.frequency
				to_chat(user, "<span class='notice'>You imprint the frequency to [src].</span>")
				return TRUE
	else
		var/obj/item/clothing/neck/link_scryer/chosen_scryer = linked_thing
		var/response = tgui_alert(user, "Would you like to copy the frequency to the multitool or imprint the frequency to [src]?", "MODlink Frequency", list("Copy", "Imprint"))
		if(!user.is_holding(I))
			return FALSE
		switch(response)
			if("Copy")
				to_chat(user, "<span class='notice'>You save the frequency of [src] to the buffer.</span>")
				M.buffer_uid = UID()
				return TRUE
			if("Imprint")
				mod_link.frequency = chosen_scryer.mod_link.frequency
				to_chat(user, "<span class='notice'>You imprint the frequency to [src].</span>")
				return TRUE


/obj/item/mod/control/screwdriver_act(mob/living/user, obj/item/screwdriver)
	if(..())
		return TRUE
	if(active || activating || locate(/mob/living/silicon/ai) in src)
		to_chat(user, "<span class='warning'>Deactivate the suit first!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	to_chat(user, "<span class='notice'>[open ? "Closing" : "Opening"] cover...</span>")
	screwdriver.play_tool_sound(src, 100)
	if(screwdriver.use_tool(src, user, 1 SECONDS))
		if(active || activating)
			to_chat(user, "<span class='warning'>Deactivate the suit first!</span>")
		to_chat(user, "<span class='notice'>Cover [open ? "closed" : "opened"]</span>")
		open = !open
	return TRUE

/obj/item/mod/control/crowbar_act(mob/living/user, obj/item/crowbar)
	. = ..()
	if(!open)
		to_chat(user, "<span class='warning'>Open the cover first!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Insufficient access!</span>")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(seconds_electrified && get_charge() && shock(user))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MOD_MODULE_REMOVAL, user) & MOD_CANCEL_REMOVAL)
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(length(modules))
		var/list/removable_modules = list()
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.removable)
				continue
			removable_modules += module
		var/obj/item/mod/module/module_to_remove = tgui_input_list(user, "Which module do you want to pry out?", "Module Removal", removable_modules)
		if(!module_to_remove?.mod)
			return FALSE
		uninstall(module_to_remove)
		module_to_remove.forceMove(drop_location())
		crowbar.play_tool_sound(src, 100)
		SEND_SIGNAL(src, COMSIG_MOD_MODULE_REMOVED, user)
		return TRUE
	to_chat(user, "<span class='warning'>No modules!</span>")
	playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	return FALSE

/obj/item/mod/control/attackby__legacy__attackchain(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/mod/module))
		if(!open)
			to_chat(user, "<span class='warning'>Open the cover first!</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		install(attacking_item, user)
		SEND_SIGNAL(src, COMSIG_MOD_MODULE_ADDED, user)
		return TRUE
	else if(istype(attacking_item, /obj/item/mod/core))
		if(!open)
			to_chat(user, "<span class='warning'>Open the cover first!</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		if(core)
			to_chat(user, "<span class='warning'>Core already installed!</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		var/obj/item/mod/core/attacking_core = attacking_item
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		user.drop_item()
		attacking_core.install(src)
		update_charge_alert()
		return TRUE
	else if(open && attacking_item.GetID())
		update_access(user, attacking_item.GetID())
		return TRUE
	else if(istype(attacking_item, /obj/item/stock_parts/cell))
		if(!core)
			to_chat(user, "<span class='warning'>There is no core installed!</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		core.on_attackby(attacking_item, user, params)
	else if(istype(attacking_item, /obj/item/stack/ore/plasma) || istype(attacking_item, /obj/item/stack/sheet/mineral/plasma))
		if(!core)
			to_chat(user, "<span class='warning'>There is no core installed!</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		core.on_attackby(attacking_item, user, params)
	else if(istype(attacking_item, /obj/item/mod/skin_applier))
		return ..()
	else if(bag && istype(attacking_item))
		bag.attackby__legacy__attackchain(attacking_item, user, params)

	return ..()

/obj/item/mod/control/attack_hand(mob/living/carbon/user)
	if(!iscarbon(user))
		return
	if(loc == user && user.back && user.back == src)
		bag?.open(user)
	else
		..()

/obj/item/mod/control/AltClick(mob/user)
	if(ishuman(user) && Adjacent(user) && !user.incapacitated(FALSE, TRUE))
		bag?.open(user)
		add_fingerprint(user)
	else if(isobserver(user))
		bag?.show_to(user)

/obj/item/mod/control/attack_ghost(mob/user)
	if(isobserver(user))
		// Revenants don't get to play with the toys.
		bag?.show_to(user)
	return ..()

/obj/item/mod/control/proc/can_be_inserted(I, stop_messages)
	if(bag)
		return bag.can_be_inserted(I, stop_messages)
	return FALSE

/obj/item/mod/control/proc/handle_item_insertion(I, mob/user, prevent_warning)
	if(bag)
		bag.handle_item_insertion(I, user, prevent_warning)

/obj/item/mod/control/get_cell()
	if(!open)
		return
	var/obj/item/stock_parts/cell/cell = get_charge_source()
	if(!istype(cell))
		return
	return cell

/obj/item/mod/control/GetAccess()
	if(locate(/mob/living/silicon/ai) in src)
		return req_access.Copy()
	return ..()

/obj/item/mod/control/emag_act(mob/user)
	locked = !locked
	to_chat(user, "<span class='warning'>Suit access [locked ? "locked" : "unlocked"]")
	return TRUE

/obj/item/mod/control/emp_act(severity)
	. = ..()
	if(!active || !wearer)
		return
	to_chat(wearer, "<span class='warning'>[severity > EMP_HEAVY ? "Light" : "Strong"] electromagnetic pulse detected!")
	if(emp_proof)
		return
	selected_module?.on_deactivation(display_message = TRUE)
	wearer.apply_damage(10 / severity, BURN, spread_damage = TRUE) //Test this with ion shotguns.
	to_chat(wearer, "<span class='danger'>You feel [src] heat up from the EMP, burning you slightly!")
	if(wearer.stat < UNCONSCIOUS && prob(10))
		wearer.emote("scream")
	core.emp_act(severity)
	if(prob(50 / severity))
		wires.emp_pulse() //3 wires get pulsed. Dangerous to a mod user.
	for(var/obj/item/mod/module/holster/H in modules)
		H.holstered?.emp_act(severity)
	if(bag)
		bag.emp_act(severity)


/obj/item/mod/control/dropped(mob/user)
	. = ..()
	if(!wearer)
		return
	clean_up()
	update_mod_overlays(TRUE)
	if(active && !toggle_activate(force_deactivate = TRUE))
		return
	for(var/obj/item/part as anything in mod_parts)
		if(part.loc == src)
			continue
		retract(null, part)
	return ..()

/obj/item/mod/control/update_icon_state()
	if(current_disguise || isnull(chameleon_action) || active)
		icon_state = "[skin]-[base_icon_state][active ? "-sealed" : ""]"
	return ..()

/obj/item/mod/control/proc/set_wearer(mob/living/carbon/human/user)
	if(wearer == user)
		// This should also not happen.
		// This path is hit when equipping an outfit with visualsOnly, but only sometimes, and this eventually gets called twice.
		// I'm not sure this proc should ever be being called by visualsOnly, but it is,
		// and this was an emergency patch.
		return
	else if(!isnull(wearer))
		stack_trace("set_wearer() was called with a new wearer without unset_wearer() being called")

	wearer = user
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_SET, wearer)
	RegisterSignal(wearer, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	update_charge_alert()
	update_mod_overlays()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_equip()

/obj/item/mod/control/proc/unset_wearer()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_unequip()
	UnregisterSignal(wearer, list(COMSIG_ATOM_EXITED, COMSIG_SPECIES_GAIN))
	wearer.clear_alert("mod_charge")
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_UNSET, wearer)
	wearer = null

/obj/item/mod/control/proc/clean_up()
	if(active || activating)
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.active)
				continue
			module.on_deactivation(display_message = FALSE)
		for(var/obj/item/part as anything in mod_parts)
			seal_part(part, seal = FALSE)
	for(var/obj/item/part as anything in mod_parts)
		retract(null, part)
	if(active)
		finish_activation(on = FALSE)
		mod_link?.end_call()
	var/mob/old_wearer = wearer
	unset_wearer()
	old_wearer.drop_item()

/obj/item/mod/control/proc/quick_module(mob/user)
	if(!length(modules))
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/obj/item/mod/module/module as anything in modules)
		if(module.module_type == MODULE_PASSIVE)
			continue
		display_names[module.name] = module
		var/image/module_image = image(icon = module.icon, icon_state = module.icon_state)
		if(module == selected_module)
			module_image.underlays += image(icon = 'icons/hud/radial.dmi', icon_state = "module_selected")
		else if(module.active)
			module_image.underlays += image(icon = 'icons/hud/radial.dmi', icon_state = "module_active")
		if(!COOLDOWN_FINISHED(module, cooldown_timer))
			module_image.add_overlay(image(icon = 'icons/hud/radial.dmi', icon_state = "module_cooldown"))
		items += list(module.name = module_image)
	if(!length(items))
		return
	var/radial_anchor = src
	var/pick = show_radial_menu(user, radial_anchor, items, custom_check = FALSE, require_near = TRUE)
	if(!pick)
		return
	var/module_reference = display_names[pick]
	var/obj/item/mod/module/picked_module = module_reference
	picked_module.on_select()

/obj/item/mod/control/proc/shock(mob/living/user)
	if(!istype(user) || get_charge() < 1)
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	return electrocute_mob(user, get_charge_source(), src, 1, check_range)

/obj/item/mod/control/proc/install(obj/item/mod/module/new_module, mob/user)
	for(var/obj/item/mod/module/old_module as anything in modules)
		if(is_type_in_list(new_module, old_module.incompatible_modules) || is_type_in_list(old_module, new_module.incompatible_modules))
			if(user)
				to_chat(user, "<span class='warning'>[new_module] incompatible with [old_module]!")
				playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return
	var/complexity_with_module = complexity
	complexity_with_module += new_module.complexity
	if(complexity_with_module > complexity_max)
		if(user)
			to_chat(user, "<span class='warning'>[new_module] would make [src] too complex!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(user)
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[new_module] is stuck to your hand!</span>")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return
	new_module.forceMove(src)
	modules += new_module
	complexity += new_module.complexity
	new_module.mod = src
	new_module.on_install()
	if(wearer)
		new_module.on_equip()
	if(active)
		new_module.on_suit_activation()
	if(user)
		to_chat(user, "<span class='notice'>[new_module] added!")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)

/obj/item/mod/control/proc/uninstall(obj/item/mod/module/old_module, deleting = FALSE)
	modules -= old_module
	complexity -= old_module.complexity
	if(wearer)
		old_module.on_unequip()
	if(active)
		old_module.on_suit_deactivation(deleting = deleting)
		if(old_module.active)
			old_module.on_deactivation(display_message = !deleting, deleting = deleting)
	old_module.on_uninstall(deleting = deleting)
	QDEL_LIST_ASSOC_VAL(old_module.pinned_to)
	old_module.mod = null

/// Intended for callbacks, don't use normally, just get wearer by itself.
/obj/item/mod/control/proc/get_wearer()
	return wearer

/obj/item/mod/control/proc/update_access(mob/user, obj/item/card/id/card)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Insufficient access!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	req_access = card.access.Copy()
	to_chat(user, "<span class='notice'>Access updated!")

/obj/item/mod/control/proc/update_mod_overlays(full_removal = FALSE)
	if(!wearer)
		return
	for(var/I in mod_overlays)
		wearer.cut_overlay(I)
		mod_overlays -= I
	if(full_removal)
		return
	for(var/obj/item/mod/module/M in modules)
		M.add_module_overlay(wearer)

/obj/item/mod/control/proc/get_charge_source()
	return core?.charge_source()

/obj/item/mod/control/proc/get_charge()
	return core?.charge_amount() || 0

/obj/item/mod/control/proc/get_max_charge()
	return core?.max_charge_amount() || 1 //avoid dividing by 0

/obj/item/mod/control/proc/get_charge_percent()
	return ((get_charge() / get_max_charge()) * 100)

/obj/item/mod/control/proc/add_charge(amount)
	return core?.add_charge(amount) || FALSE

/obj/item/mod/control/proc/subtract_charge(amount)
	return core?.subtract_charge(amount) || FALSE

/obj/item/mod/control/proc/check_charge(amount)
	return core?.check_charge(amount) || FALSE

/obj/item/mod/control/proc/update_charge_alert()
	if(!wearer)
		return
	if(!core)
		wearer.throw_alert("mod_charge", /atom/movable/screen/alert/nocell)
		return
	core.update_charge_alert()

/obj/item/mod/control/proc/update_speed()
	var/list/all_parts = mod_parts + src
	for(var/obj/item/part as anything in all_parts)
		part.slowdown = (active ? slowdown_active : slowdown_inactive) / length(all_parts)

/obj/item/mod/control/proc/power_off()
	to_chat(wearer, "<span class='warning'>Power cells depleted!")
	toggle_activate(wearer, force_deactivate = TRUE)

/obj/item/mod/control/proc/set_mod_color(new_color)
	var/list/all_parts = mod_parts + src
	for(var/obj/item/part as anything in all_parts)
		part.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		part.add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)
	wearer?.regenerate_icons()

/obj/item/mod/control/proc/set_mod_skin(new_skin)
	if(active)
		CRASH("[src] tried to set skin while active!")
	skin = new_skin
	var/list/used_skin = theme.skins[new_skin]
	var/list/skin_updating = mod_parts + src
	for(var/obj/item/part as anything in skin_updating)
		part.icon = used_skin[MOD_ICON_OVERRIDE] || 'icons/obj/clothing/modsuit/mod_clothing.dmi'
		part.icon_state = "[skin]-[part.base_icon_state]"
	for(var/obj/item/clothing/part as anything in mod_parts)
		var/used_category
		if(part == helmet)
			used_category = HELMET_FLAGS
		if(part == chestplate)
			used_category = CHESTPLATE_FLAGS
		if(part == gauntlets)
			used_category = GAUNTLETS_FLAGS
		if(part == boots)
			used_category = BOOTS_FLAGS
		var/list/category = used_skin[used_category]
		part.flags = category[UNSEALED_CLOTHING] || NONE
		part.visor_flags = category[SEALED_CLOTHING] || NONE
		part.flags_inv = category[UNSEALED_INVISIBILITY] || NONE
		part.visor_flags_inv = category[SEALED_INVISIBILITY] || NONE
		part.flags_cover = category[UNSEALED_COVER] || NONE
		part.visor_flags_cover = category[SEALED_COVER] || NONE
		if(!category[CAN_OVERSLOT])
			if(overslotting_parts[part])
				var/obj/item/overslot = overslotting_parts[part]
				overslot.forceMove(drop_location())
			overslotting_parts -= part
			continue
		overslotting_parts |= part
	var/used_skin_modifiers = theme.skin_modifiers[new_skin]
	apply_modifiers(used_skin_modifiers)
	wearer?.regenerate_icons()

/obj/item/mod/control/proc/apply_modifiers(modifiers)
	if(modifiers & MAKE_SPACEPROOF)
		min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
		for(var/obj/item/clothing/part in mod_parts)
			part.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT

/obj/item/mod/control/proc/on_exit(datum/source, atom/movable/part, direction)
	SIGNAL_HANDLER

	if(part.loc == src)
		return
	if(part == core)
		core.uninstall()
		update_charge_alert()
		return
	if(part.loc == wearer)
		return
	if(part in modules)
		uninstall(part)
		return
	if(part in mod_parts)
		if(!wearer)
			part.forceMove(src)
			return
		retract(wearer, part, TRUE)
		if(active)
			INVOKE_ASYNC(src, PROC_REF(toggle_activate), wearer, TRUE)

/obj/item/mod/control/proc/on_part_destruction(obj/item/part, damage_flag)
	SIGNAL_HANDLER

	if(overslotting_parts[part])
		var/obj/item/overslot = overslotting_parts[part]
		overslot.forceMove(drop_location())
		overslotting_parts[part] = null
	if(QDELETED(src))
		return
	obj_destruction(damage_flag)

/obj/item/mod/control/proc/on_overslot_exit(datum/source, atom/movable/overslot, direction)
	SIGNAL_HANDLER

	if(overslot != overslotting_parts[source])
		return
	overslotting_parts[source] = null

/obj/item/mod/control/proc/on_part_deletion(obj/item/part) //the part doesnt count as being qdeleted, so our destroying does an infinite loop, fix later
	SIGNAL_HANDLER

	if(QDELETED(src))
		return
	qdel(src)


/obj/item/mod/control/water_act(volume, temperature, source, method)
	if(HAS_TRAIT(src, TRAIT_OIL_SLICKED)) //Overide base to work right
		slowdown_active = theme.slowdown_active
		slowdown_inactive = theme.slowdown_inactive
		update_speed()
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
		REMOVE_TRAIT(src, TRAIT_OIL_SLICKED, "potion")
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.regenerate_icons()

/obj/item/mod/control/extinguish_light(force)
	. = ..()
	for(var/obj/item/mod/module/module as anything in modules)
		module.extinguish_light(force)

/obj/item/mod/control/hear_message(mob/living/user, msg)
	if(bag)
		for(var/obj/object in bag)
			object.hear_message(user, msg)
