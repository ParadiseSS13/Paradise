/obj/effect/spawner/random_spawners
	name = "random spawners"
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "questionmark"
	var/list/result = list(
	/datum/nothing = 1,
	/obj/effect/decal/cleanable/blood/splatter = 1,
	/obj/effect/decal/cleanable/blood/oil = 1,
	/obj/effect/decal/cleanable/fungus = 1)
	var/spawn_inside = null

// This needs to use New() instead of Initialize() because the thing it creates might need to be initialized too
// AA 2022-08-11: The above comment doesnt even make sense. If extra atoms are loaded during SSatoms.Initialize(), they still get initialised!
/obj/effect/spawner/random_spawners/New()
	. = ..()
	var/turf/T = get_turf(src)
	if(!T)
		stack_trace("Spawner placed in nullspace!")
		return
	randspawn(T)

/obj/effect/spawner/random_spawners/proc/randspawn(turf/T)
	var/thing_to_place = pickweight(result)
	if(ispath(thing_to_place, /datum/nothing))
		// Nothing.
		qdel(src) // See line 13, this needs moving to /Initialize() so we can use the qdel hint already
		return
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
	icon_state = "blood"
	result = list(
	/datum/nothing = 20,
	/obj/effect/decal/cleanable/blood/splatter = 1)

/obj/effect/spawner/random_spawners/blood_often
	name = "blood often"
	icon_state = "blood"
	result = list(
	/datum/nothing = 5,
	/obj/effect/decal/cleanable/blood/splatter = 1)

/obj/effect/spawner/random_spawners/oil_maybe
	name = "oil maybe"
	icon_state = "oil"
	result = list(
	/datum/nothing = 20,
	/obj/effect/decal/cleanable/blood/oil = 1)

/obj/effect/spawner/random_spawners/oil_often
	name = "oil often"
	icon_state = "oil"
	result = list(
	/datum/nothing = 5,
	/obj/effect/decal/cleanable/blood/oil = 1)

/obj/effect/spawner/random_spawners/proc/rustify(turf/T)
	var/turf/simulated/wall/W = T
	if(istype(W) && !W.rusted)
		W.rust()

/obj/effect/spawner/random_spawners/wall_rusted_probably
	name = "rusted wall probably"
	icon_state = "rust"

/obj/effect/spawner/random_spawners/wall_rusted_probably/randspawn(turf/T)
	if(prob(75))
		rustify(T)
	qdel(src)

/obj/effect/spawner/random_spawners/wall_rusted_maybe
	name = "rusted wall maybe"
	icon_state = "rust"

/obj/effect/spawner/random_spawners/wall_rusted_maybe/randspawn(turf/T)
	if(prob(25))
		rustify(T)
	qdel(src)

/obj/effect/spawner/random_spawners/wall_rusted_always
	name = "rusted wall always"
	icon_state = "rust"

/obj/effect/spawner/random_spawners/wall_rusted_always/randspawn(turf/T)
	rustify(T)
	qdel(src)

/obj/effect/spawner/random_spawners/cobweb_left_frequent
	name = "cobweb left frequent"
	icon_state = "cobwebl"
	result = list(
	/datum/nothing = 1,
	/obj/effect/decal/cleanable/cobweb = 1)

/obj/effect/spawner/random_spawners/cobweb_right_frequent
	name = "cobweb right frequent"
	icon_state = "cobwebr"
	result = list(
	/datum/nothing = 1,
	/obj/effect/decal/cleanable/cobweb2 = 1)

/obj/effect/spawner/random_spawners/cobweb_left_rare
	name = "cobweb left rare"
	icon_state = "cobwebl"
	result = list(
	/datum/nothing = 10,
	/obj/effect/decal/cleanable/cobweb = 1)

/obj/effect/spawner/random_spawners/cobweb_right_rare
	name = "cobweb right rare"
	icon_state = "cobwebr"
	result = list(
	/datum/nothing = 10,
	/obj/effect/decal/cleanable/cobweb2 = 1)

