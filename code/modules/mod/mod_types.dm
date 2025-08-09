/obj/item/mod/control/pre_equipped
	/// The skin we apply to the suit, defaults to the default_skin of the theme.
	var/applied_skin
	/// The MOD core we apply to the suit.
	var/applied_core = /obj/item/mod/core/standard
	/// The cell we apply to the core. Only applies to standard core suits.
	var/applied_cell = /obj/item/stock_parts/cell/high
	/// List of modules we spawn with.
	var/list/applied_modules = list()
	/// Modules that we pin when the suit is installed for the first time, for convenience, can be applied or theme inbuilt modules.
	var/list/default_pins = list()

/obj/item/mod/control/pre_equipped/Initialize(mapload, new_theme, new_skin, new_core, new_access)
	for(var/module_to_pin in default_pins)
		default_pins[module_to_pin] = list()
	new_skin = applied_skin
	new_core = new applied_core(src)
	if(istype(new_core, /obj/item/mod/core/standard))
		var/obj/item/mod/core/standard/cell_core = new_core
		cell_core.cell = new applied_cell()
	. = ..()
	for(var/obj/item/mod/module/module as anything in applied_modules)
		module = new module(src)
		install(module)

/obj/item/mod/control/pre_equipped/set_wearer(mob/living/carbon/human/user)
	. = ..()
	for(var/obj/item/mod/module/module as anything in modules)
		if(!default_pins[module.type]) //this module isnt meant to be pinned by default
			continue
		if(wearer.UID() in default_pins[module.type]) //if we already had pinned once to this user, don care anymore
			continue
		default_pins[module.type] += wearer.UID()
		module.pin(wearer)

/obj/item/mod/control/pre_equipped/uninstall(obj/item/mod/module/old_module, deleting)
	. = ..()
	if(default_pins[old_module.type])
		default_pins -= old_module

/obj/item/mod/control/pre_equipped/standard
	icon_state = "standard-control"
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
	)

/obj/item/mod/control/pre_equipped/standard/explorer
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/jetpack
	)
	default_pins = list(
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/engineering
	icon_state = "engineering-control"
	theme = /datum/mod_theme/engineering
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/magboot,
		/obj/item/mod/module/tether,
	)
	default_pins = list(
		/obj/item/mod/module/magboot,
		/obj/item/mod/module/tether,
	)

/obj/item/mod/control/pre_equipped/atmospheric
	icon_state = "atmospheric-control"
	theme = /datum/mod_theme/atmospheric
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/t_ray,
		/obj/item/mod/module/magboot,
		/obj/item/mod/module/firefighting_tank,
	)
	default_pins = list(
		/obj/item/mod/module/magboot,
		/obj/item/mod/module/firefighting_tank
	)


/obj/item/mod/control/pre_equipped/advanced
	icon_state = "advanced-control"
	theme = /datum/mod_theme/advanced
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/firefighting_tank,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/firefighting_tank
	)

/obj/item/mod/control/pre_equipped/loader
	icon_state = "loader-control"
	theme = /datum/mod_theme/loader
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/stamp,
	)
	default_pins = list(
		/obj/item/mod/module/clamp/loader,
		/obj/item/mod/module/magnet,
		/obj/item/mod/module/hydraulic,
	)

/obj/item/mod/control/pre_equipped/mining
	icon_state = "mining-control"
	theme = /datum/mod_theme/mining
	applied_core = /obj/item/mod/core/plasma
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/gps,
		/obj/item/mod/module/orebag,
		/obj/item/mod/module/clamp,
		/obj/item/mod/module/drill,
	)
	default_pins = list(
		/obj/item/mod/module/gps,
		/obj/item/mod/module/drill,
		/obj/item/mod/module/sphere_transform,
	)

/// visit robotics.
/obj/item/mod/control/pre_equipped/mining/vendor
	applied_modules = list(
		/obj/item/mod/module/storage,
	)
	default_pins = list(
		/obj/item/mod/module/sphere_transform,
	)


/// The asteroid skin, as that one looks more space worthy / older. Good for space ruins.
/obj/item/mod/control/pre_equipped/mining/asteroid
	icon_state = "asteroid-control"
	applied_skin = "asteroid"

