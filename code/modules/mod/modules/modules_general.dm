//General modules for MODsuits

///Storage - Adds a storage component to the suit.
/obj/item/mod/module/storage
	name = "MOD storage module"
	desc = "What amounts to a series of integrated storage compartments and specialized pockets installed across \
		the surface of the suit, useful for storing various bits, and or bobs."
	icon_state = "storage"
	complexity = 3
	incompatible_modules = list(/obj/item/mod/module/storage, /obj/item/mod/module/plate_compression)
	/// Max weight class of items in the storage.
	var/max_w_class = WEIGHT_CLASS_NORMAL
	/// Max combined weight of all items in the storage.
	var/max_combined_w_class = 15
	/// Max amount of items in the storage.
	var/max_items = 7
	var/obj/item/storage/backpack/modstorage/bag

/obj/item/mod/module/storage/serialize()
	var/list/data = ..()
	data["bag"] = bag.serialize()
	return data

/obj/item/mod/module/storage/deserialize(list/data)
	. = ..()
	qdel(bag)
	bag = list_to_object(data["bag"], src)
	bag.source = src

/obj/item/mod/module/storage/Initialize(mapload)
	. = ..()
	var/obj/item/storage/backpack/modstorage/S = new(src)
	bag = S
	bag.max_w_class = max_w_class
	bag.max_combined_w_class = max_combined_w_class
	bag.storage_slots = max_items
	bag.source = src

/obj/item/mod/module/storage/Destroy()
	QDEL_NULL(bag)
	return ..()


/obj/item/mod/module/storage/on_install()
	mod.bag = bag
	bag.forceMove(mod)

/obj/item/mod/module/storage/on_uninstall(deleting = FALSE)
	if(!deleting)
		for(var/obj/I in bag.contents)
			I.forceMove(get_turf(loc))
		bag.forceMove(src)
		mod.bag = null
		return
	qdel(bag)
	UnregisterSignal(mod.chestplate, COMSIG_ITEM_PRE_UNEQUIP)

/obj/item/mod/module/storage/on_suit_deactivation(deleting)
	. = ..()
	bag.forceMove(src) //So the pinpointer doesnt lie.

/obj/item/mod/module/storage/on_unequip()
	. = ..()
	bag.forceMove(src)

/obj/item/mod/module/storage/large_capacity
	name = "MOD expanded storage module"
	desc = "Reverse engineered by Cybersun Industries from Donk Corporation designs, this system of hidden compartments \
		is entirely within the suit, distributing items and weight evenly to ensure a comfortable experience for the user; \
		whether smuggling, or simply hauling."
	icon_state = "storage_large"
	max_combined_w_class = 21
	max_items = 14

/obj/item/mod/module/storage/syndicate
	name = "MOD syndicate storage module"
	desc = "A storage system using nanotechnology developed by Donk Corporation, these compartments use \
		esoteric technology to compress the physical matter of items put inside of them, \
		essentially shrinking items for much easier and more portable storage."
	icon_state = "storage_syndi"
	max_combined_w_class = 30
	max_items = 21
	origin_tech = "materials=6;bluespace=5;syndicate=2"

/obj/item/mod/module/storage/belt
	name = "MOD case storage module"
	desc = "Some concessions had to be made when creating a compressed modular suit core. \
	As a result, Roseus Galactic equipped their suit with a slimline storage case. \
	If you find this equipped to a standard modular suit, then someone has almost certainly shortchanged you on a proper storage module."
	icon_state = "storage_case"
	complexity = 0
	max_w_class = WEIGHT_CLASS_SMALL
	removable = FALSE
	max_combined_w_class = 21
	max_items = 7

/obj/item/mod/module/storage/bluespace
	name = "MOD bluespace storage module"
	desc = "A storage system developed by Nanotrasen, these compartments employ \
		miniaturized bluespace pockets for the ultimate in storage technology; regardless of the weight of objects put inside."
	icon_state = "storage_bluespace"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_combined_w_class = 60
	max_items = 21


//Internal
/obj/item/storage/backpack/modstorage
	name = "mod's storage"
	desc = "Either you tried to spawn a storage mod, or someone fucked up. Unless you are an admin that just tried to spawn something, issue report."
	var/obj/item/mod/module/storage/source

/obj/item/storage/backpack/modstorage/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/storage/backpack/modstorage/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/storage/backpack/modstorage/process()
	update_viewers()

