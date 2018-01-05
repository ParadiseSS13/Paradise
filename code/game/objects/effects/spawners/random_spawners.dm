/obj/effect/spawner/random_spawners
	name = "random spawners"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	color = "#00FF00"
	var/list/result = list(
	/turf/simulated/floor/plasteel = 1,
	/turf/simulated/floor/plating = 1,
	/obj/effect/decal/cleanable/blood/splatter = 1,
	/obj/effect/decal/cleanable/blood/oil = 1,
	/obj/effect/decal/cleanable/fungus = 1)
	var/spawn_nothing_percentage = 0

// This needs to come before the initialization wave because
// the thing it creates might need to be initialized too
/obj/effect/spawner/random_spawners/New()
	. = ..()
	var/turf/T = get_turf(src)
	if(!T)
		log_runtime(EXCEPTION("Spawner placed in nullspace!"), src)
		return
	if(!prob(spawn_nothing_percentage))
		var/thing_to_place = pickweight(result)
		if(ispath(thing_to_place, /turf))
			T.ChangeTurf(thing_to_place)
		else
			new thing_to_place(T)
	qdel(src)

/obj/effect/spawner/random_spawners/blood_maybe
	name = "blood maybe"
	result = list(
	/turf/simulated/floor/plating = 20,
	/obj/effect/decal/cleanable/blood/splatter = 1)

/obj/effect/spawner/random_spawners/blood_often
	name = "blood often"
	result = list(
	/turf/simulated/floor/plating = 5,
	/obj/effect/decal/cleanable/blood/splatter = 1)

/obj/effect/spawner/random_spawners/oil_maybe
	name = "oil maybe"
	result = list(
	/turf/simulated/floor/plating = 20,
	/obj/effect/decal/cleanable/blood/oil = 1)

/obj/effect/spawner/random_spawners/oil_maybe
	name = "oil often"
	result = list(
	/turf/simulated/floor/plating = 5,
	/obj/effect/decal/cleanable/blood/oil = 1)

/obj/effect/spawner/random_spawners/wall_rusted_probably
	name = "rusted wall probably"
	result = list(
	/turf/simulated/wall = 2,
	/turf/simulated/wall/rust = 7)

/obj/effect/spawner/random_spawners/wall_rusted_maybe
	name = "rusted wall maybe"
	result = list(
	/turf/simulated/wall = 7,
	/turf/simulated/wall/rust = 1)

/obj/effect/spawner/random_spawners/cobweb_left_frequent
	name = "cobweb left frequent"
	result = list(
	/turf/simulated/floor/plating = 1,
	/obj/effect/decal/cleanable/cobweb = 1)

/obj/effect/spawner/random_spawners/cobweb_right_frequent
	name = "cobweb right frequent"
	result = list(
	/turf/simulated/floor/plating = 1,
	/obj/effect/decal/cleanable/cobweb2 = 1)

/obj/effect/spawner/random_spawners/cobweb_left_rare
	name = "cobweb left rare"
	result = list(
	/turf/simulated/floor/plating = 10,
	/obj/effect/decal/cleanable/cobweb = 1)

/obj/effect/spawner/random_spawners/cobweb_right_rare
	name = "cobweb right rare"
	result = list(
	/turf/simulated/floor/plating = 10,
	/obj/effect/decal/cleanable/cobweb2 = 1)

/obj/effect/spawner/random_spawners/dirt_frequent
	name = "dirt frequent"
	result = list(
	/turf/simulated/floor/plating = 1,
	/obj/effect/decal/cleanable/dirt = 1)

/obj/effect/spawner/random_spawners/dirt_rare
	name = "dirt rare"
	result = list(
	/turf/simulated/floor/plating = 10,
	/obj/effect/decal/cleanable/dirt = 1)

/obj/effect/spawner/random_spawners/fungus_maybe
	name = "rusted wall maybe"
	result = list(
	/turf/simulated/wall = 7,
	/obj/effect/decal/cleanable/fungus = 1)

