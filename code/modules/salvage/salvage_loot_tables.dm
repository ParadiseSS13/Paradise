/datum/salvage_loot_table
	/// Weighted list of items to drop
	var/list/loot = list()

/datum/salvage_loot_table/salvage
	loot = list(
		/obj/item/salvage/salvage_component/common = 20,
		/obj/item/salvage/salvage_component/uncommon = 5,
		/obj/item/salvage/salvage_component/rare = 1,
		/obj/effect/spawner/random/trash = 5,
		/obj/effect/spawner/random/stock_parts = 5,
		/obj/effect/spawner/random/smithed_item/any = 5,
		/mob/living/basic/butterfly = 1
	)

/datum/salvage_loot_table/illegal // POLTODO
	loot = list(
		/obj/item/salvage/salvage_component/common = 20,
		/obj/item/salvage/salvage_component/uncommon = 5,
		/obj/item/salvage/salvage_component/rare = 1,
		/obj/item/ammo_box/magazine/m10mm = 2,
		/obj/item/melee/energy/sword/pirate = 5,
	)

/datum/salvage_loot_table/parts
	loot = list(
		/obj/item/salvage/salvage_component/common = 10,
		/obj/item/salvage/salvage_component/uncommon = 3,
		/obj/item/salvage/salvage_component/rare = 1,
		/obj/effect/spawner/random/stock_parts = 14,
		/obj/item/stock_parts/cell/high = 5,
		/obj/item/stock_parts/cell/super = 1,
		/obj/item/stock_parts/manipulator/nano = 5,
		/obj/item/stock_parts/manipulator/pico = 1,
		/obj/item/stock_parts/matter_bin/adv = 5,
		/obj/item/stock_parts/matter_bin/super = 1,
		/obj/item/stock_parts/micro_laser/high = 5,
		/obj/item/stock_parts/micro_laser/ultra = 1,
		/obj/item/stock_parts/scanning_module/adv = 5,
		/obj/item/stock_parts/scanning_module/phasic = 1,
		/obj/effect/spawner/random/engineering/misc = 5,
	)

/datum/salvage_loot_table/cooler
	loot = list(
		/obj/item/salvage/salvage_component/common = 10,
		/obj/item/salvage/salvage_component/uncommon = 3,
		/obj/item/salvage/salvage_component/rare = 1,
		/obj/effect/spawner/random/food_or_drink/soup = 20,
		/obj/effect/spawner/random/food_or_drink/dinner = 20,
		/obj/effect/spawner/random/food_or_drink/juice_boxes = 20,
		/obj/effect/spawner/random/food_or_drink/salad = 20,
	)

/datum/salvage_loot_table/lost
	loot = list(
		/obj/item/salvage/salvage_component/common = 10,
		/obj/item/salvage/salvage_component/uncommon = 3,
		/obj/item/salvage/salvage_component/rare = 1,
		/obj/effect/spawner/random/plushies = 10,
		/obj/effect/spawner/random/toy/action_figure = 10,
		/obj/effect/spawner/random/dice = 10,
		/mob/living/simple_animal/pet/dog/fox = 1,
		/mob/living/simple_animal/pet/dog/corgi = 1,
		/mob/living/simple_animal/pet/dog/pug = 1,
		/mob/living/simple_animal/pet/cat = 1,
	)

/datum/salvage_loot_table/service
	loot = list(
		/obj/item/salvage/salvage_component/common = 10,
		/obj/item/salvage/salvage_component/uncommon = 3,
		/obj/item/salvage/salvage_component/rare = 1,
		/obj/item/hatchet = 5,
		/obj/item/kitchen/knife = 5,
		/obj/item/kitchen/cutter = 5,
		/obj/item/card/id = 1,
		/obj/item/kitchen/utensil/spork = 2,
		/obj/effect/spawner/random/snacks = 5,
		/obj/effect/spawner/random/jani_supplies = 5,
		/obj/item/reagent_containers/drinks/bottle/holywater = 1,
		/obj/item/reagent_containers/drinks/bottle/random_drink = 2
	)

/datum/salvage_loot_table/industrial
	loot = list(
		/obj/item/salvage/salvage_component/common = 5,
		/obj/item/salvage/salvage_component/uncommon = 10,
		/obj/item/salvage/salvage_component/rare = 2,
	)

/datum/salvage_loot_table/freezer
	loot = list(
		/obj/item/salvage/salvage_component/common = 5,
		/obj/item/salvage/salvage_component/uncommon = 10,
		/obj/item/salvage/salvage_component/rare = 2,
	)

/datum/salvage_loot_table/med
	loot = list(
		/obj/item/salvage/salvage_component/common = 5,
		/obj/item/salvage/salvage_component/uncommon = 10,
		/obj/item/salvage/salvage_component/rare = 2,
	)

/datum/salvage_loot_table/backlog
	loot = list(
		/obj/item/salvage/salvage_component/common = 5,
		/obj/item/salvage/salvage_component/uncommon = 10,
		/obj/item/salvage/salvage_component/rare = 2,
	)

/datum/salvage_loot_table/clown
	loot = list(
		/obj/item/salvage/salvage_component/common = 5,
		/obj/item/salvage/salvage_component/uncommon = 10,
		/obj/item/salvage/salvage_component/rare = 2,
	)

/datum/salvage_loot_table/hazmat
	loot = list(
		/obj/item/salvage/salvage_component/common = 1,
		/obj/item/salvage/salvage_component/uncommon = 5,
		/obj/item/salvage/salvage_component/rare = 5,
	)

/datum/salvage_loot_table/unstable
	loot = list(
		/obj/item/salvage/salvage_component/common = 1,
		/obj/item/salvage/salvage_component/uncommon = 5,
		/obj/item/salvage/salvage_component/rare = 5,
	)

/datum/salvage_loot_table/contain
	loot = list(
		/obj/item/salvage/salvage_component/common = 1,
		/obj/item/salvage/salvage_component/uncommon = 5,
		/obj/item/salvage/salvage_component/rare = 5,
	)

/datum/salvage_loot_table/live
	loot = list(
		/obj/item/salvage/salvage_component/common = 1,
		/obj/item/salvage/salvage_component/uncommon = 5,
		/obj/item/salvage/salvage_component/rare = 5,
	)

/datum/salvage_loot_table/exotic
	loot = list(

	)

/datum/salvage_loot_table/dno
	loot = list(

	)


/datum/salvage_loot_table/bluespace
	loot = list(

	)


/datum/salvage_loot_table/ancient
	loot = list(

	)


/datum/salvage_loot_table/deposit
	loot = list(

	)


/datum/salvage_loot_table/pandora
	loot = list(

	)