/obj/item/storage/backpack/modstorage/update_viewers()
	for(var/_M in mobs_viewing)
		var/mob/M = _M
		if(!QDELETED(M) && M.s_active == src && (M in range(1, loc)) && (source.mod.loc == _M || (M in range(1, source.mod)))) //This ensures someone isn't taking it away from the mod unit
			continue
		hide_from(M)


///Ion Jetpack - Lets the user fly freely through space using battery charge.
/obj/item/mod/module/jetpack
	name = "MOD ion jetpack module"
	desc = "A series of electric thrusters installed across the suit, this is a module highly anticipated by trainee Engineers. \
		Rather than using gasses for combustion thrust, these jets are capable of accelerating ions using \
		charge from the suit's charge. Some say this isn't Cybersun Industries's first foray into jet-enabled suits."
	icon_state = "jetpack"
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/jetpack)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_jetpack"
	overlay_state_active = "module_jetpack_on"
	/// Do we stop the wearer from gliding in space.
	var/stabilizers = FALSE

/obj/item/mod/module/jetpack/proc/set_stabilizers(new_stabilizers)
	if(stabilizers == new_stabilizers)
		return
	stabilizers = new_stabilizers

/obj/item/mod/module/jetpack/get_configuration()
	. = ..()
	.["stabilizers"] = add_ui_configuration("Stabilizers", "bool", stabilizers)

/obj/item/mod/module/jetpack/configure_edit(key, value)
	switch(key)
		if("stabilizers")
			set_stabilizers(text2bool(value))

/obj/item/mod/module/jetpack/proc/allow_thrust()
	if(!active)
		return
	if(!drain_power(use_power_cost))
		return FALSE
	return TRUE

/obj/item/mod/module/jetpack/proc/get_user()
	return mod.wearer

/obj/item/mod/module/jetpack/on_activation()
	. = ..()
	mod.jetpack_active = TRUE

/obj/item/mod/module/jetpack/on_deactivation(display_message, deleting)
	. = ..()
	mod.jetpack_active = FALSE

/obj/item/mod/module/jetpack/advanced
	name = "MOD advanced ion jetpack module"
	desc = "An improvement on the previous model of electric thrusters. This one achieves better efficency through \
		mounting of more jets and a red paint applied on it."
	icon_state = "jetpack_advanced"
	overlay_state_inactive = "module_jetpackadv"
	overlay_state_active = "module_jetpackadv_on"
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.25
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	origin_tech = "materials=4;magnets=4;engineering=5" //To replace the old hardsuit upgrade jetpack levels.

///EMP Shield - Protects the suit from EMPs.
/obj/item/mod/module/emp_shield
	name = "MOD EMP shield module"
	desc = "A field inhibitor installed into the suit, protecting it against feedback such as \
		electromagnetic pulses that would otherwise damage the electronic systems of the suit or it's modules. \
		However, it will take from the suit's power to do so."
	icon_state = "empshield"
	origin_tech = "materials=6;bluespace=5;syndicate=2"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/emp_shield, /obj/item/mod/module/dna_lock)

/obj/item/mod/module/emp_shield/on_install()
	mod.emp_proof = TRUE

/obj/item/mod/module/emp_shield/on_uninstall(deleting = FALSE)
	mod.emp_proof = FALSE

///Flashlight - Gives the suit a customizable flashlight.
/obj/item/mod/module/flashlight
	name = "MOD flashlight module"
	desc = "A simple pair of configurable flashlights installed on the left and right sides of the helmet, \
		useful for providing light in a variety of ranges and colors. \
		Some survivalists prefer the color green for their illumination, for reasons unknown."
	icon_state = "flashlight"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/flashlight)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_light"
	overlay_state_active = "module_light_on"
	light_color = COLOR_WHITE
	///The light power for the mod
	var/mod_light_range = 4
	///The light range for the mod
	var/mod_light_power = 2
	var/light_on = FALSE
	/// Charge drain per range amount.
	var/base_power = DEFAULT_CHARGE_DRAIN * 0.1
	/// Minimum range we can set.
	var/min_range = 2
	/// Maximum range we can set.
	var/max_range = 5
	/// The cooldown before we can re-activate this after having it forcefully extinguished
	COOLDOWN_DECLARE(activation_cooldown)

