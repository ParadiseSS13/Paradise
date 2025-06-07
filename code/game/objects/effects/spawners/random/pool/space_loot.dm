/datum/spawn_pool/spaceloot
	available_points = 1700

/obj/effect/spawner/random/pool/spaceloot
	spawn_pool = /datum/spawn_pool/spaceloot
	record_spawn = TRUE

/obj/effect/spawner/random/pool/spaceloot/record_item(type_path_to_make)
	if(ispath(type_path_to_make, /obj/effect))
		return

	SSblackbox.record_feedback("tally", "space_loot_spawns", 1, "[type_path_to_make]")

/obj/effect/spawner/random/pool/spaceloot/dvorak_core_table
	point_value = 100
	guaranteed = TRUE
	loot = list(
		/obj/item/rcd/combat,
		/obj/item/gun/medbeam,
		/obj/item/gun/energy/wormhole_projector,
		/obj/item/storage/box/syndie_kit/oops_all_extraction_flares,
	)

/obj/effect/spawner/random/pool/spaceloot/dvorak_emp_loot
	point_value = 35
	guaranteed = TRUE
	loot = list(
		/obj/item/grenade/empgrenade = 8,
		/obj/item/gun/energy/ionrifle/carbine = 1,
		/obj/item/gun/energy/ionrifle = 1,
	)

/obj/effect/spawner/random/pool/spaceloot/dvorak_displaycase
	point_value = 100
	guaranteed = TRUE
	loot = list(/obj/structure/displaycase/dvoraks_treat)

/obj/effect/spawner/random/pool/spaceloot/syndicate/common
	name = "syndicate depot loot, common"
	icon_state = "loot"
	point_value = 10
	loot = list(
		// Loot schema: costumes, toys, useless gimmick items
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/clothing/shoes/magboots/syndie,
		/obj/item/clothing/suit/jacket/bomber/syndicate,
		/obj/item/clothing/suit/storage/iaa/blackjacket/armored,
		/obj/item/clothing/under/syndicate/combat,
		/obj/item/clothing/under/syndicate/sniper,
		/obj/item/coin/antagtoken/syndicate,
		/obj/item/deck/cards/syndicate,
		/obj/item/lighter/zippo/gonzofist,
		/obj/item/soap/syndie,
		/obj/item/stamp/chameleon,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/suppressor,
		/obj/item/toy/syndicateballoon,
	)

/obj/effect/spawner/random/pool/spaceloot/syndicate/common/depot
	spawn_inside = /obj/structure/closet/secure_closet/depot
	spawn_loot_chance = 40
	loot = list(
		// Loot schema: costumes, toys, useless gimmick items
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/clothing/shoes/magboots/syndie,
		/obj/item/clothing/suit/jacket/bomber/syndicate,
		/obj/item/clothing/suit/storage/iaa/blackjacket/armored,
		/obj/item/clothing/under/syndicate/combat,
		/obj/item/clothing/under/syndicate/sniper,
		/obj/item/coin/antagtoken/syndicate,
		/obj/item/deck/cards/syndicate,
		/obj/item/lighter/zippo/gonzofist,
		/obj/item/soap/syndie,
		/obj/item/stamp/chameleon,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/suppressor,
		/obj/item/toy/syndicateballoon,

		// only in depot for common-tier
		/obj/item/storage/secure/briefcase/syndie,
	)

/obj/effect/spawner/random/pool/spaceloot/syndicate/stetchkin
	name = "syndicate depot loot, 80% stetchkin"
	icon_state = "stetchkin"
	spawn_loot_chance = 80
	point_value = 25
	loot = list(/obj/item/gun/projectile/automatic/pistol)

