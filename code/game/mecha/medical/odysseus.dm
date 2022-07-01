/obj/mecha/medical/odysseus
	desc = "These exosuits are developed and produced by Vey-Med. (&copy; All rights reserved)."
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

/obj/mecha/medical/odysseus/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(. && ishuman(H))
		if(istype(H.glasses, /obj/item/clothing/glasses/hud))
			occupant_message("<span class='warning'>[H.glasses] prevent you from using the built-in medical hud.</span>")
		else
			ADD_TRAIT(H, TRAIT_SEESHUD_MEDICAL, VEHICLE_TRAIT)

/obj/mecha/medical/odysseus/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user)
	. = ..()
	if(. && occupant)
		ADD_TRAIT(occupant, TRAIT_SEESHUD_MEDICAL, VEHICLE_TRAIT)

/obj/mecha/medical/odysseus/go_out()
	if(istype(occupant))
		REMOVE_TRAIT(occupant, TRAIT_SEESHUD_MEDICAL, VEHICLE_TRAIT)

	. = ..()
