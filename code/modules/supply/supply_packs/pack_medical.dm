/datum/supply_packs/medical
	name = "HEADER"
	containertype = /obj/structure/closet/crate/medical
	group = SUPPLY_MEDICAL
	announce_beacons = list("Medbay" = list("Medbay", "Chief Medical Officer's Desk"))
	department_restrictions = list(DEPARTMENT_MEDICAL)


/datum/supply_packs/medical/supplies
	name = "Medical Supplies Crate"
	contains = list(/obj/item/reagent_containers/glass/bottle/charcoal,
					/obj/item/reagent_containers/glass/bottle/charcoal,
					/obj/item/reagent_containers/glass/bottle/epinephrine,
					/obj/item/reagent_containers/glass/bottle/epinephrine,
					/obj/item/reagent_containers/glass/bottle/morphine,
					/obj/item/reagent_containers/glass/bottle/morphine,
					/obj/item/reagent_containers/glass/bottle/toxin,
					/obj/item/reagent_containers/glass/bottle/toxin,
					/obj/item/reagent_containers/glass/beaker/large,
					/obj/item/reagent_containers/glass/beaker/large,
					/obj/item/stack/medical/bruise_pack,
					/obj/item/reagent_containers/iv_bag/salglu,
					/obj/item/storage/box/beakers,
					/obj/item/storage/box/syringes,
					/obj/item/storage/box/bodybags,
					/obj/item/storage/box/iv_bags,
					/obj/item/vending_refill/medical)
	cost = 400
	containername = "medical supplies crate"

/datum/supply_packs/medical/firstaid
	name = "First Aid Kits Crate"
	contains = list(/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular)
	cost = 250
	containername = "first aid kits crate"

/datum/supply_packs/medical/firstaidadv
	name = "Advanced First Aid Kits Crate"
	contains = list(/obj/item/storage/firstaid/adv,
					/obj/item/storage/firstaid/adv,
					/obj/item/storage/firstaid/adv,
					/obj/item/storage/firstaid/adv)
	cost = 250
	containername = "advanced first aid kits crate"

/datum/supply_packs/medical/firstaidmachine
	name = "Machine First Aid Kits Crate"
	contains = list(/obj/item/storage/firstaid/machine,
					/obj/item/storage/firstaid/machine,
					/obj/item/storage/firstaid/machine,
					/obj/item/storage/firstaid/machine)
	cost = 250
	containername = "machine first aid kits crate"

/datum/supply_packs/medical/firstaibrute
	name = "Brute Treatment Kits Crate"
	contains = list(/obj/item/storage/firstaid/brute,
					/obj/item/storage/firstaid/brute,
					/obj/item/storage/firstaid/brute)
	cost = 250
	containername = "brute first aid kits crate"

/datum/supply_packs/medical/firstaidburns
	name = "Burns Treatment Kits Crate"
	contains = list(/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/fire)
	cost = 250
	containername = "fire first aid kits crate"

/datum/supply_packs/medical/firstaidtoxins
	name = "Toxin Treatment Kits Crate"
	contains = list(/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/toxin)
	cost = 250
	containername = "toxin first aid kits crate"

/datum/supply_packs/medical/firstaidoxygen
	name = "Oxygen Treatment Kits Crate"
	contains = list(/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/o2)
	cost = 250
	containername = "oxygen first aid kits crate"

/datum/supply_packs/medical/virus
	name = "Virus Crate"
	contains = list(/obj/item/reagent_containers/glass/bottle/flu_virion,
					/obj/item/reagent_containers/glass/bottle/cold,
					/obj/item/reagent_containers/glass/bottle/epiglottis_virion,
					/obj/item/reagent_containers/glass/bottle/liver_enhance_virion,
					/obj/item/reagent_containers/glass/bottle/fake_gbs,
					/obj/item/reagent_containers/glass/bottle/magnitis,
					/obj/item/reagent_containers/glass/bottle/pierrot_throat,
					/obj/item/reagent_containers/glass/bottle/brainrot,
					/obj/item/reagent_containers/glass/bottle/hullucigen_virion,
					/obj/item/reagent_containers/glass/bottle/anxiety,
					/obj/item/reagent_containers/glass/bottle/beesease,
					/obj/item/storage/box/syringes,
					/obj/item/storage/box/beakers,
					/obj/item/reagent_containers/glass/bottle/mutagen)
	cost = 350
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "virus crate"
	access = ACCESS_CMO
	announce_beacons = list("Medbay" = list("Virology", "Chief Medical Officer's Desk"))

