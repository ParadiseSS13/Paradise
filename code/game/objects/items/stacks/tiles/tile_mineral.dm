/obj/item/stack/tile/mineral/plasma
	name = "plasma tile"
	singular_name = "plasma floor tile"
	desc = "A tile made out of highly flammable plasma. This can only end well."
	icon_state = "tile_plasma"
	origin_tech = "plasmatech=1"
	turf_type = /turf/simulated/floor/mineral/plasma
	mineralType = "plasma"
	materials = list(MAT_PLASMA=500)

/obj/item/stack/tile/mineral/uranium
	name = "uranium tile"
	singular_name = "uranium floor tile"
	desc = "A tile made out of uranium. You feel a bit woozy."
	icon_state = "tile_uranium"
	turf_type = /turf/simulated/floor/mineral/uranium
	mineralType = "uranium"
	materials = list(MAT_URANIUM=500)

var/global/list/datum/stack_recipe/gold_tile_recipes = list ( \
	new/datum/stack_recipe("fancy gold tile", /obj/item/stack/tile/mineral/gold/fancy, max_res_amount = 20), \
	)

/obj/item/stack/tile/mineral/gold
	name = "gold tile"
	singular_name = "gold floor tile"
	desc = "A tile made out of gold, the swag seems strong here."
	icon_state = "tile_gold"
	turf_type = /turf/simulated/floor/mineral/gold
	mineralType = "gold"
	materials = list(MAT_GOLD=500)

/obj/item/stack/tile/mineral/gold/New(loc, amount=null)
	..()
	recipes = gold_tile_recipes

var/global/list/datum/stack_recipe/goldfancy_tile_recipes = list ( \
	new/datum/stack_recipe("regular gold tile", /obj/item/stack/tile/mineral/gold, max_res_amount = 20), \
	)

/obj/item/stack/tile/mineral/gold/fancy
	icon_state = "tile_goldfancy"
	turf_type = /turf/simulated/floor/mineral/gold/fancy

/obj/item/stack/tile/mineral/gold/fancy/New(loc, amount=null)
	..()
	recipes = goldfancy_tile_recipes

var/global/list/datum/stack_recipe/silver_tile_recipes = list ( \
	new/datum/stack_recipe("fancy silver tile", /obj/item/stack/tile/mineral/silver/fancy, max_res_amount = 20), \
	)

/obj/item/stack/tile/mineral/silver
	name = "silver tile"
	singular_name = "silver floor tile"
	desc = "A tile made out of silver, the light shining from it is blinding."
	icon_state = "tile_silver"
	turf_type = /turf/simulated/floor/mineral/silver
	mineralType = "silver"
	materials = list(MAT_SILVER=500)

/obj/item/stack/tile/mineral/silver/New(loc, amount=null)
	..()
	recipes = silver_tile_recipes

var/global/list/datum/stack_recipe/silverfancy_tile_recipes = list ( \
	new/datum/stack_recipe("regular silver tile", /obj/item/stack/tile/mineral/silver, max_res_amount = 20), \
	)

/obj/item/stack/tile/mineral/silver/fancy
	icon_state = "tile_silverfancy"
	turf_type = /turf/simulated/floor/mineral/silver/fancy

/obj/item/stack/tile/mineral/silver/fancy/New(loc, amount=null)
	..()
	recipes = silverfancy_tile_recipes

/obj/item/stack/tile/mineral/diamond
	name = "diamond tile"
	singular_name = "diamond floor tile"
	desc = "A tile made out of diamond. Wow, just, wow."
	icon_state = "tile_diamond"
	origin_tech = "materials=2"
	turf_type = /turf/simulated/floor/mineral/diamond
	mineralType = "diamond"
	materials = list(MAT_DIAMOND=500)

/obj/item/stack/tile/mineral/bananium
	name = "bananium tile"
	singular_name = "bananium floor tile"
	desc = "A tile made out of bananium, HOOOOOOOOONK!"
	icon_state = "tile_bananium"
	turf_type = /turf/simulated/floor/mineral/bananium
	mineralType = "bananium"
	materials = list(MAT_BANANIUM=500)

/obj/item/stack/tile/mineral/tranquillite
	name = "silent tile"
	singular_name = "silent floor tile"
	desc = "A tile made out of tranquillite, SHHHHHHHHH!"
	icon_state = "tile_tranquillite"
	turf_type = /turf/simulated/floor/mineral/tranquillite
	mineralType = "tranquillite"
	materials = list(MAT_TRANQUILLITE=500)

/obj/item/stack/tile/mineral/abductor
	name = "alien floor tile"
	singular_name = "alien floor tile"
	desc = "A tile made out of alien alloy."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "tile_abductor"
	origin_tech = "materials=6;abductor=1"
	turf_type = /turf/simulated/floor/mineral/abductor
	mineralType = "abductor"

/obj/item/stack/tile/mineral/titanium
	name = "titanium tile"
	singular_name = "titanium floor tile"
	desc = "A tile made of titanium, used for shuttles."
	icon_state = "tile_shuttle"
	turf_type = /turf/simulated/floor/mineral/titanium
	mineralType = "titanium"
	materials = list(MAT_TITANIUM=500)

/obj/item/stack/tile/mineral/titanium/purple
	turf_type = /turf/simulated/floor/mineral/titanium/purple
	icon_state = "tile_plasma"

/obj/item/stack/tile/mineral/plastitanium
	name = "plas-titanium tile"
	singular_name = "plas-titanium floor tile"
	desc = "A tile made of plas-titanium, used for very evil shuttles."
	icon_state = "tile_darkshuttle"
	turf_type = /turf/simulated/floor/mineral/plastitanium
	mineralType = "plastitanium"
	materials = list(MAT_TITANIUM=250, MAT_PLASMA=250)