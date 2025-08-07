/obj/effect/spawner/random/traders
	name = "trader item spawner"
	spawn_loot_count = 6

/obj/effect/spawner/random/traders/civilian
	name = "1. civilian gear"
	icon_state = "toolbox"
	loot = list(
		// General utility gear
		/obj/item/clothing/gloves/combat = 10,
		/obj/item/clothing/mask/holo_cigar = 10,
		/obj/item/reagent_containers/spray/cleaner/advanced = 10,

		/obj/item/book_of_babel = 5,
		/obj/item/clothing/mask/whistle = 5,
		/obj/item/clothing/under/costume/psyjump = 5,
		/obj/item/clothing/under/syndicate/combat = 5,
		/obj/item/immortality_talisman = 5,
		/obj/item/soap = 5,
		/obj/item/soap/syndie = 5,
		/obj/item/storage/backpack/satchel_flat = 5,
		/obj/item/storage/box/syndie_kit/chameleon = 5, //costumes!
	)

/obj/effect/spawner/random/traders/minerals
	name = "2. minerals"
	icon_state = "metal"
	loot = list(

		// Common stuff you get from mining which isn't already present on the
		// station. Note that plasma and derived hybrid materials are NOT
		// included in this list because plasma is the trader's objective!

		/obj/item/stack/sheet/mineral/silver = 5,
		/obj/item/stack/sheet/mineral/gold = 5,
		/obj/item/stack/sheet/mineral/uranium = 5,
		/obj/item/stack/sheet/mineral/diamond = 5,
		/obj/item/stack/sheet/mineral/titanium = 5,
		/obj/item/stack/sheet/plasteel = 5,

		// Rare space ore sheets
		/obj/item/stack/sheet/mineral/platinum = 5,
		/obj/item/stack/sheet/mineral/iridium = 5,
		/obj/item/stack/sheet/mineral/palladium = 5,

		// Rare stuff you can't get from mining
		/obj/item/stack/sheet/mineral/tranquillite = 5,
		/obj/item/stack/sheet/mineral/bananium = 5,
		/obj/item/stack/sheet/wood = 5,
		/obj/item/stack/sheet/plastic = 5,
		/obj/item/stack/sheet/mineral/sandstone = 5,
	)

/obj/effect/spawner/random/traders/minerals/make_item(spawn_loc, type_path_to_make)
	var/obj/item/stack/sheet/S = ..()
	if(istype(S))
		S.amount = 25

	return S

/obj/effect/spawner/random/traders/donksoft
	name = "3. donksoft gear"
	icon_state = "stetchkin"

	loot = list(
		/obj/item/gun/projectile/automatic/c20r/toy = 5,
		/obj/item/gun/projectile/automatic/l6_saw/toy = 5,
		/obj/item/gun/projectile/automatic/toy/pistol = 10,
		/obj/item/gun/projectile/automatic/toy/pistol/enforcer = 5,
		/obj/item/gun/projectile/shotgun/toy = 5,
		/obj/item/gun/projectile/shotgun/toy/crossbow = 5,
		/obj/item/gun/projectile/shotgun/toy/tommygun = 5,
		/obj/item/gun/projectile/automatic/sniper_rifle/toy = 5,
	)

/obj/effect/spawner/random/traders/science
	name = "4. science gear"
	// TODO: I know I created an anomaly core random spawner icon but it disappeared in some merge or other
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "anomaly_core"
	loot = list(
		// Robotics
		/obj/item/assembly/signaler/anomaly/random = 50, // anomaly core
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray = 25, // mecha x-ray laser
		/obj/item/mecha_parts/mecha_equipment/teleporter/precise = 25, // upgraded mecha teleporter
		/obj/item/autosurgeon/organ = 50,
		/obj/item/mod/construction/plating/research = 25,

		// Research
		/obj/item/paper/researchnotes = 125, // papers that give random R&D levels
		/obj/item/storage/box/telescience = 25, // Code green or blue. Probably not antags. People haven't touched it in ages. Let us see what happens.

		// Xenobio
		/obj/item/slimepotion/sentience = 50, // Low-value, but we want to encourage getting more players back in the round.
		/obj/item/slimepotion/transference = 50,
		/obj/item/dissector/alien = 50,
		/obj/item/regen_mesh = 50,

		// Might as well let AI be interested
		/obj/item/ai_upgrade/surveillance_upgrade = 25,
		/obj/item/ai_upgrade/expanded_storage = 10,
		/obj/item/ai_upgrade/expanded_network = 10,
		/obj/item/ai_upgrade/expanded_tank = 10,
		/obj/item/ai_upgrade/expanded_fabricator = 10,
	)

