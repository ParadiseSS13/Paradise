/obj/effect/spawner/random/plushies
	name = "plushie spawner"
	icon_state = "plushie"
	loot = list(
		list(
			/obj/item/toy/plushie/carpplushie/ice,
			/obj/item/toy/plushie/carpplushie/silent,
			/obj/item/toy/plushie/carpplushie/silent,
			/obj/item/toy/plushie/carpplushie/electric,
			/obj/item/toy/plushie/carpplushie/gold,
			/obj/item/toy/plushie/carpplushie/toxin,
			/obj/item/toy/plushie/carpplushie/dragon,
			/obj/item/toy/plushie/carpplushie/pink,
			/obj/item/toy/plushie/carpplushie/candy,
			/obj/item/toy/plushie/carpplushie/nebula,
			/obj/item/toy/plushie/carpplushie/void
		),

		list(
			/obj/item/toy/plushie/red_fox,
			/obj/item/toy/plushie/black_fox,
			/obj/item/toy/plushie/marble_fox,
			/obj/item/toy/plushie/blue_fox,
			/obj/item/toy/plushie/orange_fox,
			/obj/item/toy/plushie/coffee_fox,
			/obj/item/toy/plushie/pink_fox,
			/obj/item/toy/plushie/purple_fox,
			/obj/item/toy/plushie/crimson_fox
		),

		list(
			/obj/item/toy/plushie/corgi,
			/obj/item/toy/plushie/girly_corgi,
			/obj/item/toy/plushie/robo_corgi,
			/obj/item/toy/plushie/octopus,
			/obj/item/toy/plushie/face_hugger,
			/obj/item/toy/plushie/deer,
			/obj/item/toy/plushie/snakeplushie,
			/obj/item/toy/plushie/lizardplushie,
			/obj/item/toy/plushie/slimeplushie,
			/obj/item/toy/plushie/nukeplushie,
			/obj/item/toy/plushie/shark
		),

		list(
			/obj/item/toy/plushie/black_cat,
			/obj/item/toy/plushie/grey_cat,
			/obj/item/toy/plushie/white_cat,
			/obj/item/toy/plushie/orange_cat,
			/obj/item/toy/plushie/siamese_cat,
			/obj/item/toy/plushie/tabby_cat,
			/obj/item/toy/plushie/tuxedo_cat
		),

		list(// Species plushies minus Nian.
			/obj/item/toy/plushie/dionaplushie,
			/obj/item/toy/plushie/draskplushie,
			/obj/item/toy/plushie/greyplushie,
			/obj/item/toy/plushie/humanplushie,
			/obj/item/toy/plushie/kidanplushie,
			/obj/item/toy/plushie/ipcplushie,
			/obj/item/toy/plushie/plasmamanplushie,
			/obj/item/toy/plushie/skrellplushie,
			/obj/item/toy/plushie/voxplushie,
			/obj/item/toy/plushie/abductor,
			/obj/item/toy/plushie/abductor/agent,
			/obj/item/toy/plushie/borgplushie/random
		),

		list (
			/obj/item/toy/plushie/nianplushie = 3,
			/obj/item/toy/plushie/nianplushie/monarch = 2,
			/obj/item/toy/plushie/nianplushie/luna = 2,
			/obj/item/toy/plushie/nianplushie/atlas = 2,
			/obj/item/toy/plushie/nianplushie/reddish = 2,
			/obj/item/toy/plushie/nianplushie/royal = 2,
			/obj/item/toy/plushie/nianplushie/gothic = 2,
			/obj/item/toy/plushie/nianplushie/lovers = 2,
			/obj/item/toy/plushie/nianplushie/whitefly = 2,
			/obj/item/toy/plushie/nianplushie/punished = 2,
			/obj/item/toy/plushie/nianplushie/firewatch = 2,
			/obj/item/toy/plushie/nianplushie/deadhead = 2,
			/obj/item/toy/plushie/nianplushie/poison = 2,
			/obj/item/toy/plushie/nianplushie/ragged = 2,
			/obj/item/toy/plushie/nianplushie/snow = 2,
			/obj/item/toy/plushie/nianplushie/clockwork = 2,
			/obj/item/toy/plushie/nianplushie/moonfly = 2,
			/obj/item/toy/plushie/nianplushie/rainbow = 1
		),
	)

/obj/effect/spawner/random/plushies/explosive
	/// Chance to spawn a minibomb in the plushie.
	var/explosive_chance = 1

/obj/effect/spawner/random/plushies/explosive/make_item(spawn_loc, type_path_to_make)
	var/obj/item/toy/plushie/plushie = ..()

	if(!istype(plushie))
		return plushie

	if(prob(explosive_chance))
		plushie.has_stuffing = FALSE
		var/obj/item/grenade/syndieminibomb/grenade = new(plushie)
		plushie.grenade = grenade

	return plushie
