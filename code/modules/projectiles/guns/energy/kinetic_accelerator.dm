/obj/item/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "A self-recharging, ranged mining tool that does increased damage in low pressure environments. It can be upgraded using specialised mod kits."
	icon_state = "kineticgun"
	inhand_icon_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	cell_type = /obj/item/stock_parts/cell/emproof
	needs_permit = FALSE
	origin_tech = "combat=3;powerstorage=3;engineering=3"
	can_flashlight = TRUE
	can_be_lensed = FALSE
	flight_x_offset = 15
	flight_y_offset = 9
	var/overheat_time = 16
	var/holds_charge = FALSE
	var/unique_frequency = FALSE // modified by KA modkits
	var/overheat = FALSE
	can_bayonet = TRUE
	knife_x_offset = 20
	knife_y_offset = 12

	var/max_mod_capacity = 100
	var/list/modkits = list()

	var/recharge_timerid

	var/empty_state = "kineticgun_empty"

/obj/item/gun/energy/kinetic_accelerator/update_icon_state()
	icon_state = current_skin || initial(icon_state)

/obj/item/gun/energy/kinetic_accelerator/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(max_mod_capacity)
			. += "<b>[get_remaining_mod_capacity()]%</b> mod capacity remaining."
			for(var/A in get_modkits())
				var/obj/item/borg/upgrade/modkit/M = A
				. |= "<span class='notice'>You can use a crowbar on it to remove it's installed mod kits.</span>"
				. += "<span class='notice'>There is a [M.name] mod installed, using <b>[M.cost]%</b> capacity.</span>"

/obj/item/gun/energy/kinetic_accelerator/attackby__legacy__attackchain(obj/item/I, mob/user)
	if(istype(I, /obj/item/borg/upgrade/modkit) && max_mod_capacity)
		var/obj/item/borg/upgrade/modkit/MK = I
		MK.install(src, user)
	else
		return ..()

/obj/item/gun/energy/kinetic_accelerator/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!max_mod_capacity)
		return
	if(!length(modkits))
		to_chat(user, "<span class='notice'>There are no modifications currently installed.</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You pry the modifications out.</span>")
	for(var/obj/item/borg/upgrade/modkit/M in modkits)
		M.uninstall(src)

/obj/item/gun/energy/kinetic_accelerator/proc/get_remaining_mod_capacity()
	var/current_capacity_used = 0
	for(var/A in get_modkits())
		var/obj/item/borg/upgrade/modkit/M = A
		current_capacity_used += M.cost
	return max_mod_capacity - current_capacity_used

/obj/item/gun/energy/kinetic_accelerator/proc/get_modkits()
	. = list()
	for(var/A in modkits)
		. += A

/obj/item/gun/energy/kinetic_accelerator/proc/modify_projectile(obj/item/projectile/kinetic/K)
	K.kinetic_gun = src //do something special on-hit, easy!
	for(var/A in get_modkits())
		var/obj/item/borg/upgrade/modkit/M = A
		M.modify_projectile(K)

/obj/item/gun/energy/kinetic_accelerator/cyborg
	holds_charge = TRUE
	unique_frequency = TRUE
	icon_state = "kineticgun_b"

/obj/item/gun/energy/kinetic_accelerator/cyborg/malf
	name = "kinetic accelerator cannon"
	desc = "A cyborg-modified kinetic accelerator that operates in pressurized environments, but cannot be upgraded and fires slowly."
	icon_state = "kineticgun_h"
	max_mod_capacity = 0
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/malf)
	overheat_time = 2 SECONDS

/obj/item/gun/energy/kinetic_accelerator/minebot
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	overheat_time = 20
	holds_charge = TRUE
	unique_frequency = TRUE

/obj/item/gun/energy/kinetic_accelerator/Initialize(mapload)
	. = ..()
	if(!holds_charge)
		empty()

/obj/item/gun/energy/kinetic_accelerator/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	. = ..()
	attempt_reload()

/obj/item/gun/energy/kinetic_accelerator/equipped(mob/user)
	. = ..()
	if(!can_shoot())
		attempt_reload()