/obj/effect/spawner/random/pool/spaceloot/syndicate/rare
	name = "syndicate depot loot, rare"
	icon_state = "doubleloot"
	point_value = 45
	// Basic stealth, utility and environmental gear.
	loot = list(
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/clothing/gloves/color/black/thief,
		/obj/item/clothing/shoes/chameleon/noslip,
		/obj/item/clothing/under/syndicate/silicon_cham,
		/obj/item/clothing/mask/chameleon/voice_change,
		/obj/item/flash/cameraflash,
		/obj/item/gun/projectile/automatic/toy/pistol/riot,
		/obj/item/lighter/zippo/gonzofist,
		/obj/item/mod/module/chameleon,
		/obj/item/mod/module/holster/hidden,
		/obj/item/mod/module/noslip,
		/obj/item/mod/module/visor/night,
		/obj/item/mod/module/plate_compression,
		/obj/item/reagent_containers/hypospray/autoinjector/hyper_medipen,
		/obj/item/reagent_containers/hypospray/autoinjector/nanocalcium,
		/obj/item/stack/sheet/mineral/gold{amount = 20},
		/obj/item/stack/sheet/mineral/plasma{amount = 20},
		/obj/item/stack/sheet/mineral/silver{amount = 20},
		/obj/item/stack/sheet/mineral/uranium{amount = 20},
		/obj/item/stamp/chameleon,
		/obj/item/storage/backpack/duffel/syndie/med/surgery,
		/obj/item/storage/backpack/satchel_flat,
		/obj/item/storage/belt/military,
		/obj/item/storage/box/syndie_kit/camera_bug,
		/obj/item/storage/box/syndie_kit/chameleon,
		/obj/item/storage/box/syndie_kit/space,

		// common -> rare-tier for ruins
		/obj/item/storage/secure/briefcase/syndie,
	)

/obj/effect/spawner/random/pool/spaceloot/syndicate/rare/depot
	spawn_inside = /obj/structure/closet/secure_closet/depot
	spawn_loot_chance = 40
	loot = list(
		/obj/item/ammo_box/magazine/m10mm,
		/obj/item/clothing/gloves/color/black/thief,
		/obj/item/clothing/shoes/chameleon/noslip,
		/obj/item/clothing/under/syndicate/silicon_cham,
		/obj/item/clothing/mask/chameleon/voice_change,
		/obj/item/flash/cameraflash,
		/obj/item/gun/projectile/automatic/toy/pistol/riot,
		/obj/item/lighter/zippo/gonzofist,
		/obj/item/mod/module/chameleon,
		/obj/item/mod/module/holster/hidden,
		/obj/item/mod/module/noslip,
		/obj/item/mod/module/visor/night,
		/obj/item/mod/module/plate_compression,
		/obj/item/reagent_containers/hypospray/autoinjector/hyper_medipen,
		/obj/item/reagent_containers/hypospray/autoinjector/nanocalcium,
		/obj/item/stack/sheet/mineral/gold{amount = 20},
		/obj/item/stack/sheet/mineral/plasma{amount = 20},
		/obj/item/stack/sheet/mineral/silver{amount = 20},
		/obj/item/stack/sheet/mineral/uranium{amount = 20},
		/obj/item/stamp/chameleon,
		/obj/item/storage/backpack/duffel/syndie/med/surgery,
		/obj/item/storage/backpack/satchel_flat,
		/obj/item/storage/belt/military,
		/obj/item/storage/box/syndie_kit/camera_bug,
		/obj/item/storage/box/syndie_kit/chameleon,
		/obj/item/storage/box/syndie_kit/space,
	)

/obj/effect/spawner/random/pool/spaceloot/syndicate/officer
	name = "syndicate depot loot, officer"
	point_value = 110
	// Primarily utility items with occasional low damage weaponry, and a blood-red, because that's too good for rare-tier.
	loot = list(
		/obj/item/borg/upgrade/syndicate,
		/obj/item/clothing/glasses/hud/security/chameleon,
		/obj/item/clothing/glasses/thermal,
		/obj/item/clothing/shoes/magboots/elite,
		/obj/item/door_remote/omni/access_tuner,
		/obj/item/encryptionkey/binary,
		/obj/item/jammer,
		/obj/item/mod/module/power_kick,
		/obj/item/mod/module/visor/thermal,
		/obj/item/pen/edagger,
		/obj/item/pinpointer/advpinpointer,
		/obj/item/stack/sheet/mineral/diamond{amount = 10},
		/obj/item/storage/belt/sheath/snakesfang,
		/obj/item/storage/box/syndidonkpockets,
		/obj/item/storage/box/syndie_kit/stechkin,
		/obj/item/mod/control/pre_equipped/traitor,
	)

