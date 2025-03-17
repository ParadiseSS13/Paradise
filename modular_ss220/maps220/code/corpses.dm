/* For Black Market Packers gateway */
/obj/effect/mob_spawn/human/corpse/tacticool
	mob_type = /mob/living/carbon/human
	name = "Tacticool corpse"
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "tactifool"
	mob_name = "Unknown"
	random = TRUE
	death = TRUE
	disable_sensors = TRUE
	outfit = /datum/outfit/packercorpse

/datum/outfit/packercorpse
	name = "Packer Corpse"
	uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/storage/backpack
	l_ear = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/black

/obj/effect/mob_spawn/human/corpse/tacticool/Initialize(mapload)
	brute_damage = rand(0, 400)
	burn_damage = rand(0, 400)
	return ..()

/obj/effect/mob_spawn/human/corpse/syndicatesoldier/trader
	name = "Syndi trader corpse"
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "tactifool"
	random = TRUE
	disable_sensors = TRUE
	outfit = /datum/outfit/syndicatetrader

/datum/outfit/syndicatetrader
	uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/black/forensics
	belt = /obj/item/gun/projectile/automatic/pistol
	mask = /obj/item/clothing/mask/balaclava
	suit = /obj/item/clothing/suit/armor/vest/combat

/obj/effect/mob_spawn/human/corpse/syndicatesoldier/trader/Initialize(mapload)
	brute_damage = rand(150, 500)
	burn_damage = rand(100, 300)
	return ..()

// MARK: Spacebattle
/obj/effect/mob_spawn/human/corpse/spacebattle
	var/list/pocketloot = list(
		/obj/item/storage/fancy/cigarettes/cigpack_robust,
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

/datum/outfit/spacebattle
	box = /obj/item/storage/box/survival

/obj/effect/mob_spawn/human/corpse/spacebattle/assistant
	name = "Dead Civilian"
	mob_name = "Ship Personnel"
	outfit = /datum/outfit/spacebattle/assistant

/datum/outfit/spacebattle/assistant
	id = /obj/item/card/id/away/old
	uniform = /obj/item/clothing/under/color/random
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/satchel_norm

/obj/effect/mob_spawn/human/corpse/spacebattle/security
	name = "Dead Officer"
	mob_name = "Ship Officer"
	outfit = /datum/outfit/spacebattle/security

/datum/outfit/spacebattle/security
	id = /obj/item/card/id/away/old/sec
	uniform = /obj/item/clothing/under/retro/security
	suit = /obj/item/clothing/suit/armor/vest/security
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/helmet
	gloves = /obj/item/clothing/gloves/fingerless
	back = /obj/item/storage/backpack/satchel_sec

/datum/outfit/spacebattle/security/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	switch(rand(1,10))
		if(1 to 7)
			suit_store = /obj/item/gun/projectile/automatic/wt550
			backpack_contents += /obj/item/ammo_box/magazine/wt550m9
		if(8 to 9)
			suit_store = /obj/item/gun/projectile/shotgun/lethal
			backpack_contents += /obj/item/storage/fancy/shell/buck
		if(10)
			suit_store = /obj/item/gun/projectile/automatic/pistol/enforcer/lethal

/datum/outfit/spacebattle/security/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H?.w_uniform)
		var/obj/item/clothing/under/U = H.w_uniform
		var/obj/item/clothing/accessory/holster/waist/W = new /obj/item/clothing/accessory/holster/waist(U)
		U.accessories += W
		W.on_attached(U)

/obj/effect/mob_spawn/human/corpse/spacebattle/security/bridge
	name = "Dead Bridge Officer"
	mob_name = "Bridge Officer"
	outfit = /datum/outfit/spacebattle/security/bridge

/datum/outfit/spacebattle/security/bridge
	uniform = /obj/item/clothing/under/rank/procedure/blueshield
	shoes = /obj/item/clothing/shoes/combat
	head = /obj/item/clothing/head/helmet/night
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/satchel
	backpack_contents = list(
		/obj/item/reagent_containers/patch/silver_sulf/small,
		/obj/item/reagent_containers/patch/styptic/small,
		/obj/item/stock_parts/cell/high,
	)

/obj/effect/mob_spawn/human/corpse/spacebattle/engineer
	name = "Dead Engineer"
	mob_name = "Engineer"
	outfit = /datum/outfit/spacebattle/engineer

/datum/outfit/spacebattle/engineer
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
	box = /obj/item/storage/box/engineer

/datum/outfit/spacebattle/engineer/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	switch(rand(1,3))
		if(1)
			backpack_contents += list(
			/obj/item/clothing/head/welding,
			/obj/item/weldingtool/largetank,
			/obj/item/stack/sheet/metal{amount = 10},
			/obj/item/stack/rods{amount = 3},
			)
		if(2)
			backpack_contents += list(
			/obj/item/apc_electronics,
			/obj/item/stock_parts/cell/high,
			/obj/item/t_scanner,
			/obj/item/stack/cable_coil{amount = 7},
			)
		if(3)
			backpack_contents += list(
			/obj/item/storage/briefcase/inflatable,
			/obj/item/stack/sheet/glass{amount = 5},
			/obj/item/grenade/gas/oxygen,
			/obj/item/analyzer,
			)

/obj/effect/mob_spawn/human/corpse/spacebattle/engineer/space
	outfit = /datum/outfit/spacebattle/engineer/space

/datum/outfit/spacebattle/engineer/space
	suit = null
	head = null
	back = /obj/item/mod/control/pre_equipped/prototype/spacebattle

/obj/effect/mob_spawn/human/corpse/spacebattle/medic
	name = "Dead Medic"
	mob_name = "Medic"
	outfit = /datum/outfit/spacebattle/medic

/datum/outfit/spacebattle/medic
	id = /obj/item/card/id/away/old/med
	uniform = /obj/item/clothing/under/retro/medical
	neck = /obj/item/clothing/neck/stethoscope
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/white
	back = /obj/item/storage/backpack/satchel_med
	backpack_contents = list(
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/pill_bottle/random_drug_bottle = 1,
		)

/obj/effect/mob_spawn/human/corpse/spacebattle/scientist
	name = "Dead Scientist"
	mob_name = "Scientist"
	outfit = /datum/outfit/spacebattle/scientist

/datum/outfit/spacebattle/scientist
	id = /obj/item/card/id/away/old/sci
	uniform = /obj/item/clothing/under/retro/science
	shoes = /obj/item/clothing/shoes/black
	suit = /obj/item/clothing/suit/storage/labcoat/science
	back = /obj/item/storage/backpack/satchel_tox

/datum/outfit/spacebattle/scientist/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(prob(1))
		backpack_contents += pick(
			// jackpot
			/obj/item/assembly/signaler/anomaly/pyro,
			/obj/item/assembly/signaler/anomaly/cryo,
			/obj/item/assembly/signaler/anomaly/grav,
			/obj/item/assembly/signaler/anomaly/flux,
			/obj/item/assembly/signaler/anomaly/bluespace,
			/obj/item/assembly/signaler/anomaly/vortex,
			)

/obj/effect/mob_spawn/human/corpse/spacebattle/scientist/mc16
	outfit = /datum/outfit/spacebattle/scientist/mc16

/datum/outfit/spacebattle/scientist/mc16
	id = /obj/item/card/id/away/old/sci/mc16

/obj/item/card/id/away/old/sci/mc16
	name = "MC-16 multicard"
	desc = "A clip on ID Badge, has one of those fancy new magnetic strips built in."