/obj/effect/spawner/random_spawners/fungus_probably
	name = "rusted wall maybe"
	result = list(
	/turf/simulated/wall = 1,
	/obj/effect/decal/cleanable/fungus = 7)


// Used in depot on z6

/obj/effect/spawner/random_spawners/syndicate
	spawn_nothing_percentage = 50

// Turrets

/obj/effect/spawner/random_spawners/syndicate/turret
	name = "50pc int turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "syndieturret0"
	color = "#FF0000"
	result = list(
	/obj/machinery/porta_turret/syndicate/interior  = 1
	)

/obj/effect/spawner/random_spawners/syndicate/turret/external
	name = "50pc ext turret"
	result = list(
	/obj/machinery/porta_turret/syndicate/exterior  = 1
	)


// Mobs
/obj/effect/spawner/random_spawners/syndicate/mob
	name = "50pc melee syndimob"
	icon = 'icons/mob/animal.dmi'
	icon_state = "syndicatemelee"
	color = "#FF0000"
	result = list(
	/mob/living/simple_animal/hostile/syndicate/melee/autogib = 1
	)

// Traps

/obj/effect/spawner/random_spawners/syndicate/trap
	color = "#FF0000"

/obj/effect/spawner/random_spawners/syndicate/trap/pizzabomb
	name = "50pc trap pizza"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "pizzabox1"
	spawn_nothing_percentage = 0
	result = list(
	/obj/item/pizzabox/meat = 1,
	/obj/item/device/pizza_bomb/autoarm = 1
	)

/obj/effect/spawner/random_spawners/syndicate/trap/medbot
	name = "50pc trap medibot"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "medibot0"
	result = list(
	/mob/living/simple_animal/bot/medbot/syndicate/emagged = 1
	)

/obj/effect/spawner/random_spawners/syndicate/trap/mine
	name = "50pc trap landmine"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "uglyminearmed"
	result = list(
	/obj/effect/mine/explosive = 1
	)

/obj/effect/spawner/random_spawners/syndicate/trap/toolbox
	name = "50pc trap toolbox"
	icon = 'icons/obj/storage.dmi'
	icon_state = "syndicate"
	spawn_nothing_percentage = 0
	result = list(
	/obj/item/weapon/storage/toolbox/syndicate = 1,
	/obj/item/weapon/storage/toolbox/syndicate/trapped = 1
	)

/obj/effect/spawner/random_spawners/syndicate/trap/documents
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder_syellow"
	spawn_nothing_percentage = 0
	result = list(
	/obj/item/weapon/folder/syndicate/yellow = 1,
	/obj/item/weapon/folder/syndicate/yellow_trapped = 1
	)

// Loot

/obj/effect/spawner/random_spawners/syndicate/loot

