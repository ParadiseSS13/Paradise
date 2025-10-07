//Security modules for MODsuits

///Holster - Instantly holsters any not huge gun.
/obj/item/mod/module/holster
	name = "MOD holster module"
	desc = "Based off typical storage compartments, this system allows the suit to holster a \
		standard firearm across its surface and allow for extremely quick retrieval. \
		While some users prefer the chest, others the forearm for quick deployment, \
		some law enforcement prefer the holster to extend from the thigh."
	icon_state = "holster"
	module_type = MODULE_USABLE
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/holster)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	/// Gun we have holstered.
	var/obj/item/gun/holstered

/obj/item/mod/module/holster/on_use()
	. = ..()
	if(!.)
		return
	var/msg = "[holstered]"
	if(!holstered)
		var/obj/item/gun/holding = mod.wearer.get_active_hand()
		if(!holding)
			to_chat(mod.wearer, "<span class='warning'>Nothing to holster!</span>")
			return
		if(!istype(holding) || holding.w_class > WEIGHT_CLASS_NORMAL) //god no holstering a BSG / combat shotgun
			to_chat(mod.wearer, "<span class='warning'>It's too big to fit!</span>")
			return
		holstered = holding
		mod.wearer.visible_message("<span class='notice'>[mod.wearer] holsters [holstered].</span>", "<span class='notice'>You holster [holstered].</span>")
		mod.wearer.unequip(mod.wearer.get_active_hand())
		holstered.forceMove(src)
	else if(mod.wearer.put_in_active_hand(holstered))
		mod.wearer.visible_message("<span class='warning'>[mod.wearer] draws [msg], ready to shoot!</span>", \
			"<span class='warning'>You draw [msg], ready to shoot!</span>")
	else
		to_chat(mod.wearer, "<span class='warning'>You need an empty hand to draw [holstered]!</span>")

/obj/item/mod/module/holster/on_uninstall(deleting = FALSE)
	if(holstered)
		holstered.forceMove(drop_location())

/obj/item/mod/module/holster/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == holstered)
		holstered = null

/obj/item/mod/module/holster/Destroy()
	QDEL_NULL(holstered)
	return ..()

///Mirage grenade dispenser - Dispenses grenades that copy the user's appearance.
/obj/item/mod/module/dispenser/mirage
	name = "MOD mirage grenade dispenser module"
	desc = "This module can create mirage grenades at the user's liking. These grenades create holographic copies of the user."
	icon_state = "mirage_grenade"
	cooldown_time = 20 SECONDS
	overlay_state_inactive = "module_mirage_grenade"
	dispense_type = /obj/item/grenade/mirage

/obj/item/mod/module/dispenser/mirage/on_use()
	. = ..()
	if(!.)
		return
	var/obj/item/grenade/mirage/grenade = .
	grenade.attack_self__legacy__attackchain(mod.wearer)

/obj/item/grenade/mirage
	name = "mirage grenade"
	desc = "A special device that, when activated, produces a holographic copy of the user."
	icon_state = "mirage"
	det_time = 3 SECONDS
	/// Mob that threw the grenade.
	var/mob/living/thrower


/obj/item/grenade/mirage/Destroy()
	thrower = null
	return ..()

/obj/item/grenade/mirage/attack_self__legacy__attackchain(mob/user)
	. = ..()
	thrower = user

/obj/item/grenade/mirage/prime()
	do_sparks(rand(3, 6), FALSE, src)
	if(thrower)
		var/mob/living/simple_animal/hostile/illusion/mirage/M = new(get_turf(src))
		M.Copy_Parent(thrower, 15 SECONDS)
	qdel(src)

/// It's just standing there, menacingly
/mob/living/simple_animal/hostile/illusion/mirage
	AIStatus = AI_OFF
	density = FALSE

/mob/living/simple_animal/hostile/illusion/mirage/death(gibbed)
	do_sparks(rand(3, 6), FALSE, src)
	return ..()


