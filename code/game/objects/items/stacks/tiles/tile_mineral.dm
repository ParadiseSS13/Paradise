/obj/item/stack/tile/mineral/plasma
	name = "plasma tile"
	singular_name = "plasma floor tile"
	desc = "Flooring constructed from pure plasma crystal. There is absolutely nothing that can go wrong."
	icon_state = "tile_plasma"
	origin_tech = "plasmatech=1"
	turf_type = /turf/simulated/floor/mineral/plasma
	mineralType = "plasma"
	materials = list(MAT_PLASMA=500)

/obj/item/stack/tile/mineral/plasma/welder_act(mob/user, obj/item/I)
	if(I.use_tool(src, user, volume = I.tool_volume))
		atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 5)
		user.visible_message(SPAN_WARNING("[user.name] sets the plasma tiles on fire!"), \
							SPAN_WARNING("You set the plasma tiles on fire!"))
		message_admins("Plasma tiles ignited by [key_name_admin(user)](<A href='byond://?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A href='byond://?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) in ([x],[y],[z] - <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma tiles ignited by [key_name(user)] in ([x],[y],[z])")
		investigate_log("was <font color='red'><b>ignited</b></font> by [key_name(user)]",INVESTIGATE_ATMOS)
		qdel(src)

/obj/item/stack/tile/mineral/uranium
	name = "uranium tile"
	singular_name = "uranium floor tile"
	desc = "Flooring made from uranium. It's radioactive, IT'S RADIOACTIVE!"
	icon_state = "tile_uranium"
	turf_type = /turf/simulated/floor/mineral/uranium
	mineralType = "uranium"
	materials = list(MAT_URANIUM=500)

GLOBAL_LIST_INIT(gold_tile_recipes, list ( \
	new/datum/stack_recipe("fancy gold tile", /obj/item/stack/tile/mineral/gold/fancy, max_res_amount = 20), \
	))

/obj/item/stack/tile/mineral/gold
	name = "gold tile"
	singular_name = "gold floor tile"
	desc = "Flooring made of solid gold. It's only a matter of time before someone tries to steal it."
	icon_state = "tile_gold"
	turf_type = /turf/simulated/floor/mineral/gold
	mineralType = "gold"
	materials = list(MAT_GOLD=500)

/obj/item/stack/tile/mineral/gold/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.gold_tile_recipes

GLOBAL_LIST_INIT(goldfancy_tile_recipes, list ( \
	new/datum/stack_recipe("regular gold tile", /obj/item/stack/tile/mineral/gold, max_res_amount = 20), \
	))

/obj/item/stack/tile/mineral/gold/fancy
	icon_state = "tile_goldfancy"
	turf_type = /turf/simulated/floor/mineral/gold/fancy

/obj/item/stack/tile/mineral/gold/fancy/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.goldfancy_tile_recipes

GLOBAL_LIST_INIT(silver_tile_recipes, list ( \
	new/datum/stack_recipe("fancy silver tile", /obj/item/stack/tile/mineral/silver/fancy, max_res_amount = 20), \
	))

/obj/item/stack/tile/mineral/silver
	name = "silver tile"
	singular_name = "silver floor tile"
	desc = "Flooring made of solid silver. Not quite as valuable as gold, but still very snobby to use."
	icon_state = "tile_silver"
	turf_type = /turf/simulated/floor/mineral/silver
	mineralType = "silver"
	materials = list(MAT_SILVER=500)

/obj/item/stack/tile/mineral/silver/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.silver_tile_recipes

GLOBAL_LIST_INIT(silverfancy_tile_recipes, list ( \
	new/datum/stack_recipe("regular silver tile", /obj/item/stack/tile/mineral/silver, max_res_amount = 20), \
	))

/obj/item/stack/tile/mineral/silver/fancy
	icon_state = "tile_silverfancy"
	turf_type = /turf/simulated/floor/mineral/silver/fancy

/obj/item/stack/tile/mineral/silver/fancy/Initialize(mapload, new_amount, merge)
	. = ..()
	recipes = GLOB.silverfancy_tile_recipes

/obj/item/stack/tile/mineral/diamond
	name = "diamond tile"
	singular_name = "diamond floor tile"
	desc = "Flooring made out of pure diamond. Considering the large variety of industrial and scientific uses for diamond, this seems extremely wasteful."
	icon_state = "tile_diamond"
	origin_tech = "materials=2"
	turf_type = /turf/simulated/floor/mineral/diamond
	mineralType = "diamond"
	materials = list(MAT_DIAMOND=500)

/obj/item/stack/tile/mineral/bananium
	name = "bananium tile"
	singular_name = "bananium floor tile"
	desc = "Flooring constructed from pure bananium crystal. It squeaks with every step taken on it. Pressing into it causes it to HONK!"
	icon_state = "tile_bananium"
	turf_type = /turf/simulated/floor/mineral/bananium
	mineralType = "bananium"
	materials = list(MAT_BANANIUM=500)

/obj/item/stack/tile/mineral/tranquillite
	name = "silent tile"
	singular_name = "silent floor tile"
	desc = "Flooring constructed from pure tranquilite crystal. No matter how hard it is stamped on, no sound is produced."
	icon_state = "tile_tranquillite"
	turf_type = /turf/simulated/floor/mineral/tranquillite
	mineralType = "tranquillite"
	materials = list(MAT_TRANQUILLITE=500)

/obj/item/stack/tile/mineral/abductor
	name = "alien floor tile"
	desc = "Did we learn the secrets of building floors from an advanced alien civilization like this one?"
	singular_name = "alien floor tile"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "tile_abductor"
	origin_tech = "materials=6;abductor=1"
	turf_type = /turf/simulated/floor/mineral/abductor
	mineralType = "abductor"

/obj/item/stack/tile/mineral/titanium
	name = "titanium tile"
	singular_name = "titanium floor tile"
	desc = "Lightweight flooring made out of titanium, often used in spacecraft construction."
	icon_state = "tile_shuttle"
	turf_type = /turf/simulated/floor/mineral/titanium
	mineralType = "titanium"
	materials = list(MAT_TITANIUM=500)

/obj/item/stack/tile/mineral/titanium/purple
	turf_type = /turf/simulated/floor/mineral/titanium/purple
	icon_state = "tile_plasma"

/obj/item/stack/tile/mineral/plastitanium
	name = "plastitanium tile"
	singular_name = "plastitanium floor tile"
	desc = "Evil-looking flooring made out of plastitanium. Often used for constructing military-grade spacecraft."
	icon_state = "tile_darkshuttle"
	turf_type = /turf/simulated/floor/mineral/plastitanium
	mineralType = "plastitanium"
	materials = list(MAT_TITANIUM=250, MAT_PLASMA=250)
