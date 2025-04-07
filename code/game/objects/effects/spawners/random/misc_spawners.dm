/obj/effect/spawner/random/dice
	loot = list(
		/obj/item/dice/d4,
		/obj/item/dice/d6,
		/obj/item/dice/d8,
		/obj/item/dice/d10,
		/obj/item/dice/d12,
	)
	record_spawn = TRUE

/obj/effect/spawner/random/dice/Initialize(mapload)
	. = ..()
	spawn_loot_count = rand(1, 2)

/obj/effect/spawner/random/bureaucracy
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "folder"
	name = "bureaucracy spawner"
	loot = list(
		/obj/item/hand_labeler,
		/obj/item/hand_labeler_refill,
		/obj/item/stack/tape_roll,
		/obj/item/paper_bin,
		/obj/item/pen,
		/obj/item/pen/blue,
		/obj/item/pen/red,
		/obj/item/folder/blue,
		/obj/item/folder/red,
		/obj/item/folder/yellow,
		/obj/item/clipboard,
	)
	record_spawn = TRUE

/obj/effect/spawner/random/book
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "book"
	name = "book spawner"
	loot = list(
		/obj/item/book/manual/atmospipes,
		/obj/item/book/manual/barman_recipes,
		/obj/item/book/manual/detective,
		/obj/item/book/manual/engineering_particle_accelerator,
		/obj/item/book/manual/engineering_singularity_safety,
		/obj/item/book/manual/evaguide,
		/obj/item/book/manual/hydroponics_pod_people,
		/obj/item/book/manual/medical_cloning,
		/obj/item/book/manual/research_and_development,
		/obj/item/book/manual/ripley_build_and_repair,
		/obj/item/book/manual/supermatter_engine,
		/obj/item/book/manual/wiki/botanist,
		/obj/item/book/manual/wiki/engineering_construction,
		/obj/item/book/manual/wiki/engineering_guide,
		/obj/item/book/manual/wiki/faxes,
		/obj/item/book/manual/wiki/hacking,
		/obj/item/book/manual/wiki/hydroponics,
		/obj/item/book/manual/wiki/robotics_cyborgs,
		/obj/item/book/manual/wiki/security_space_law,
		/obj/item/book/manual/wiki/security_space_law/black,
		/obj/item/book/manual/wiki/sop_command,
		/obj/item/book/manual/wiki/sop_engineering,
		/obj/item/book/manual/wiki/sop_general,
		/obj/item/book/manual/wiki/sop_legal,
		/obj/item/book/manual/wiki/sop_medical,
		/obj/item/book/manual/wiki/sop_science,
		/obj/item/book/manual/wiki/sop_security,
		/obj/item/book/manual/wiki/sop_service,
		/obj/item/book/manual/wiki/sop_supply,
		/obj/item/book/manual/zombie_manual,
	)
	record_spawn = TRUE

/obj/effect/spawner/random/book/record_item(type_path_to_make)
	SSblackbox.record_feedback("tally", "random_spawners", 1, "[/obj/item/book]")

/obj/effect/spawner/random/mod_maint
	name = "maint MOD module spawner"
	loot = list(
		/obj/item/mod/module/springlock = 2,
		/obj/item/mod/module/balloon = 1,
		/obj/item/mod/module/stamp = 1
	)
	record_spawn = TRUE

/obj/effect/spawner/random/jani_supplies
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "mopbucket"
	name = "janitorial supplies spawner"
	loot = list(
		/obj/item/storage/box/mousetraps,
		/obj/item/storage/box/lights/tubes,
		/obj/item/storage/box/lights/mixed,
		/obj/item/storage/box/lights/bulbs,
	)
	record_spawn = TRUE

/obj/effect/spawner/random/stock_parts
	name = "stock parts spawner"
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "stock_parts"
	loot_subtype_path = /obj/item/stock_parts

/obj/effect/spawner/random/stock_parts/Initialize(mapload)
	spawn_loot_count = rand(4, 7)
	. = ..()

/obj/effect/spawner/random/glowstick
	name = "random glowstick spawner"
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "glowstick"
	loot = list(
		/obj/item/flashlight/flare/glowstick,
		/obj/item/flashlight/flare/glowstick/red,
		/obj/item/flashlight/flare/glowstick/blue,
		/obj/item/flashlight/flare/glowstick/orange,
		/obj/item/flashlight/flare/glowstick/yellow,
		/obj/item/flashlight/flare/glowstick/pink,
	)

/obj/effect/spawner/random/smithed_item
	name = "random smithed item"
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "metal"
	record_spawn = TRUE

	/// Weighted list of possible item qualities
	var/static/list/smithed_item_qualities = list(
		/datum/smith_quality = 9,
		/datum/smith_quality/improved = 1
	)
	/// Weighted list of possible item materials
	var/static/list/smithed_item_materials = list(
		/datum/smith_material/metal = 40,
		/datum/smith_material/silver = 10,
		/datum/smith_material/gold = 5,
		/datum/smith_material/plasma = 10,
		/datum/smith_material/titanium = 5,
		/datum/smith_material/uranium = 3,
		/datum/smith_material/brass = 15
	)

/obj/effect/spawner/random/smithed_item/make_item(spawn_loc, type_path_to_make)
	var/obj/item/smithed_item/new_item = ..()
	new_item.quality = pickweight(smithed_item_qualities)
	new_item.material = pickweight(smithed_item_materials)
	new_item.set_stats()
	new_item.update_appearance(UPDATE_NAME)

	return new_item

/obj/effect/spawner/random/smithed_item/any
	loot = list(
		/obj/item/smithed_item/insert/ballistic,
		/obj/item/smithed_item/insert/thermal,
		/obj/item/smithed_item/insert/fireproofing,
		/obj/item/smithed_item/insert/reflective,
		/obj/item/smithed_item/insert/rad_hazard,
		/obj/item/smithed_item/insert/rubberized,
		/obj/item/smithed_item/tool_bit/speed,
		/obj/item/smithed_item/tool_bit/balanced,
		/obj/item/smithed_item/tool_bit/efficiency,
		/obj/item/smithed_item/lens/accelerator,
		/obj/item/smithed_item/lens/speed,
		/obj/item/smithed_item/lens/amplifier,
		/obj/item/smithed_item/lens/efficiency
	)

/obj/effect/spawner/random/smithed_item/insert
	name = "random smithed insert"
	loot = list(
		/obj/item/smithed_item/insert/ballistic,
		/obj/item/smithed_item/insert/thermal,
		/obj/item/smithed_item/insert/fireproofing,
		/obj/item/smithed_item/insert/reflective,
		/obj/item/smithed_item/insert/rad_hazard,
		/obj/item/smithed_item/insert/rubberized
	)

/obj/effect/spawner/random/smithed_item/bit
	name = "random smithed tool bit"
	loot = list(
		/obj/item/smithed_item/tool_bit/speed,
		/obj/item/smithed_item/tool_bit/balanced,
		/obj/item/smithed_item/tool_bit/efficiency
	)

/obj/effect/spawner/random/smithed_item/lens
	name = "random smithed lens"
	loot = list(
		/obj/item/smithed_item/lens/accelerator,
		/obj/item/smithed_item/lens/speed,
		/obj/item/smithed_item/lens/amplifier,
		/obj/item/smithed_item/lens/efficiency
	)
