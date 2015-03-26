/datum/seed/slurrypod
	name = "slurrypod"
	seed_name = "slurrypod"
	display_name = "slurrypod"
	mutants = list("omegaslurrypod")
	packet_icon = "seed-slurrypod"
	plant_icon = "slurrypod"
	chems = list("toxin" = list(1,10))
	var/exploding = 0
	var/chem_splash = "toxin"
	harvest_repeat = 1

	lifespan = 25
	maturation = 6
	production = 6
	yield = 3
	potency = 20
/datum/seed/slurrypod/on_tick()
	if(prob(10) && !src.exploding)
		if(hydro_tray)
			if(hydro_tray.age >= maturation)
				exploding = 1
				hydro_tray.visible_message("<span class = 'danger'>The <b>[name]</b> begins to bubble and expand!</span>")
				sleep(100)
				hydro_tray.visible_message("<span class = 'danger'>The <b>[name]</b> bursts, sending toxic goop everywhere!</span>")
				for(var/mob/living/carbon/human/M in range(3,hydro_tray))
					M << "<span class = 'danger'>You are splashed by toxic goop!</span>"
					M.reagents.add_reagent(chem_splash, rand(5,20))
				for (var/obj/machinery/portable_atmospherics/hydroponics/T in range(3,hydro_tray))
					T.reagents.add_reagent(chem_splash, rand(5,10))