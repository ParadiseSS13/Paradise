/datum/supply_packs/misc
	name = "HEADER"

/datum/supply_packs/misc/mule
	name = "MULEbot Crate"
	contains = list(/mob/living/simple_animal/bot/mulebot)
	cost = 250
	containertype = /obj/structure/largecrate/mule
	containername = "\improper MULEbot crate"
	department_restrictions = list(DEPARTMENT_SUPPLY)

/datum/supply_packs/misc/loader
	name = "Loader MODsuit Crate"
	contains = list(/obj/item/mod/control/pre_equipped/loader)
	cost = 750 //Unique, expencive. Better sell that plasma
	containertype = /obj/structure/largecrate
	containername = "\improper Loader MODsuit crate"
	department_restrictions = list(DEPARTMENT_SUPPLY)

/datum/supply_packs/misc/hightank
	name = "High-Capacity Water Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/watertank/high)
	cost = 100
	containertype = /obj/structure/largecrate
	containername = "high-capacity water tank crate"

/datum/supply_packs/misc/lasertag
	name = "Laser Tag Crate"
	contains = list(/obj/item/beach_ball/dodgeball,
					/obj/item/beach_ball/dodgeball,
					/obj/item/gun/energy/laser/tag/red,
					/obj/item/gun/energy/laser/tag/red,
					/obj/item/gun/energy/laser/tag/red,
					/obj/item/gun/energy/laser/tag/blue,
					/obj/item/gun/energy/laser/tag/blue,
					/obj/item/gun/energy/laser/tag/blue,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/redtag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/suit/bluetag,
					/obj/item/clothing/head/helmet/redtaghelm,
					/obj/item/clothing/head/helmet/bluetaghelm)
	cost = 300
	containername = "laser tag crate"

/datum/supply_packs/misc/religious_supplies
	name = "Religious Supplies Crate"
	contains = list(/obj/item/reagent_containers/drinks/bottle/holywater,
					/obj/item/reagent_containers/drinks/bottle/holywater,
					/obj/item/storage/bible/booze,
					/obj/item/storage/bible/booze,
					/obj/item/clothing/suit/hooded/dark_robes,
					/obj/item/clothing/suit/hooded/dark_robes,
					/obj/item/clothing/under/misc/burial,
					/obj/item/clothing/under/misc/burial)
	cost = 250
	containername = "religious supplies crate"

/datum/supply_packs/misc/minerkit
	name = "Shaft Miner Starter Kit"
	cost = 250
	access = ACCESS_QM
	contains = list(/obj/item/storage/backpack/duffel/mining_conscript)
	containertype = /obj/structure/closet/crate/secure
	containername = "shaft miner starter kit"
	department_restrictions = list(DEPARTMENT_SUPPLY)

/datum/supply_packs/misc/barberkit
	name = "Barber Kit Crate"
	contains = list(/obj/item/clothing/under/rank/civilian/barber,
					/obj/item/storage/box/lip_stick,
					/obj/item/storage/box/barber)
	cost = 100
	containername = "barber kit crate"

/datum/supply_packs/misc/carpet
	name = "Carpet Crate"
	cost = 150
	contains = list(/obj/item/stack/tile/carpet/twenty)
	containername = "carpet crate"

/datum/supply_packs/misc/personal_crates
	name = "Personal Crates Pack"
	cost = 100
	containertype = /obj/structure/largecrate
	contains = list(/obj/structure/closet/crate/secure/personal,
					/obj/structure/closet/crate/secure/personal,
					/obj/structure/closet/crate/secure/personal,
					/obj/structure/closet/crate/secure/personal,
					/obj/structure/closet/crate/secure/personal,
					/obj/structure/closet/crate/secure/personal)
	containername = "personal crates pack"


///////////// Paper Work