/obj/item/mod/module/flashlight/on_activation()
	if(!COOLDOWN_FINISHED(src, activation_cooldown))
		to_chat(mod.wearer, "<span class='warning'>[src] isn't ready after being shut down!</span>")
		return
	. = ..()
	if(!.)
		return

	COOLDOWN_RESET(src, activation_cooldown)

	active_power_cost = base_power * mod_light_range
	mod.set_light(mod_light_range, mod_light_power, light_color)

/obj/item/mod/module/flashlight/on_deactivation(display_message = TRUE, deleting = FALSE)
	mod.set_light(0, mod_light_power, light_color)
	. = ..()
	if(!.)
		return

/obj/item/mod/module/flashlight/on_process()
	active_power_cost = base_power * mod_light_range
	return ..()

/obj/item/mod/module/flashlight/get_configuration()
	. = ..()
	.["light_color"] = add_ui_configuration("Light Color", "color", light_color)
	.["light_range"] = add_ui_configuration("Light Range", "number", mod_light_range)

/obj/item/mod/module/flashlight/configure_edit(key, value)
	switch(key)
		if("light_color")
			value = input(usr, "Pick new light color", "Flashlight Color") as color|null
			if(!value)
				return
			if(is_color_dark(value, 50))
				to_chat(mod.wearer, ("<span class='warning'>That is too dark</span>"))
				return
			light_color = value
			mod.wearer.regenerate_icons()
		if("light_range")
			mod_light_range = (clamp(text2num(value), min_range, max_range))
	mod.set_light(0, mod_light_power, light_color)
	mod_color_overide = light_color
	on_deactivation()

/obj/item/mod/module/flashlight/extinguish_light(force)
	. = ..()
	on_deactivation(FALSE)
	COOLDOWN_START(src, activation_cooldown, 20 SECONDS)

	to_chat(mod.wearer, "<span class='warning'>Your [name] shuts off!</span>")

///Dispenser - Dispenses an item after a time passes.
/obj/item/mod/module/dispenser
	name = "MOD burger dispenser module"
	desc = "A rare piece of technology reverse-engineered from a prototype found in a Donk Corporation vessel. \
		This can draw incredible amounts of power from the suit's charge to create edible organic matter in the \
		palm of the wearer's glove; however, research seemed to have entirely stopped at cheeseburgers. \
		Notably, all attempts to get it to dispense Earl Grey tea have failed."
	icon_state = "dispenser"
	module_type = MODULE_USABLE
	complexity = 3
	use_power_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/dispenser)
	cooldown_time = 5 SECONDS
	/// Path we dispense.
	var/dispense_type = /obj/item/reagent_containers/food/snacks/burger/cheese
	/// Time it takes for us to dispense.
	var/dispense_time = 0 SECONDS

/obj/item/mod/module/dispenser/on_use()
	. = ..()
	if(!.)
		return
	if(dispense_time && !do_after(mod.wearer, dispense_time, target = mod.wearer))
		return FALSE
	var/obj/item/dispensed = new dispense_type(mod.wearer.loc)
	mod.wearer.put_in_hands(dispensed)
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)
	drain_power(use_power_cost)
	return dispensed

///Thermal Regulator - Regulates the wearer's core temperature.
/obj/item/mod/module/thermal_regulator
	name = "MOD thermal regulator module"
	desc = "Advanced climate control, using an inner body glove interwoven with thousands of tiny, \
		flexible cooling lines. This circulates coolant at various user-controlled temperatures, \
		ensuring they're comfortable; even if they're some that like it hot."
	icon_state = "regulator"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/thermal_regulator)
	cooldown_time = 0.5 SECONDS
	/// The temperature we are regulating to.
	var/temperature_setting = BODYTEMP_NORMAL
	/// Minimum temperature we can set.
	var/min_temp = 293.15
	/// Maximum temperature we can set.
	var/max_temp = 318.15

/obj/item/mod/module/thermal_regulator/get_configuration()
	. = ..()
	.["temperature_setting"] = add_ui_configuration("Temperature", "number", temperature_setting - T0C)

/obj/item/mod/module/thermal_regulator/configure_edit(key, value)
	switch(key)
		if("temperature_setting")
			temperature_setting = clamp(text2num(value) + T0C, min_temp, max_temp)

