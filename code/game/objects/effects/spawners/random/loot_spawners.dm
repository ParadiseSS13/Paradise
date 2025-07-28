/obj/effect/spawner/random/loot
	name = "random loot spawner"

/obj/effect/spawner/random/loot/contraband_posters
	name = "5x contraband posters spawner"
	spawn_loot_count = 5
	loot = list(/obj/item/poster/random_contraband)

/obj/effect/spawner/random/loot/cryo_beakers
	name = "3x cryo beaker spawner"
	spawn_loot_count = 3
	loot = list(/obj/item/reagent_containers/glass/beaker/bluespace)

/obj/effect/spawner/random/loot/good_times
	name = "good times spawner"
	spawn_all_loot = TRUE
	loot = list(
		/obj/item/food/grown/ambrosia/deus,
		/obj/item/lighter,
		/obj/item/reagent_containers/drinks/bottle/rum,
		/obj/item/reagent_containers/drinks/bottle/whiskey,
	)

/obj/effect/spawner/random/loot/bank_robber
	name = "bank robber spawner"
	spawn_all_loot = TRUE
	loot = list(
		/obj/item/clothing/mask/balaclava,
		/obj/item/gun/projectile/automatic/pistol,
		/obj/item/ammo_box/magazine/m10mm,
	)

/obj/effect/spawner/random/loot/pet_uhhh_supplies
	name = "pet uhhh supplies spawner"
	spawn_all_loot = TRUE
	loot = list(
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/head/kitty,
		/obj/item/petcollar,
		/obj/item/petcollar,
		/obj/item/petcollar,
		/obj/item/petcollar,
		/obj/item/petcollar,
	)

/obj/effect/spawner/random/loot/coins
	name = "coins spawner"
	loot = list(
		/obj/item/coin/silver = 3,
		/obj/item/coin/iron = 3,
		/obj/item/coin/gold = 1,
		/obj/item/coin/diamond = 1,
		/obj/item/coin/plasma = 1,
		/obj/item/coin/uranium = 1,
	)

/obj/effect/spawner/random/loot/coins/Initialize(mapload)
	spawn_loot_count = rand(4, 7)
	. = ..()

/obj/effect/spawner/random/loot/space_kit
	name = "space kit spawner"
	spawn_all_loot = TRUE
	loot = list(
		/obj/item/borg/upgrade/modkit/aoe/mobs,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/suit/space,
	)

/obj/effect/spawner/random/loot_crate
	name = "lootcrate spawner"
	icon_state = "crate_secure"
	spawn_inside = /obj/structure/closet/crate/secure/loot
	loot = list(
		/obj/effect/spawner/random/loot/contraband_posters = 5,
		/obj/effect/spawner/random/loot/cryo_beakers = 5,
		/obj/effect/spawner/random/loot/good_times = 5,
		/obj/effect/spawner/random/loot/outfit/cham_ties = 5,
		/obj/effect/spawner/random/loot/outfit/shorts = 5,
		/obj/item/melee/baton = 5,
		/obj/item/melee/skateboard/pro = 5,
		/obj/item/reagent_containers/glass/beaker/bluespace = 5,
		/obj/item/seeds/firelemon = 5,
		/obj/item/stack/ore/diamond/ten = 5,

		/obj/effect/spawner/random/loot/coins = 2,
		/obj/effect/spawner/random/loot/outfit/clown = 2,
		/obj/effect/spawner/random/loot/outfit/fancy = 2,
		/obj/effect/spawner/random/loot/outfit/ian_fan = 2,
		/obj/effect/spawner/random/loot/pet_uhhh_supplies = 2,
		/obj/effect/spawner/random/loot/space_kit = 2,
		/obj/effect/spawner/random/stock_parts = 2,
		/obj/effect/spawner/random/toy/mech_figure = 2,
		/obj/item/defibrillator/compact = 2,
		/obj/item/gun/energy/plasmacutter = 2,
		/obj/item/melee/classic_baton = 2,
		/obj/item/pickaxe/diamond = 2,
		/obj/item/pickaxe/drill = 2,
		/obj/item/pickaxe/drill/diamonddrill = 2,
		/obj/item/pickaxe/drill/jackhammer = 2,
		/obj/item/stack/ore/bluespace_crystal/five = 2,
		/obj/item/toy/balloon = 2,
		/obj/item/toy/katana = 2,
		/obj/item/toy/syndicateballoon = 2,

		/obj/effect/spawner/random/loot/bank_robber = 1,
		/obj/effect/spawner/random/loot/outfit/luchador = 1,
		/obj/effect/spawner/random/loot/outfit/mime = 1,
		/obj/item/clothing/head/bearpelt = 1,
		/obj/item/hand_tele = 1,
		/obj/item/katana = 1,
		/obj/item/melee/skateboard/hoverboard = 1,
		/obj/item/organ/internal/brain = 1,
		/obj/item/organ/internal/brain/xeno = 1,
		/obj/item/organ/internal/cyberimp/arm/katana = 1,
		/obj/item/soulstone/anybody = 1,
		/obj/item/weed_extract = 1,
	)

/obj/effect/spawner/random/loot_crate/rarely
	name = "lootcrate spawner, 20% chance"
	spawn_loot_chance = 20

/obj/effect/spawner/random/loot/bluespace_tap/food_mixed
	loot = list(
		/obj/effect/spawner/random/bluespace_tap/food_common = 6,
		/obj/effect/spawner/random/bluespace_tap/food_uncommon = 3,
		/obj/effect/spawner/random/bluespace_tap/food_rare,
	)

/obj/effect/spawner/random/syndie_mob_loot
	loot = list(
		/obj/item/reagent_containers/patch/styptic,
		/obj/item/reagent_containers/patch/silver_sulf,
		/obj/item/food/syndicake,
		/obj/item/food/donkpocket,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/mixed,
	)