/obj/item/gun/energy/kinetic_accelerator/dropped()
	. = ..()
	if(!QDELING(src) && !holds_charge)
		// Put it on a delay because moving item from slot to hand
		// calls dropped().
		addtimer(CALLBACK(src, PROC_REF(empty_if_not_held)), 2)

/obj/item/gun/energy/kinetic_accelerator/proc/empty_if_not_held()
	if(!ismob(loc))
		empty()

/obj/item/gun/energy/kinetic_accelerator/proc/empty()
	cell.use(500)
	update_icon()

/obj/item/gun/energy/kinetic_accelerator/proc/attempt_reload(recharge_time)
	if(overheat)
		return
	if(!recharge_time)
		recharge_time = overheat_time
	overheat = TRUE

	var/carried = 0
	if(!unique_frequency)
		for(var/obj/item/gun/energy/kinetic_accelerator/K in loc.GetAllContents())
			if(!K.unique_frequency)
				carried++

		carried = max(carried, 1)
	else
		carried = 1

	deltimer(recharge_timerid)
	recharge_timerid = addtimer(CALLBACK(src, PROC_REF(reload)), recharge_time * carried, TIMER_STOPPABLE)

/obj/item/gun/energy/kinetic_accelerator/emp_act(severity)
	return

/obj/item/gun/energy/kinetic_accelerator/robocharge()
	return

/obj/item/gun/energy/kinetic_accelerator/proc/reload()
	cell.give(500)
	on_recharge()
	if(!suppressed)
		playsound(loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	else if(isliving(loc))
		to_chat(loc, "<span class='warning'>[src] silently charges up.</span>")
	update_icon()
	overheat = FALSE

/obj/item/gun/energy/kinetic_accelerator/update_overlays()
	. = ..()
	if(empty_state && !can_shoot())
		. += empty_state

	if(gun_light && can_flashlight)
		var/iconF = "flight"
		if(gun_light.on)
			iconF = "flight_on"
		. +=  image(icon = icon, icon_state = iconF, pixel_x = flight_x_offset, pixel_y = flight_y_offset)
	if(bayonet && can_bayonet)
		. += knife_overlay

/obj/item/gun/energy/kinetic_accelerator/experimental
	name = "experimental kinetic accelerator"
	desc = "A modified version of the proto-kinetic accelerator, with twice the modkit space of the standard version."
	icon_state = "kineticgun_h"
	origin_tech = "combat=5;powerstorage=3;engineering=5"
	max_mod_capacity = 200

/obj/item/gun/energy/kinetic_accelerator/railgun
	name = "proto-kinetic railgun"
	desc = "A heavy-duty proto-kinetic accelerator that uses highly overclocked coils to fire a kinetic projectile at staggering speeds."
	icon_state = "kineticrailgun"
	base_icon_state = "kineticrailgun"
	w_class = WEIGHT_CLASS_HUGE
	overheat_time = 3 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/railgun)
	weapon_weight = WEAPON_HEAVY
	max_mod_capacity = 15 // A crumb of mod capacity as a treat
	recoil = 3 // railgun go brrrrr

/obj/item/gun/energy/kinetic_accelerator/railgun/examine_more(mob/user)
	. = ..()
	. += "Before the nice streamlined and modern day Proto-Kinetic Accelerator was created, multiple designs were drafted by the Mining Research and Development \
	team. Many were failures, including this one, which came out too bulky and too ineffective. Well recently the MR&D Team got drunk and said 'fuck it we ball' and \
	went back to the bulky design, overclocked it, and made it functional, turning it into what is essentially a literal man portable particle accelerator. \
	The design results in a massive hard to control blast of kinetic energy, with the power to punch right through creatures and cause massive damage. The \
	only problem with the design is that it is so bulky you need to carry it with two hands, and the technology has been outfitted with a special firing pin \
	that denies use near or on the station, due to its destructive nature."

/obj/item/gun/energy/kinetic_accelerator/railgun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(is_station_level(src.loc.z))
		to_chat(user, "<span class='warning'>[src] clicks. It's internal safety prevents it from firing near the station.</span>")
		return
	return ..()