/obj/item/mod/control/pre_equipped/medical
	icon_state = "medical-control"
	theme = /datum/mod_theme/medical
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/injector,
	)

/obj/item/mod/control/pre_equipped/rescue
	icon_state = "rescue-control"
	theme = /datum/mod_theme/rescue
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/injector,
		/obj/item/mod/module/defibrillator,
		/obj/item/mod/module/monitor,
	)
	default_pins = list(
		/obj/item/mod/module/defibrillator,
	)

/obj/item/mod/control/pre_equipped/research
	icon_state = "research-control"
	theme = /datum/mod_theme/research
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/t_ray,
	)

/obj/item/mod/control/pre_equipped/security
	icon_state = "security-control"
	theme = /datum/mod_theme/security
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dispenser/mirage,
		/obj/item/mod/module/jetpack,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/dispenser/mirage,
	)

/obj/item/mod/control/pre_equipped/safeguard
	icon_state = "safeguard-control"
	theme = /datum/mod_theme/safeguard
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dispenser/mirage,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/holster,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/dispenser/mirage,
	)

/obj/item/mod/control/pre_equipped/safeguard/gamma
	applied_cell = /obj/item/stock_parts/cell/hyper
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dispenser/mirage,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/holster,
		/obj/item/mod/module/energy_shield/gamma,
	)

/obj/item/mod/control/pre_equipped/praetorian
	icon_state = "praetorian-control"
	theme = /datum/mod_theme/praetorian
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/monitor,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/magnate
	icon_state = "magnate-control"
	theme = /datum/mod_theme/magnate
	applied_cell = /obj/item/stock_parts/cell/hyper
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/jetpack/advanced,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
	)

/obj/item/mod/control/pre_equipped/magnate/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/mod/control/pre_equipped/cosmohonk
	icon_state = "cosmohonk-control"
	theme = /datum/mod_theme/cosmohonk
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/waddle,
		/obj/item/mod/module/bikehorn,
	)
	default_pins = list(
		/obj/item/mod/module/bikehorn,
	)

/obj/item/mod/control/pre_equipped/traitor
	icon_state = "syndicate-control"
	starting_frequency = MODLINK_FREQ_SYNDICATE
	theme = /datum/mod_theme/syndicate
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/noslip,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster,
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/traitor/Initialize(mapload)
	. = ..()
	new /obj/item/storage/box/survival_syndie/traitor(bag)

/obj/item/mod/control/pre_equipped/traitor_elite
	icon_state = "elite-control"
	starting_frequency = MODLINK_FREQ_SYNDICATE
	theme = /datum/mod_theme/elite
	applied_cell = /obj/item/stock_parts/cell/bluespace
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/status_readout,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/noslip,
		/obj/item/mod/module/flashlight,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster,
		/obj/item/mod/module/jetpack/advanced,
	)

/obj/item/mod/control/pre_equipped/traitor_elite/Initialize(mapload)
	. = ..()
	new /obj/item/storage/box/survival_syndie/traitor(bag)

/obj/item/mod/control/pre_equipped/nuclear
	icon_state = "syndicate-control"
	starting_frequency = MODLINK_FREQ_SYNDICATE
	theme = /datum/mod_theme/syndicate
	applied_cell = /obj/item/stock_parts/cell/hyper
	req_access = list(ACCESS_SYNDICATE)
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/dna_lock/emp_shield,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/noslip,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster,
		/obj/item/mod/module/jetpack/advanced,
	)

/obj/item/mod/control/pre_equipped/nuclear/Initialize(mapload, new_theme, new_skin, new_core, new_access)
	. = ..()
	ADD_TRAIT(chestplate, TRAIT_HYPOSPRAY_IMMUNE, ROUNDSTART_TRAIT)

/obj/item/mod/control/pre_equipped/elite
	icon_state = "elite-control"
	starting_frequency = MODLINK_FREQ_SYNDICATE
	theme = /datum/mod_theme/elite
	applied_cell = /obj/item/stock_parts/cell/bluespace
	req_access = list(ACCESS_SYNDICATE)
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate,
		/obj/item/mod/module/dna_lock/emp_shield,
		/obj/item/mod/module/status_readout,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/noslip,
	)
	default_pins = list(
		/obj/item/mod/module/armor_booster,
		/obj/item/mod/module/jetpack/advanced,
	)

