/obj/random
	name = "Random Object"
	desc = "This item type is used to spawn random objects at round-start"
	icon = 'icons/misc/mark.dmi'
	icon_state = "rup"
	var/spawn_nothing_percentage = 0 // this variable determines the likelyhood that this random object will not spawn anything


// creates a new object and deletes itself
/obj/random/New()
	..()
	if(!prob(spawn_nothing_percentage))
		spawn_item()
	qdel(src)


// this function should return a specific item to spawn
/obj/random/proc/item_to_spawn()
	return 0


// creates the random item
/obj/random/proc/spawn_item()
	var/build_path = item_to_spawn()
	return (new build_path(src.loc))


/obj/random/tool
	name = "Random Tool"
	desc = "This is a random tool"
	icon = 'icons/obj/items.dmi'
	icon_state = "welder"
	item_to_spawn()
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
	item_to_spawn()
		return pick(prob(5);/obj/item/t_scanner,\
					prob(2);/obj/item/radio/intercom,\
					prob(5);/obj/item/analyzer)


/obj/random/powercell
	name = "Random Powercell"
	desc = "This is a random powercell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_to_spawn()
		return pick(prob(10);/obj/item/stock_parts/cell/crap,\
					prob(40);/obj/item/stock_parts/cell,\
					prob(40);/obj/item/stock_parts/cell/high,\
					prob(9);/obj/item/stock_parts/cell/super,\
					prob(1);/obj/item/stock_parts/cell/hyper)


/obj/random/bomb_supply
	name = "Bomb Supply"
	desc = "This is a random bomb supply."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "signaller"
	item_to_spawn()
		return pick(/obj/item/assembly/igniter,\
					/obj/item/assembly/prox_sensor,\
					/obj/item/assembly/signaler)


/obj/random/toolbox
	name = "Random Toolbox"
	desc = "This is a random toolbox."
	icon = 'icons/obj/storage.dmi'
	icon_state = "red"
	item_to_spawn()
		return pick(prob(3);/obj/item/storage/toolbox/mechanical,\
					prob(2);/obj/item/storage/toolbox/electrical,\
					prob(1);/obj/item/storage/toolbox/emergency)


/obj/random/tech_supply
	name = "Random Tech Supply"
	desc = "This is a random piece of technology supplies."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	spawn_nothing_percentage = 50
	item_to_spawn()
		return pick(prob(3);/obj/random/powercell,\
					prob(2);/obj/random/technology_scanner,\
					prob(1);/obj/item/stack/packageWrap,\
					prob(2);/obj/random/bomb_supply,\
					prob(1);/obj/item/extinguisher,\
					prob(1);/obj/item/clothing/gloves/color/fyellow,\
					prob(3);/obj/item/stack/cable_coil,\
					prob(2);/obj/random/toolbox,\
					prob(2);/obj/item/storage/belt/utility,\
					prob(5);/obj/random/tool,\
					prob(3);/obj/item/stack/tape_roll)

/obj/random/laser
	name = "Random laser gun"
	desc = "This is a random weapon"
	icon = 'icons/obj/items.dmi'
	icon_state = "kit_1"
	item_to_spawn()
		return pick(prob(20);/obj/item/gun/energy/lasercannon,\
					prob(5);/obj/item/gun/energy/immolator,\
					prob(5);/obj/item/gun/energy/clown,\
					prob(10);/obj/item/gun/energy/disabler,\
					prob(14);/obj/item/gun/energy/gun/advtaser,\
					prob(10);/obj/item/gun/energy/laser/scatter,\
					prob(5);/obj/item/gun/energy/pulse,\
					prob(10);/obj/item/gun/energy/shock_revolver,\
					prob(10);/obj/item/melee/energy/blade,\
					prob(3);/obj/item/melee/candy_sword,\
					prob(3);/obj/item/reagent_containers/food/snacks/pie)

/obj/random/buff
	name = "Random Buff"
	desc = "Spawns random healing or speed buffs."
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity2"
	item_to_spawn()
		return pick(/obj/effect/mine/pickup/healing,\
					/obj/effect/mine/pickup/speed)

/obj/random/mine
	name = "Random mine"
	desc = "Spawns random mines, mostly stun but a chance of explosive and n2o."
	icon = 'icons/obj/items.dmi'
	icon_state = "uglyminearmed"
	item_to_spawn()
		return pick(prob(90);/obj/effect/mine/stun,\
					prob(8);/obj/effect/mine/gas/n2o,\
					prob(2);/obj/effect/mine/explosive,\
					/obj)


/obj/random/banana
	name = "Random banana"
	desc = "30% chance of spawning a banana"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana_peel"
	item_to_spawn()
		return pick(prob(38);/obj/item/grown/bananapeel,\
					prob(2);/obj/item/grown/bananapeel/bluespace,\
					prob(70);/obj)