/obj/item/gun/energy/kinetic_accelerator/repeater
	name = "proto-kinetic repeater"
	desc = "A proto-kinetic accelerator boasting deeper capacitors for prolonged firing solutions."
	icon_state = "kineticrepeater"
	base_icon_state = "kineticrepeater"
	overheat_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/repeater)
	max_mod_capacity = 75

/obj/item/gun/energy/kinetic_accelerator/repeater/examine_more(mob/user)
	. = ..()
	. += "During the pizza party celebrating the release of the new crusher designs, the Mining Research and Development team members were only allowed one slice. \
	One member exclaimed 'I wish we could have more than one slice' and another replied 'I wish we could shoot the accelerator more than once' and thus, the repeater \
	on the spot. The repeater trades a bit of power for the ability to fire three shots before becoming empty, while retaining the ability to fully recharge in one \
	go. The extra technology packed inside to make this possible unfortunately reduces mod space meaning you cant carry as many mods compared to a regular accelerator."

/obj/item/gun/energy/kinetic_accelerator/shotgun
	name = "proto-kinetic shotgun"
	desc = "A sleek proto-kinetic accelerator with an integrated scattering system, allowing for multiple simultaneous kinetic blasts to be released simultaneously."
	icon_state = "kineticshotgun"
	base_icon_state = "kineticshotgun"
	overheat_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/shotgun)
	weapon_weight = WEAPON_HEAVY
	max_mod_capacity = 75

/obj/item/gun/energy/kinetic_accelerator/shotgun/examine_more(mob/user)
	. = ..()
	. += "During the crusher design pizza party, one member of the Mining Research and Development team brought out a real riot shotgun, and killed three \
	other research members with one blast. The MR&D Director immedietly thought of a genuis idea, creating the proto-kinetic shotgun moments later, which he \
	immedietly used to execute the research member who brought the real shotgun. The proto-kinetic shotgun trades off some mod capacity and cooldown in favor \
	of firing three shots at once with reduce range and power. The total damage of all three shots is higher than a regular PKA but the individual shots are weaker. \
	Looks like you need both hands to use it effectively."

/obj/item/gun/energy/kinetic_accelerator/shockwave
	name = "proto-kinetic shockwave"
	desc = "A short-range portable cannon that fires a kinetic slug into the ground, allowing it to split and strike in all directions."
	icon_state = "kineticshockwave"
	base_icon_state = "kineticshockwave"
	overheat_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/shockwave)
	max_mod_capacity = 75

/obj/item/gun/energy/kinetic_accelerator/shockwave/examine_more(mob/user)
	. = ..()
	. += "Quite frankly, we have no idea how the Mining Research and Development team came up with this one, all we know is that alot of \
	beer was involved. This proto-kinetic design will slam the ground, creating a shockwave around the user, with the same power as the base PKA.\
	The only downside is the lowered mod capacity, the lack of range it offers, and the higher cooldown, but its pretty good for clearing rocks."

/obj/item/gun/energy/kinetic_accelerator/shockwave/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	target = get_edge_target_turf(user, user.dir)
	return ..()

//Casing
/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/item/projectile/kinetic
	muzzle_flash_color = null
	select_name = "kinetic"
	e_cost = 500
	fire_sound = 'sound/weapons/kenetic_accel.ogg' // fine spelling there chap

/obj/item/ammo_casing/energy/kinetic/railgun
	projectile_type = /obj/item/projectile/kinetic/railgun
	select_name = "kinetic"
	fire_sound = 'sound/weapons/beam_sniper.ogg'

/obj/item/ammo_casing/energy/kinetic/repeater
	projectile_type = /obj/item/projectile/kinetic/repeater
	e_cost = 150 // Three shots

/obj/item/ammo_casing/energy/kinetic/shotgun
	projectile_type = /obj/item/projectile/kinetic/shotgun
	pellets = 6
	variance = 50

/obj/item/ammo_casing/energy/kinetic/shockwave
	projectile_type = /obj/item/projectile/kinetic/shockwave
	pellets = 8
	variance = 360
	fire_sound = 'sound/weapons/cannon.ogg'