/datum/supply_packs/misc/paper
	name = "Bureaucracy Crate"
	contains = list(/obj/structure/filingcabinet/chestdrawer,
					/obj/item/camera_film,
					/obj/item/hand_labeler,
					/obj/item/hand_labeler_refill,
					/obj/item/hand_labeler_refill,
					/obj/item/stack/tape_roll,
					/obj/item/paper_bin,
					/obj/item/pen,
					/obj/item/pen/blue,
					/obj/item/pen/red,
					/obj/item/stamp/denied,
					/obj/item/stamp/granted,
					/obj/item/folder/blue,
					/obj/item/folder/red,
					/obj/item/folder/yellow,
					/obj/item/clipboard,
					/obj/item/clipboard)
	cost = 100
	containertype = /obj/structure/closet/crate/nanotrasen
	containername = "bureaucracy crate"

/datum/supply_packs/misc/artscrafts
	name = "Arts and Crafts Supplies Crate"
	contains = list(/obj/item/storage/fancy/crayons,
	/obj/item/camera,
	/obj/item/camera_film,
	/obj/item/camera_film,
	/obj/item/storage/photo_album,
	/obj/item/stack/package_wrap,
	/obj/item/reagent_containers/glass/paint/red,
	/obj/item/reagent_containers/glass/paint/green,
	/obj/item/reagent_containers/glass/paint/blue,
	/obj/item/reagent_containers/glass/paint/yellow,
	/obj/item/reagent_containers/glass/paint/violet,
	/obj/item/reagent_containers/glass/paint/black,
	/obj/item/reagent_containers/glass/paint/white,
	/obj/item/reagent_containers/glass/paint/remover,
	/obj/item/poster/random_official,
	/obj/item/stack/wrapping_paper,
	/obj/item/stack/wrapping_paper,
	/obj/item/stack/wrapping_paper,
	/obj/item/storage/toolbox/artistic)
	cost = 100
	containername = "arts and crafts crate"

/datum/supply_packs/misc/posters
	name = "Corporate Posters Crate"
	contains = list(/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official,
					/obj/item/poster/random_official)
	cost = 50
	containertype = /obj/structure/closet/crate/nanotrasen
	containername = "corporate posters crate"

///////////// Janitor Supplies

/datum/supply_packs/misc/janitor
	name = "Janitorial Supplies Crate"
	contains = list(/obj/item/reagent_containers/glass/bucket,
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/mop,
					/obj/item/push_broom,
					/obj/item/caution,
					/obj/item/caution,
					/obj/item/caution,
					/obj/item/storage/bag/trash,
					/obj/item/reagent_containers/spray/cleaner,
					/obj/item/reagent_containers/glass/rag,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner)
	cost = 200
	containername = "janitorial supplies crate"
	announce_beacons = list("Janitor" = list("Janitorial"))
	department_restrictions = list(DEPARTMENT_SERVICE)

/datum/supply_packs/misc/janitor/janicart
	name = "Janitorial Cart and Galoshes Crate"
	contains = list(/obj/structure/janitorialcart,
					/obj/item/clothing/shoes/galoshes)
	cost = 100
	containertype = /obj/structure/largecrate
	containername = "janitorial cart crate"
	department_restrictions = list(DEPARTMENT_SERVICE)

/datum/supply_packs/misc/janitor/janitank
	name = "Janitor Watertank Backpack"
	contains = list(/obj/item/watertank/janitor)
	cost = 100
	containertype = /obj/structure/closet/crate/secure
	containername = "janitor watertank crate"
	access = ACCESS_JANITOR
	department_restrictions = list(DEPARTMENT_SERVICE)

/datum/supply_packs/misc/janitor/lightbulbs
	name = "Replacement Lights Crate"
	contains = list(/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed)
	cost = 100
	containername = "replacement lights crate"

/datum/supply_packs/misc/janicart
	name = "Janicart Crate"
	contains = list(/obj/vehicle/janicart,
					/obj/item/key/janitor)
	cost = 500
	containertype = /obj/structure/largecrate
	containername = "Janicart. Caution while driving is advised."
	department_restrictions = list(DEPARTMENT_SERVICE)