/obj/effect/spawner/random/pool/spaceloot/syndicate/officer/depot
	spawn_inside = /obj/structure/closet/secure_closet/depot
	spawn_loot_chance = 40
	loot = list(
		/obj/item/borg/upgrade/syndicate,
		/obj/item/clothing/glasses/hud/security/chameleon,
		/obj/item/clothing/glasses/thermal,
		/obj/item/clothing/shoes/magboots/elite,
		/obj/item/door_remote/omni/access_tuner,
		/obj/item/encryptionkey/binary,
		/obj/item/jammer,
		/obj/item/mod/module/power_kick,
		/obj/item/mod/module/visor/thermal,
		/obj/item/pen/edagger,
		/obj/item/pinpointer/advpinpointer,
		/obj/item/stack/sheet/mineral/diamond{amount = 10},
		/obj/item/storage/belt/sheath/snakesfang,
		/obj/item/storage/box/syndidonkpockets,
		/obj/item/storage/box/syndie_kit/stechkin,
		/obj/item/mod/control/pre_equipped/traitor,

		// only in depot for officer-tier
		/obj/item/mod/module/stealth,
	)

/obj/effect/spawner/random/pool/spaceloot/syndicate/armory
	name = "syndicate depot loot, armory"
	// Combat orientated items that could give the player an advantage if an antag messes with them.
	point_value = 200
	loot = list(
		/obj/item/bio_chip_implanter/proto_adrenalin,
		/obj/item/chameleon,
		/obj/item/gun/medbeam,
		/obj/item/gun/projectile/automatic/sniper_rifle/toy,
		/obj/item/melee/energy/sword/saber,
		/obj/item/mod/control/pre_equipped/traitor_elite,
		/obj/item/organ/internal/cyberimp/arm/razorwire,
		/obj/item/organ/internal/cyberimp/brain/sensory_enhancer,
		/obj/item/reagent_containers/hypospray/autoinjector/stimulants,
		/obj/item/shield/energy,
		/obj/item/weaponcrafting/gunkit/universal_gun_kit,

		// officer -> armory tier for ruins
		/obj/item/mod/module/stealth,
	)

/obj/effect/spawner/random/pool/spaceloot/syndicate/armory/elite/Initialize(mapload)
	loot ^= list(/obj/item/mod/control/pre_equipped/traitor_elite)
	. = ..()

/obj/effect/spawner/random/pool/spaceloot/syndicate/armory/depot
	guaranteed = TRUE
	spawn_inside = /obj/structure/closet/secure_closet/depot/armory
	loot = list(
		/obj/item/bio_chip_implanter/proto_adrenalin,
		/obj/item/chameleon,
		/obj/item/gun/medbeam,
		/obj/item/gun/projectile/automatic/sniper_rifle/toy,
		/obj/item/melee/energy/sword/saber,
		/obj/item/mod/control/pre_equipped/traitor_elite,
		/obj/item/organ/internal/cyberimp/arm/razorwire,
		/obj/item/organ/internal/cyberimp/brain/sensory_enhancer,
		/obj/item/reagent_containers/hypospray/autoinjector/stimulants,
		/obj/item/shield/energy,
		/obj/item/weaponcrafting/gunkit/universal_gun_kit,

		// only in armory tier for depot
		/obj/item/storage/box/syndie_kit/teleporter,
		/obj/item/cqc_manual,
	)

/obj/effect/spawner/random/pool/spaceloot/syndicate/mixed
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/syndicate/common = 25,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/rare = 20,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/officer = 5,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/armory = 1,
	)

/obj/effect/spawner/random/pool/spaceloot/syndicate/mob
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "syndicate_random"
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/syndicate/mob/common = 80,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/mob/modsuit = 19,

		// Let the massacre begin
		/obj/effect/spawner/random/pool/spaceloot/syndicate/mob/elite, // 1%
	)

