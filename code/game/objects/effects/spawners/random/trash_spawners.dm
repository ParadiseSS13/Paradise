/// Food trash spawner, for when you specifically want it to look like someone
/// didn't clean up after themselves after lunch.
/obj/effect/spawner/random/food_trash
	icon_state = "tray"
	name = "Food trash spawner"
	loot = list(
		/obj/item/trash/bowl,
		/obj/item/trash/candle,
		/obj/item/trash/candy,
		/obj/item/trash/cheesie,
		/obj/item/trash/chips,
		/obj/item/trash/fried_vox,
		/obj/item/trash/gum,
		/obj/item/trash/liquidfood,
		/obj/item/trash/pistachios,
		/obj/item/trash/plate,
		/obj/item/trash/popcorn,
		/obj/item/trash/popsicle_stick,
		/obj/item/trash/raisins,
		/obj/item/trash/semki,
		/obj/item/trash/snack_bowl,
		/obj/item/trash/sosjerky,
		/obj/item/trash/spacetwinkie,
		/obj/item/trash/syndi_cakes,
		/obj/item/trash/tastybread,
		/obj/item/trash/tray,
		/obj/item/trash/twimsts,
		/obj/item/trash/waffles,
	)

	spawn_random_angle = TRUE
	record_spawn = TRUE

/obj/effect/spawner/random/food_trash/record_item(type_path_to_make)
	SSblackbox.record_feedback("tally", "random_spawners", 1, "[/obj/item/trash]")

/obj/effect/spawner/random/trash
	icon_state = "trash"

	name = "Trash spawner"
	loot = list(
		// Food litter often
		/obj/effect/spawner/random/food_trash = 8,

		// Some regular trash
		list(
			/obj/item/broken_bottle,
			/obj/item/cigbutt,
			/obj/item/cigbutt/roach,
			/obj/item/flashlight/flare/glowstick/used,
			/obj/item/flashlight/flare/used,
			/obj/item/paper/crumpled,
			/obj/item/shard,
			/obj/item/trash/tapetrash,
		) = 5,

		// Ammo casings rarely
		list(
			/obj/item/trash/spentcasing/shotgun,
			/obj/item/trash/spentcasing/shotgun/rubbershot,
			/obj/item/trash/spentcasing/shotgun/beanbag,
			/obj/item/trash/spentcasing/shotgun/slug,
			/obj/item/trash/spentcasing/shotgun/dragonsbreath,
			/obj/item/trash/spentcasing/shotgun/stun,
			/obj/item/trash/spentcasing/bullet,
			/obj/item/trash/spentcasing/bullet/medium,
			/obj/item/trash/spentcasing/bullet/large,
			/obj/item/trash/spentcasing/bullet/lasershot
		) = 1,
	)

	// TODO: Random spawner scatter behavior doesn't work well with items in
	// containers or on dense objects like racks. Fix up so we can scatter trash.
	spawn_random_angle = TRUE
	spawn_random_offset = TRUE
	spawn_random_offset_max_pixels = 8

/obj/effect/spawner/random/trash/record_item(type_path_to_make)
	if(istype(type_path_to_make, /obj/effect/spawner))
		return

	SSblackbox.record_feedback("tally", "random_spawners", 1, "[/obj/item/trash]")
