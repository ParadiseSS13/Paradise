/obj/effect/spawner/random/medical
	icon_state = "medical"
	record_spawn = TRUE

/obj/effect/spawner/random/medical/surgery_tool/common
	name = "Surgery tool spawner"
	icon_state = "scalpel"
	loot = list(
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/fix_o_vein,
		/obj/item/bonegel,
		/obj/item/bonesetter,
		/obj/item/cautery,
	)

/obj/effect/spawner/random/medical/surgery_tool/adv
	loot = list(
		/obj/item/scalpel/laser,
		/obj/item/surgical_drapes,
	)

/obj/effect/spawner/random/medical/surgery_tool
	loot = list(
		/obj/effect/spawner/random/medical/surgery_tool/common = 12,
		/obj/effect/spawner/random/medical/surgery_tool/adv = 1,
	)

/obj/effect/spawner/random/medical/beaker
	loot = list(
		/obj/item/reagent_containers/glass/beaker = 300,
		/obj/item/reagent_containers/glass/beaker/large = 200,
		/obj/item/reagent_containers/glass/beaker/noreact = 5,
		/obj/item/reagent_containers/glass/beaker/bluespace = 1,
	)

/obj/effect/spawner/random/medical/prosthetic
	loot = list(
		/obj/item/robot_parts/chest,
		/obj/item/robot_parts/head,
		/obj/item/robot_parts/l_arm,
		/obj/item/robot_parts/l_leg,
		/obj/item/robot_parts/r_arm,
		/obj/item/robot_parts/r_leg,
	)