/obj/effect/spawner/random/pool/spaceloot/syndicate/mob/elite
	point_value = 200 // Guaranteed armory-tier loot on death
	loot = list(/mob/living/simple_animal/hostile/syndicate/modsuit/elite)

// Used when we want our mob to be protected from environment pressure
/obj/effect/spawner/random/pool/spaceloot/syndicate/mob/modsuit
	icon_state = "syndicate_random_mod"
	point_value = 6 // Modsuit chance
	loot = list(
		/mob/living/simple_animal/hostile/syndicate/modsuit,
		/mob/living/simple_animal/hostile/syndicate/modsuit/ranged,
	)

/obj/effect/spawner/random/pool/spaceloot/syndicate/mob/common
	icon_state = "syndicate"
	point_value = 3
	loot = list(
		/mob/living/simple_animal/hostile/syndicate/ranged = 4,
		/mob/living/simple_animal/hostile/syndicate = 3, // Melee is stronger than ranged variant most of the time
		/mob/living/simple_animal/hostile/syndicate/shield,
	)

// Only two of these
/obj/effect/spawner/random/pool/spaceloot/zoo
	unique_picks = TRUE
	guaranteed = TRUE
	point_value = 20
	loot = list(
		/obj/item/gun/energy/floragun,
		/obj/item/gun/energy/temperature,
	)

/obj/effect/spawner/random/pool/spaceloot/moonoutpost19
	name = "moon outpost 19 loot spawner"
	point_value = 30
	guaranteed = TRUE
	spawn_all_loot = TRUE

/obj/effect/spawner/random/pool/spaceloot/moonoutpost19/vault1
	loot = list(/obj/item/paper/researchnotes)

/obj/effect/spawner/random/pool/spaceloot/moonoutpost19/vault2
	loot = list(
		/obj/item/storage/lockbox/experimental_weapon,
		/obj/item/assembly/signaler/anomaly/random,
	)

/obj/effect/spawner/random/pool/spaceloot/moonoutpost19/vault3
	loot = list(
		/obj/item/mecha_parts/core,
		/obj/item/stock_parts/cell/infinite/abductor,
	)

/obj/effect/spawner/random/pool/spaceloot/deepstorage/main
	name = "warehouse main reward spawner"
	guaranteed = TRUE
	point_value = 100
	loot = list(
		/obj/item/storage/belt/champion/wrestling,
		/obj/item/storage/box/weaver_kit,
		/obj/item/gun/medbeam,
		/obj/item/storage/lockbox/experimental_weapon,
	)

/obj/effect/spawner/random/pool/spaceloot/mechtransport
	name = "mech transport storage loot spawner"
	guaranteed = TRUE
	point_value = 20
	spawn_all_loot = TRUE
	spawn_random_offset = TRUE
	spawn_random_offset_max_pixels = 8

/obj/effect/spawner/random/pool/spaceloot/mechtransport/storage1
	loot = list(
		/obj/item/mecha_parts/mecha_equipment/repair_droid,
		/obj/item/mecha_parts/mecha_equipment/extinguisher,
		/obj/item/mecha_modkit/voice/honk,
	)

/obj/effect/spawner/random/pool/spaceloot/mechtransport/storage2
	loot = list(
		/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill,
		/obj/item/mecha_parts/mecha_equipment/drill,
		/obj/item/mecha_parts/mecha_equipment/drill,
	)

/obj/effect/spawner/random/pool/spaceloot/mechtransport/storage3
	loot = list(/obj/item/mecha_parts/mecha_equipment/medical/sleeper)

/obj/effect/spawner/random/pool/spaceloot/mechtransport/storage4
	loot = list(/obj/item/mecha_parts/core)