/datum/supply_packs/medical/vending
	name = "Medical Vending Crate"
	cost = 100
	contains = list(/obj/item/vending_refill/medical,
					/obj/item/vending_refill/wallmed)
	containername = "medical vending crate"

/datum/supply_packs/medical/vending/clothingvendor
	name = "Medical Clothing Vendors Crate"
	contains = list(/obj/item/vending_refill/medidrobe,
					/obj/item/vending_refill/chemdrobe,
					/obj/item/vending_refill/virodrobe)
	containername = "medical clothing vendors crate"

/datum/supply_packs/medical/bloodpacks
	name = "Blood Pack Variety Crate"
	contains = list(/obj/item/reagent_containers/iv_bag,
					/obj/item/reagent_containers/iv_bag,
					/obj/item/reagent_containers/iv_bag/blood/a_plus,
					/obj/item/reagent_containers/iv_bag/blood/a_minus,
					/obj/item/reagent_containers/iv_bag/blood/b_plus,
					/obj/item/reagent_containers/iv_bag/blood/b_minus,
					/obj/item/reagent_containers/iv_bag/blood/o_plus,
					/obj/item/reagent_containers/iv_bag/blood/o_minus,
					/obj/item/reagent_containers/iv_bag/slime,
					/obj/item/reagent_containers/iv_bag/blood/vox,
					/obj/machinery/iv_drip)
	cost = 500
	containertype = /obj/structure/closet/crate/freezer
	containername = "blood pack crate"

/datum/supply_packs/medical/surgery
	name = "Surgery Crate"
	contains = list(/obj/item/cautery,
					/obj/item/surgicaldrill,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/tank/internals/anesthetic,
					/obj/item/fix_o_vein,
					/obj/item/hemostat,
					/obj/item/scalpel,
					/obj/item/bonegel,
					/obj/item/retractor,
					/obj/item/bonesetter,
					/obj/item/circular_saw,
					/obj/item/surgical_drapes)
	cost = 400
	containertype = /obj/structure/closet/crate/secure
	containername = "surgery crate"
	access = ACCESS_MEDICAL

/datum/supply_packs/medical/gloves
	name = "Nitrile Glove Crate"
	contains = list(/obj/item/clothing/gloves/color/latex/nitrile,
					/obj/item/clothing/gloves/color/latex/nitrile,
					/obj/item/clothing/gloves/color/latex/nitrile,
					/obj/item/clothing/gloves/color/latex/nitrile)
	cost = 200
	containername = "nitrile glove crate"

/datum/supply_packs/medical/omnizine
	name = "Omnizine Shipment Crate"
	contains = list(/obj/item/reagent_containers/glass/bottle/reagent/omnizine)
	cost = 300
	containername = "omnizine shipment crate"

/datum/supply_packs/medical/biosuits
	name = "Biosuit 4-pack"
	contains = list(
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/head/bio_hood,
	)
	cost = 400
	containername = "biosuit shipment crate"

/datum/supply_packs/medical/surgical_masks
	name = "Sterile Mask And Goggles 4-pack"
	contains = list(/obj/item/clothing/mask/surgical,
					/obj/item/clothing/mask/surgical,
					/obj/item/clothing/mask/surgical,
					/obj/item/clothing/mask/surgical,
					/obj/item/clothing/glasses/goggles,
					/obj/item/clothing/glasses/goggles,
					/obj/item/clothing/glasses/goggles,
					/obj/item/clothing/glasses/goggles,
				)
	cost = 200
	containername = "sterile mask shipment crate"
