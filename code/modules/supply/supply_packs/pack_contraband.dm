// This category exists to make it easier to find out what on earth you've unlocked when you've hacked and/or emagged the cargo console.
// It also makes it easier to keep track of contraband for development purposes.
/datum/supply_packs/contraband
	name = "HEADER"
	containertype = /obj/structure/closet/crate
	group = SUPPLY_CONTRABAND
	containername = "crate" // Most crates get discrete shipping unless otherwise overriden.
	contraband = TRUE

// MARK: Multitool
/datum/supply_packs/contraband/bloody_armor
	name = "Pre-Owned Armor"
	contains = list(/obj/item/clothing/suit/armor/vest/bloody,
					/obj/item/clothing/suit/armor/vest/bloody,
					/obj/item/clothing/suit/armor/vest/bloody)
	cost = 400
	containername = "pre-owned armor crate"
	containertype = /obj/structure/closet/crate/secure/gear
	access = ACCESS_SECURITY // The crate is locked but you don't need authorization to order it. If you can stomach the cost.

/datum/supply_packs/contraband/sus_soap
	name = "Suspicious Soap Crate"
	contains = list(/obj/item/soap/syndie,
					/obj/item/soap/syndie)
	cost = 250
	containertype = /obj/structure/closet/crate/janitorial
	containername = "suspicious soap crate"

/datum/supply_packs/contraband/foamforce_pistols
	name = "Foam Force Pistols Crate"
	contains = list(/obj/item/gun/projectile/automatic/toy/pistol,
					/obj/item/gun/projectile/automatic/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol,
					/obj/item/ammo_box/magazine/toy/pistol)
	cost = 500
	containername = "foam force pistols crate"

/datum/supply_packs/contraband/dueling_pistols
	name = "Dueling Pistols Crate"
	contains = list(/obj/item/storage/box/dueling_pistols,
					/obj/item/storage/box/dueling_pistols)
	cost = 650
	containername = "dueling pistols crate"

/datum/supply_packs/contraband/syndi_sci_cosplay
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

/datum/supply_packs/contraband/flag_greytide
	name = "Assistant Flag Crate"
	contains = list(
		/obj/item/flag/grey
	)
	cost = 250
	containername = "\improper \"GREYTIDE STATIONWIDE\" crate"

/datum/supply_packs/contraband/flag_contraband
	name = "Nanotrasen Unapproved Flags Crate"
	contains = list(/obj/item/flag/ussp,
					/obj/item/flag/syndi)
	cost = 200

/datum/supply_packs/contraband/posters
	name = "Nanotrasen Blacklisted Posters Crate"
	contains = list(/obj/item/poster/random_contraband,
					/obj/item/poster/random_contraband,
					/obj/item/poster/random_contraband,
					/obj/item/poster/random_contraband,
					/obj/item/poster/random_contraband,
					/obj/item/poster/random_contraband,
					/obj/item/poster/random_contraband,
					/obj/item/poster/random_contraband,
					/obj/item/poster/random_contraband)
	cost = 50

/datum/supply_packs/contraband/random_pills
	name = "Dr. Feelgood's 3-for-1 Variety Pill Bottles"
	contains = list(/obj/item/storage/pill_bottle/random_drug_bottle,
					/obj/item/storage/pill_bottle/random_drug_bottle,
					/obj/item/storage/pill_bottle/random_drug_bottle)
	cost = 200

/datum/supply_packs/contraband/oranic_drugs
	name = "Professor Tranquil's Most Relaxing Hits"
	contains = list(/obj/item/storage/pill_bottle/space_drugs,
					/obj/item/storage/pill_bottle/happiness,
					/obj/item/storage/fancy/cigarettes/cigpack_midori,
					/obj/item/reagent_containers/syringe/krokodil,)
	cost = 150

/datum/supply_packs/contraband/robot_drugs
	name = "Mechanist KLUNK's Synthetic Pick-Me-Ups"
	contains = list(/obj/item/storage/pill_bottle/space_drugs,
					/obj/item/reagent_containers/glass/bottle/w33d,
					/obj/item/reagent_containers/glass/bottle/w33d,
					/obj/item/reagent_containers/glass/bottle/grokodil)
	cost = 150

/datum/supply_packs/contraband/prison_mix
	name = "Big Ed's Special Prison Mix"
	contains = list(/obj/item/reagent_containers/glass/beaker/waterbottle/large/jenkem,
					/obj/item/reagent_containers/glass/beaker/waterbottle/large/jenkem,
					/obj/item/reagent_containers/glass/beaker/waterbottle/large/jenkem,
					/obj/item/reagent_containers/glass/beaker/waterbottle/large/prison_wine,
					/obj/item/reagent_containers/glass/beaker/waterbottle/large/prison_wine,
					/obj/item/reagent_containers/glass/beaker/waterbottle/large/prison_wine)
	cost = 50

// MARK: Emag only
/datum/supply_packs/emergency/specialops
	name = "Special Ops Supplies"
	contains = list(/obj/item/storage/box/emps,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/pen/sleepy,
					/obj/item/grenade/chem_grenade/incendiary)
	cost = 150 // This is hard enough to get, let's make it easier to buy.
	containertype = /obj/structure/closet/crate
	containername = "special ops crate"
	hidden = TRUE
	contraband = FALSE
