/obj/effect/spawner/random/dice
	loot = list(
		/obj/item/dice/d4,
		/obj/item/dice/d6,
		/obj/item/dice/d8,
		/obj/item/dice/d10,
		/obj/item/dice/d12,
	)
	record_spawn = TRUE

/obj/effect/spawner/random/dice/Initialize()
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
		/obj/item/book/manual/wiki/chef_recipes,
		/obj/item/book/manual/wiki/engineering_construction,
		/obj/item/book/manual/wiki/engineering_guide,
		/obj/item/book/manual/wiki/experimentor,
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

/obj/effect/spawner/random/mod/maint
	name = "maint MOD module spawner"
	loot = list(
		/obj/item/mod/module/springlock = 2,
		/obj/item/mod/module/balloon = 1,
		/obj/item/mod/module/stamp = 1
	)
	record_spawn = TRUE

/obj/effect/spawner/random/janitor/supplies
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

