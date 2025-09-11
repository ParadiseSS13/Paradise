// Скучный квас
/obj/structure/reagent_dispensers/kvassbarrel
	name = "бочка кваса"
	desc = "Бочка кваса. Такие в СССП можно встретить повсюду жарким летом."
	icon = 'modular_ss220/aesthetics/dispensers/icons/dispensers.dmi'
	icon_state = "kvassbarrel"
	reagent_id = "kvass"
	tank_volume = 1000
	anchored = FALSE
	face_while_pulling = FALSE

/datum/supply_packs/organic/kvassbarrel
	name = "Бочка безалкогольного кваса"
	contains = list(/obj/structure/reagent_dispensers/kvassbarrel)
	cost = 250
	containertype = /obj/structure/largecrate
	containername = "бочка безалкогольного кваса"

// Алкогольный квас
/obj/structure/reagent_dispensers/kvassbarrel/alcohol
	reagent_id = "alco_kvass"

/obj/structure/reagent_dispensers/kvassbarrel/alcohol/examine(mob/user)
	. = ..()
	if(user.Adjacent(src))
		. += span_notice("От этой веет спиртным запахом...")

/datum/supply_packs/organic/kvassbarrel/alcohol
	name = "Бочка алкогольного кваса"
	contains = list(/obj/structure/reagent_dispensers/kvassbarrel/alcohol)
	cost = 500
	containername = "бочка алкогольного кваса"
	contraband = TRUE
