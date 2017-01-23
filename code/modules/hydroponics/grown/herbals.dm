/obj/item/seeds/comfrey
	name = "pack of comfrey seeds"
	desc = "These seeds grow into comfrey."
	icon_state = "seed-cabbage"
	species = "cabbage"
	plantname = "comfrey"
	product = /obj/item/weapon/grown/holder_spawner/comfrey
	yield = 4
	maturation = 3
	growthstages = 1
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'

/obj/item/weapon/grown/holder_spawner/comfrey
	spawned_thing = /obj/item/stack/medical/bruise_pack/comfrey

/obj/item/weapon/grown/holder_spawner/comfrey/alter_stats(obj/item/stack/medical/bruise_pack/comfrey/C)
	C.heal_brute = seed.potency


/obj/item/seeds/aloe
	name = "pack of aloe seeds"
	desc = "These seeds grow into aloe vera plant."
	icon_state = "seed-ambrosiavulgaris"
	species = "ambrosiavulgaris"
	plantname = "Aloe Vera Plant"
	product = /obj/item/weapon/grown/holder_spawner/aloe
	yield = 4
	icon_dead = "ambrosia-dead"

/obj/item/weapon/grown/holder_spawner/aloe
	spawned_thing = /obj/item/stack/medical/ointment/aloe

/obj/item/weapon/grown/holder_spawner/aloe/alter_stats(obj/item/stack/medical/ointment/aloe/A)
	A.heal_burn = seed.potency