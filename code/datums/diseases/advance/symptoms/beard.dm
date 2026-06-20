/*
//////////////////////////////////////
Facial Hypertrichosis

	Very very Noticable.
	Decreases resistance slightly.
	Decreases stage speed.
	Reduced transmittability
	Intense Level.

BONUS
	Makes the mob grow a massive beard, regardless of gender.

//////////////////////////////////////
*/

/datum/symptom/beard

	name = "Facial Hypertrichosis"
	stealth = -1
	stage_speed = 2
	transmissibility = -1
	level = 4
	severity = 1
	var/list/long_f_styles = list("Very Long Beard", "Dwarf Beard", "Skrell Overgrown",
		"Tajara Faded Goatee", "Dorsal Frills", "Vox Mane Beard", "Vulpine and Earfluff")
	var/list/medium_f_styles = list("Full Beard", "Skrell Full Beard", "Skrell Long Monotail",
		"Tajara Goatee", "Long Webbed Frills", "Neck Quills", "Vulpine")

/datum/symptom/beard/symptom_act(datum/disease/advance/A, unmitigated)
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		if(!istype(head_organ))
			return
		switch(A.stage)
			if(1, 2)
				to_chat(H, SPAN_WARNING("Your chin itches."))
				if(head_organ.f_style == "Shaved")
					switch(H.dna.species.name)
						if("Human")
							head_organ.f_style = "Adam Jensen Beard"
						if("Skrell")
							head_organ.f_style = "Skrell Monotail"
						if("Slime People")
							head_organ.f_style = "Adam Jensen Beard"
						if("Unathi")
							head_organ.f_style = "Short Webbed Frills"
						if("Vulpkanin")
							head_organ.f_style = "Ruff"
					H.update_fhair()
			if(3, 4)
				to_chat(H, SPAN_WARNING("You feel tough."))
				if(!(head_organ.f_style in long_f_styles) && !(head_organ.f_style in medium_f_styles))
					switch(H.dna.species.name)
						if("Human")
							head_organ.f_style = "Full Beard"
						if("Skrell")
							head_organ.f_style = pick("Skrell Full Beard", "Skrell Long Monotail")
						if("Slime People")
							head_organ.f_style = "Full Beard"
						if("Tajaran")
							head_organ.f_style = "Tajara Goatee"
						if("Unathi")
							head_organ.f_style = "Long Webbed Frills"
						if("Vox")
							head_organ.f_style = "Neck Quills"
						if("Vulpkanin")
							head_organ.f_style = "Vulpine"
					H.update_fhair()
			else
				to_chat(H, SPAN_WARNING("You feel manly!"))
				if(!(head_organ.f_style in long_f_styles))
					switch(H.dna.species.name)
						if("Human")
							head_organ.f_style = pick("Dwarf Beard", "Very Long Beard")
						if("Skrell")
							head_organ.f_style = "Skrell Overgrown"
						if("Slime People")
							head_organ.f_style = pick("Dwarf Beard", "Very Long Beard")
						if("Tajaran")
							head_organ.f_style = "Tajara Faded Goatee"
						if("Unathi")
							head_organ.f_style = "Dorsal Frills"
						if("Vox")
							head_organ.f_style = "Vox Mane Beard"
						if("Vulpkanin")
							head_organ.f_style = "Vulpine and Earfluff"
					H.update_fhair()
	return