/obj/effect/spawner/random_spawners/dirt_frequent
	name = "dirt frequent"
	icon_state = "dirt"
	result = list(
	/datum/nothing = 1,
	/obj/effect/decal/cleanable/dirt = 1)

/obj/effect/spawner/random_spawners/dirt_often
	name = "dirt often"
	icon_state = "dirt"
	result = list(
	/datum/nothing = 5,
	/obj/effect/decal/cleanable/dirt = 1)

/obj/effect/spawner/random_spawners/dirt_maybe
	name = "dirt maybe"
	icon_state = "dirt"
	result = list(
	/datum/nothing = 7,
	/obj/effect/decal/cleanable/dirt = 1)

/obj/effect/spawner/random_spawners/fungus_maybe
	name = "fungus maybe"
	icon_state = "fungus"
	color = "#D5820B"
	result = list(
		/datum/nothing = 7,
		/obj/effect/decal/cleanable/fungus = 1)

/obj/effect/spawner/random_spawners/fungus_probably
	name = "fungus probably"
	icon_state = "fungus"
	color = "#D5820B"
	result = list(
		/datum/nothing = 1,
		/obj/effect/decal/cleanable/fungus = 7)

/obj/effect/spawner/random_spawners/mod
	name = "MOD module spawner"
	desc = "Modularize this, please."
	icon_state = "circuit"

/obj/effect/spawner/random_spawners/mod/maint
	name = "maint MOD module spawner"
	result = list(
		/obj/item/mod/module/springlock = 2,
		/obj/item/mod/module/balloon = 1,
		/obj/item/mod/module/stamp = 1
	)


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
	name = "33pc trap pizza"
	result = list(/obj/item/pizzabox/meat = 1,
		/obj/item/pizzabox/hawaiian = 1,
		/obj/item/pizzabox/margherita = 1,
		/obj/item/pizzabox/vegetable = 1,
		/obj/item/pizzabox/mushroom = 1,
		/obj/item/pizzabox/pepperoni = 7, //Higher weight as a pizza bomb looks like pepperoni by default
		/obj/item/pizzabox/garlic = 1,
		/obj/item/pizzabox/firecracker = 1,
		/obj/item/pizzabox/pizza_bomb/autoarm = 7)

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
		/obj/item/deck/cards/syndicate = 1,
		/obj/item/storage/secure/briefcase/syndie = 1,
		/obj/item/toy/syndicateballoon = 1,
		/obj/item/soap/syndie = 1,
		/obj/item/clothing/under/syndicate = 1,
		/obj/item/clothing/mask/gas/syndicate = 1,
		/obj/item/suppressor = 1,
		/obj/item/coin/antagtoken/syndicate = 1,
		/obj/item/storage/box/syndie_kit/space = 1,
		/obj/item/clothing/shoes/magboots/syndie = 1)

/obj/effect/spawner/random_spawners/syndicate/loot/stetchkin
	name = "20pc stetchkin"
	icon_state = "x3"
	spawn_inside = null
	result = list(/datum/nothing = 1,
		/obj/item/wrench = 1,
		/obj/item/food/snacks/syndicake = 1,
		/obj/item/coin/antagtoken/syndicate = 1,
		/obj/item/gun/projectile/automatic/pistol = 1)

