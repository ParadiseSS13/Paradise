/* Random food spawners */
/obj/effect/spawner/random/CCfood


/obj/effect/spawner/random/CCfood/dessert
	spawn_loot_count = 3
	loot = list(
		/obj/item/food/baguette,
		/obj/item/food/applepie,
		/obj/item/food/bananabreadslice,
		/obj/item/food/bananacakeslice,
		/obj/item/food/carrotcakeslice,
		/obj/item/food/croissant,
		/obj/item/reagent_containers/drinks/cans/cola,
		)

/obj/effect/spawner/random/CCfood/meat
	spawn_loot_count = 3
	loot = list(
		/obj/item/food/lasagna,
		/obj/item/food/burger/bigbite,
		/obj/item/food/fishandchips,
		/obj/item/food/fishburger,
		/obj/item/food/hotdog,
		/obj/item/food/meatpie,
		/obj/item/reagent_containers/drinks/cans/cola,
		)

/obj/effect/spawner/random/CCfood/alcohol
	spawn_loot_count = 1
	loot = list(
		/obj/item/reagent_containers/drinks/flask/detflask,
		/obj/item/reagent_containers/drinks/cans/tonic,
		/obj/item/reagent_containers/drinks/cans/thirteenloko,
		/obj/item/reagent_containers/drinks/cans/synthanol,
		/obj/item/reagent_containers/drinks/cans/space_mountain_wind,
		/obj/item/reagent_containers/drinks/cans/lemon_lime,
		)

/* Lootdrop */
/obj/effect/spawner/random/maintenance
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'

/obj/effect/spawner/random/trash
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'

/obj/effect/spawner/random/trash/Initialize(mapload)
	. = ..()
	loot += list(
		list(
			/obj/item/trash/bowl,
			/obj/item/trash/can,
			/obj/item/trash/candle,
			/obj/item/trash/candy,
			/obj/item/trash/cheesie,
			/obj/item/trash/chips,
			/obj/item/trash/fried_vox,
			/obj/item/trash/gum,
			/obj/item/trash/liquidfood,
			/obj/item/trash/pistachios,
			/obj/item/trash/plate,
			/obj/item/trash/popcorn,
			/obj/item/trash/raisins,
			/obj/item/trash/semki,
			/obj/item/trash/snack_bowl,
			/obj/item/trash/sosjerky,
			/obj/item/trash/spacetwinkie,
			/obj/item/trash/spentcasing,
			/obj/item/trash/syndi_cakes,
			/obj/item/trash/tapetrash,
			/obj/item/trash/tastybread,
			/obj/item/trash/tray,
			/obj/item/trash/waffles,
			/obj/item/trash/vulpix_chips,
			/obj/item/trash/foodtray,
		) = 5,
	)

// Office toys spawner
/obj/effect/spawner/random/officetoys
	name = "office desk toy spawner"
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "officetoy"
	loot = list(
		/obj/item/toy/desk/officetoy,
		/obj/item/toy/desk/dippingbird,
		/obj/item/toy/desk/newtoncradle,
		/obj/item/toy/desk/fan,
		/obj/item/hourglass
	)

/* Random spawners */
/obj/effect/spawner/random_spawners/mod
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "mod"

/obj/effect/spawner/random_spawners/syndicate/loot
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "common"

/obj/effect/spawner/random_spawners/syndicate/loot/level2
	icon_state = "rare"

/obj/effect/spawner/random_spawners/syndicate/loot/level3
	icon_state = "officer"

/obj/effect/spawner/random_spawners/syndicate/loot/level4
	icon_state = "armory"

/obj/effect/spawner/random_spawners/syndicate/loot/stetchkin
	icon_state = "stetchkin"

/obj/item/reagent_containers/pill/random_drugs
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "pills"

/obj/item/reagent_containers/pill/random_drugs/Initialize(mapload)
	icon = 'icons/obj/chemical.dmi'
	. = ..()