/obj/effect/spawner/random/pool/spaceloot/whiteship_robotics
	name = "whiteship robotics implant"
	guaranteed = TRUE
	point_value = 15
	spawn_random_offset = TRUE
	spawn_random_offset_max_pixels = 8

	loot = list(
		/obj/item/organ/internal/cyberimp/chest/nutriment,
		/obj/item/organ/internal/cyberimp/brain/wire_interface,
		/obj/item/organ/internal/cyberimp/arm/toolset,
		/obj/item/organ/internal/eyes/cybernetic/meson,
	)


/obj/effect/spawner/random/pool/spaceloot/whiteship_armoury_shotgun_ammo
	name = "whiteship shotgun ammo"
	guaranteed = TRUE
	spawn_loot_chance = 33
	point_value = 10 // Do you have a shotgun?

	loot = list(
		/obj/item/storage/fancy/shell/confetti,
		/obj/item/storage/fancy/shell/ion,
		/obj/item/storage/fancy/shell/incindiary,
		/obj/item/storage/fancy/shell/dragonsbreath,
		/obj/item/storage/fancy/shell/rubbershot,
	)

/obj/effect/spawner/random/pool/spaceloot/whiteship_armoury_c_foam
	name = "whiteship c_foam"
	icon_state = "stetchkin"
	guaranteed = TRUE
	spawn_loot_chance = 20 // 1/5 chance after a 1/3 chance for this layout.
	point_value = 40

	loot = list(
		/obj/item/gun/projectile/c_foam_launcher
	)

/obj/effect/spawner/random/pool/spaceloot/trader_departments
	name = "trader department loot spawner"

/obj/effect/spawner/random/pool/spaceloot/trader_departments/civilian
	loot = /obj/effect/spawner/random/traders/civilian::loot

/obj/effect/spawner/random/pool/spaceloot/trader_departments/science
	// without /obj/item/autosurgeon/organ
	loot = list(
		/obj/item/paper/researchnotes = 125,

		/obj/item/assembly/signaler/anomaly/random = 50,
		/obj/item/autosurgeon/organ = 50,
		/obj/item/slimepotion/sentience = 50,
		/obj/item/slimepotion/transference = 50,

		/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray = 25,
		/obj/item/mecha_parts/mecha_equipment/teleporter/precise = 25,
		/obj/item/mod/construction/plating/research = 25,
		/obj/item/storage/box/telescience = 25,
		/obj/item/ai_upgrade/surveillance_upgrade = 25,
	)

/obj/effect/spawner/random/pool/spaceloot/trader_departments/engineering
	loot = /obj/effect/spawner/random/traders/engineering::loot

/obj/effect/spawner/random/pool/spaceloot/trader_departments/medical
	loot = /obj/effect/spawner/random/traders/medical::loot

/obj/effect/spawner/random/pool/spaceloot/trader_departments/security
	loot = /obj/effect/spawner/random/traders/security::loot

/obj/effect/spawner/random/pool/spaceloot/trader_departments/common
	point_value = 20

	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/trader_departments/civilian = 20,
		/obj/effect/spawner/random/pool/spaceloot/trader_departments/science = 10,
		/obj/effect/spawner/random/pool/spaceloot/trader_departments/engineering = 10,
	)

/obj/effect/spawner/random/pool/spaceloot/trader_departments/rare
	point_value = 80
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/trader_departments/medical = 5,
		/obj/effect/spawner/random/pool/spaceloot/trader_departments/security = 1,
	)