///Active Sonar - Displays a hud circle on the turf of any living creatures in the given radius
/obj/item/mod/module/active_sonar
	name = "MOD active sonar"
	desc = "Ancient tech from the 20th century, this module uses sonic waves to detect living creatures within the user's radius. \
		Its loud ping is much harder to hide in an indoor station than in the outdoor operations it was designed for."
	icon_state = "active_sonar"
	module_type = MODULE_USABLE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 4
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/active_sonar)
	cooldown_time = 7.5 SECONDS //come on man this is discount thermals, it doesnt need a 15 second cooldown

/obj/item/mod/module/active_sonar/on_use()
	. = ..()
	if(!.)
		return
	playsound(mod.wearer, 'sound/mecha/skyfall_power_up.ogg', vol = 20, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	if(!do_after(mod.wearer, 1.1 SECONDS, target = mod.wearer))
		return
	var/creatures_detected = 0
	for(var/mob/living/creature in range(9, mod.wearer))
		if(creature == mod.wearer || creature.stat == DEAD)
			continue
		new /obj/effect/temp_visual/sonar_ping(mod.wearer.loc, mod.wearer, creature)
		creatures_detected++
	playsound(mod.wearer, 'sound/effects/ping_hit.ogg', vol = 75, vary = TRUE, extrarange = 9) // Should be audible for the radius of the sonar
	to_chat(mod.wearer, ("<span class='notice'>You slam your fist into the ground, sending out a sonic wave that detects [creatures_detected] living beings nearby!</span>"))

/obj/effect/temp_visual/sonar_ping
	duration = 3 SECONDS
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	randomdir = FALSE
	/// The image shown to modsuit users
	var/image/modsuit_image
	/// The person in the modsuit at the moment, really just used to remove this from their screen
	var/source_UID
	/// The icon state applied to the image created for this ping.
	var/real_icon_state = "sonar_ping"

/obj/effect/temp_visual/sonar_ping/Initialize(mapload, mob/living/looker, mob/living/creature)
	. = ..()
	if(!looker || !creature)
		return INITIALIZE_HINT_QDEL
	modsuit_image = image(icon = icon, loc = src, icon_state = real_icon_state, layer = ABOVE_ALL_MOB_LAYER, pixel_x = ((creature.x - looker.x) * 32), pixel_y = ((creature.y - looker.y) * 32))
	modsuit_image.plane = ABOVE_LIGHTING_PLANE
	modsuit_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	source_UID = looker.UID()
	add_mind(looker)

/obj/effect/temp_visual/sonar_ping/Destroy()
	var/mob/living/previous_user = locateUID(source_UID)
	if(previous_user)
		remove_mind(previous_user)
	// Null so we don't shit the bed when we delete
	modsuit_image = null
	return ..()

/// Add the image to the modsuit wearer's screen
/obj/effect/temp_visual/sonar_ping/proc/add_mind(mob/living/looker)
	looker?.client?.images |= modsuit_image

/// Remove the image from the modsuit wearer's screen
/obj/effect/temp_visual/sonar_ping/proc/remove_mind(mob/living/looker)
	looker?.client?.images -= modsuit_image

///Firewall. Deployable dropwall that lights projectiles on fire.
/obj/item/mod/module/anomaly_locked/firewall
	name = "MOD firewall module"
	desc = "A module that uses a pyroclastic core to make immolating dropwalls."
	icon_state = "firewall"
	overlay_state_inactive = "module_mirage_grenade"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	cooldown_time = 20 SECONDS
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/pyro)
	/// Path we dispense.
	var/dispense_type = /obj/item/grenade/barrier/dropwall/firewall

/obj/item/mod/module/anomaly_locked/firewall/on_use()
	. = ..()
	if(!.)
		return
	var/obj/item/dispensed = new dispense_type(mod.wearer.loc)
	mod.wearer.put_in_hands(dispensed)
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)
	drain_power(use_power_cost)
	var/obj/item/grenade/grenade = dispensed
	grenade.attack_self__legacy__attackchain(mod.wearer)
	return grenade

/obj/item/mod/module/anomaly_locked/firewall/prebuilt
	prebuilt = TRUE
	removable = FALSE // No switching it into another suit / no free anomaly core