/obj/item/reagent_containers/drinks/bottle/random_drink
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "drinks"

/obj/item/reagent_containers/drinks/bottle/random_drink/Initialize(mapload)
	icon = 'icons/obj/drinks.dmi'
	. = ..()

/* Space Battle */
/obj/effect/mob_spawn/human/corpse/spacebattle
	var/list/pocketloot = list(/obj/item/storage/fancy/cigarettes/cigpack_robust,
		/obj/item/storage/fancy/cigarettes/cigpack_uplift,
		/obj/item/storage/fancy/cigarettes/cigpack_random,
		/obj/item/cigbutt,
		/obj/item/clothing/mask/cigarette/menthol,
		/obj/item/clothing/mask/cigarette,
		/obj/item/clothing/mask/cigarette/random,
		/obj/item/lighter/random,
		/obj/item/assembly/igniter,
		/obj/item/storage/fancy/matches,
		/obj/item/match,
		/obj/item/food/donut,
		/obj/item/food/candy/candybar,
		/obj/item/food/tastybread,
		/obj/item/reagent_containers/drinks/cans/dr_gibb,
		/obj/item/pen,
		/obj/item/screwdriver,
		/obj/item/stack/tape_roll,
		/obj/item/radio,
		/obj/item/coin,
		/obj/item/coin/twoheaded,
		/obj/item/coin/iron,
		/obj/item/coin/silver,
		/obj/item/flashlight,
		/obj/item/stock_parts/cell,
		/obj/item/paper/crumpled,
		/obj/item/extinguisher/mini,
		/obj/item/deck/cards,
		/obj/item/reagent_containers/pill/salbutamol,
		/obj/item/reagent_containers/patch/silver_sulf/small,
		/obj/item/reagent_containers/patch/styptic/small,
		/obj/item/reagent_containers/pill/salicylic,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/weldingtool/mini,
		/obj/item/flashlight/flare/glowstick/emergency,
		/obj/item/flashlight/flare,
		/obj/item/toy/crayon/white,
		)

/obj/effect/mob_spawn/human/corpse/spacebattle/Initialize(mapload)
	l_pocket = pick(pocketloot)
	r_pocket = pick(pocketloot)
	return ..()

/obj/effect/mob_spawn/human/corpse/spacebattle/assistant
	name = "Dead Civilian"
	mob_name = "Ship Personnel"
	id = /obj/item/card/id/away/old
	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/black

/obj/effect/mob_spawn/human/corpse/spacebattle/security
	name = "Dead Officer"
	mob_name = "Ship Officer"
	id = /obj/item/card/id/away/old/sec
	uniform = /obj/item/clothing/under/retro/security
	belt = /obj/item/clothing/accessory/holster/waist
	suit = /obj/item/clothing/suit/armor/vest/security
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/helmet
	gloves = /obj/item/clothing/gloves/fingerless
	back = /obj/item/storage/backpack/satchel_sec

/obj/effect/mob_spawn/human/corpse/spacebattle/security/Initialize(mapload)
	var/secgun = rand(1,10)
	switch(secgun)
		//70%
		if(1 to 7)
			suit_store = /obj/item/gun/projectile/automatic/pistol/enforcer/lethal
			backpack_contents = list(
				/obj/item/storage/box/survival = 1,
				/obj/item/ammo_box/magazine/enforcer/lethal = 1
				)
		//20%
		if(8 to 9)
			suit_store = /obj/item/gun/projectile/automatic/wt550
			backpack_contents = list(
				/obj/item/storage/box/survival = 1,
				/obj/item/ammo_box/magazine/wt550m9 = 1
				)
		//10%
		if(10)
			suit_store = /obj/item/gun/projectile/shotgun/riot
			backpack_contents = list(
				/obj/item/storage/box/survival = 1,
				/obj/item/storage/fancy/shell/buck = 1
				)
	return ..()

