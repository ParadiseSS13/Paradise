// MARK: CC loot pool
/datum/spawn_pool/centcommloot
	available_points = INFINITY

/obj/effect/spawner/random/pool/centcommloot
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "giftbox"
	spawn_pool = /datum/spawn_pool/centcommloot
	record_spawn = TRUE

/obj/effect/spawner/random/pool/centcommloot/record_item(type_path_to_make)
	if(ispath(type_path_to_make, /obj/effect))
		return

	SSblackbox.record_feedback("tally", "CC_loot_spawns", 1, "[type_path_to_make]")

/obj/effect/spawner/random/pool/spaceloot/syndicate/common/depot/centcomm
	spawn_inside = null
	spawn_loot_chance = 100
	spawn_pool = /datum/spawn_pool/centcommloot
	record_spawn = FALSE

/obj/effect/spawner/random/pool/spaceloot/syndicate/rare/depot/centcomm
	spawn_inside = null
	spawn_loot_chance = 100
	spawn_pool = /datum/spawn_pool/centcommloot
	record_spawn = FALSE

/obj/effect/spawner/random/pool/spaceloot/syndicate/officer/depot/centcomm
	spawn_inside = null
	spawn_loot_chance = 100
	spawn_pool = /datum/spawn_pool/centcommloot
	record_spawn = FALSE

/obj/effect/spawner/random/pool/spaceloot/syndicate/armory/depot/centcomm
	spawn_inside = null
	spawn_pool = /datum/spawn_pool/centcommloot
	record_spawn = FALSE

/obj/effect/spawner/random/pool/centcommloot/syndicate/mixed
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/syndicate/common/depot/centcomm = 30,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/rare/depot/centcomm = 20,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/officer/depot/centcomm = 5,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/armory/depot/centcomm,
	)

// MARK: Space loot pool
/obj/effect/spawner/random/pool/spaceloot/syndicate/officer/depot/Initialize(mapload)
	loot |= list(
		/obj/item/clothing/mask/holo_cigar,
		/obj/item/card/id/syndicate,
	)
	. = ..()

/obj/effect/spawner/random/pool/spaceloot/syndicate/armory/Initialize(mapload)
	loot |= list(
		/obj/item/clothing/mask/holo_cigar,
		/obj/item/card/id/syndicate,
	)
	. = ..()

/obj/effect/spawner/random/pool/spaceloot/mechtransport_new/mecha
	icon_state = "durand_old"
	point_value = 100
	loot = list(/obj/mecha/combat/durand/old/mechtransport_new)

/obj/effect/spawner/random/pool/spaceloot/mechtransport_new/mecha_equipment
	point_value = 40
	spawn_all_loot = TRUE
	loot = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/honker,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,
	)

/obj/effect/spawner/random/pool/spaceloot/mod
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "mod"

/obj/effect/spawner/random/pool/spaceloot/mod/syndie
	name = "syndie mod 10pc"
	loot = list(
		/obj/machinery/suit_storage_unit/syndicate/empty = 90,
		/obj/effect/spawner/random/pool/spaceloot/mod/syndie/traitor = 9,
		/obj/effect/spawner/random/pool/spaceloot/mod/syndie/elite = 1,
	)

/obj/effect/spawner/random/pool/spaceloot/mod/syndie/traitor
	point_value = 110
	loot = list(/obj/machinery/suit_storage_unit/syndicate/secure/traitor)

/obj/effect/spawner/random/pool/spaceloot/mod/syndie/elite
	point_value = 200
	loot = list(/obj/machinery/suit_storage_unit/syndicate/secure/traitor_elite)

/obj/effect/spawner/random/pool/spaceloot/syndicate/common_rare
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/syndicate/common = 3,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/rare = 2,
	)

/obj/effect/spawner/random/pool/spaceloot/laser
	name = "laser 40pc"
	icon_state = "stetchkin"
	point_value = 30
	spawn_loot_chance = 40
	loot = list(
		/obj/item/gun/energy/laser,
		/obj/item/gun/energy/laser/retro,
	)

/obj/effect/spawner/random/pool/spaceloot/mining_tool
	loot = list(
		/obj/effect/spawner/random/loot/mining_tool = 99,
		/obj/effect/spawner/random/pool/spaceloot/eka,
	)

/obj/effect/spawner/random/pool/spaceloot/eka
	point_value = 65
	loot = list(
		/obj/item/gun/energy/kinetic_accelerator/experimental,
	)

/obj/effect/spawner/random/pool/spaceloot/security/modsuit
	name = "sec mod 75pc"
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "mod"
	point_value = 75
	spawn_loot_chance = 75
	loot = list(
		/obj/machinery/suit_storage_unit/security/space = 9,
		/obj/machinery/suit_storage_unit/security/space/safeguard,
	)