/obj/effect/spawner/random_spawners/syndicate/loot/spacepod
	name = "50pc loot spacepod"
	icon = 'icons/goonstation/48x48/pods.dmi'
	icon_state = "pod_synd"
	result = list(
	/obj/spacepod/civilian = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/radiokey
	name = "50pc loot key"
	icon = 'icons/obj/radio.dmi'
	icon_state = "cypherkey"
	result = list(
	/obj/item/device/radio/headset/syndicate = 1,
	/obj/item/device/encryptionkey/syndicate = 1
	)


/obj/effect/spawner/random_spawners/syndicate/loot/jammer
	name = "50pc loot jammer"
	icon = 'icons/obj/device.dmi'
	icon_state = "jammer"
	result = list(
	/obj/item/device/jammer = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/spacepod
	name = "50pc loot spacepod"
	icon_state = "pod_civ"
	result = list(
	/obj/spacepod/civilian = 1
	)


/obj/effect/spawner/random_spawners/syndicate/loot/spacesuit
	name = "50pc loot spacesuit kit"
	icon = 'icons/obj/storage.dmi'
	icon_state = "box_of_doom"
	result = list(
	/obj/item/weapon/storage/box/syndie_kit/space = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/thermals
	name = "50pc loot thermals"
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "thermal"
	result = list(
	/obj/item/clothing/glasses/thermal = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/armor
	name = "50pc loot armor"
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "armor-combat"
	result = list(
	/obj/item/clothing/suit/armor/vest/combat = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/cigs
	name = "50pc loot cigs"
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "syndiepacket"
	result = list(
	/obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/pistol
	name = "50pc loot stechkin pistol"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "pistol"
	result = list(
	/obj/item/weapon/gun/projectile/automatic/pistol = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/ammo10mm
	name = "50pc loot 10mm ammo"

	icon_state = "9x19p"
	result = list(
	/obj/item/ammo_box/magazine/m10mm = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/m90
	name = "50pc loot m90 auto carbine"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "m90"
	result = list(
	/obj/item/weapon/gun/projectile/automatic/m90 = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/m90ammo
	name = "50pc loot ammo for m90"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "a762-50"
	result = list(
	/obj/item/ammo_box/magazine/m556 = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/camoprojector
	name = "50pc loot camo projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	result = list(
	/obj/item/device/chameleon = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/medicalkit
	name = "medkit 50pc tactical"
	icon = 'icons/obj/storage.dmi'
	icon_state = "bezerk"
	spawn_nothing_percentage = 0
	result = list(
	/obj/item/weapon/storage/firstaid = 1,
	/obj/item/weapon/storage/firstaid/tactical = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/cyborg
	name = "cyborg 50pc borgupgrade"
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade3"
	result = list(
	/obj/item/weapon/stock_parts/cell/bluespace = 1,
	/obj/item/borg/upgrade/vtec = 1,
	/obj/item/borg/upgrade/syndicate = 1,
	/obj/item/borg/upgrade/selfrepair = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/drugs
	name = "medical 50pc drugs"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pill4"
	result = list(
	/obj/item/weapon/storage/pill_bottle/happy = 1,
	/obj/item/weapon/storage/pill_bottle/zoom = 1,
	/obj/item/weapon/storage/pill_bottle/random_drug_bottle = 3
	)

/obj/effect/spawner/random_spawners/syndicate/loot/minerals
	name = "minerals 75pc"
	icon = 'icons/obj/items.dmi'
	icon_state = "sheet-gold"
	spawn_nothing_percentage = 25
	result = list(
	/obj/item/stack/sheet/mineral/diamond = 1,
	/obj/item/stack/sheet/mineral/uranium = 1,
	/obj/item/stack/sheet/mineral/plasma = 1,
	/obj/item/stack/sheet/mineral/silver = 1,
	/obj/item/stack/sheet/mineral/gold = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/shoes
	name = "shoes 50pc"
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "brown"
	spawn_nothing_percentage = 50
	result = list(
	/obj/item/clothing/shoes/syndigaloshes = 1
	)

/obj/effect/spawner/random_spawners/syndicate/loot/rcd
	name = "rcd 50pc"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	result = list(
	/obj/item/weapon/rcd_ammo = 1,
	/obj/item/weapon/rcd = 1
	)

// Key layout features

/obj/effect/spawner/random_spawners/syndicate/layout
	color = "#0000FF"

/obj/effect/spawner/random_spawners/syndicate/layout/door
	name = "50pc door 25pc falsewall 25pc wall"
	icon = 'icons/obj/doors/Doorhatchele.dmi'
	icon_state = "door_closed"
	spawn_nothing_percentage = 0
	result = list(
	/obj/machinery/door/airlock/hatch/syndicate = 2,
	/turf/simulated/wall/r_wall = 1,
	/obj/structure/falsewall/reinforced = 1
	)

/obj/effect/spawner/random_spawners/syndicate/layout/telebeacon
	name = "50pc feature telebeacon"
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beaconf"
	result = list(
	/obj/machinery/bluespace_beacon/syndicate = 1
	)