/obj/item/mod/control/pre_equipped/elite/Initialize(mapload, new_theme, new_skin, new_core, new_access)
	. = ..()
	ADD_TRAIT(chestplate, TRAIT_HYPOSPRAY_IMMUNE, ROUNDSTART_TRAIT)

/obj/item/mod/control/pre_equipped/prototype
	icon_state = "prototype-control"
	starting_frequency = MODLINK_FREQ_THETA
	theme = /datum/mod_theme/prototype
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/tether,
	)
	default_pins = list(
		/obj/item/mod/module/tether,
		/obj/item/mod/module/anomaly_locked/kinesis/prebuilt/prototype,
	)

/obj/item/mod/control/pre_equipped/responsory
	icon_state = "responsory-control"
	starting_frequency = MODLINK_FREQ_CENTCOM
	theme = /datum/mod_theme/responsory
	applied_cell = /obj/item/stock_parts/cell/bluespace
	req_access = list(ACCESS_CENT_GENERAL)
	applied_modules = list(
		/obj/item/mod/module/storage/syndicate, //Yes yes syndicate tech in ert but they need the storage
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/status_readout,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/ert_camera,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/magboot/advanced,
	)
	/// The insignia type, insignias show what sort of member of the ERT you're dealing with.
	var/insignia_type = /obj/item/mod/module/insignia
	/// Additional module we add, as a treat.
	var/additional_module
	/// Inquisitorial module, as we have reached that point.
	var/inquisitorial_module

/obj/item/mod/control/pre_equipped/responsory/Initialize(mapload, new_theme, new_skin, new_core)
	applied_modules.Insert(1, insignia_type)
	if(additional_module)
		applied_modules += additional_module
		default_pins += additional_module
	if(inquisitorial_module)
		applied_modules += inquisitorial_module

	return ..()

/obj/item/mod/control/pre_equipped/responsory/commander
	insignia_type = /obj/item/mod/module/insignia/commander
	additional_module = /obj/item/mod/module/power_kick

/obj/item/mod/control/pre_equipped/responsory/security
	insignia_type = /obj/item/mod/module/insignia/security
	additional_module = /obj/item/mod/module/anomaly_locked/firewall/prebuilt //Defence and flaming hot offence. Good for reflective blob, xenos, antagonists with guns

/obj/item/mod/control/pre_equipped/responsory/security/Initialize(mapload, new_theme, new_skin, new_core, new_access)
	. = ..()
	ADD_TRAIT(chestplate, TRAIT_RSG_IMMUNE, ROUNDSTART_TRAIT)

/obj/item/mod/control/pre_equipped/responsory/engineer
	insignia_type = /obj/item/mod/module/insignia/engineer
	additional_module = list(/obj/item/mod/module/anomaly_locked/kinesis/prebuilt, /obj/item/mod/module/firefighting_tank) //This can only end well.

/obj/item/mod/control/pre_equipped/responsory/medic
	insignia_type = /obj/item/mod/module/insignia/medic
	additional_module = /obj/item/mod/module/defibrillator

/obj/item/mod/control/pre_equipped/responsory/medic/Initialize(mapload, new_theme, new_skin, new_core, new_access)
	. = ..()
	ADD_TRAIT(chestplate, TRAIT_RSG_IMMUNE, ROUNDSTART_TRAIT)

/obj/item/mod/control/pre_equipped/responsory/janitor
	insignia_type = /obj/item/mod/module/insignia/janitor
	additional_module = list(/obj/item/mod/module/clamp, /obj/item/mod/module/boot_heating)

/obj/item/mod/control/pre_equipped/responsory/clown
	insignia_type = /obj/item/mod/module/insignia/clown
	additional_module = /obj/item/mod/module/bikehorn

/obj/item/mod/control/pre_equipped/responsory/chaplain
	insignia_type = /obj/item/mod/module/insignia/chaplain
	additional_module = /obj/item/mod/module/injector

