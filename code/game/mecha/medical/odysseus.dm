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
	var/builtin_hud_user = 0

	moved_inside(var/mob/living/carbon/human/H as mob)
		if(..())
			if(H.glasses && istype(H.glasses, /obj/item/clothing/glasses/hud))
				occupant_message("<span class='warning'>Your [H.glasses] prevent you from using the built-in medical hud.</span>")
			else
				var/datum/atom_hud/data/human/medical/advanced/A = huds[DATA_HUD_MEDICAL_ADVANCED]
				A.add_hud_to(H)
				builtin_hud_user = 1
			return 1
		else
			return 0

	mmi_moved_inside(var/obj/item/device/mmi/mmi_as_oc as obj,mob/user as mob)
		if(..())
			if(occupant.client)
				var/datum/atom_hud/A = huds[DATA_HUD_MEDICAL_ADVANCED]
				A.add_hud_to(occupant)
				builtin_hud_user = 1
			return 1
		else
			return 0

	go_out()
		if(istype(occupant,/mob/living/carbon/human)  && builtin_hud_user)
			var/mob/living/carbon/human/H = occupant
			var/datum/atom_hud/data/human/medical/advanced/A = huds[DATA_HUD_MEDICAL_ADVANCED]
			A.remove_hud_from(H)
			builtin_hud_user = 0
		else if ((istype(occupant, /mob/living/carbon/brain) || pilot_is_mmi()) && builtin_hud_user )
			var/mob/living/carbon/brain/H = occupant
			var/datum/atom_hud/A = huds[DATA_HUD_MEDICAL_ADVANCED]
			A.remove_hud_from(H)
			builtin_hud_user = 0

		..()
		return

//TODO - Check documentation for client.eye and client.perspective...
/obj/item/clothing/glasses/hud/health/mech
	name = "Integrated Medical Hud"
	HUDType = DATA_HUD_MEDICAL_ADVANCED