/// Vortex arm mounted shotgun. Fucks up reality in front of it, very power draining. Compeating with the vortex arm and stealth armor after all
/obj/item/mod/module/anomaly_locked/vortex_shotgun
	name = "MOD vortex shotgun module"
	desc = "A module that uses a vortex core to rend the fabric of space time in front of it."
	icon_state = "vortex"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CHARGE_DRAIN * 750
	device = /obj/item/gun/energy/vortex_shotgun
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/vortex)

/obj/item/mod/module/anomaly_locked/vortex_shotgun/Initialize(mapload)
	. = ..()
	RegisterSignal(device, COMSIG_GUN_FIRED, PROC_REF(on_gun_fire))

/obj/item/mod/module/anomaly_locked/vortex_shotgun/proc/on_gun_fire()
	SIGNAL_HANDLER
	if(!drain_power(use_power_cost)) //Drain the rest dry
		drain_power(mod.core.check_charge())

/obj/item/mod/module/anomaly_locked/vortex_shotgun/prebuilt
	prebuilt = TRUE
	removable = FALSE // No switching it into another suit / no free anomaly core

///Cryogrenade. Freezes foes in place, cools them
/obj/item/mod/module/anomaly_locked/cryogrenade
	name = "MOD Cryogrenade module"
	desc = "A module that uses a cryogenic core to make freezing grenades."
	icon_state = "cryogrenade"
	overlay_state_inactive = "module_mirage_grenade"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	cooldown_time = 20 SECONDS
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/cryo)
	/// Path we dispense.
	var/dispense_type = /obj/item/grenade/cryogrenade_mod

/obj/item/mod/module/anomaly_locked/cryogrenade/on_use()
	. = ..()
	if(!.)
		return
	var/obj/item/dispensed = new dispense_type(mod.wearer.loc)
	mod.wearer.put_in_hands(dispensed)
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)
	drain_power(use_power_cost)
	var/obj/item/grenade/grenade = dispensed
	grenade.attack_self__legacy__attackchain(mod.wearer)
	return grenade

/obj/item/mod/module/anomaly_locked/cryogrenade/prebuilt
	prebuilt = TRUE
	removable = FALSE // No switching it into another suit / no free anomaly core

/obj/item/grenade/cryogrenade_mod
	name = "cryogenic grenade"
	desc = "A very cold grenade."
	icon_state = "gluon"
	var/freeze_range = 4
	var/stamina_damage = 60
	var/body_adjustment = -230
	var/reagent_volume = 15
	/// Mob that threw the grenade.
	var/mob/living/thrower

/obj/item/grenade/cryogrenade_mod/Destroy()
	thrower = null
	return ..()

/obj/item/grenade/cryogrenade_mod/attack_self__legacy__attackchain(mob/user)
	. = ..()
	thrower = user

/obj/item/grenade/cryogrenade_mod/prime()
	update_mob()
	playsound(loc, 'sound/effects/empulse.ogg', 50, TRUE)
	for(var/turf/simulated/floor/T in view(freeze_range, loc))
		T.MakeSlippery(TURF_WET_ICE)
		for(var/mob/living/carbon/C in T)
			if(C == thrower)
				continue
			C.adjustStaminaLoss(stamina_damage)
			C.adjust_bodytemperature(body_adjustment)
			C.apply_status_effect(/datum/status_effect/freon)
			if(C.reagents)
				C.reagents.add_reagent("frostoil", reagent_volume)
				C.reagents.add_reagent("ice", reagent_volume)
	qdel(src)

/// Smoke Grenade Module, its tacticool.
/obj/item/mod/module/dispenser/smoke
	name = "MOD smoke grenade dispenser module"
	desc = "A module that dispenses primed smoke grenades to disperse crowds."
	icon_state = "smoke_grenade"
	cooldown_time = 10 SECONDS
	complexity = 1
	overlay_state_inactive = "module_smoke_grenade"
	dispense_type = /obj/item/grenade/smokebomb

/obj/item/mod/module/dispenser/smoke/on_use()
	var/obj/item/grenade/smokebomb/grenade = ..()
	if(!grenade)
		return
	grenade.attack_self__legacy__attackchain(mod.wearer)