/// Diffrent look, as well as magic proof. It's perfect for inqusitors. Or if you want to give your ERT a fancy look. At this time, the other ones are unused, and frankly I don't like the idea of antimagic gamma.
/obj/item/mod/control/pre_equipped/responsory/inquisitory
	applied_skin = "inquisitory"
	inquisitorial_module = /obj/item/mod/module/anti_magic

/obj/item/mod/control/pre_equipped/responsory/inquisitory/commander
	insignia_type = /obj/item/mod/module/insignia/commander
	additional_module = /obj/item/mod/module/power_kick

/obj/item/mod/control/pre_equipped/responsory/inquisitory/security
	insignia_type = /obj/item/mod/module/insignia/security
	additional_module = /obj/item/mod/module/dispenser/mirage

/obj/item/mod/control/pre_equipped/responsory/inquisitory/medic
	insignia_type = /obj/item/mod/module/insignia/medic
	additional_module = /obj/item/mod/module/defibrillator

/obj/item/mod/control/pre_equipped/responsory/inquisitory/chaplain
	insignia_type = /obj/item/mod/module/insignia/chaplain
	additional_module = /obj/item/mod/module/power_kick //JUDGEMENT

/obj/item/mod/control/pre_equipped/apocryphal
	icon_state = "apocryphal-control"
	starting_frequency = MODLINK_FREQ_CENTCOM
	theme = /datum/mod_theme/apocryphal
	applied_cell = /obj/item/stock_parts/cell/bluespace
	req_access = list(ACCESS_CENT_SPECOPS)
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/status_readout,
		/obj/item/mod/module/magboot/advanced,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/magboot/advanced,
	)

/obj/item/mod/control/pre_equipped/apocryphal/Initialize(mapload, new_theme, new_skin, new_core, new_access)
	. = ..()
	ADD_TRAIT(chestplate, TRAIT_RSG_IMMUNE, ROUNDSTART_TRAIT)

/obj/item/mod/control/pre_equipped/apocryphal/officer
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/status_readout,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/power_kick,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/power_kick, //If you are not drop kicking a xenomorph, what are you doing as an DS commander?
	)

/obj/item/mod/control/pre_equipped/corporate
	icon_state = "corporate-control"
	starting_frequency = MODLINK_FREQ_CENTCOM
	theme = /datum/mod_theme/corporate
	applied_core = /obj/item/mod/core/infinite
	req_access = list(ACCESS_CENT_SPECOPS)
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/dna_lock/emp_shield,
		/obj/item/mod/module/status_readout,
		/obj/item/mod/module/anomaly_locked/kinesis/plus,
		/obj/item/mod/module/magboot/advanced,
	)
	default_pins = list(
		/obj/item/mod/module/anomaly_locked/kinesis/plus,
		/obj/item/mod/module/magboot/advanced,
	)

/obj/item/mod/control/pre_equipped/debug
	icon_state = "debug-control"
	starting_frequency = null
	theme = /datum/mod_theme/debug
	applied_core = /obj/item/mod/core/infinite
	/// One of every type of module, for testing if they all work correctly // boy this isn't even 25% the modules
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/bikehorn,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/injector,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/stealth/ninja,
		/obj/item/mod/module/noslip
	)
	default_pins = list(
		/obj/item/mod/module/bikehorn,
		/obj/item/mod/module/jetpack/advanced,
	)
	activation_step_time = 0.1 SECONDS // coders are cooler than admins

/obj/item/mod/control/pre_equipped/administrative
	icon_state = "debug-control"
	starting_frequency = null
	theme = /datum/mod_theme/administrative
	applied_core = /obj/item/mod/core/infinite
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/emp_shield,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/stealth/ninja,
	)
	default_pins = list(
		/obj/item/mod/module/stealth/ninja,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/jetpack/advanced,
	)

//these exist for the prefs menu
/obj/item/mod/control/pre_equipped/empty
	starting_frequency = null

/obj/item/mod/control/pre_equipped/empty/syndicate
	theme = /datum/mod_theme/syndicate

/obj/item/mod/control/pre_equipped/empty/syndicate/honkerative
	applied_skin = "honkerative"

/obj/item/mod/control/pre_equipped/empty/elite
	theme = /datum/mod_theme/elite

INITIALIZE_IMMEDIATE(/obj/item/mod/control/pre_equipped/empty)
