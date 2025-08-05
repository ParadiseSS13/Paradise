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
	ADD_TRAIT(mod.wearer, TRAIT_NOSLIP, UID())
	mod.slowdown += slowdown_active
	ADD_TRAIT(mod.wearer, TRAIT_MAGPULSE, "magbooted")

/obj/item/mod/module/magboot/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	if(!.)
		return
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSLIP, UID())
	mod.slowdown -= slowdown_active
	REMOVE_TRAIT(mod.wearer, TRAIT_MAGPULSE, "magbooted")

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
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.1 //Lowered from 0.3 due to no protection.
	incompatible_modules = list(/obj/item/mod/module/rad_protection)
	tgui_id = "rad_counter"

/obj/item/mod/module/rad_protection/add_ui_data()
	. = ..()
	.["userradiated"] = mod.wearer?.radiation || 0
	.["usertoxins"] = mod.wearer?.getToxLoss() || 0
	.["usermaxtoxins"] = mod.wearer?.getMaxHealth() || 0


///Emergency Tether - Shoots a grappling hook projectile in 0g that throws the user towards it.
/obj/item/mod/module/tether
	name = "MOD emergency tether module"
	desc = "A custom-built grappling-hook powered by a winch capable of hauling the user. \
		While some older models of cargo-oriented grapples have capacities of a few tons, \
		these are only capable of working in zero-gravity environments, a blessing to some Engineers."
	icon_state = "tether"
	module_type = MODULE_ACTIVE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/tether)
	cooldown_time = 4 SECONDS

/obj/item/mod/module/tether/on_use()
	if(has_gravity(get_turf(src)))
		to_chat(mod.wearer, "<span class='warning'>Too much gravity to use the tether!</span>")
		playsound(src, 'sound/weapons/gun_interactions/dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mod/module/tether/on_select_use(atom/target)
	if(get_turf(target) == get_turf(src)) // Put this check before the parent call so the cooldown won't start if it fails
		return FALSE

	. = ..()
	if(!.)
		return
	var/obj/item/projectile/tether = new /obj/item/projectile/tether(get_turf(mod.wearer))
	tether.original = target
	tether.firer = mod.wearer
	tether.preparePixelProjectile(target, mod.wearer)
	tether.fire()
	playsound(src, 'sound/weapons/batonextend.ogg', 25, TRUE)
	INVOKE_ASYNC(tether, TYPE_PROC_REF(/obj/item/projectile/tether, make_chain))
	drain_power(use_power_cost)

/obj/item/projectile/tether
	name = "tether"
	icon_state = "tether_projectile"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	var/chain_icon_state = "line"
	speed = 2
	damage = 5
	range = 15
	hitsound = 'sound/weapons/batonextend.ogg'
	hitsound_wall = 'sound/weapons/batonextend.ogg'
	///How fast the tether will throw the user at the target
	var/yank_speed = 1

/obj/item/projectile/tether/proc/make_chain()
	if(firer)
		chain = Beam(firer, chain_icon_state, icon, time = 10 SECONDS, maxdistance = range)

/obj/item/projectile/tether/on_hit(atom/target)
	. = ..()
	if(firer && isliving(firer))
		var/mob/living/L = firer
		L.apply_status_effect(STATUS_EFFECT_IMPACT_IMMUNE)
		L.throw_at(target, 15, yank_speed, L, FALSE, FALSE, callback = CALLBACK(L, TYPE_PROC_REF(/mob/living, remove_status_effect), STATUS_EFFECT_IMPACT_IMMUNE), block_movement = FALSE)

/obj/item/projectile/tether/Destroy()
	QDEL_NULL(chain)
	return ..()

/// Atmos water tank module

#define EXTINGUISHER 0
#define NANOFROST 1
#define METAL_FOAM 2

/obj/item/mod/module/firefighting_tank
	name = "MOD firefighting tank"
	desc = "A refrigerated and pressurized module tank with an extinguisher nozzle, intended to fight fires. \
	Swaps between extinguisher, nanofrost launcher, and metal foam dispenser for breaches. Nanofrost converts plasma in the air to nitrogen, but only if it is combusting at the time.\
	The smaller volume compared to a dedicated firefighting backpack means that non-water modes suffer from longer cooldowns."
	icon_state = "firefighting_tank"
	module_type = MODULE_ACTIVE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/firefighting_tank)
	device = /obj/item/extinguisher/mini/nozzle/mod
	// Used by nozzle code.
	var/volume = 500

/obj/item/extinguisher/mini/nozzle/mod
	name = "modsuit extinguisher nozzle"
	desc = "A heavy duty nozzle attached to a modsuit's internal tank."
	metal_regen_time = 5 SECONDS
	nanofrost_cooldown_time = 10 SECONDS

/obj/item/extinguisher/mini/nozzle/mod/update_icon_state()
	switch(nozzle_mode)
		if(EXTINGUISHER)
			icon_state = "atmos_nozzle_1"
		if(NANOFROST)
			icon_state = "atmos_nozzle_2"
		if(METAL_FOAM)
			icon_state = "atmos_nozzle_3"

#undef EXTINGUISHER
#undef NANOFROST
#undef METAL_FOAM
