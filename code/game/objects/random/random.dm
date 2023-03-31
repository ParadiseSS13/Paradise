// TODO: Refactor these into spawners
/obj/random
	name = "Random Object"
	desc = "This item type is used to spawn random objects at round-start"
	icon = 'icons/misc/mark.dmi'
	icon_state = "rup"
	var/spawn_nothing_percentage = 0 // this variable determines the likelyhood that this random object will not spawn anything


// creates a new object and deletes itself
/obj/random/Initialize(mapload)
	. = ..()
	if(!MAYBE)
		spawn_item()
	return INITIALIZE_HINT_QDEL


// this function should return a specific item to spawn
/obj/random/proc/item_to_spawn()
	return


// creates the random item
/obj/random/proc/spawn_item()
	var/build_path = item_to_spawn()
	return (new build_path(src.loc))


/obj/random/tool
	name = "Random Tool"
	desc = "This is a random tool"
	icon = 'icons/obj/tools.dmi'
	icon_state = "random_tool"

/obj/random/tool/item_to_spawn()
	return pick(/obj/item/screwdriver,\
				/obj/item/wirecutters,\
				/obj/item/weldingtool,\
				/obj/item/crowbar,\
				/obj/item/wrench,\
				/obj/item/flashlight)


/obj/random/technology_scanner
	name = "Random Scanner"
	desc = "This is a random technology scanner."
	icon = 'icons/obj/device.dmi'
	icon_state = "atmos"

/obj/random/technology_scanner/item_to_spawn()
	return pick(MAYBE;/obj/item/t_scanner,\
				MAYBE;/obj/item/radio/intercom,\
				MAYBE;/obj/item/analyzer)


/obj/random/powercell
	name = "Random Powercell"
	desc = "This is a random powercell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"

/obj/random/powercell/item_to_spawn()
	return pick(MAYBE;/obj/item/stock_parts/cell/crap,\
				MAYBE;/obj/item/stock_parts/cell,\
				MAYBE;/obj/item/stock_parts/cell/high,\
				MAYBE;/obj/item/stock_parts/cell/super,\
				MAYBE;/obj/item/stock_parts/cell/hyper)

/obj/random/bomb_supply
	name = "Bomb Supply"
	desc = "This is a random bomb supply."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "signaller"

/obj/random/bomb_supply/item_to_spawn()
	return pick(/obj/item/assembly/igniter,\
				/obj/item/assembly/prox_sensor,\
				/obj/item/assembly/signaler)


/obj/random/toolbox
	name = "Random Toolbox"
	desc = "This is a random toolbox."
	icon = 'icons/obj/storage.dmi'
	icon_state = "red"

/obj/random/toolbox/item_to_spawn()
	return pick(MAYBE;/obj/item/storage/toolbox/mechanical,\
				MAYBE;/obj/item/storage/toolbox/electrical,\
				MAYBE;/obj/item/storage/toolbox/emergency)

/obj/random/tech_supply
	name = "Random Tech Supply"
	desc = "This is a random piece of technology supplies."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	spawn_nothing_percentage = 50

/obj/random/tech_supply/item_to_spawn()
	return pick(MAYBE;/obj/random/powercell,\
				MAYBE;/obj/random/technology_scanner,\
				MAYBE;/obj/item/stack/packageWrap,\
				MAYBE;/obj/random/bomb_supply,\
				MAYBE;/obj/item/extinguisher,\
				MAYBE;/obj/item/clothing/gloves/color/fyellow,\
				MAYBE;/obj/item/stack/cable_coil,\
				MAYBE;/obj/random/toolbox,\
				MAYBE;/obj/item/storage/belt/utility,\
				MAYBE;/obj/random/tool,\
				MAYBE;/obj/item/stack/tape_roll)