/obj/effect/mob_spawn/human/corpse/spacebattle/engineer
	name = "Dead Engineer"
	mob_name = "Engineer"
	id = /obj/item/card/id/away/old/eng
	uniform = /obj/item/clothing/under/retro/engineering
	belt = /obj/item/storage/belt/utility/full
	suit = /obj/item/clothing/suit/storage/hazardvest
	shoes = /obj/item/clothing/shoes/workboots
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/hardhat/orange
	glasses = /obj/item/clothing/glasses/meson
	suit_store = /obj/item/tank/internals/emergency_oxygen/engi
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	back = /obj/item/storage/backpack/duffel/engineering
	backpack_contents = /obj/item/storage/box/engineer

/obj/effect/mob_spawn/human/corpse/spacebattle/engineer/Initialize(mapload)
	var/engstaff = rand(1,3)
	switch(engstaff)
		if(1)
			backpack_contents = list(
			/obj/item/clothing/head/welding = 1,
			/obj/item/weldingtool/largetank = 1,
			/obj/item/stack/sheet/metal{amount = 10} = 1,
			/obj/item/stack/rods{amount = 3} = 1
			)
		if(2)
			backpack_contents = list(
			/obj/item/apc_electronics = 1,
			/obj/item/stock_parts/cell/high = 1,
			/obj/item/t_scanner = 1,
			/obj/item/stack/cable_coil{amount = 7} = 1
			)
		if(3)
			backpack_contents = list(
			/obj/item/storage/briefcase/inflatable = 1,
			/obj/item/stack/sheet/glass{amount = 5} = 1,
			/obj/item/grenade/gas/oxygen = 1,
			/obj/item/analyzer = 1
			)
	return ..()

/obj/effect/mob_spawn/human/corpse/spacebattle/engineer/space
	suit = /obj/item/clothing/suit/space/hardsuit/ancient
	head = /obj/item/clothing/head/helmet/space/hardsuit/ancient
	shoes = /obj/item/clothing/shoes/magboots

/obj/effect/mob_spawn/human/corpse/spacebattle/medic
	name = "Dead Medic"
	mob_name = "Medic"
	id = /obj/item/card/id/away/old/med
	uniform = /obj/item/clothing/under/retro/medical
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/white
	id = /obj/item/card/id/medical
	back = /obj/item/storage/backpack/satchel_med

/obj/effect/mob_spawn/human/corpse/spacebattle/medic/Initialize(mapload)
	backpack_contents = list(
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/pill_bottle/random_drug_bottle = 1,
		)
	return ..()

/obj/effect/mob_spawn/human/corpse/spacebattle/bridgeofficer
	name = "Bridge Officer"
	mob_name = "Bridge Officer"
	id = /obj/item/card/id/away/old/sec
	uniform = /obj/item/clothing/under/rank/procedure/blueshield{name = "Bridge Officer uniform"}
	belt = /obj/item/clothing/accessory/holster/waist
	suit = /obj/item/clothing/suit/armor/vest/security
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/helmet/night
	gloves = /obj/item/clothing/gloves/fingerless
	back = /obj/item/storage/backpack/satchel

/obj/effect/mob_spawn/human/corpse/spacebattle/bridgeofficer/Initialize(mapload)
	backpack_contents = list(
		/obj/item/reagent_containers/patch/silver_sulf/small,
		/obj/item/reagent_containers/patch/styptic/small,
		/obj/item/stock_parts/cell/high = 1,
		/obj/item/storage/fancy/shell/buck = 1
		)
	return ..()

/obj/effect/mob_spawn/human/corpse/spacebattle/scientist
	name = "Dead Scientist"
	mob_name = "Scientist"
	id = /obj/item/card/id/away/old/sci
	uniform = /obj/item/clothing/under/retro/science
	shoes = /obj/item/clothing/shoes/black
	suit = /obj/item/clothing/suit/storage/labcoat/science