/obj/item/ammo_casing/energy/kinetic/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	if(loc && istype(loc, /obj/item/gun/energy/kinetic_accelerator))
		var/obj/item/gun/energy/kinetic_accelerator/KA = loc
		KA.modify_projectile(BB)

//Malf casing
/obj/item/ammo_casing/energy/kinetic/malf
	projectile_type = /obj/item/projectile/kinetic/malf

//Projectiles
/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 40
	flag = BOMB
	range = 3

	var/pressure_decrease_active = FALSE
	var/pressure_decrease = 0.25
	var/obj/item/gun/energy/kinetic_accelerator/kinetic_gun

/obj/item/projectile/kinetic/malf
	pressure_decrease = 1
	color = "#FFFFFF"
	icon_state = "ka_tracer"

/obj/item/projectile/kinetic/pod
	range = 4

/obj/item/projectile/kinetic/pod/regular
	damage = 50
	pressure_decrease = 0.5

/obj/item/projectile/kinetic/railgun
	name = "hyper kinetic force"
	damage = 75
	range = 6
	pressure_decrease = 0.10 // Pressured environments are a no go for the railgun
	pass_flags = PASSMOB

/obj/item/projectile/kinetic/repeater
	name = "rapid kinetic force"
	damage = 20
	range = 4

/obj/item/projectile/kinetic/shotgun
	name = "split kinetic force"
	damage = 10
	range = 3

/obj/item/projectile/kinetic/shockwave
	name = "concussive kinetic force"
	damage = 40
	range = 1

/obj/item/projectile/kinetic/Destroy()
	kinetic_gun = null
	return ..()

/obj/item/projectile/kinetic/prehit(atom/target)
	. = ..()
	if(.)
		if(kinetic_gun)
			var/list/mods = kinetic_gun.get_modkits()
			for(var/obj/item/borg/upgrade/modkit/M in mods)
				M.projectile_prehit(src, target, kinetic_gun)
		if(!lavaland_equipment_pressure_check(get_turf(target)))
			name = "weakened [name]"
			damage = damage * pressure_decrease
			pressure_decrease_active = TRUE


/obj/item/projectile/kinetic/on_range()
	strike_thing()
	..()

/obj/item/projectile/kinetic/on_hit(atom/target)
	strike_thing(target)
	. = ..()