/datum/supply_packs/misc/noslipfloor
	name = "High-traction Floor Tiles"
	contains = list(/obj/item/stack/tile/noslip/loaded)
	cost = 200
	containername = "high-traction floor tiles"

/datum/supply_packs/misc/soap
	name = "Assorted Soap Crate"
	contains = list(/obj/item/soap,
					/obj/item/soap,
					/obj/item/soap,
					/obj/item/soap/nanotrasen)
	cost = 250
	containername = "soap crate"

/datum/supply_packs/misc/sus_soap
	name = "Suspicious Soap Crate"
	contains = list(/obj/item/soap/syndie,
					/obj/item/soap/syndie)
	cost = 250
	containername = "suspicious soap crate"
	hidden = TRUE

///////////// Costumes

/datum/supply_packs/misc/servicecostume
	name = "Service Costume Crate"
	contains = list(/obj/item/storage/backpack/clown,
					/obj/item/clothing/shoes/clown_shoes,
					/obj/item/clothing/mask/gas/clown_hat,
					/obj/item/clothing/under/rank/civilian/clown,
					/obj/item/bikehorn,
					/obj/item/storage/backpack/mime,
					/obj/item/clothing/under/rank/civilian/mime,
					/obj/item/clothing/shoes/black,
					/obj/item/clothing/gloves/color/white,
					/obj/item/clothing/mask/gas/mime,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/suit/suspenders,
					/obj/item/reagent_containers/drinks/bottle/bottleofnothing,
					/obj/item/reagent_containers/drinks/bottle/bottleofbanana
					)
	cost = 250
	containertype = /obj/structure/closet/crate/secure
	containername = "service costumes"
	access = ACCESS_THEATRE
	department_restrictions = list(DEPARTMENT_SERVICE)

/datum/supply_packs/misc/costume
	name = "Costume Crate"
	contains = list(/obj/item/staff,
					/obj/item/clothing/suit/wizrobe/fake,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/head/wizard/fake,
					/obj/item/clothing/head/foragecap,
					/obj/item/clothing/suit/officercoat,
					/obj/item/clothing/under/costume/officeruniform,
					/obj/item/clothing/suit/lordadmiral,
					/obj/item/clothing/head/lordadmiralhat,
					/obj/item/clothing/head/hasturhood,
					/obj/item/clothing/suit/hastur,
					/obj/item/clothing/suit/monkeysuit,
					/obj/item/clothing/mask/gas/monkeymask,
					/obj/item/clothing/suit/corgisuit,
					/obj/item/clothing/head/corgi,
					/obj/item/clothing/suit/corgisuit/en,
					/obj/item/clothing/head/corgi/en)
	cost = 400
	containername = "costume crate"

/datum/supply_packs/misc/mafia
	name = "Mafia Supply Crate"
	contains = list(/obj/item/clothing/suit/browntrenchcoat,
					/obj/item/clothing/suit/blacktrenchcoat,
					/obj/item/clothing/head/fedora/whitefedora,
					/obj/item/clothing/head/fedora/brownfedora,
					/obj/item/clothing/head/fedora,
					/obj/item/clothing/under/costume/flappers,
					/obj/item/clothing/under/suit/mafia,
					/obj/item/clothing/under/suit/mafia/vest,
					/obj/item/clothing/under/suit/mafia/white,
					/obj/item/clothing/under/suit/mafia/tan,
					/obj/item/gun/projectile/shotgun/toy/tommygun,
					/obj/item/gun/projectile/shotgun/toy/tommygun)
	cost = 300
	containername = "mafia supply crate"

/datum/supply_packs/misc/sunglasses
	name = "Sunglasses Crate"
	contains = list(/obj/item/clothing/glasses/sunglasses,
					/obj/item/clothing/glasses/sunglasses,
					/obj/item/clothing/glasses/sunglasses)
	cost = 450
	containername = "sunglasses crate"

