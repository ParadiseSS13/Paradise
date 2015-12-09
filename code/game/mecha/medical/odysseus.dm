/obj/mecha/medical/odysseus
	desc = "These exosuits are developed and produced by Vey-Med. (&copy; All rights reserved)."
	name = "Odysseus"
	icon_state = "odysseus"
	initial_icon = "odysseus"
	step_in = 3
	max_temperature = 15000
	health = 120
	wreckage = /obj/effect/decal/mecha_wreckage/odysseus
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6
	var/obj/item/clothing/glasses/hud/health/mech/hud

	New()
		..()
		hud = new /obj/item/clothing/glasses/hud/health/mech(src)
		return

	moved_inside(var/mob/living/carbon/human/H as mob)
		if(..())
			if(H.glasses)
				occupant_message("<font color='red'>[H.glasses] prevent you from using [src] [hud]</font>")
			else
				H.glasses = hud
			return 1
		else
			return 0

	pilot_mmi_hud(var/mob/living/carbon/brain/pilot)
		pilot.regular_hud_updates()
		process_med_hud(pilot, 1)
		return ..()

	go_out()
		if(ishuman(occupant))
			var/mob/living/carbon/human/H = occupant
			if(H.glasses == hud)
				H.glasses = null
		..()
		return

//TODO - Check documentation for client.eye and client.perspective...
/obj/item/clothing/glasses/hud/health/mech
	name = "Integrated Medical Hud"
	HUDType = MEDHUD
