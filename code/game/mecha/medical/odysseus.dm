/obj/mecha/medical/odysseus
	desc = "These exosuits are developed and produced by DeForest Medical Corporation, for rescue operations."
	name = "Odysseus"
	icon_state = "odysseus"
	initial_icon = "odysseus"
	step_in = 3
	max_temperature = 15000
	max_integrity = 120
	wreckage = /obj/structure/mecha_wreckage/odysseus
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6
	normal_step_energy_drain = 6
	var/builtin_hud_user = 0

/obj/mecha/medical/odysseus/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(. && ishuman(H))
		if(istype(H.glasses, /obj/item/clothing/glasses/hud))
			occupant_message("<span class='warning'>[H.glasses] prevent you from using the built-in medical hud.</span>")
		else
			var/datum/atom_hud/data/human/medical/advanced/A = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
			A.add_hud_to(H)
			builtin_hud_user = 1

/obj/mecha/medical/odysseus/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user)
	. = ..()
	if(.)
		if(occupant.client)
			var/datum/atom_hud/A = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
			A.add_hud_to(occupant)
			builtin_hud_user = 1

/obj/mecha/medical/odysseus/go_out()
	if(ishuman(occupant) && builtin_hud_user)
		var/mob/living/carbon/human/H = occupant
		var/datum/atom_hud/data/human/medical/advanced/A = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		A.remove_hud_from(H)
		builtin_hud_user = 0
	else if((isbrain(occupant) || pilot_is_mmi()) && builtin_hud_user)
		var/mob/living/brain/H = occupant
		var/datum/atom_hud/A = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		A.remove_hud_from(H)
		builtin_hud_user = 0

	. = ..()

/obj/mecha/medical/odysseus/examine_more(mob/user)
	. = ..()
	. += "<i>The Odysseus is a relatively fast, lightweight, and easy-to-maintain exosuit developed by DeForest Medical Corporation. \
	Initially designed for patient rescue and care within hostile environments, it has seen semi-widespread use throughout the sector, usually by larger corporations and military groups who value its ability to get in and out of even the most rugged disaster zones.</i>"
	. += ""
	. += "<i>DeForest has seen modest success from the Odysseus, with only minor complaints arising from its sluggish pace and lack of armor or defensive capabilities. \
	Despite these flaws, it has found a home amid Nanotrasen medical teams, where Paramedics find solid uses for it and its varied equipment loadout. \
	As with all station-side mechs, Nanotrasen has purchased the license to produce the Odysseus in their facilities.</i>"
