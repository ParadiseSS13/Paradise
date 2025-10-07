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
