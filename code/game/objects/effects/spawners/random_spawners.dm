/obj/effect/spawner/random_spawners
	name = "random spawners"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	var/list/result = list(
	/turf/simulated/floor/plasteel = 1,
	/turf/simulated/floor/plating = 1,
	/obj/effect/decal/cleanable/blood/splatter = 1,
	/obj/effect/decal/cleanable/blood/oil = 1,
	/obj/effect/decal/cleanable/fungus = 1)
	var/spawn_inside = null

// This needs to use New() instead of Initialize() because the thing it creates might need to be initialized too
/obj/effect/spawner/random_spawners/New()
	. = ..()
	var/turf/T = get_turf(src)
	if(!T)
		log_runtime(EXCEPTION("Spawner placed in nullspace!"), src)
		return
	randspawn(T)

/obj/effect/spawner/random_spawners/proc/randspawn(turf/T)
	var/thing_to_place = pickweight(result)
	if(ispath(thing_to_place, /datum/nothing))
		// Nothing.
	else if(ispath(thing_to_place, /turf))
		T.ChangeTurf(thing_to_place)
	else
		if(ispath(spawn_inside, /obj))
			var/obj/O = new thing_to_place(T)
			var/obj/E = new spawn_inside(T)
			O.forceMove(E)
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



// z6 DEPOT SPAWNERS

/obj/effect/spawner/random_spawners/syndicate



// Turrets

/obj/effect/spawner/random_spawners/syndicate/turret
	name = "50pc int turret"
	icon_state = "x"
	result = list(/datum/nothing = 1,
		/obj/machinery/porta_turret/syndicate/interior = 1)

/obj/effect/spawner/random_spawners/syndicate/turret/external
	name = "50pc ext turret"
	result = list(/datum/nothing = 1,
		/obj/machinery/porta_turret/syndicate/exterior = 1)


// Mobs

/obj/effect/spawner/random_spawners/syndicate/mob
	name = "50pc melee syndimob"
	icon_state = "x"
	color = "#333333"
	result = list(/datum/nothing = 1,
		/mob/living/simple_animal/hostile/syndicate/melee/autogib/depot = 1)


// Traps

/obj/effect/spawner/random_spawners/syndicate/trap
	icon_state = "x"
	color = "#000000"

/obj/effect/spawner/random_spawners/syndicate/trap/pizzabomb
	name = "50pc trap pizza"
	result = list(/obj/item/pizzabox/meat = 1,
		/obj/item/pizzabox/hawaiian = 1,
		/obj/item/pizza_bomb/autoarm = 1)

/obj/effect/spawner/random_spawners/syndicate/trap/medbot
	name = "50pc trap medibot"
	result = list(/datum/nothing = 1,
		/mob/living/simple_animal/bot/medbot/syndicate/emagged = 1)

/obj/effect/spawner/random_spawners/syndicate/trap/mine
	name = "50pc trap landmine"
	result = list(/datum/nothing = 1,
		/obj/effect/mine/depot = 1)

/obj/effect/spawner/random_spawners/syndicate/trap/documents
	name = "66pc trapped documents"
	result = list(/obj/item/documents/syndicate/yellow = 1,
		/obj/item/documents/syndicate/yellow/trapped = 1)




// Loot

/obj/effect/spawner/random_spawners/syndicate/loot
	name = "common loot"
	icon_state = "x3"
	spawn_inside = /obj/structure/closet/secure_closet/syndicate/depot
	// Loot schema: costumes, toys, useless gimmick items
	result = list(/datum/nothing = 13,
		/obj/item/storage/toolbox/syndicate = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/item/toy/cards/deck/syndicate = 1,
		/obj/item/storage/secure/briefcase/syndie = 1,
		/obj/item/toy/syndicateballoon = 1,
		/obj/item/soap/syndie = 1,
		/obj/item/clothing/under/syndicate = 1,
		/obj/item/clothing/under/syndicate/tacticool = 1,
		/obj/item/clothing/mask/gas/syndicate = 1,
		/obj/item/suppressor = 1,
		/obj/item/coin/antagtoken/syndicate = 1,
		/obj/item/storage/box/syndie_kit/cutouts = 1)

/obj/effect/spawner/random_spawners/syndicate/loot/stetchkin
	name = "20pc stetchkin"
	icon_state = "x3"
	spawn_inside = null
	result = list(/datum/nothing = 1,
		/obj/item/wrench = 1,
		/obj/item/reagent_containers/food/snacks/syndicake = 1,
		/obj/item/coin/antagtoken/syndicate = 1,
		/obj/item/gun/projectile/automatic/pistol = 1)