/datum/supply_packs/misc/welding_goggles
	name = "Welding Goggles Crate"
	contains = list(/obj/item/clothing/glasses/welding,
					/obj/item/clothing/glasses/welding,
					/obj/item/clothing/glasses/welding)
	cost = 300
	containername = "welding goggles crate"

/datum/supply_packs/misc/randomised
	var/num_contained = 3 //number of items picked to be contained in a randomised crate
	contains = list(/obj/item/clothing/head/collectable/chef,
					/obj/item/clothing/head/collectable/paper,
					/obj/item/clothing/head/collectable/tophat,
					/obj/item/clothing/head/collectable/captain,
					/obj/item/clothing/head/collectable/beret,
					/obj/item/clothing/head/collectable/welding,
					/obj/item/clothing/head/collectable/flatcap,
					/obj/item/clothing/head/collectable/pirate,
					/obj/item/clothing/head/collectable/kitty,
					/obj/item/clothing/head/crown/fancy,
					/obj/item/clothing/head/collectable/rabbitears,
					/obj/item/clothing/head/collectable/wizard,
					/obj/item/clothing/head/collectable/hardhat,
					/obj/item/clothing/head/collectable/hos,
					/obj/item/clothing/head/collectable/thunderdome,
					/obj/item/clothing/head/collectable/swat,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/police,
					/obj/item/clothing/head/collectable/slime,
					/obj/item/clothing/head/collectable/xenom,
					/obj/item/clothing/head/collectable/petehat)
	name = "Collectable Hats Crate"
	cost = 2500
	containername = "collectable hats crate! Brought to you by Bass.inc!"

/datum/supply_packs/misc/randomised/New()
	manifest += "Contains any [num_contained] of:"
	..()

/datum/supply_packs/misc/randomised/plushie
	name = "Collectable Plushies Crate"
	cost = 1000
	containername = "collectable plushies crate! Brought to you by Bass.inc!"
	contains = list(
		/obj/effect/spawner/random/plushies,
		/obj/effect/spawner/random/plushies,
		/obj/effect/spawner/random/plushies/explosive,
	)

/datum/supply_packs/misc/foamforce
	name = "Foam Force Crate"
	contains = list(/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy,
					/obj/item/gun/projectile/shotgun/toy)
	cost = 250
	containername = "foam force crate"

/datum/supply_packs/misc/foamforce/bonus
	name = "Foam Force Pistols Crate"
	contains = list(/obj/item/gun/projectile/automatic/toy/pistol,
					/obj/item/gun/projectile/automatic/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol)
	cost = 500
	containername = "foam force pistols crate"
	contraband = 1

/datum/supply_packs/misc/bigband
	name = "Big Band Instrument Collection"
	contains = list(/obj/item/instrument/violin,
					/obj/item/instrument/guitar,
					/obj/item/instrument/eguitar,
					/obj/item/instrument/glockenspiel,
					/obj/item/instrument/accordion,
					/obj/item/instrument/saxophone,
					/obj/item/instrument/trombone,
					/obj/item/instrument/recorder,
					/obj/item/instrument/harmonica,
					/obj/item/instrument/xylophone,
					/obj/structure/musician/piano)
	cost = 500
	containername = "big band musical instruments collection"

/datum/supply_packs/misc/randomised/contraband
	num_contained = 5
	contains = list(/obj/item/storage/pill_bottle/random_drug_bottle,
					/obj/item/poster/random_contraband,
					/obj/item/storage/fancy/cigarettes/dromedaryco,
					/obj/item/storage/fancy/cigarettes/cigpack_shadyjims)
	name = "Contraband Crate"
	cost = 250
	containername = "crate"	//let's keep it subtle, eh?
	contraband = TRUE

/datum/supply_packs/misc/flags
	name = "Unapproved flags Crate"
	contains = list(/obj/item/flag/ussp,
					/obj/item/flag/syndi)
	cost = 200
	containername = "flags crate"
	contraband = TRUE