/obj/item/projectile/kinetic/proc/strike_thing(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	if(kinetic_gun) //hopefully whoever shot this was not very, very unfortunate.
		var/list/mods = kinetic_gun.get_modkits()
		for(var/obj/item/borg/upgrade/modkit/M in mods)
			M.projectile_strike_predamage(src, target_turf, target, kinetic_gun)
		for(var/obj/item/borg/upgrade/modkit/M in mods)
			M.projectile_strike(src, target_turf, target, kinetic_gun)
	if(ismineralturf(target_turf))
		if(is_ancient_rock(target_turf))
			visible_message("<span class='notice'>This rock appears to be resistant to all mining tools except pickaxes!</span>")
		else
			var/turf/simulated/mineral/M = target_turf
			M.gets_drilled(firer)
	var/obj/effect/temp_visual/kinetic_blast/K = new /obj/effect/temp_visual/kinetic_blast(target_turf)
	K.color = color

/obj/item/gun/energy/kinetic_accelerator/pistol
	name = "proto-kinetic pistol"
	desc = "A lightweight mining tool, sacrificing upgrade capacity for convenience."
	icon_state = "kineticpistol"
	w_class = WEIGHT_CLASS_SMALL
	max_mod_capacity = 65
	can_bayonet = FALSE
	flight_y_offset = 10
	can_holster = TRUE
	empty_state = "kineticpistol_empty"

//Modkits
/obj/item/borg/upgrade/modkit
	name = "kinetic accelerator modification kit"
	desc = "An upgrade for kinetic accelerators."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	origin_tech = "programming=2;materials=2;magnets=4"
	require_module = TRUE
	module_type = /obj/item/robot_module/miner
	usesound = 'sound/items/screwdriver.ogg'
	allow_duplicate = TRUE
	var/denied_type = null
	var/maximum_of_type = 1
	var/cost = 30
	var/modifier = 1 //For use in any mod kit that has numerical modifiers
	var/minebot_upgrade = TRUE
	var/minebot_exclusive = FALSE

/obj/item/borg/upgrade/modkit/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += "<span class='notice'>Occupies <b>[cost]%</b> of mod capacity.</span>"

/obj/item/borg/upgrade/modkit/attackby__legacy__attackchain(obj/item/A, mob/user)
	if(istype(A, /obj/item/gun/energy/kinetic_accelerator) && !issilicon(user))
		var/obj/item/gun/energy/kinetic_accelerator/KA = A
		if(KA.max_mod_capacity)
			install(A, user)
		else
			return ..()
	else
		return ..()

/obj/item/borg/upgrade/modkit/action(mob/user, mob/living/silicon/robot/R)
	if(!..())
		return

	for(var/obj/item/gun/energy/kinetic_accelerator/cyborg/H in R.module.modules)
		return install(H, user)

/obj/item/borg/upgrade/modkit/proc/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = TRUE
	if(istype(loc, /obj/item/gun/energy/kinetic_accelerator)) //Could be in another KA too.
		message_admins("[key_name_admin(user)] attempted to install a modkit into a kinetic accelerator while it is installed in an accelerator. Could be a double click, or an exploit attempt.")
		return FALSE
	if(minebot_upgrade)
		if(minebot_exclusive && !istype(KA.loc, /mob/living/basic/mining_drone))
			to_chat(user, "<span class='notice'>The modkit you're trying to install is only rated for minebot use.</span>")
			return FALSE
	else if(istype(KA.loc, /mob/living/basic/mining_drone))
		to_chat(user, "<span class='notice'>The modkit you're trying to install is not rated for minebot use.</span>")
		return FALSE
	if(denied_type)
		var/number_of_denied = 0
		for(var/A in KA.get_modkits())
			var/obj/item/borg/upgrade/modkit/M = A
			if(istype(M, denied_type))
				number_of_denied++
			if(number_of_denied >= maximum_of_type)
				. = FALSE
				break
	if(KA.get_remaining_mod_capacity() >= cost)
		if(.)
			to_chat(user, "<span class='notice'>You install the modkit.</span>")
			playsound(loc, usesound, 100, 1)
			user.unequip(src)
			forceMove(KA)
			KA.modkits += src
		else
			to_chat(user, "<span class='notice'>The modkit you're trying to install would conflict with an already installed modkit. Use a crowbar to remove existing modkits.</span>")
	else
		to_chat(user, "<span class='notice'>You don't have room(<b>[KA.get_remaining_mod_capacity()]%</b> remaining, [cost]% needed) to install this modkit. Use a crowbar to remove existing modkits.</span>")
		. = FALSE

/obj/item/borg/upgrade/modkit/proc/uninstall(obj/item/gun/energy/kinetic_accelerator/KA)
	forceMove(get_turf(KA))
	KA.modkits -= src

/obj/item/borg/upgrade/modkit/Destroy()
	if(istype(loc, /obj/item/gun/energy/kinetic_accelerator))
		var/obj/item/gun/energy/kinetic_accelerator/accelerator = loc
		accelerator.modkits -= src
	return ..()

/obj/item/borg/upgrade/modkit/proc/modify_projectile(obj/item/projectile/kinetic/K)
	return

//use this one for effects you want to trigger before any damage is done at all and before damage is decreased by pressure
/obj/item/borg/upgrade/modkit/proc/projectile_prehit(obj/item/projectile/kinetic/K, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	return

//use this one for effects you want to trigger before mods that do damage
/obj/item/borg/upgrade/modkit/proc/projectile_strike_predamage(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	return

//and this one for things that don't need to trigger before other damage-dealing mods
/obj/item/borg/upgrade/modkit/proc/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	return

//Range
/obj/item/borg/upgrade/modkit/range
	name = "range increase"
	desc = "Increases the range of a kinetic accelerator when installed."
	cost = 24 //so you can fit four plus a tracer cosmetic

/obj/item/borg/upgrade/modkit/range/modify_projectile(obj/item/projectile/kinetic/K)
	K.range += modifier


//Damage
/obj/item/borg/upgrade/modkit/damage
	name = "damage increase"
	desc = "Increases the damage of kinetic accelerator when installed."
	modifier = 10

/obj/item/borg/upgrade/modkit/damage/modify_projectile(obj/item/projectile/kinetic/K)
	K.damage += modifier


//Cooldown
/obj/item/borg/upgrade/modkit/cooldown
	name = "cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Not rated for minebot use."
	modifier = 3.2
	minebot_upgrade = FALSE

/obj/item/borg/upgrade/modkit/cooldown/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.overheat_time -= modifier

/obj/item/borg/upgrade/modkit/cooldown/uninstall(obj/item/gun/energy/kinetic_accelerator/KA)
	KA.overheat_time += modifier
	..()

/obj/item/borg/upgrade/modkit/cooldown/minebot
	name = "minebot cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Only rated for minebot use."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	denied_type = /obj/item/borg/upgrade/modkit/cooldown/minebot
	modifier = 10
	cost = 0
	minebot_upgrade = TRUE
	minebot_exclusive = TRUE

//AoE blasts
/obj/item/borg/upgrade/modkit/aoe
	modifier = 0
	var/turf_aoe = FALSE
	var/stats_stolen = FALSE

/obj/item/borg/upgrade/modkit/aoe/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	if(..())
		return
	for(var/obj/item/borg/upgrade/modkit/aoe/AOE in KA.modkits) //make sure only one of the aoe modules has values if somebody has multiple
		if(AOE.stats_stolen || AOE == src)
			continue
		modifier += AOE.modifier //take its modifiers
		AOE.modifier = 0
		turf_aoe += AOE.turf_aoe
		AOE.turf_aoe = FALSE
		AOE.stats_stolen = TRUE

/obj/item/borg/upgrade/modkit/aoe/uninstall(obj/item/gun/energy/kinetic_accelerator/KA)
	..()
	modifier = initial(modifier) //get our modifiers back
	turf_aoe = initial(turf_aoe)
	stats_stolen = FALSE

/obj/item/borg/upgrade/modkit/aoe/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(stats_stolen)
		return
	new /obj/effect/temp_visual/pka_explosion(target_turf)
	if(turf_aoe)
		for(var/T in RANGE_TURFS(1, target_turf) - target_turf)
			if(ismineralturf(T) && !is_ancient_rock(T))
				var/turf/simulated/mineral/M = T
				M.gets_drilled(K.firer)
	if(modifier)
		for(var/mob/living/L in range(1, target_turf) - K.firer - target)
			var/armor = L.run_armor_check(K.def_zone, K.flag, armor_penetration_flat = K.armor_penetration_flat, armor_penetration_percentage = K.armor_penetration_percentage)
			L.apply_damage(K.damage * modifier, K.damage_type, K.def_zone, armor)
			to_chat(L, "<span class='userdanger'>You're struck by a [K.name]!</span>")

/obj/item/borg/upgrade/modkit/aoe/turfs
	name = "mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock in an AoE."
	denied_type = /obj/item/borg/upgrade/modkit/aoe/turfs
	turf_aoe = TRUE

/obj/item/borg/upgrade/modkit/aoe/turfs/andmobs
	name = "offensive mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock and damage mobs in an AoE."
	maximum_of_type = 3
	modifier = 0.25

/obj/item/borg/upgrade/modkit/aoe/mobs
	name = "offensive explosion"
	desc = "Causes the kinetic accelerator to damage mobs in an AoE."
	modifier = 0.2

//Minebot passthrough
/obj/item/borg/upgrade/modkit/minebot_passthrough
	name = "minebot passthrough"
	desc = "Causes kinetic accelerator shots to pass through minebots."
	cost = 0

//Tendril-unique modules
/obj/item/borg/upgrade/modkit/cooldown/repeater
	name = "rapid repeater"
	desc = "Quarters the kinetic accelerator's cooldown on striking a living target, but greatly increases the base cooldown."
	denied_type = /obj/item/borg/upgrade/modkit/cooldown/repeater
	modifier = -14 //Makes the cooldown 3 seconds(with no cooldown mods) if you miss. Don't miss.
	cost = 50

/obj/item/borg/upgrade/modkit/cooldown/repeater/projectile_strike_predamage(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	var/valid_repeat = FALSE
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			valid_repeat = TRUE
	if(ismineralturf(target_turf))
		valid_repeat = TRUE
	if(valid_repeat)
		KA.overheat = FALSE
		KA.attempt_reload(KA.overheat_time * 0.25) //If you hit, the cooldown drops to 0.75 seconds.

/obj/item/borg/upgrade/modkit/lifesteal
	name = "lifesteal crystal"
	desc = "Causes kinetic accelerator shots to slightly heal the firer on striking a living target."
	icon_state = "modkit_crystal"
	modifier = 2.5 //Not a very effective method of healing.
	cost = 20
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/borg/upgrade/modkit/lifesteal/projectile_prehit(obj/item/projectile/kinetic/K, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(isliving(target) && isliving(K.firer))
		var/mob/living/L = target
		if(L.stat == DEAD)
			return
		L = K.firer
		L.heal_ordered_damage(modifier, damage_heal_order)

/obj/item/borg/upgrade/modkit/resonator_blasts
	name = "resonator blast"
	desc = "Causes kinetic accelerator shots to leave and detonate resonator blasts."
	denied_type = /obj/item/borg/upgrade/modkit/resonator_blasts
	modifier = 0.25 //A bonus 15 damage if you burst the field on a target, 60 if you lure them into it.

/obj/item/borg/upgrade/modkit/resonator_blasts/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(target_turf && !ismineralturf(target_turf)) //Don't make fields on mineral turfs.
		var/obj/effect/temp_visual/resonance/R = locate(/obj/effect/temp_visual/resonance) in target_turf
		if(R)
			R.damage_multiplier = modifier
			R.burst()
			return
		new /obj/effect/temp_visual/resonance(target_turf, K.firer, null, RESONATOR_MODE_MANUAL, 100) //manual detonate mode and will NOT spread

/obj/item/borg/upgrade/modkit/bounty
	name = "death syphon"
	desc = "Killing or assisting in killing a creature permanently increases your damage against that type of creature."
	denied_type = /obj/item/borg/upgrade/modkit/bounty
	modifier = 1.25
	var/maximum_bounty = 25
	var/list/bounties_reaped = list()

/obj/item/borg/upgrade/modkit/bounty/projectile_prehit(obj/item/projectile/kinetic/K, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(isliving(target))
		var/mob/living/L = target
		var/list/existing_marks = L.has_status_effect_list(STATUS_EFFECT_SYPHONMARK)
		for(var/i in existing_marks)
			var/datum/status_effect/syphon_mark/SM = i
			if(SM.reward_target == src) //we want to allow multiple people with bounty modkits to use them, but we need to replace our own marks so we don't multi-reward
				SM.reward_target = null
				qdel(SM)
		L.apply_status_effect(STATUS_EFFECT_SYPHONMARK, src)

/obj/item/borg/upgrade/modkit/bounty/projectile_strike(obj/item/projectile/kinetic/K, turf/target_turf, atom/target, obj/item/gun/energy/kinetic_accelerator/KA)
	if(isliving(target))
		var/mob/living/L = target
		if(bounties_reaped[L.type])
			var/kill_modifier = 1
			if(K.pressure_decrease_active)
				kill_modifier *= K.pressure_decrease
			var/armor = L.run_armor_check(K.def_zone, K.flag, armor_penetration_flat = K.armor_penetration_flat, armor_penetration_percentage = K.armor_penetration_percentage)
			L.apply_damage(bounties_reaped[L.type]*kill_modifier, K.damage_type, K.def_zone, armor)

/obj/item/borg/upgrade/modkit/bounty/proc/get_kill(mob/living/L)
	var/bonus_mod = 1
	if(ismegafauna(L)) //megafauna reward
		bonus_mod = 4
	if(!bounties_reaped[L.type])
		bounties_reaped[L.type] = min(modifier * bonus_mod, maximum_bounty)
	else
		bounties_reaped[L.type] = min(bounties_reaped[L.type] + (modifier * bonus_mod), maximum_bounty)

//Indoors
/obj/item/borg/upgrade/modkit/indoors
	name = "decrease pressure penalty"
	desc = "A syndicate modification kit that increases the damage a kinetic accelerator does in high pressure environments."
	modifier = 2
	denied_type = /obj/item/borg/upgrade/modkit/indoors
	maximum_of_type = 2
	cost = 35

/obj/item/borg/upgrade/modkit/indoors/modify_projectile(obj/item/projectile/kinetic/K)
	K.pressure_decrease *= modifier


//Trigger Guard
/obj/item/borg/upgrade/modkit/trigger_guard
	name = "modified trigger guard"
	desc = "Allows creatures normally incapable of firing guns to operate the weapon when installed."
	cost = 20
	denied_type = /obj/item/borg/upgrade/modkit/trigger_guard

/obj/item/borg/upgrade/modkit/trigger_guard/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/borg/upgrade/modkit/trigger_guard/uninstall(obj/item/gun/energy/kinetic_accelerator/KA)
	KA.trigger_guard = TRIGGER_GUARD_NORMAL
	..()

//Cosmetic

/obj/item/borg/upgrade/modkit/chassis_mod
	name = "super chassis"
	desc = "Makes your KA yellow. All the fun of having a more powerful KA without actually having a more powerful KA."
	cost = 0
	denied_type = /obj/item/borg/upgrade/modkit/chassis_mod
	var/chassis_icon = "kineticgun_u"
	var/chassis_name = "super-kinetic accelerator"
	var/pistol_chassis_icon = "kineticpistol_u"
	var/pistol_chassis_name = "super-kinetic pistol"

/obj/item/borg/upgrade/modkit/chassis_mod/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		if(istype(KA, /obj/item/gun/energy/kinetic_accelerator/pistol))
			KA.current_skin = pistol_chassis_icon
			KA.name = pistol_chassis_name
		else
			KA.current_skin = chassis_icon
			KA.name = chassis_name
		KA.update_icon()

/obj/item/borg/upgrade/modkit/chassis_mod/uninstall(obj/item/gun/energy/kinetic_accelerator/KA)
	KA.current_skin = initial(KA.current_skin)
	KA.name = initial(KA.name)
	KA.update_icon()
	..()

/obj/item/borg/upgrade/modkit/chassis_mod/orange
	name = "hyper chassis"
	desc = "Makes your KA orange. All the fun of having explosive blasts without actually having explosive blasts."
	chassis_icon = "kineticgun_h"
	chassis_name = "hyper-kinetic accelerator"
	pistol_chassis_icon = "kineticpistol_h"
	pistol_chassis_name = "hyper-kinetic pistol"

/obj/item/borg/upgrade/modkit/tracer
	name = "white tracer bolts"
	desc = "Causes kinetic accelerator bolts to have a white tracer trail and explosion."
	cost = 0
	denied_type = /obj/item/borg/upgrade/modkit/tracer
	var/bolt_color = "#FFFFFF"

/obj/item/borg/upgrade/modkit/tracer/modify_projectile(obj/item/projectile/kinetic/K)
	K.icon_state = "ka_tracer"
	K.color = bolt_color

/obj/item/borg/upgrade/modkit/tracer/adjustable
	name = "adjustable tracer bolts"
	desc = "Causes kinetic accelerator bolts to have an adjustable-colored tracer trail and explosion. Use in-hand to change color."

/obj/item/borg/upgrade/modkit/tracer/adjustable/attack_self__legacy__attackchain(mob/user)
	bolt_color = tgui_input_color(user, "Please select a tracer color", "PKA Tracer Color", bolt_color)
