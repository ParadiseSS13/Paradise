/obj/effect/spawner/random/toy
	name = "random toy spawner"
	icon_state = "toy"

/obj/effect/spawner/random/toy/mech_figure
	name = "random mech figurine"
	loot_subtype_path = /obj/item/toy/figure/mech

/obj/effect/spawner/random/toy/action_figure
	name = "random action figure"
	loot_subtype_path = /obj/item/toy/figure/crew

/obj/effect/spawner/random/toy/carp_plushie
	name = "random carp plushie"
	loot_type_path = /obj/item/toy/plushie/carpplushie

/obj/effect/spawner/random/toy/therapy_doll
	name = "random therapy doll"
	loot_subtype_path = /obj/item/toy/therapy

/obj/effect/spawner/random/toy/clusterbuster
	loot = list(
		/obj/item/gun/projectile/shotgun/toy/crossbow,
		/obj/item/reagent_containers/spray/waterflower,
		/obj/item/toy/balloon,
		/obj/item/toy/spinningtoy,
	)
	loot_subtype_path = /obj/item/toy/figure/mech

// author requests these be exempt from maints loot. intended to be an off-station or beach-specific item
/obj/effect/spawner/random/toy/shell
	name = "random beach shell"
	loot_type_path = /obj/item/toy/shell

/obj/effect/spawner/random/toy/trading_card_pack
	name = "random trading card pack"
	icon_state = "cardpack"
	loot = list(
		/obj/item/cardpack/series_command = 2,
		/obj/item/cardpack/series_engineering = 3,
		/obj/item/cardpack/series_medical = 3,
		/obj/item/cardpack/series_research = 3,
		/obj/item/cardpack/series_security = 3,
		/obj/item/cardpack/series_service = 3,
		/obj/item/cardpack/series_supply = 3,
		/obj/item/cardpack/series_miscellaneous = 3,
		/obj/item/cardpack/series_syndicate = 1)
