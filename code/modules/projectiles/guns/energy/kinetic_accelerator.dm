/obj/item/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "A self recharging, ranged mining tool that does increased damage in low pressure. Capable of holding up to six slots worth of mod kits."
	icon_state = "kineticgun"
	item_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	cell_type = /obj/item/stock_parts/cell/emproof
	needs_permit = 0
	unique_rename = 1
	origin_tech = "combat=3;powerstorage=3;engineering=3"
	weapon_weight = WEAPON_LIGHT
	can_flashlight = 1
	flight_x_offset = 15
	flight_y_offset = 9
	var/overheat_time = 16
	var/holds_charge = FALSE
	var/unique_frequency = FALSE // modified by KA modkits
	var/overheat = FALSE

	var/max_mod_capacity = 100
	var/list/modkits = list()

	var/empty_state = "kineticgun_empty"

/obj/item/gun/energy/kinetic_accelerator/examine(mob/user)
	if(..(user, 1))
		if(max_mod_capacity)
			to_chat(user, "<b>[get_remaining_mod_capacity()]%</b> mod capacity remaining.")
			for(var/A in get_modkits())
				var/obj/item/borg/upgrade/modkit/M = A
				to_chat(user, "<span class='notice'>There is a [M.name] mod installed, using <b>[M.cost]%</b> capacity.</span>")

/obj/item/gun/energy/kinetic_accelerator/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/crowbar))
		if(modkits.len)
			to_chat(user, "<span class='notice'>You pry the modifications out.</span>")
			playsound(loc, A.usesound, 100, 1)
			for(var/obj/item/borg/upgrade/modkit/M in modkits)
				M.uninstall(src)
		else
			to_chat(user, "<span class='notice'>There are no modifications currently installed.</span>")
	else if(istype(A, /obj/item/borg/upgrade/modkit))
		var/obj/item/borg/upgrade/modkit/MK = A
		MK.install(src, user)
	else
		..()

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
	for(var/A in get_modkits())
		var/obj/item/borg/upgrade/modkit/M = A
		M.modify_projectile(K)

/obj/item/gun/energy/kinetic_accelerator/cyborg
	holds_charge = TRUE
	unique_frequency = TRUE
	max_mod_capacity = 80

/obj/item/gun/energy/kinetic_accelerator/New()
	. = ..()
	if(!holds_charge)
		empty()

/obj/item/gun/energy/kinetic_accelerator/shoot_live_shot()
	. = ..()
	attempt_reload()

/obj/item/gun/energy/kinetic_accelerator/equipped(mob/user)
	. = ..()
	if(!can_shoot())
		attempt_reload()

/obj/item/gun/energy/kinetic_accelerator/dropped()
	. = ..()
	if(!holds_charge)
		// Put it on a delay because moving item from slot to hand
		// calls dropped().
		spawn(2)
			empty_if_not_held()

/obj/item/gun/energy/kinetic_accelerator/proc/empty_if_not_held()
	if(!ismob(loc))
		empty()

/obj/item/gun/energy/kinetic_accelerator/proc/empty()
	power_supply.use(500)
	update_icon()

/obj/item/gun/energy/kinetic_accelerator/proc/attempt_reload()
	if(overheat)
		return
	overheat = TRUE

	var/carried = 0
	if(!unique_frequency)
		for(var/obj/item/gun/energy/kinetic_accelerator/K in \
			loc.GetAllContents())

			carried++

		carried = max(carried, 1)
	else
		carried = 1

	spawn(overheat_time * carried)
		reload()

/obj/item/gun/energy/kinetic_accelerator/emp_act(severity)
	return

