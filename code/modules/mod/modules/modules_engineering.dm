//Engineering modules for MODsuits

///Welding Protection - Makes the helmet protect from flashes and welding.
/obj/item/mod/module/welding
	name = "MOD welding protection module"
	desc = "A module installed into the visor of the suit, this projects a \
		polarized, holographic overlay in front of the user's eyes. It's rated high enough for \
		immunity against extremities such as spot and arc welding, solar eclipses, and handheld flashlights."
	icon_state = "welding"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/welding, /obj/item/mod/module/armor_booster)
	overlay_state_inactive = "module_welding"

/obj/item/mod/module/welding/on_suit_activation()
	mod.helmet.flash_protect = FLASH_PROTECTION_WELDER

/obj/item/mod/module/welding/on_suit_deactivation(deleting = FALSE)
	if(deleting)
		return
	mod.helmet.flash_protect = initial(mod.helmet.flash_protect)

///T-Ray Scan - Scans the terrain for undertile objects.
/obj/item/mod/module/t_ray
	name = "MOD t-ray scan module"
	desc = "A module installed into the visor of the suit, allowing the user to use a pulse of terahertz radiation \
		to essentially echolocate things beneath the floor, mostly cables and pipes. \
		A staple of atmospherics work, and counter-smuggling work."
	icon_state = "tray"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/t_ray)
	cooldown_time = 0.5 SECONDS
	/// T-ray scan range.
	var/range = 4

/obj/item/mod/module/t_ray/on_active_process()
	t_ray_scan(mod.wearer, 0.8 SECONDS, range)

///Magnetic Stability - Gives the user a slowdown but makes them negate gravity and be immune to slips.
/obj/item/mod/module/magboot
	name = "MOD magnetic stability module"
	desc = "These are powerful electromagnets fitted into the suit's boots, allowing users both \
		excellent traction no matter the condition indoors, and to essentially hitch a ride on the exterior of a hull. \
		However, these basic models do not feature computerized systems to automatically toggle them on and off, \
		so numerous users report a certain stickiness to their steps."
	icon_state = "magnet"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/magboot)
	cooldown_time = 0.5 SECONDS
	/// Slowdown added onto the suit.
	var/slowdown_active = 0.5

/obj/item/mod/module/magboot/on_activation()
	. = ..()
	if(!.)
		return
	mod.boots.flags |= NOSLIP
	mod.slowdown += slowdown_active
	mod.boots.magbooted = TRUE

/obj/item/mod/module/magboot/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	mod.boots.flags ^= NOSLIP
	mod.slowdown -= slowdown_active
	mod.boots.magbooted = FALSE

/obj/item/mod/module/magboot/advanced
	name = "MOD advanced magnetic stability module"
	removable = FALSE
	complexity = 0
	slowdown_active = 0

///Radiation Protection - Gives the user rad info in the ui, currently
/obj/item/mod/module/rad_protection
	name = "MOD radiation detector module"
	desc = "A protoype module that improves the sensors on the modsuit to detect radiation on the user. \
	Currently due to time restraints and a lack of lead on lavaland, it does not have a built in geiger counter or radiation protection."
	icon_state = "radshield"
	complexity = 0 //I'm setting this to zero for now due to it not currently increasing radiaiton armor. If we add giger counter / additional rad protecion to this, it should be 2. We denied radiation potions before, so this should NOT give full rad immunity on a engi modsuit
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.1 //Lowered from 0.3 due to no protection.
	incompatible_modules = list(/obj/item/mod/module/rad_protection)
	tgui_id = "rad_counter"

/obj/item/mod/module/rad_protection/add_ui_data()
	. = ..()
	.["userradiated"] = mod.wearer?.radiation || 0
	.["usertoxins"] = mod.wearer?.getToxLoss() || 0
	.["usermaxtoxins"] = mod.wearer?.getMaxHealth() || 0

///Mister - Sprays water over an area.
/obj/item/mod/module/mister
	name = "MOD water mister module"
	desc = "A module containing a mister, able to spray it over areas."
	icon_state = "mister"
	module_type = MODULE_ACTIVE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/reagent_containers/spray/mister
	incompatible_modules = list(/obj/item/mod/module/mister)
	cooldown_time = 0.5 SECONDS
	/// Volume of our reagent holder.
	var/volume = 500

/obj/item/mod/module/mister/Initialize(mapload)
	create_reagents(volume, OPENCONTAINER)
	return ..()

///Resin Mister - Sprays resin over an area.
/obj/item/mod/module/mister/atmos
	name = "MOD resin mister module"
	desc = "An atmospheric resin mister, able to fix up areas quickly."
	device = /obj/item/extinguisher/mini/nozzle/mod
	volume = 250

/obj/item/mod/module/mister/atmos/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/water, volume)

/obj/item/extinguisher/mini/nozzle/mod
	name = "MOD atmospheric mister"
	desc = "An atmospheric resin mister with three modes, mounted as a module."
