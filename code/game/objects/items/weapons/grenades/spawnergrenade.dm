/obj/item/grenade/spawnergrenade
	name = "delivery grenade"
	desc = "Upon detonation, this will unleash an unspecified anomaly into the vicinity."
	icon_state = "delivery"
	origin_tech = "materials=3;magnets=4"
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver
	var/flash_viewers = TRUE
	spawner_type = /mob/living/basic/viscerator

/obj/item/grenade/spawnergrenade/prime() // Prime now just handles the two loops that query for people in lockers and people who can see it.

	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		if(flash_viewers)
			for(var/mob/living/carbon/C in viewers(T, null))
				C.flash_eyes()

		for(var/i in 1 to deliveryamt)
			var/atom/movable/x = new spawner_type(T)
			x.admin_spawned = admin_spawned
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(x, pick(NORTH,SOUTH,EAST,WEST))

			// Spawn some hostile syndicate critters

	qdel(src)
	return

/obj/item/grenade/spawnergrenade/manhacks
	name = "viscerator delivery grenade"
	desc = "This grenade contains 5 viscerators, tiny flying drones with lethally sharp blades. Upon detonation, they will be deployed and begin searching the area for targets."
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=3"

/obj/item/grenade/spawnergrenade/spesscarp
	name = "carp delivery grenade"
	desc = "This grenade contains 5 dehydrated space carp in a similar manner to dehydrated monkeys, which, upon detonation, \
	will be rehydrated by a small reservoir of water contained within the grenade. These space carp will then attack anything in sight."
	spawner_type = /mob/living/basic/carp
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=3"

/obj/item/grenade/spawnergrenade/feral_cats
	name = "feral cat delivery grenade"
	desc = "This grenade contains 5 dehydrated feral cats in a similar manner to dehydrated monkeys, which, upon detonation, \
	will be rehydrated by a small reservoir of water contained within the grenade. These cats will then attack anything in sight."
	spawner_type = /mob/living/basic/feral_cat
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=3"
	flash_viewers = FALSE