// MARK: Awaymission pool
/datum/spawn_pool/gatewayloot
	available_points = 850

/obj/effect/spawner/random/pool/gatewayloot
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "giftbox"
	spawn_pool = /datum/spawn_pool/gatewayloot

/obj/effect/spawner/random/pool/gatewayloot/record_item(type_path_to_make)
	if(ispath(type_path_to_make, /obj/effect))
		return

	SSblackbox.record_feedback("tally", "gatewayloot_loot_spawns", 1, "[type_path_to_make]")

/obj/effect/spawner/random/pool/spaceloot/mining_tool/gateway
	spawn_pool = /datum/spawn_pool/gatewayloot
	record_spawn = FALSE
	loot = list(
		/obj/effect/spawner/random/loot/mining_tool = 99,
		/obj/effect/spawner/random/pool/spaceloot/eka/gateway,
	)

/obj/effect/spawner/random/pool/spaceloot/eka/gateway
	spawn_pool = /datum/spawn_pool/gatewayloot
	record_spawn = FALSE

/obj/effect/spawner/random/pool/spaceloot/security/modsuit/gateway
	spawn_pool = /datum/spawn_pool/gatewayloot
	record_spawn = FALSE

/obj/effect/spawner/random/pool/gatewayloot/unathi/kitchen
	point_value = 70
	loot = list(/obj/item/gun/magic/hook) // currently there is not much to suggest

/obj/effect/spawner/random/pool/gatewayloot/spellbook
	icon_state = "book"
	point_value = 100
	loot = list(/obj/item/spellbook/oneuse/random/necropolis)

/obj/effect/spawner/random/pool/gatewayloot/wisp
	point_value = 100
	loot = list(/obj/item/wisp_lantern)

/obj/effect/spawner/random/pool/gatewayloot/wizard
	point_value = 150
	loot = list(/mob/living/simple_animal/hostile/deadwizard)

/obj/effect/spawner/random/pool/gatewayloot/tsf/lieutenant
	spawn_all_loot = TRUE
	point_value = 125
	loot = list(
		/obj/item/clothing/head/beret/solgov,
		/obj/item/clothing/under/solgov/command,
		/obj/item/clothing/gloves/combat,
		/obj/item/clothing/shoes/combat,
		/obj/item/gun/projectile/automatic/pistol/deagle,
	)

/obj/effect/spawner/random/pool/gatewayloot/tsf/marine
	spawn_all_loot = TRUE
	point_value = 140
	loot = list(
		/obj/item/clothing/head/soft/solgov/marines,
		/obj/item/clothing/under/solgov,
		/obj/item/clothing/gloves/combat,
		/obj/item/clothing/shoes/combat,
		/obj/item/gun/projectile/automatic/pistol/m1911,
	)

/obj/effect/spawner/random/pool/gatewayloot/tsf/hardsuit
	point_value = 70
	loot = list(/obj/item/clothing/suit/space/hardsuit/ert/solgov)

/obj/effect/spawner/random/pool/gatewayloot/tsf/mixed
	loot = list(
		/obj/effect/spawner/random/pool/gatewayloot/tsf/marine = 9,
		/obj/effect/spawner/random/pool/gatewayloot/tsf/lieutenant,
	)

/obj/effect/spawner/random/pool/gatewayloot/cult
	name = "cult item 60pc"
	point_value = 20
	spawn_loot_chance = 60
	loot = list(
		/obj/item/shield/mirror,
		/obj/item/melee/cultblade,
		/obj/item/whetstone/cult,
		/obj/item/clothing/suit/hooded/cultrobes,
		/obj/item/reagent_containers/drinks/bottle/holywater/hell,
		/obj/item/soulstone/anybody,
		/obj/item/blank_tarot_card,
	)

/obj/effect/spawner/random/pool/gatewayloot/cult/valuable
	name = "valuable cult alike item"
	point_value = 60
	spawn_loot_chance = 100
	loot = list(
		/obj/item/book_of_babel,
		/obj/item/shared_storage/red,
		/obj/item/organ/internal/heart/cursed/wizard,
		/obj/item/nullrod/scythe/talking,
		/obj/item/nullrod/armblade/mining,
		/obj/item/tarot_card_pack,
		/obj/item/tarot_card_pack/jumbo,
		/obj/item/tarot_card_pack/mega,
		/obj/item/immortality_talisman,
		/obj/item/organ/internal/eyes/night_vision/nightmare,
	)

