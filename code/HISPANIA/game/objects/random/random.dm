/obj/random/laser
	name = "Random laser gun"
	desc = "This is a random weapon"
	icon = 'icons/obj/items.dmi'
	icon_state = "kit_1"

/obj/random/laser/item_to_spawn()
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

/obj/random/buff/item_to_spawn()
		return pick(/obj/effect/mine/pickup/healing,\
					/obj/effect/mine/pickup/speed)

/obj/random/mine
	name = "Random mine"
	desc = "Spawns random mines, mostly stun but a chance of explosive and n2o."
	icon = 'icons/obj/items.dmi'
	icon_state = "uglyminearmed"

/obj/random/mine/item_to_spawn()
		return pick(prob(90);/obj/effect/mine/stun,\
					prob(8);/obj/effect/mine/gas/n2o,\
					prob(2);/obj/effect/mine/explosive,\
					prob (1);/obj/item/bikehorn/rubberducky)

/obj/random/banana
	name = "Random banana"
	desc = "30% chance of spawning a banana"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana_peel"

/obj/random/banana/item_to_spawn()
		return pick(prob(38);/obj/item/grown/bananapeel,\
					prob(2);/obj/item/grown/bananapeel/bluespace,\
					prob(70);/obj/item/bikehorn/rubberducky)
