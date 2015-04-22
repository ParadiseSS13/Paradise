/datum/seed/puker
	name = "puker"
	seed_name = "puker"
	display_name = "puker"
	mutants = null
	packet_icon = "seed-puker"
	plant_icon = "puker"
	harvest_repeat = 1

	lifespan = 25
	maturation = 6
	production = 6
	yield = 0
	potency = 20
/datum/seed/puker/on_tick()
	if(prob(20))
		if(hydro_tray)
			if(hydro_tray.age >= maturation)
				hydro_tray.visible_message("<span class='warning'>The [name] vomits profusely!</span>")
				playsound(hydro_tray.loc, 'sound/effects/splat.ogg', 50, 1)
				var/turf/location = get_turf(hydro_tray)
				if(istype(location, /turf/simulated))
					location.add_vomit_floor(hydro_tray, 1)

/datum/seed/peeker
	name = "peeker"
	seed_name = "peeker"
	display_name = "peeker"
	mutants = null
	packet_icon = "seed-peeker"
	plant_icon = "peeker"
	harvest_repeat = 1

	lifespan = 25
	maturation = 6
	production = 6
	yield = 0
	potency = 20
/datum/seed/peeker/on_tick()
	if(prob(16))
		if(hydro_tray)
			if(hydro_tray.age >= maturation)
				var/list/stuff_to_look_at = list()
				for(var/mob/living/M in range(7,hydro_tray))
					stuff_to_look_at.Add(M)
				for(var/obj/item/O in range(7,hydro_tray))
					stuff_to_look_at.Add(O)
				if(stuff_to_look_at.len > 1) // The clown says "please stop staring at me plant :("
					hydro_tray.visible_message("<span class='warning'>The [name] stares at [pick(stuff_to_look_at)].</span>")

/datum/seed/dripper
	name = "dripper"
	seed_name = "dripper"
	display_name = "dripper"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/purplegoop)
	mutants = null
	packet_icon = "seed-dripper"
	plant_icon = "dripper"
	harvest_repeat = 1
	chems = list("plasma" = list(1,10))

	lifespan = 25
	maturation = 6
	production = 6
	yield = 3
	potency = 20

/datum/seed/light_lotus
	name = "light_lotus"
	seed_name = "light lotus"
	display_name = "light lotus"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/grown/glowfruit)
	mutants = null
	packet_icon = "seed-light_lotus"
	plant_icon = "light_lotus"
	harvest_repeat = 1
	chems = list("omnizine" = list(1,10))

	lifespan = 25
	maturation = 6
	production = 6
	yield = 2
	potency = 20