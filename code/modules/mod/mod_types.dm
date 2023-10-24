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
		if(UID(wearer) in default_pins[module.type]) //if we already had pinned once to this user, don care anymore
			continue
		default_pins[module.type] += UID(wearer)
		module.pin(wearer)

/obj/item/mod/control/pre_equipped/uninstall(obj/item/mod/module/old_module, deleting)
	. = ..()
	if(default_pins[old_module.type])
		default_pins -= old_module

/obj/item/mod/control/pre_equipped/standard
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
	)

/obj/item/mod/control/pre_equipped/engineering
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
	theme = /datum/mod_theme/atmospheric
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/t_ray,
		/obj/item/mod/module/magboot,
	)
	default_pins = list(
		/obj/item/mod/module/magboot,
	)


/obj/item/mod/control/pre_equipped/advanced
	theme = /datum/mod_theme/advanced
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/jetpack/advanced,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/magboot/advanced,
	)

/obj/item/mod/control/pre_equipped/loader
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

/obj/item/mod/control/pre_equipped/mining/vendor //visit robotics.
	theme = /datum/mod_theme/mining
	applied_core = /obj/item/mod/core/plasma
	applied_modules = list(
		/obj/item/mod/module/storage,
	)
	default_pins = list(
		/obj/item/mod/module/sphere_transform,
	)


/obj/item/mod/control/pre_equipped/mining/asteroid //The asteroid skin, as that one looks more space worthy / older. Good for space ruins.
	applied_skin = "asteroid"

/obj/item/mod/control/pre_equipped/medical
	theme = /datum/mod_theme/medical
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/injector,
	)

/obj/item/mod/control/pre_equipped/rescue
	theme = /datum/mod_theme/rescue
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/injector,
		/obj/item/mod/module/defibrillator,
	)
	default_pins = list(
		/obj/item/mod/module/defibrillator,
	)

/obj/item/mod/control/pre_equipped/research
	theme = /datum/mod_theme/research
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/t_ray,
	)

/obj/item/mod/control/pre_equipped/security
	theme = /datum/mod_theme/security
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/dispenser/mirage,
		/obj/item/mod/module/jetpack,
	)

/obj/item/mod/control/pre_equipped/safeguard
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
	)

/obj/item/mod/control/pre_equipped/magnate
	theme = /datum/mod_theme/magnate
	applied_cell = /obj/item/stock_parts/cell/hyper
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/jetpack/advanced,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
	)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF // Theft targets should be hard to destroy

/obj/item/mod/control/pre_equipped/magnate/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(alert_admins_on_destroy))

/obj/item/mod/control/pre_equipped/cosmohonk
	theme = /datum/mod_theme/cosmohonk
	applied_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/waddle,
		/obj/item/mod/module/bikehorn,
	)

/obj/item/mod/control/pre_equipped/traitor
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

/obj/item/mod/control/pre_equipped/traitor_elite
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

/obj/item/mod/control/pre_equipped/nuclear
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

/obj/item/mod/control/pre_equipped/elite
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

/obj/item/mod/control/pre_equipped/prototype
	theme = /datum/mod_theme/prototype
	req_access = list()
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
	theme = /datum/mod_theme/responsory
	applied_cell = /obj/item/stock_parts/cell/hyper
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
	/// The insignia type, insignias show what sort of member of the ERT you're dealing with.
	var/insignia_type = /obj/item/mod/module/insignia
	/// Additional module we add, as a treat.
	var/additional_module

/obj/item/mod/control/pre_equipped/responsory/Initialize(mapload, new_theme, new_skin, new_core)
	applied_modules.Insert(1, insignia_type)
	if(additional_module)
		applied_modules += additional_module
		default_pins += additional_module
	return ..()

/obj/item/mod/control/pre_equipped/responsory/commander
	insignia_type = /obj/item/mod/module/insignia/commander
	additional_module = /obj/item/mod/module/power_kick

/obj/item/mod/control/pre_equipped/responsory/security
	insignia_type = /obj/item/mod/module/insignia/security
	additional_module = /obj/item/mod/module/dispenser/mirage

/obj/item/mod/control/pre_equipped/responsory/engineer
	insignia_type = /obj/item/mod/module/insignia/engineer
	additional_module = /obj/item/mod/module/anomaly_locked/kinesis/prebuilt //This can only end well.

/obj/item/mod/control/pre_equipped/responsory/medic
	insignia_type = /obj/item/mod/module/insignia/medic
	additional_module = /obj/item/mod/module/defibrillator

/obj/item/mod/control/pre_equipped/responsory/janitor
	insignia_type = /obj/item/mod/module/insignia/janitor
	additional_module = /obj/item/mod/module/clamp

/obj/item/mod/control/pre_equipped/responsory/clown
	insignia_type = /obj/item/mod/module/insignia/clown
	additional_module = /obj/item/mod/module/bikehorn

/obj/item/mod/control/pre_equipped/responsory/chaplain
	insignia_type = /obj/item/mod/module/insignia/chaplain
	additional_module = /obj/item/mod/module/injector

/obj/item/mod/control/pre_equipped/responsory/inquisitory //Diffrent look, as well as magic proof on TG. We don't have the magic proof stuff here, but it's perfect for inqusitors. Or if you want to give your ERT a fancy look.
	applied_skin = "inquisitory"

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
	theme = /datum/mod_theme/debug
	applied_core = /obj/item/mod/core/infinite
	applied_modules = list( //one of every type of module, for testing if they all work correctly // boy this isn't even 25% the modules
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
	)
	activation_step_time = 0.1 SECONDS // coders are cooler than admins

/obj/item/mod/control/pre_equipped/administrative
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

/obj/item/mod/control/pre_equipped/empty/syndicate
	theme = /datum/mod_theme/syndicate

/obj/item/mod/control/pre_equipped/empty/syndicate/honkerative
	applied_skin = "honkerative"

/obj/item/mod/control/pre_equipped/empty/elite
	theme = /datum/mod_theme/elite

INITIALIZE_IMMEDIATE(/obj/item/mod/control/pre_equipped/empty)