/obj/effect/spawner/random_spawners/syndicate/loot/level2
	name = "rare loot"
	// Loot schema: space gear, basic armor, basic ammo (10mm, rcd), drugs, more dangerous/useful gimmick items, lower-value minerals
	result = list(/datum/nothing = 27,
		/obj/item/storage/box/syndie_kit/space = 1,
		/obj/item/storage/box/syndie_kit/hardsuit = 1,
		/obj/item/clothing/shoes/magboots/syndie = 1,
		/obj/item/clothing/suit/armor/vest/combat = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/storage/pill_bottle/happy = 1,
		/obj/item/storage/pill_bottle/zoom = 1,
		/obj/item/storage/pill_bottle/random_drug_bottle = 2,
		/obj/item/storage/backpack/duffel/syndie/surgery = 1,
		/obj/item/clothing/shoes/chameleon/noslip = 1,
		/obj/item/storage/belt/military = 1,
		/obj/item/clothing/under/chameleon = 1,
		/obj/item/storage/backpack/satchel_flat = 1,
		/obj/item/rcd = 1,
		/obj/item/rcd_ammo = 1,
		/obj/item/stamp/chameleon = 1,
		/obj/item/flag/chameleon = 1,
		/obj/item/lighter/zippo/gonzofist = 1,
		/obj/item/clothing/gloves/fingerless/rapid = 1,
		/obj/item/grenade/spawnergrenade/manhacks = 1,
		/obj/item/grenade/syndieminibomb = 1,
		/obj/item/storage/box/syndie_kit/throwing_weapons = 1,
		/obj/item/pen/edagger = 1,
		/obj/item/stack/sheet/mineral/plasma{amount = 20} = 1,
		/obj/item/stack/sheet/mineral/silver{amount = 20} = 1,
		/obj/item/stack/sheet/mineral/gold{amount = 20} = 1)

/obj/effect/spawner/random_spawners/syndicate/loot/level3
	name = "officer loot"
	// Loot schema: medkits, very useful devices (jammer, illegal upgrade, RCD), better quality ammo (AP, fire), basic weapons (pistol, empgrenade), high value ores (diamond, uranium)
	result = list(/datum/nothing = 25,
		/obj/item/jammer = 1,
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/box/syndie_kit/bonerepair = 1,
		/obj/item/gun/projectile/automatic/pistol = 1,
		/obj/item/stock_parts/cell/bluespace = 1,
		/obj/item/card/emag = 1,
		/obj/item/encryptionkey/binary = 1,
		/obj/item/pinpointer/advpinpointer = 1,
		/obj/item/borg/upgrade/vtec = 1,
		/obj/item/borg/upgrade/syndicate = 1,
		/obj/item/borg/upgrade/selfrepair = 1,
		/obj/item/stack/sheet/mineral/diamond{amount = 10} = 1,
		/obj/item/stack/sheet/mineral/uranium{amount = 10} = 1,
		/obj/item/clothing/shoes/magboots/syndie/advance = 1,
		/obj/item/grenade/empgrenade = 1,
		/obj/item/grenade/clown_grenade = 1,
		/obj/item/grenade/spawnergrenade/feral_cats = 1,
		/obj/item/ammo_box/magazine/m10mm/ap = 1,
		/obj/item/ammo_box/magazine/m10mm/fire = 1,
		/obj/item/ammo_box/magazine/m10mm/hp = 1,
		/obj/item/rad_laser = 1,
		/obj/item/storage/box/syndie_kit/emp = 1,
		/obj/item/batterer = 1,
		/obj/item/toy/carpplushie/dehy_carp = 1,
		/obj/item/clothing/glasses/hud/security/chameleon = 1)

/obj/effect/spawner/random_spawners/syndicate/loot/level4
	name = "armory loot"
	spawn_inside = /obj/structure/closet/secure_closet/syndicate/depot/armory
	// Loot schema: high-power weapons (m90, esword, ebow, revolver), devices that negate depot challenges (thermal glasses, chameleon device), explosives
	result = list(/obj/item/gun/projectile/automatic/c20r = 1,
		/obj/item/gun/projectile/automatic/m90 = 1,
		/obj/item/gun/projectile/automatic/sniper_rifle/syndicate = 1,
		/obj/item/melee/energy/sword/saber = 1,
		/obj/item/gun/energy/kinetic_accelerator/crossbow = 1,
		/obj/item/gun/projectile/revolver = 1,
		/obj/item/clothing/gloves/color/yellow/power = 1,
		/obj/item/twohanded/chainsaw = 1,
		/obj/item/bee_briefcase = 1,
		/obj/item/twohanded/energizedfireaxe = 1,
		/obj/item/clothing/glasses/thermal = 1,
		/obj/item/chameleon = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/stimulants = 1,
		/obj/item/storage/box/syndie_kit/atmosn2ogrenades = 1,
		/obj/item/grenade/plastic/x4 = 1)


// Layout-affecting spawns

/obj/effect/spawner/random_spawners/syndicate/layout
	icon_state = "x2"

/obj/effect/spawner/random_spawners/syndicate/layout/door
	name = "50pc door 25pc falsewall 25pc wall"
	result = list(/obj/machinery/door/airlock/hatch/syndicate = 6,
		/turf/simulated/wall/mineral/plastitanium/nodiagonal = 2,
		/obj/structure/falsewall/plastitanium = 2)

/obj/effect/spawner/random_spawners/syndicate/layout/door/secret
	name = "50pc falsewall 50pc wall"
	result = list(/turf/simulated/wall/mineral/plastitanium/nodiagonal = 1,
		/obj/structure/falsewall/plastitanium = 1)

/obj/effect/spawner/random_spawners/syndicate/layout/door/vault
	name = "80pc vaultdoor 20pc wall"
	result = list(/obj/machinery/door/airlock/hatch/syndicate/vault = 4,
		/turf/simulated/wall/mineral/plastitanium/nodiagonal = 1)


/obj/effect/spawner/random_spawners/syndicate/layout/spacepod
	name = "50pc loot spacepod"
	result = list(/obj/spacepod/syndi = 1,
		/obj/spacepod/syndi/unlocked = 1)