/obj/item/gun/energy/kinetic_accelerator/proc/reload()
	power_supply.give(500)
	if(!suppressed)
		playsound(loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	else if(isliving(loc))
		to_chat(loc, "<span class='warning'>[src] silently charges up.</span>")
	update_icon()
	overheat = FALSE

/obj/item/gun/energy/kinetic_accelerator/update_icon()
	overlays.Cut()
	if(empty_state && !can_shoot())
		overlays += empty_state

	if(gun_light && can_flashlight)
		var/iconF = "flight"
		if(gun_light.on)
			iconF = "flight_on"
		overlays += image(icon = icon, icon_state = iconF, pixel_x = flight_x_offset, pixel_y = flight_y_offset)


/obj/item/gun/energy/kinetic_accelerator/experimental
	name = "experimental kinetic accelerator"
	desc = "A modified version of the proto-kinetic accelerator, with twice the modkit space of the standard version."
	icon_state = "kineticgun_h"
	item_state = "kineticgun_h"
	origin_tech = "combat=5;powerstorage=3;engineering=5"
	max_mod_capacity = 200

//Casing
/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/item/projectile/kinetic
	select_name = "kinetic"
	e_cost = 500
	fire_sound = 'sound/weapons/kenetic_accel.ogg' // fine spelling there chap

/obj/item/ammo_casing/energy/kinetic/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	if(loc && istype(loc, /obj/item/gun/energy/kinetic_accelerator))
		var/obj/item/gun/energy/kinetic_accelerator/KA = loc
		KA.modify_projectile(BB)

	var/turf/proj_turf = get_turf(BB)
	if(!isturf(proj_turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure > 50)
		BB.name = "weakened [BB.name]"
		var/obj/item/projectile/kinetic/K = BB
		K.damage *= K.pressure_decrease


//Projectiles
/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 40
	damage_type = BRUTE
	flag = "bomb"
	range = 3

	var/pressure_decrease = 0.25
	var/turf_aoe = FALSE
	var/mob_aoe = FALSE
	var/list/hit_overlays = list()

/obj/item/projectile/kinetic/pod
	range = 4

/obj/item/projectile/kinetic/pod/regular
	damage = 50
	pressure_decrease = 0.5

/obj/item/projectile/kinetic/pod/enhanced
	turf_aoe = TRUE
	mob_aoe = TRUE

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
	if(ismineralturf(target_turf))
		var/turf/simulated/mineral/M = target_turf
		M.gets_drilled(firer)
	var/obj/effect/temp_visual/kinetic_blast/K = new /obj/effect/temp_visual/kinetic_blast(target_turf)
	K.color = color
	for(var/type in hit_overlays)
		new type(target_turf)
	if(turf_aoe)
		for(var/T in RANGE_TURFS(1, target_turf) - target_turf)
			if(ismineralturf(T))
				var/turf/simulated/mineral/M = T
				M.gets_drilled(firer)
	if(mob_aoe)
		for(var/mob/living/L in range(1, target_turf) - firer - target)
			var/armor = L.run_armor_check(def_zone, flag, "", "", armour_penetration)
			L.apply_damage(damage*mob_aoe, damage_type, def_zone, armor)
			L.visible_message("<span class='danger'>[L] is hit by \a [src]!</span>",
								"<span class='userdanger'>You are hit by \a [src]!</span>")
			add_attack_logs(firer, L, "Shot with a [type]")


//Modkits
/obj/item/borg/upgrade/modkit
	name = "modification kit"
	desc = "An upgrade for kinetic accelerators."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	origin_tech = "programming=2;materials=2;magnets=4"
	require_module = 1
	module_type = /obj/item/robot_module/miner
	usesound = 'sound/items/screwdriver.ogg'
	var/denied_type = null
	var/maximum_of_type = 1
	var/cost = 30
	var/modifier = 1 //For use in any mod kit that has numerical modifiers

/obj/item/borg/upgrade/modkit/examine(mob/user)
	if(..(user, 1))
		to_chat(user, "<span class='notice'>Occupies <b>[cost]%</b> of mod capacity.</span>")

/obj/item/borg/upgrade/modkit/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/gun/energy/kinetic_accelerator) && !issilicon(user))
		install(A, user)
	else
		..()

/obj/item/borg/upgrade/modkit/action(mob/living/silicon/robot/R)
	if(..())
		return

	for(var/obj/item/gun/energy/kinetic_accelerator/cyborg/H in R.module.modules)
		return install(H, usr)

/obj/item/borg/upgrade/modkit/proc/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = TRUE
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
			user.unEquip(src)
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

/obj/item/borg/upgrade/modkit/proc/modify_projectile(obj/item/projectile/kinetic/K)


//Range
/obj/item/borg/upgrade/modkit/range
	name = "range increase"
	desc = "Increases the range of a kinetic accelerator when installed."
	modifier = 1
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
	desc = "Decreases the cooldown of a kinetic accelerator."
	modifier = 2.5

/obj/item/borg/upgrade/modkit/cooldown/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.overheat_time -= modifier

/obj/item/borg/upgrade/modkit/cooldown/uninstall(obj/item/gun/energy/kinetic_accelerator/KA)
	KA.overheat_time += modifier
	..()


//AoE blasts
/obj/item/borg/upgrade/modkit/aoe
	modifier = 0

/obj/item/borg/upgrade/modkit/aoe/modify_projectile(obj/item/projectile/kinetic/K)
	K.name = "kinetic explosion"
	if(!K.turf_aoe && !K.mob_aoe)
		K.hit_overlays += /obj/effect/temp_visual/explosion/fast
	K.mob_aoe += modifier

/obj/item/borg/upgrade/modkit/aoe/turfs
	name = "mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock in an AoE."
	denied_type = /obj/item/borg/upgrade/modkit/aoe/turfs

/obj/item/borg/upgrade/modkit/aoe/turfs/modify_projectile(obj/item/projectile/kinetic/K)
	..()
	K.turf_aoe = TRUE

/obj/item/borg/upgrade/modkit/aoe/turfs/andmobs
	name = "offensive mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock and damage mobs in an AoE."
	maximum_of_type = 3
	modifier = 0.25

/obj/item/borg/upgrade/modkit/aoe/mobs
	name = "offensive explosion"
	desc = "Causes the kinetic accelerator to damage mobs in an AoE."
	modifier = 0.2


//Indoors
/obj/item/borg/upgrade/modkit/indoors
	name = "decrease pressure penalty"
	desc = "Increases the damage a kinetic accelerator does in a high pressure environment."
	modifier = 2
	denied_type = /obj/item/borg/upgrade/modkit/indoors
	maximum_of_type = 2
	cost = 40

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

/obj/item/borg/upgrade/modkit/chassis_mod/install(obj/item/gun/energy/kinetic_accelerator/KA, mob/user)
	. = ..()
	if(.)
		KA.icon_state = chassis_icon
		KA.name = chassis_name

/obj/item/borg/upgrade/modkit/chassis_mod/uninstall(obj/item/gun/energy/kinetic_accelerator/KA)
	KA.icon_state = initial(KA.icon_state)
	KA.name = initial(KA.name)
	..()

/obj/item/borg/upgrade/modkit/chassis_mod/orange
	name = "hyper chassis"
	desc = "Makes your KA orange. All the fun of having explosive blasts without actually having explosive blasts."
	chassis_icon = "kineticgun_h"
	chassis_name = "hyper-kinetic accelerator"

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
	desc = "Causes kinetic accelerator bolts to have a adjustably-colored tracer trail and explosion. Use in-hand to change color."

/obj/item/borg/upgrade/modkit/tracer/adjustable/attack_self(mob/user)
	bolt_color = input(user,"Choose Color") as color