/obj/effect/spawner/random_spawners/syndicate/loot/level2
	name = "rare loot"
	// Basic stealth, utility and environmental gear.
	result = list(/datum/nothing = 27,
		/obj/item/mod/control/pre_equipped/traitor = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/storage/backpack/duffel/syndie/med/surgery = 1,
		/obj/item/clothing/shoes/chameleon/noslip = 1,
		/obj/item/storage/belt/military = 1,
		/obj/item/clothing/under/chameleon = 1,
		/obj/item/storage/backpack/satchel_flat = 1,
		/obj/item/stamp/chameleon = 1,
		/obj/item/lighter/zippo/gonzofist = 1,
		/obj/item/stack/sheet/mineral/plasma{amount = 20} = 1,
		/obj/item/stack/sheet/mineral/silver{amount = 20} = 1,
		/obj/item/stack/sheet/mineral/gold{amount = 20} = 1,
		/obj/item/stack/sheet/mineral/uranium{amount = 20} = 1,
		/obj/item/mod/module/noslip = 1,
		/obj/item/mod/module/visor/night = 1,
		/obj/item/clothing/gloves/color/black/thief = 1,
		/obj/item/clothing/suit/storage/iaa/blackjacket/armored = 1,
		/obj/item/clothing/suit/jacket/bomber/syndicate = 1,
		/obj/item/mod/module/holster/hidden = 1,
		/obj/item/storage/firstaid/tactical = 1,
		/obj/item/clothing/under/syndicate/silicon_cham = 1,
		/obj/item/storage/box/syndie_kit/camera_bug = 1,
		/obj/item/gun/projectile/automatic/toy/pistol/riot = 1,
		/obj/item/flash/cameraflash = 1,
		/obj/item/mod/module/chameleon = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/nanocalcium = 1)

/obj/effect/spawner/random_spawners/syndicate/loot/level3
	name = "officer loot"
	// Primarily utility items with occasional low damage weaponry.
	result = list(/datum/nothing = 25,
		/obj/item/jammer = 1,
		/obj/item/encryptionkey/binary = 1,
		/obj/item/pinpointer/advpinpointer = 1,
		/obj/item/borg/upgrade/syndicate = 1,
		/obj/item/borg/upgrade/selfrepair = 1,
		/obj/item/storage/box/syndie_kit/stechkin = 1,
		/obj/item/stack/sheet/mineral/diamond{amount = 10} = 1,
		/obj/item/stack/sheet/mineral/uranium{amount = 10} = 1,
		/obj/item/clothing/shoes/magboots/elite = 1,
		/obj/item/clothing/glasses/hud/security/chameleon = 1,
		/obj/item/mod/module/visor/thermal = 1,
		/obj/item/mod/module/stealth = 1,
		/obj/item/mod/module/power_kick = 1,
		/obj/item/storage/box/syndidonkpockets = 1,
		/obj/item/pen/edagger = 1,
		/obj/item/door_remote/omni/access_tuner = 1,
		/obj/item/clothing/glasses/thermal = 1)


/obj/effect/spawner/random_spawners/syndicate/loot/level4
	name = "armory loot"
	spawn_inside = /obj/structure/closet/secure_closet/syndicate/depot/armory
	// Combat orientated items that could give the player an advantage if an antag messes with them.
	result = list(/obj/item/melee/energy/sword/saber = 1,
		/obj/item/autosurgeon/organ/syndicate/oneuse/razorwire = 1,
		/obj/item/chameleon = 1,
		/obj/item/CQC_manual = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/stimulants = 1,
		/obj/item/clothing/gloves/fingerless/rapid = 1,
		/obj/item/gun/medbeam = 1,
		/obj/item/shield/energy = 1,
		/obj/item/storage/box/syndie_kit/teleporter = 1,
		/obj/item/weaponcrafting/gunkit/universal_gun_kit = 1)


// Layout-affecting spawns

/obj/effect/spawner/random_spawners/syndicate/layout
	icon_state = "x2"

/obj/effect/spawner/random_spawners/syndicate/layout/door
	name = "50pc door 25pc falsewall 25pc wall"
	result = list(/obj/machinery/door/airlock/hatch/syndicate = 6,
		/turf/simulated/wall/mineral/plastitanium/nodiagonal = 2,
		/obj/structure/falsewall/plastitanium = 2)

/obj/effect/spawner/random_spawners/syndicate/layout/door/vault
	name = "80pc vaultdoor 20pc wall"
	result = list(/obj/machinery/door/airlock/hatch/syndicate/vault = 4,
		/turf/simulated/wall/mineral/plastitanium/nodiagonal = 1)