/datum/supply_packs/misc/pimpcoat
	name = "Very Expensive Coat for Rich People"
	contains = list(/obj/item/clothing/suit/pimpcoat)
	cost = 1000
	containername = "expensive coat crate"

/// This is a very classy crate.
/datum/supply_packs/misc/formalwear
	name = "Formal Wear Crate"
	contains = list(/obj/item/clothing/under/dress/blacktango,
					/obj/item/clothing/under/misc/assistantformal,
					/obj/item/clothing/under/misc/assistantformal,
					/obj/item/clothing/under/rank/procedure/iaa/blue,
					/obj/item/clothing/suit/storage/iaa/bluejacket,
					/obj/item/clothing/under/rank/procedure/iaa/purple,
					/obj/item/clothing/suit/storage/iaa/purplejacket,
					/obj/item/clothing/under/rank/procedure/iaa,
					/obj/item/clothing/suit/storage/iaa/blackjacket,
					/obj/item/clothing/accessory/waistcoat,
					/obj/item/clothing/neck/tie/blue,
					/obj/item/clothing/neck/tie/red,
					/obj/item/clothing/neck/tie/black,
					/obj/item/clothing/head/bowlerhat,
					/obj/item/clothing/head/fedora,
					/obj/item/clothing/head/flatcap,
					/obj/item/clothing/head/beret,
					/obj/item/clothing/head/that,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/shoes/laceup,
					/obj/item/clothing/under/suit/charcoal,
					/obj/item/clothing/under/suit/navy,
					/obj/item/clothing/under/suit/burgundy,
					/obj/item/clothing/under/suit/checkered,
					/obj/item/clothing/under/suit/tan,
					/obj/item/lipstick/random)
	cost = 400 //Lots of very expensive items. You gotta pay up to look good!
	containername = "formal-wear crate"

/datum/supply_packs/misc/wedding
	name = "Wedding Crate"
	contains = list(/obj/item/clothing/gloves/ring/gold/blessed,
					/obj/item/clothing/gloves/ring/gold/blessed,
					/obj/item/clothing/under/dress/wedding/bride_white,
					/obj/item/clothing/under/dress/wedding/bride_red,
					/obj/item/clothing/under/dress/wedding/bride_blue,
					/obj/item/clothing/under/dress/wedding/bride_purple,
					/obj/item/clothing/under/dress/wedding/bride_orange)
	cost = 400
	containername = "wedding crate"

/// For team sports like space polo
/datum/supply_packs/misc/teamcolors
	name = "Team Jerseys Crate"
	// 4 red jerseys, 4 blue jerseys, and 1 baseball
	contains = list(/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/red/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/clothing/under/color/blue/jersey,
					/obj/item/beach_ball/baseball)
	cost = 300
	containername = "team jerseys crate"

/// For space polo! Or horsehead Quiditch
/datum/supply_packs/misc/polo
	name = "Polo Supply Crate"
	// 6 brooms, 6 horse masks for the brooms, and 1 beach ball
	contains = list(/obj/item/staff/broom,
					/obj/item/staff/broom,
					/obj/item/staff/broom,
					/obj/item/staff/broom,
					/obj/item/staff/broom,
					/obj/item/staff/broom,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/clothing/mask/horsehead,
					/obj/item/beach_ball)
	cost = 250
	containername = "polo supply crate"

/// For non log spamming cargo brawls!
/datum/supply_packs/misc/boxing
	name = "Boxing Supply Crate"
	// 4 boxing gloves
	contains = list(/obj/item/clothing/gloves/boxing/blue,
					/obj/item/clothing/gloves/boxing/green,
					/obj/item/clothing/gloves/boxing/yellow,
					/obj/item/clothing/gloves/boxing)
	cost = 200
	containername = "boxing supply crate"

