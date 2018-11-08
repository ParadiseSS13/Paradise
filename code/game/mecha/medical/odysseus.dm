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
	normal_step_energy_drain = 6
	var/builtin_hud_user = 0

/obj/mecha/medical/odysseus/moved_inside(var/mob/living/carbon/human/H)
	. = ..()
	if(. && ishuman(H))
		if(istype(H.glasses, /obj/item/clothing/glasses/hud))
			occupant_message("<span class='warning'>[H.glasses] prevent you from using the built-in medical hud.</span>")
		else
			var/datum/atom_hud/data/human/medical/advanced/A = huds[DATA_HUD_MEDICAL_ADVANCED]
			A.add_hud_to(H)
			builtin_hud_user = 1

/obj/mecha/medical/odysseus/mmi_moved_inside(var/obj/item/mmi/mmi_as_oc, mob/user)
	. = ..()
	if(.)
		if(occupant.client)
			var/datum/atom_hud/A = huds[DATA_HUD_MEDICAL_ADVANCED]
			A.add_hud_to(occupant)
			builtin_hud_user = 1

/obj/mecha/medical/odysseus/go_out()
	if(ishuman(occupant) && builtin_hud_user)
		var/mob/living/carbon/human/H = occupant
		var/datum/atom_hud/data/human/medical/advanced/A = huds[DATA_HUD_MEDICAL_ADVANCED]
		A.remove_hud_from(H)
		builtin_hud_user = 0
	else if((isbrain(occupant) || pilot_is_mmi()) && builtin_hud_user)
		var/mob/living/carbon/brain/H = occupant
		var/datum/atom_hud/A = huds[DATA_HUD_MEDICAL_ADVANCED]
		A.remove_hud_from(H)
		builtin_hud_user = 0

	. = ..()