/obj/effect/spawner/random/pool/gatewayloot/rsg
	name = "rsg 60pc"
	icon_state = "stetchkin"
	point_value = 80
	spawn_loot_chance = 60
	loot = list(
		/obj/item/gun/syringe/rapidsyringe
	)

/obj/effect/spawner/random/pool/gatewayloot/immortality_ring
	point_value = 185
	loot = list(
		/obj/item/clothing/gloves/ring/immortality_ring
	)

/obj/effect/spawner/random/pool/spaceloot/mod/syndie/gateway
	spawn_pool = /datum/spawn_pool/gatewayloot
	record_spawn = FALSE
	loot = list(
		/obj/machinery/suit_storage_unit/syndicate/empty = 90,
		/obj/effect/spawner/random/pool/spaceloot/mod/syndie/traitor/gateway = 9,
		/obj/effect/spawner/random/pool/spaceloot/mod/syndie/elite/gateway = 1,
	)

/obj/effect/spawner/random/pool/spaceloot/mod/syndie/traitor/gateway
	spawn_pool = /datum/spawn_pool/gatewayloot
	record_spawn = FALSE

/obj/effect/spawner/random/pool/spaceloot/mod/syndie/elite/gateway
	spawn_pool = /datum/spawn_pool/gatewayloot
	record_spawn = FALSE

/obj/effect/spawner/random/pool/spaceloot/syndicate/common/gateway
	spawn_pool = /datum/spawn_pool/gatewayloot
	record_spawn = FALSE
	point_value = -1

/obj/effect/spawner/random/pool/spaceloot/syndicate/rare/gateway
	spawn_pool = /datum/spawn_pool/gatewayloot
	record_spawn = FALSE
	point_value = 20

/obj/effect/spawner/random/pool/spaceloot/syndicate/officer/gateway
	spawn_pool = /datum/spawn_pool/gatewayloot
	record_spawn = FALSE
	point_value = 55

/obj/effect/spawner/random/pool/spaceloot/syndicate/armory/gateway
	spawn_pool = /datum/spawn_pool/gatewayloot
	record_spawn = FALSE
	point_value = 100

/obj/effect/spawner/random/pool/gatewayloot/syndicate/mixed
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/syndicate/common/gateway = 30,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/rare/gateway = 20,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/officer/gateway = 5,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/armory/gateway,
	)

/obj/effect/spawner/random/pool/gatewayloot/syndicate/common_rare
	loot = list(
		/obj/effect/spawner/random/pool/spaceloot/syndicate/common/gateway = 3,
		/obj/effect/spawner/random/pool/spaceloot/syndicate/rare/gateway = 2,
	)

/obj/effect/spawner/random/pool/gatewayloot/lockbox
	point_value = 180
	loot = list(/obj/item/storage/lockbox/experimental_weapon/gateway)

/obj/effect/spawner/random/pool/gatewayloot/ammo_box/shotgun
	point_value = 20
	loot = list(
		/obj/item/storage/fancy/shell/buck = 4,
		/obj/item/storage/fancy/shell/slug,
	)

/obj/effect/spawner/random/pool/gatewayloot/speedloader
	point_value = 25
	loot = list(
		/obj/item/ammo_box/shotgun/buck = 4,
		/obj/item/ammo_box/shotgun,
	)

/obj/effect/spawner/random/pool/gatewayloot/proto_egun
	point_value = 100
	loot = list(/obj/item/gun/energy/e_gun/old)

/obj/effect/spawner/random/pool/gatewayloot/claymore
	point_value = 50
	loot = list(
		/obj/item/claymore/ceremonial = 6,
		/obj/item/nullrod/claymore = 3,
		/obj/item/claymore,
	)

/obj/effect/spawner/random/pool/gatewayloot/nt/handgun
	name = "enforcer 25pc"
	icon_state = "stetchkin"
	spawn_loot_chance = 75
	loot = list(
		/obj/effect/spawner/random/pool/gatewayloot/enforcer/mag = 2,
		/obj/effect/spawner/random/pool/gatewayloot/enforcer,
	)

/obj/effect/spawner/random/pool/gatewayloot/enforcer
	icon_state = "stetchkin"
	point_value = 85
	loot = list(/obj/item/gun/projectile/automatic/pistol/enforcer/lethal)

/obj/effect/spawner/random/pool/gatewayloot/enforcer/mag
	point_value = 15
	loot = list(/obj/item/ammo_box/magazine/enforcer/lethal)

/obj/effect/spawner/random/pool/gatewayloot/syndie_boss
	loot = list(
		/obj/item/toy/hampter/syndicate,
		/obj/effect/spawner/random/pool/gatewayloot/griefsky,
	)