/datum/supply_packs/misc/vending/clothingvendor
	name = "Service Clothing Vendors Crate"
	cost = 50
	contains = list(/obj/item/vending_refill/bardrobe,
					/obj/item/vending_refill/chefdrobe,
					/obj/item/vending_refill/hydrodrobe,
					/obj/item/vending_refill/janidrobe,
					/obj/item/vending_refill/lawdrobe,
					/obj/item/vending_refill/chapdrobe)
	containername = "service clothing vendor crate"

/datum/supply_packs/misc/vending/clothingvendor/cargo
	name = "Cargo Clothing Vendors Crate"
	contains = list(/obj/item/vending_refill/cargodrobe,
					/obj/item/vending_refill/exploredrobe,
					/obj/item/vending_refill/minedrobe)
	containername = "cargo clothing vendor crate"

/datum/supply_packs/misc/hoverboard
	name = "Hoverboard Crate"
	contains = list(/obj/item/melee/skateboard/hoverboard)
	cost = 999 // Price of cool. Also under 1000 so it's not grand theft if stolen, lmao
	containername = "hoverboard crate"

///////////// Station Goals

/datum/supply_packs/misc/station_goal
	name = "Empty Station Goal Crate"
	cost = 10
	special = TRUE
	containername = "empty station goal crate"
	containertype = /obj/structure/closet/crate/nanotrasen

/datum/supply_packs/misc/station_goal/bsa
	name = "Bluespace Artillery Parts"
	cost = 1500
	contains = list(/obj/item/circuitboard/machine/bsa/front,
					/obj/item/circuitboard/machine/bsa/middle,
					/obj/item/circuitboard/machine/bsa/back,
					/obj/item/circuitboard/computer/bsa_control
					)
	containername = "bluespace artillery parts crate"


/datum/supply_packs/misc/station_goal/bluespace_tap
	name = "Bluespace Harvester Parts"
	cost = 1000
	contains = list(
					/obj/item/circuitboard/machine/bluespace_tap,
					/obj/item/paper/bluespace_tap
					)
	containername = "bluespace harvester parts crate"

/datum/supply_packs/misc/station_goal/dna_vault
	name = "DNA Vault Parts"
	cost = 1000
	contains = list(
					/obj/item/circuitboard/machine/dna_vault
					)
	containername = "dna vault parts crate"

/datum/supply_packs/misc/station_goal/dna_probes
	name = "DNA Vault Samplers"
	cost = 250
	contains = list(/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe,
					/obj/item/dna_probe
					)
	containername = "dna samplers crate"

/datum/supply_packs/misc/station_goal/shield_sat
	name = "Shield Generator Satellites"
	cost = 100
	contains = list(
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield,
					/obj/machinery/satellite/meteor_shield
					)
	containername = "shield sat crate"

/datum/supply_packs/misc/station_goal/shield_sat_control
	name = "Shield System Control Board"
	cost = 750
	contains = list(
					/obj/item/circuitboard/computer/sat_control
					)
	containername = "shield control board crate"

/datum/supply_packs/misc/toilet
	name = "Lavatory Crate"
	cost = 100
	contains = list(
					/obj/item/bathroom_parts,
					/obj/item/bathroom_parts/urinal,
					/obj/item/bathroom_parts/sink,
					/obj/item/mounted/shower
					)
	containername = "lavatory crate"

/datum/supply_packs/misc/snow_machine
	name = "Snow Machine Crate"
	cost = 750
	contains = list(
					/obj/machinery/snow_machine
					)
	special = TRUE
	department_restrictions = list(DEPARTMENT_COMMAND)

