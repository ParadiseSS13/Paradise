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
	. = ..()
	if(!.)
		return
	var/obj/item/projectile/tether = new /obj/item/projectile/tether(get_turf(mod.wearer))
	tether.original = target
	tether.firer = mod.wearer
	tether.preparePixelProjectile(target, get_turf(target), mod.wearer)
	tether.fire()
	playsound(src, 'sound/weapons/batonextend.ogg', 25, TRUE)
	INVOKE_ASYNC(tether, TYPE_PROC_REF(/obj/item/projectile/tether, make_chain))
	drain_power(use_power_cost)

/obj/item/projectile/tether
	name = "tether"
	icon_state = "tether_projectile"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	speed = 2
	damage = 5
	range = 15
	hitsound = 'sound/weapons/batonextend.ogg'
	hitsound_wall = 'sound/weapons/batonextend.ogg'

/obj/item/projectile/tether/proc/make_chain()
	if(firer)
		chain = Beam(firer, icon_state = "line", icon = 'icons/obj/clothing/modsuit/mod_modules.dmi', time = 10 SECONDS, maxdistance = 15)

/obj/item/projectile/tether/on_hit(atom/target)
	. = ..()
	if(firer && isliving(firer))
		var/mob/living/L = firer
		L.apply_status_effect(STATUS_EFFECT_IMPACT_IMMUNE)
		L.throw_at(target, 15, 1, L, FALSE, FALSE, callback = CALLBACK(L, TYPE_PROC_REF(/mob/living, remove_status_effect), STATUS_EFFECT_IMPACT_IMMUNE))

/obj/item/projectile/tether/Destroy()
	QDEL_NULL(chain)
	return ..()

///Atmos water tank module

/obj/item/mod/module/firefighting_tank
	name = "MOD firefighting tank"
	desc = "A refridgerated and pressurized module tank with an extinguisher nozzle, intended to fight fires. Swaps between extinguisher, nanofrost launcher, and metal foam dispenser for breaches. Nanofrost converts plasma in the air to nitrogen, but only if it is combusting at the time."
	icon_state = "firefighting_tank"
	module_type = MODULE_ACTIVE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 3
	device = /obj/item/extinguisher/mini/mod

#define EXTINGUISHER 0
#define NANOFROST 1
#define METAL_FOAM 2

/obj/item/extinguisher/mini/mod
	name = "modsuit extinguisher nozzle"
	desc = "A heavy duty nozzle attached to a modsuit's internal tank."
	icon = 'icons/obj/watertank.dmi'
	icon_state = "atmos_nozzle"
	item_state = "nozzleatmos"
	safety = 0
	max_water = 500
	power = 8
	precision = 1
	cooling_power = 5
	w_class = WEIGHT_CLASS_HUGE
	flags = NODROP //Necessary to ensure that the nozzle and tank never seperate
	var/nozzle_mode = 0
	var/metal_synthesis_cooldown = 0
	var/nanofrost_cooldown = 0

/obj/item/extinguisher/mini/mod/attack_self(mob/user as mob)
	switch(nozzle_mode)
		if(EXTINGUISHER)
			nozzle_mode = NANOFROST
			icon_state = "atmos_nozzle_2"
			to_chat(user, "Swapped to nanofrost launcher")
			return
		if(NANOFROST)
			nozzle_mode = METAL_FOAM
			icon_state = "atmos_nozzle_3"
			to_chat(user, "Swapped to metal foam synthesizer")
			return
		if(METAL_FOAM)
			nozzle_mode = EXTINGUISHER
			icon_state = "atmos_nozzle_1"
			to_chat(user, "Swapped to water extinguisher")
			return
	return

/obj/item/extinguisher/mini/mod/afterattack(atom/target, mob/user)
	if(nozzle_mode == EXTINGUISHER)
		..()
		return
	var/Adj = user.Adjacent(target)
	if(Adj)
		AttemptRefill(target, user)
	if(nozzle_mode == NANOFROST)
		if(Adj)
			return //Safety check so you don't blast yourself trying to refill your tank
		var/datum/reagents/R = reagents
		if(R.total_volume < 100)
			to_chat(user, "You need at least 100 units of water to use the nanofrost launcher!")
			return
		if(nanofrost_cooldown)
			to_chat(user, "Nanofrost launcher is still recharging")
			return
		nanofrost_cooldown = 1
		R.remove_any(100)
		var/obj/effect/nanofrost_container/A = new /obj/effect/nanofrost_container(get_turf(src))
		log_game("[key_name(user)] used Nanofrost at [get_area(user)] ([user.x], [user.y], [user.z]).")
		playsound(src,'sound/items/syringeproj.ogg',40,1)
		for(var/a=0, a<5, a++)
			step_towards(A, target)
			sleep(2)
		A.Smoke()
		spawn(100)
			if(src)
				nanofrost_cooldown = 0
		return
	if(nozzle_mode == METAL_FOAM)
		if(!Adj|| !isturf(target))
			return
		if(metal_synthesis_cooldown < 5)
			var/obj/effect/particle_effect/foam/F = new /obj/effect/particle_effect/foam(get_turf(target), 1)
			F.amount = 0
			metal_synthesis_cooldown++
			spawn(50)
				if(src)
					metal_synthesis_cooldown--
		else
			to_chat(user, "Metal foam mix is still being synthesized.")
			return

#undef EXTINGUISHER
#undef NANOFROST
#undef METAL_FOAM