/obj/effect/spawner/random/pool/spaceloot/trader_organizations
	name = "trader organization loot spawner"

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/federation_minor
	loot = /obj/effect/spawner/random/traders/federation_minor::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/ussp_minor
	loot = /obj/effect/spawner/random/traders/ussp_minor::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/steadfast_minor
	loot = /obj/effect/spawner/random/traders/steadfast_minor::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/merchantguild_major
	loot = /obj/effect/spawner/random/traders/merchantguild_major::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/cybersun_minor
	loot = /obj/effect/spawner/random/traders/cybersun_minor::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/glintscale_minor
	loot = /obj/effect/spawner/random/traders/glintscale_minor::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/steadfast_major
	loot = /obj/effect/spawner/random/traders/steadfast_major::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/syntheticunion_minor
	// without /obj/item/autosurgeon/organ
	loot = list(
		/obj/item/clothing/glasses/meson/sunglasses = 5,
		/obj/item/clothing/glasses/thermal/monocle = 5,
		/obj/item/organ/internal/cyberimp/arm/toolset = 5,
		/obj/item/organ/internal/cyberimp/arm/surgery = 5,
		/obj/item/organ/internal/cyberimp/arm/janitorial = 5,
		/obj/item/organ/internal/cyberimp/brain/anti_stam = 5,
		/obj/item/organ/internal/cyberimp/brain/anti_sleep = 5,
		/obj/item/organ/internal/cyberimp/brain/clown_voice = 4,
		/obj/item/organ/internal/cyberimp/mouth/breathing_tube = 5,
		/obj/item/organ/internal/cyberimp/chest/ipc_repair = 5,
		/obj/item/organ/internal/cyberimp/chest/ipc_joints/magnetic_joints = 5,
		/obj/item/organ/internal/cyberimp/chest/ipc_joints/sealed = 5,
		/obj/item/flag/species/machine = 2
	)

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/skipjack_minor
	loot = /obj/effect/spawner/random/traders/skipjack_minor::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/solarcentral_minor
	loot = /obj/effect/spawner/random/traders/solarcentral_minor::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/merchantguild_minor
	loot = /obj/effect/spawner/random/traders/merchantguild_minor::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/federation_major
	loot = /obj/effect/spawner/random/traders/federation_major::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/ussp_major
	loot = /obj/effect/spawner/random/traders/ussp_major::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/glintscale_major
	loot = /obj/effect/spawner/random/traders/glintscale_major::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/syntheticunion_major
	loot = /obj/effect/spawner/random/traders/syntheticunion_major::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/skipjack_major
	loot = /obj/effect/spawner/random/traders/skipjack_major::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/solarcentral_major
	loot = /obj/effect/spawner/random/traders/solarcentral_major::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/technocracy_minor
	// without /obj/item/autosurgeon/organ
	loot = list(
		/obj/item/paper/researchnotes = 15,
		/obj/item/storage/box/beakers/bluespace = 5,
		/obj/item/storage/box/stockparts/deluxe = 5,
		/obj/item/clothing/glasses/thermal/monocle = 5,
		/obj/item/organ/internal/cyberimp/arm/toolset_abductor = 3,
		/obj/item/organ/internal/cyberimp/arm/surgery = 4,
		/obj/item/organ/internal/cyberimp/arm/advmop = 3,
		/obj/item/organ/internal/cyberimp/brain/anti_stam = 5,
		/obj/item/organ/internal/cyberimp/brain/anti_sleep = 5,
		/obj/item/organ/internal/cyberimp/brain/anti_drop = 5,
		/obj/item/flag/species/greys = 2
	)

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/technocracy_major
	loot = /obj/effect/spawner/random/traders/technocracy_major::loot

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/common
	point_value = 30
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/federation_minor,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/ussp_minor,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/steadfast_minor,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/merchantguild_major,
	)

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/uncommon
	point_value = 50
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/cybersun_minor,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/glintscale_minor,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/steadfast_major,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/syntheticunion_minor,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/skipjack_minor,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/solarcentral_minor,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/merchantguild_minor,
	)

/obj/effect/spawner/random/pool/spaceloot/trader_organizations/rare
	point_value = 150
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/federation_major,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/ussp_major,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/glintscale_major,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/syntheticunion_major,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/skipjack_major,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/solarcentral_major,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/technocracy_minor,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/technocracy_major,
	)

/obj/effect/spawner/random/pool/spaceloot/trader_mixed
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/trader_departments/common = 10,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/common = 10,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/uncommon = 5,
		/obj/effect/spawner/random/pool/spaceloot/trader_departments/rare = 2,
		/obj/effect/spawner/random/pool/spaceloot/trader_organizations/rare = 2,
	)

/obj/effect/spawner/random/pool/spaceloot/mixed
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/trader_mixed,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/mixed
	)