/obj/item/mod/module/thermal_regulator/on_active_process()
	if(mod.wearer.bodytemperature > temperature_setting)
		mod.wearer.bodytemperature = max(temperature_setting, mod.wearer.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(mod.wearer.bodytemperature < temperature_setting)
		mod.wearer.bodytemperature = min(temperature_setting, mod.wearer.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))

/obj/item/mod/module/dna_lock
	name = "MOD DNA lock module"
	desc = "A module which engages with the various locks and seals tied to the suit's systems, \
		enabling it to only be worn by someone corresponding with the user's exact DNA profile; \
		however, this incredibly sensitive module is shorted out by EMPs. Luckily, stable mutagen has been outlawed."
	icon_state = "dnalock"
	origin_tech = "materials=6;bluespace=5;syndicate=1"
	module_type = MODULE_USABLE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/dna_lock, /obj/item/mod/module/emp_shield)
	cooldown_time = 0.5 SECONDS
	/// The DNA we lock with.
	var/dna = null

/obj/item/mod/module/dna_lock/on_install()
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(on_mod_activation))
	RegisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL, PROC_REF(on_mod_removal))
	RegisterSignal(mod, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))
	RegisterSignal(mod, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag))

/obj/item/mod/module/dna_lock/on_uninstall(deleting = FALSE)
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	UnregisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL)
	UnregisterSignal(mod, COMSIG_ATOM_EMP_ACT)
	UnregisterSignal(mod, COMSIG_ATOM_EMAG_ACT)

/obj/item/mod/module/dna_lock/on_use()
	. = ..()
	if(!.)
		return
	dna = mod.wearer.dna.unique_enzymes
	drain_power(use_power_cost)

/obj/item/mod/module/dna_lock/emp_act(severity)
	. = ..()
	if(mod.emp_proof)
		return
	on_emp(src, severity)

/obj/item/mod/module/dna_lock/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	on_emag(src, user, emag_card)

/obj/item/mod/module/dna_lock/proc/dna_check(mob/user)
	if(!iscarbon(user))
		return FALSE
	if(!dna)
		return TRUE
	if(dna == mod.wearer.dna.unique_enzymes)
		return TRUE
	return FALSE

/obj/item/mod/module/dna_lock/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER

	dna = null

/obj/item/mod/module/dna_lock/proc/on_emag(datum/source, mob/user, obj/item/card/emag/emag_card)
	SIGNAL_HANDLER

	dna = null

/obj/item/mod/module/dna_lock/proc/on_mod_activation(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!dna_check(user))
		atom_say("ERROR: User does not match owner DNA")
		return MOD_CANCEL_ACTIVATE

/obj/item/mod/module/dna_lock/proc/on_mod_removal(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!dna_check(user))
		atom_say("ERROR: User does not match owner DNA")
		return MOD_CANCEL_REMOVAL

/obj/item/mod/module/dna_lock/emp_shield
	name = "MOD DN-MP shield lock"
	desc = "This syndicate module is a combination EMP shield and DNA lock. Provides the best of both worlds, with the weakness of niether."
	icon_state = "dnalock"
	origin_tech = "materials=6;bluespace=5;syndicate=3"
	complexity = 3
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5

/obj/item/mod/module/dna_lock/emp_shield/on_install()
	. = ..()
	mod.emp_proof = TRUE

/obj/item/mod/module/dna_lock/emp_shield/on_uninstall(deleting = FALSE)
	. = ..()
	mod.emp_proof = FALSE

///Plasma Stabilizer - Prevents plasmamen from igniting in the suit
/obj/item/mod/module/plasma_stabilizer
	name = "MOD plasma stabilizer module"
	desc = "This system essentially forms an atmosphere of its own, within the suit, \
		efficiently and quickly preventing oxygen from causing the user's head to burst into flame. \
		This allows plasmamen to safely remove their helmet, allowing for easier \
		equipping of any MODsuit-related equipment, or otherwise. \
		The purple glass of the visor seems to be constructed for nostalgic purposes."
	icon_state = "plasma_stabilizer"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/plasma_stabilizer)
	overlay_state_inactive = "module_plasma"

/obj/item/mod/module/plasma_stabilizer/on_equip()
	ADD_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION_HEAD_ONLY, MODSUIT_TRAIT)

/obj/item/mod/module/plasma_stabilizer/on_unequip()
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION_HEAD_ONLY, MODSUIT_TRAIT)