/datum/supply_packs/misc/cookware_crate
	name = "Kitchen Cookware Crate"
	cost = 100
	contains = list(
		/obj/item/reagent_containers/cooking/board,
		/obj/item/reagent_containers/cooking/bowl,
		/obj/item/reagent_containers/cooking/bowl,
		/obj/item/reagent_containers/cooking/deep_basket,
		/obj/item/reagent_containers/cooking/deep_basket,
		/obj/item/reagent_containers/cooking/grill_grate,
		/obj/item/reagent_containers/cooking/grill_grate,
		/obj/item/reagent_containers/cooking/icecream_bowl,
		/obj/item/reagent_containers/cooking/oven,
		/obj/item/reagent_containers/cooking/pan,
		/obj/item/reagent_containers/cooking/pan,
		/obj/item/reagent_containers/cooking/pot,
		/obj/item/reagent_containers/cooking/pot,
	)
	containertype = /obj/structure/closet/crate/cookware
	containername = "cookware crate"

/datum/supply_packs/misc/mugs
	name = "Coffee Mugs Crate"
	contains = list(
		/obj/item/reagent_containers/drinks/mug,
		/obj/item/reagent_containers/drinks/mug,
		/obj/item/reagent_containers/drinks/mug
	)
	cost = 100
	containername = "coffee mugs crate"

/datum/supply_packs/misc/mugs_sec
	name = "Security Coffee Mugs Crate"
	contains = list(
		/obj/item/reagent_containers/drinks/mug/sec,
		/obj/item/reagent_containers/drinks/mug/sec,
		/obj/item/reagent_containers/drinks/mug/sec
	)
	cost = 100
	containername = "security coffee mugs crate"
	containertype = /obj/structure/closet/crate/secure
	access = ACCESS_SECURITY

/datum/supply_packs/misc/mugs_sci
	name = "Science Coffee Mugs Crate"
	contains = list(
		/obj/item/reagent_containers/drinks/mug/sci,
		/obj/item/reagent_containers/drinks/mug/sci,
		/obj/item/reagent_containers/drinks/mug/sci
	)
	cost = 100
	containername = "science coffee mugs crate"
	containertype = /obj/structure/closet/crate/secure
	access = ACCESS_RESEARCH

/datum/supply_packs/misc/mugs_eng
	name = "Engineering Coffee Mugs Crate"
	contains = list(
		/obj/item/reagent_containers/drinks/mug/eng,
		/obj/item/reagent_containers/drinks/mug/eng,
		/obj/item/reagent_containers/drinks/mug/eng
	)
	cost = 100
	containername = "engineering coffee mugs crate"
	containertype = /obj/structure/closet/crate/secure
	access = ACCESS_CONSTRUCTION

/datum/supply_packs/misc/mugs_med
	name = "Medical Coffee Mugs Crate"
	contains = list(
		/obj/item/reagent_containers/drinks/mug/med,
		/obj/item/reagent_containers/drinks/mug/med,
		/obj/item/reagent_containers/drinks/mug/med
	)
	cost = 100
	containername = "medical coffee mugs crate"
	containertype = /obj/structure/closet/crate/secure
	access = ACCESS_MEDICAL

/datum/supply_packs/misc/mugs_serv
	name = "Service Coffee Mugs Crate"
	contains = list(
		/obj/item/reagent_containers/drinks/mug/serv,
		/obj/item/reagent_containers/drinks/mug/serv,
		/obj/item/reagent_containers/drinks/mug/serv
	)
	cost = 100
	containername = "service coffee mugs crate"

/datum/supply_packs/misc/mugs_novelty
	name = "Novelty Coffee Mugs Crate"
	contains = list(
		/obj/item/reagent_containers/drinks/mug/novelty,
		/obj/item/reagent_containers/drinks/mug/novelty,
		/obj/item/reagent_containers/drinks/mug/novelty
	)
	cost = 250
	containername = "novelty coffee mugs crate"

/datum/supply_packs/misc/sec_cosplay
	name = "Security Officer Cosplay Kit"
	contains = list(
		/obj/item/clothing/under/color/red,
		/obj/item/clothing/head/helmet/fake,
		/obj/item/clothing/suit/fake_armor,
		/obj/item/clothing/shoes/jackboots,
		/obj/item/storage/fancy/donut_box,
		/obj/item/restraints/handcuffs/toy,
		/obj/item/toy/flash,
		/obj/item/clothing/glasses/sunglasses_fake,
		/obj/item/gun/energy/gun/fake
	)
	cost = 500
	containername = "security officer cosplay kit"