/obj/effect/spawner/random/pool/gatewayloot/griefsky
	point_value = 150
	loot = list(/mob/living/simple_animal/bot/secbot/griefsky/syndie)

/obj/effect/spawner/random/pool/gatewayloot/mecha
	icon_state = "durand_old"

/obj/effect/spawner/random/pool/gatewayloot/mecha/mauler
	point_value = 160
	loot = list(/obj/mecha/combat/marauder/mauler/spacebattle)

/obj/effect/spawner/random/pool/gatewayloot/mecha/ripley_emagged
	point_value = 75
	loot = list(/obj/mecha/working/ripley/emagged)

/obj/effect/spawner/random/pool/gatewayloot/bluespace_tap/organic_mixed
	loot = list(
		/obj/effect/spawner/random/bluespace_tap/organic_common = 6,
		/obj/effect/spawner/random/pool/gatewayloot/bluespace_tap/organic_uncommon = 3,
		/obj/effect/spawner/random/pool/gatewayloot/bluespace_tap/organic_rare,
	)

/obj/effect/spawner/random/pool/gatewayloot/bluespace_tap/organic_uncommon
	point_value = 25
	loot = list(
		/obj/effect/spawner/random/bluespace_tap/organic_uncommon,
	)

/obj/effect/spawner/random/pool/gatewayloot/bluespace_tap/organic_rare
	point_value = 50
	loot = list(
		/obj/effect/spawner/random/bluespace_tap/organic_rare,
	)

/obj/effect/spawner/random/pool/gatewayloot/bluespace_tap/cultural_mixed
	loot = list(
		/obj/effect/spawner/random/bluespace_tap/cultural_common = 6,
		/obj/effect/spawner/random/bluespace_tap/cultural_uncommon = 3,
		/obj/effect/spawner/random/pool/gatewayloot/bluespace_tap/cultural_rare,
	)

/obj/effect/spawner/random/pool/gatewayloot/bluespace_tap/cultural_rare
	point_value = 60
	loot = list(
		/obj/effect/spawner/random/bluespace_tap/cultural_rare,
	)

/obj/effect/spawner/random/pool/gatewayloot/nt/corpse/security
	point_value = 30
	loot = list(/obj/effect/mob_spawn/human/corpse/spacebattle/security)

/obj/effect/spawner/random/pool/gatewayloot/nt/corpse/security/bridge
	loot = list(/obj/effect/mob_spawn/human/corpse/spacebattle/security/bridge)

/obj/effect/spawner/random/pool/gatewayloot/wish_granter
	point_value = 100
	loot = list(
		/obj/machinery/wish_granter_dark,
		/obj/item/dice/d20/fate/one_use,
	)

/obj/effect/spawner/random/pool/gatewayloot/ussp_major
	point_value = 100
	loot = list(
		/obj/item/gun/projectile/shotgun/boltaction = 54,
		/obj/item/clothing/suit/space/hardsuit/soviet = 30,
		/obj/item/clothing/mask/holo_cigar = 10,
		/obj/item/clothing/glasses/thermal/eyepatch = 5,

		/obj/item/gun/projectile/revolver/nagant, // ~1/100
	)

/obj/effect/spawner/random/pool/gatewayloot/syndicate/mob
	icon = 'icons/effects/spawner_icons.dmi'
	icon_state = "syndicate"
	loot = list(
		/obj/effect/spawner/random/pool/gatewayloot/syndicate/mob/common = 80,
		/obj/effect/spawner/random/pool/gatewayloot/syndicate/mob/modsuit = 19,

		// Let the massacre begin
		/obj/effect/spawner/random/pool/gatewayloot/syndicate/mob/elite, // 1%
	)

/obj/effect/spawner/random/pool/gatewayloot/syndicate/mob/common
	point_value = 3
	loot = list(
		/mob/living/simple_animal/hostile/syndicate/ranged = 4,
		/mob/living/simple_animal/hostile/syndicate = 3, // Melee is stronger than ranged variant most of the time
		/mob/living/simple_animal/hostile/syndicate/shield,
	)

// Used when we want our mob to be protected from environment pressure
/obj/effect/spawner/random/pool/gatewayloot/syndicate/mob/modsuit
	point_value = 6 // Modsuit chance
	loot = list(
		/mob/living/simple_animal/hostile/syndicate/modsuit,
		/mob/living/simple_animal/hostile/syndicate/modsuit/ranged,
	)

/obj/effect/spawner/random/pool/gatewayloot/syndicate/mob/elite
	point_value = 200 // Guaranteed armory-tier loot on death
	loot = list(/mob/living/simple_animal/hostile/syndicate/modsuit/elite)