/obj/effect/spawner/random/traders/medical
	name = "5. medical gear"
	icon_state = "medkit"
	loot = list(
		// Medchem
		/obj/item/storage/pill_bottle/random_meds/labelled = 100, // random medical and other chems
		/obj/item/reagent_containers/glass/bottle/reagent/omnizine = 50,

		// Surgery
		/obj/item/organ/internal/heart/gland/ventcrawling = 50,
		/obj/item/organ/internal/heart/gland/heals = 50,

		// Genetics Research (should really be under science, but I was stuck for items to put in medical)
		/obj/item/dnainjector/regenerate = 50, // regeneration
		/obj/item/dnainjector/nobreath = 50,
		/obj/item/dnainjector/telemut = 50,

		// Medical in general
		/obj/item/mod/construction/plating/rescue = 25,
		/obj/item/gun/medbeam = 25, //Antags can see this to remove it if a threat, unlikely to happen with another midround
		/obj/item/bodyanalyzer = 25,
		/obj/item/circuitboard/sleeper/syndicate = 25,
	)

/obj/effect/spawner/random/traders/security
	name = "6. security gear"
	icon_state = "riot_shield"
	loot = list(
		// Melee
		/obj/item/kitchen/knife/combat = 50,
		/obj/item/fluff/desolate_baton_kit = 50, // permission granted by Desolate to use their fluff kit in this loot table

		// Utility
		/obj/item/storage/belt/military/assault = 50,
		/obj/item/clothing/mask/gas/sechailer/swat = 50,
		/obj/item/clothing/glasses/thermal = 50, // see heat-source mobs through walls. Less powerful than already-available xray.
		/obj/item/mod/construction/plating/safeguard = 25,
		/obj/item/mod/module/power_kick = 50,
		/obj/item/storage/box/syndie_kit/camera_bug = 25, //Camera viewing on the go, planting cameras with detective work? Could be interesting!

		// Ranged weapons
		/obj/item/storage/box/enforcer_rubber = 50, //Lethal ammo can be printed at an autolathe, so no need for the lethal subtype
		/obj/item/gun/projectile/shotgun/automatic/dual_tube = 100, // cycler shotgun, not normally available to crew
		/obj/item/weaponcrafting/gunkit/universal_gun_kit/sol_gov = 20
	)

/obj/effect/spawner/random/traders/engineering
	name = "7. eng gear"
	icon_state = "wrench"
	spawn_loot_count = 8 //increased due to this pool being a bit more... niche?
	loot = list(
		/obj/item/clothing/glasses/material, // shows objects, but not mobs, through walls
		/obj/item/clothing/glasses/meson/night, // NV mesons
		/obj/item/holosign_creator/atmos,
		/obj/item/mod/construction/plating/advanced,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/rcd/combat,
		/obj/item/rpd/bluespace,
		/obj/item/slimepotion/oil_slick, //Suggested by discord, moderately common but not as common as most rnd things
		/obj/item/storage/backpack/holding,
		/obj/item/storage/belt/utility/chief/full,
		/obj/item/tank/internals/emergency_oxygen/double,
	)

/obj/effect/spawner/random/traders/large_item
	name = "8. large item"
	icon_state = "durand_old"
	spawn_loot_count = 1
	loot = list(
		/obj/machinery/cooker/cerealmaker,
		/obj/machinery/disco,
		/obj/machinery/snow_machine,
		/obj/mecha/combat/durand/old,
		/obj/structure/spirit_board,
	)

/obj/effect/spawner/random/traders/vehicle
	name = "9. vehicle"
	icon_state = "motorcycle"
	loot = list(
		/obj/vehicle/motorcycle,
		/obj/vehicle/snowmobile,
		/obj/vehicle/snowmobile/blue,
		/obj/tgvehicle/speedbike/red,
		/obj/tgvehicle/speedbike,
	)

/obj/effect/spawner/random/traders/vehicle/make_item(spawn_loc, type_path_to_make)
	var/obj/vehicle/V = ..()
	if(istype(V) && V.key_type)
		V.inserted_key = new V.key_type(V)

	return V

/obj/effect/spawner/random/traders/service
	name = "10. service gear"

	loot = list(
		// Mining
		/obj/item/pickaxe/drill/jackhammer = 10,
		/obj/item/gun/energy/kinetic_accelerator/experimental = 10,
		/obj/item/borg/upgrade/modkit/aoe/turfs/andmobs = 10,

		// Botanist
		/obj/item/storage/box/botany_labelled_seeds = 10,

		// Clown
		/obj/item/grenade/clusterbuster/honk = 10,
		/obj/item/bikehorn/golden = 10,
		/obj/item/gun/throw/piecannon = 10,

		// Bartender
		/obj/item/storage/box/bartender_rare_ingredients_kit = 10,

		// Chef
		/obj/item/storage/box/chef_rare_ingredients_kit = 10,
		/obj/item/mod/module/dispenser = 5, // Prints burgers. When you want to be space mcdonalds.
		// It would be nice to also have items for other service jobs: Mime, Librarian, Chaplain, etc

		// Chaplain
		/obj/structure/constructshell = 5, //Fuck it we ball what could go wrong
	)