/datum/supply_packs/misc/syndi_sci_cosplay
	name = "Unethical Sciencist Cosplay Kit"
	contains = list(
		/obj/item/clothing/suit/storage/labcoat,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/clothing/shoes/jackboots,
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/storage/belt/utility/expedition/vendor,
		/obj/item/storage/toolbox/fakesyndi,
		/obj/item/folder/syndicate/fake_red
	)
	cost = 500
	containername = "unethical sciencist cosplay kit"
	contraband = TRUE

/datum/supply_packs/misc/potted_plants_medium
	name = "Potted Plants Crate"
	contains = list(
		/obj/item/kirbyplants/medium,
		/obj/item/kirbyplants/medium,
		/obj/item/kirbyplants/medium
	)
	cost = 100
	containername = "potted plants crate"
	containertype = /obj/structure/closet/crate/plastic

/datum/supply_packs/misc/potted_plants_small
	name = "Tabletop Potted Plants Crate"
	contains = list(
		/obj/item/kirbyplants/small,
		/obj/item/kirbyplants/small,
		/obj/item/kirbyplants/small
	)
	cost = 50
	containername = "tabletop potted plants crate"
	containertype = /obj/structure/closet/crate/plastic

/datum/supply_packs/misc/potted_plants_alien
	name = "Alien Potted Plants Crate"
	contains = list(
		/obj/item/kirbyplants/large/alien,
		/obj/item/kirbyplants/large/alien,
		/obj/item/kirbyplants/large/alien
	)
	cost = 150
	containername = "alien potted plants crate"
	containertype = /obj/structure/closet/crate/plastic

/datum/supply_packs/misc/flag_sci
	name = "RnD Flag Crate"
	contains = list(
		/obj/item/flag/rnd
	)
	cost = 250
	containertype = /obj/structure/closet/crate/secure
	containername = "RnD flag crate"
	access = ACCESS_RESEARCH

/datum/supply_packs/misc/flag_sec
	name = "Security Flag Crate"
	contains = list(
		/obj/item/flag/sec
	)
	cost = 250
	containertype = /obj/structure/closet/crate/secure
	containername = "security flag crate"
	access = ACCESS_SECURITY

/datum/supply_packs/misc/flag_sup
	name = "Supply Flag Crate"
	contains = list(
		/obj/item/flag/cargo
	)
	cost = 250
	containertype = /obj/structure/closet/crate/secure
	containername = "supply flag crate"
	access = ACCESS_CARGO

/datum/supply_packs/misc/flag_atm
	name = "Atmospherics Flag Crate"
	contains = list(
		/obj/item/flag/atmos
	)
	cost = 250
	containertype = /obj/structure/closet/crate/secure
	containername = "atmospherics flag crate"
	access = ACCESS_CONSTRUCTION

/datum/supply_packs/misc/flag_com
	name = "Command Flag Crate"
	contains = list(
		/obj/item/flag/command
	)
	cost = 250
	containertype = /obj/structure/closet/crate/secure/nanotrasen
	containername = "command flag crate"
	access = ACCESS_HEADS

/datum/supply_packs/misc/flag_greytide
	name = "Assistant Flag Crate"
	contains = list(
		/obj/item/flag/grey
	)
	cost = 250
	containername = "assistant flag crate"
	contraband = TRUE

/datum/supply_packs/misc/premium_havana_cigar
	name = "premium Havana cigar crate"
	contains = list(
		/obj/item/storage/fancy/havana_cigar
	)
	cost = 5000 // This is a very luxurious product. And it's only made on Earth. And it's subject to TSF export taxes.
	containername = "premium Havana cigar crate"
	containertype = /obj/structure/largecrate
