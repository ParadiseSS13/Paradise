/obj/item/device/spacepod_equipment/weaponry/proc/fire_weapons()
	if(my_atom.next_firetime > world.time)
		usr << "<span class='warning'>Your weapons are recharging.</span>"
		return
	var/turf/firstloc
	var/turf/secondloc
	if(!my_atom.equipment_system || !my_atom.equipment_system.weapon_system)
		usr << "<span class='warning'>Missing equipment or weapons.</span>"
		my_atom.verbs -= text2path("[type]/proc/fire_weapons")
		return
	my_atom.battery.use(shot_cost)
	var/olddir
	for(var/i = 0; i < shots_per; i++)
		if(olddir != my_atom.dir)
			switch(my_atom.dir)
				if(NORTH)
					firstloc = get_step(my_atom, NORTH)
					secondloc = get_step(firstloc,EAST)
				if(SOUTH)
					firstloc = get_turf(my_atom)
					secondloc = get_step(firstloc,EAST)
				if(EAST)
					firstloc = get_step(my_atom, EAST)
					secondloc = get_step(firstloc,NORTH)
				if(WEST)
					firstloc = get_turf(my_atom)
					secondloc = get_step(firstloc,NORTH)
		olddir = dir
		var/proj_type = text2path(projectile_type)
		var/obj/item/projectile/projone = new proj_type(firstloc)
		var/obj/item/projectile/projtwo = new proj_type(secondloc)
		projone.starting = get_turf(my_atom)
		projone.shot_from = src
		projone.firer = usr
		projone.def_zone = "chest"
		projtwo.starting = get_turf(my_atom)
		projtwo.shot_from = src
		projtwo.firer = usr
		projtwo.def_zone = "chest"
		spawn()
			playsound(src, fire_sound, 50, 1)
			projone.dumbfire(my_atom.dir)
			projtwo.dumbfire(my_atom.dir)
		sleep(2)
	my_atom.next_firetime = world.time + fire_delay

/datum/spacepod/equipment
	var/obj/spacepod/my_atom
	var/obj/item/device/spacepod_equipment/weaponry/weapon_system // weapons system
	var/obj/item/device/spacepod_equipment/misc/misc_system // misc system
	var/obj/item/device/spacepod_equipment/cargo/cargo_system // cargo system
	//var/obj/item/device/spacepod_equipment/engine/engine_system // engine system
	//var/obj/item/device/spacepod_equipment/shield/shield_system // shielding system

/datum/spacepod/equipment/New(var/obj/spacepod/SP)
	..()
	if(istype(SP))
		my_atom = SP

/obj/item/device/spacepod_equipment
	name = "equipment"
	var/obj/spacepod/my_atom

/obj/item/device/spacepod_equipment/proc/removed(var/mob/user) // So that you can unload cargo when you remove the module
	return

// base item for spacepod weapons

/obj/item/device/spacepod_equipment/weaponry
	name = "pod weapon"
	desc = "You shouldn't be seeing this"
	icon = 'icons/pods/ship.dmi'
	icon_state = "blank"
	var/projectile_type
	var/shot_cost = 0
	var/shots_per = 1
	var/fire_sound
	var/fire_delay = 15

/obj/item/device/spacepod_equipment/weaponry/taser
	name = "disabler system"
	desc = "A weak taser system for space pods, fires disabler beams."
	icon_state = "pod_taser"
	projectile_type = "/obj/item/projectile/beam/disabler"
	shot_cost = 400
	fire_sound = "sound/weapons/Taser.ogg"

/obj/item/device/spacepod_equipment/weaponry/burst_taser
	name = "burst taser system"
	desc = "A weak taser system for space pods, this one fires 3 at a time."
	icon_state = "pod_b_taser"
	projectile_type = "/obj/item/projectile/beam/disabler"
	shot_cost = 1200
	shots_per = 3
	fire_sound = "sound/weapons/Taser.ogg"
	fire_delay = 30

/obj/item/device/spacepod_equipment/weaponry/laser
	name = "laser system"
	desc = "A weak laser system for space pods, fires concentrated bursts of energy"
	icon_state = "pod_w_laser"
	projectile_type = "/obj/item/projectile/beam"
	shot_cost = 600
	fire_sound = 'sound/weapons/Laser.ogg'

// MINING LASERS
/obj/item/device/spacepod_equipment/weaponry/mining_laser_basic
	name = "weak mining laser system"
	desc = "A weak mining laser system for space pods, fires bursts of energy that cut through rock"
	icon_state = "pod_taser"
	projectile_type = "/obj/item/projectile/kinetic"
	shot_cost = 200
	fire_delay = 10
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/obj/item/device/spacepod_equipment/weaponry/mining_laser
	name = "mining laser system"
	desc = "A mining laser system for space pods, fires bursts of energy that cut through rock"
	icon_state = "pod_m_laser"
	projectile_type = "/obj/item/projectile/kinetic/hyper"
	shot_cost = 600
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/obj/item/device/spacepod_equipment/weaponry/mining_laser_burst
	name = "burst mining laser system"
	desc = "A mining laser system for space pods, this one fires 3 at a time"
	icon_state = "pod_w_laser"
	projectile_type = "/obj/item/projectile/kinetic/hyper"
	shot_cost = 1200
	shots_per = 3
	fire_delay = 30
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

//base item for spacepod misc equipment (tracker)
/obj/item/device/spacepod_equipment/misc
	name = "pod misc"
	desc = "You shouldn't be seeing this"
	icon = 'icons/pods/ship.dmi'
	icon_state = "blank"
	var/enabled

/obj/item/device/spacepod_equipment/misc/tracker
	name = "\improper spacepod tracking system"
	desc = "A tracking device for spacepods."
	icon_state = "pod_locator"
	enabled = 0

/obj/item/device/spacepod_equipment/misc/tracker/attackby(obj/item/I as obj, mob/user as mob, params)
	if(isscrewdriver(I))
		if(enabled)
			enabled = 0
			user.show_message("<span class='notice'>You disable \the [src]'s power.")
			return
		enabled = 1
		user.show_message("<span class='notice'>You enable \the [src]'s power.</span>")
	else
		..()

/obj/item/device/spacepod_equipment/cargo
	name = "pod cargo"
	desc = "You shouldn't be seeing this"
	icon = 'icons/pods/ship.dmi'
	icon_state = "blank"

/obj/item/device/spacepod_equipment/cargo/proc/passover(var/obj/item/I)
	return

/obj/item/device/spacepod_equipment/cargo/proc/unload()
	return

/obj/item/device/spacepod_equipment/cargo/ore
	name = "\improper spacepod ore storage system"
	desc = "An ore storage system for spacepods. Scoops up any ore you drive over."
	icon_state = "pod_locator"
	var/obj/structure/ore_box/box

/obj/item/device/spacepod_equipment/cargo/ore/passover(var/obj/item/I)
	if(box && istype(I,/obj/item/weapon/ore))
		I.forceMove(box)

/obj/item/device/spacepod_equipment/cargo/ore/unload()
	if(box)
		box.loc = get_turf(my_atom)
		box = null

/obj/item/device/spacepod_equipment/cargo/ore/removed(var/mob/user)
	. = ..()
	unload()