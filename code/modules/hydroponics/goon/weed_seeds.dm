/datum/seed/slurrypod
	name = "slurrypod"
	seed_name = "slurrypod"
	display_name = "slurrypod"
	mutants = list("omegaslurrypod")
	packet_icon = "seed-slurrypod"
	plant_icon = "slurrypod"
	chems = list("toxic_slurry" = list(1,10))
	var/exploding = 0
	var/chem_splash = "toxic_slurry"
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

/datum/seed/slurrypod/omega_slurrypod
	name = "omega_slurrypod"
	seed_name = "omega_slurrypod"
	display_name = "omega slurrypod"
	mutants = null
	packet_icon = "seed-omega_slurrypod"
	plant_icon = "omega_slurrypod"
	chems = list("glowing_slurry" = list(1,10))
	chem_splash = "glowing_slurry"

/datum/seed/lasher
	name = "lasher"
	seed_name = "lasher"
	display_name = "lasher"
	packet_icon = "seed-lasher"
	plant_icon = "lasher"
	lifespan = 25
	maturation = 6
	production = 0
	yield = 0
/datum/seed/lasher/on_tick()
	if(prob(10))
		if(hydro_tray)
			if(hydro_tray.age >= maturation)
				for(var/mob/living/carbon/human/M in range(1,hydro_tray))
					hydro_tray.visible_message("<span class = 'danger'>The <b>[name]</b> slashes [M] with thorny vines!</span>")
					M << "<span class = 'danger'>You are lashed by the plant!</span>"
					M.adjustBruteLoss(3)
/datum/seed/lasher/on_attack(var/mob/living/user, var/obj/item/I)
	if(I && prob(50))
		if(hydro_tray.age >= maturation)
			user.drop_item()
			qdel(I)
			user << "<span class = 'notice'>The lasher grabs and smashes your [I]!"
			return