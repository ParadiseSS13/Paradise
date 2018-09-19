/obj/item/organ/internal/cyberimp/eyes
	name = "cybernetic eyes"
	desc = "artificial photoreceptors with specialized functionality"
	icon_state = "eye_implant"
	implant_overlay = "eye_implant_overlay"
	slot = "eye_sight"
	parent_organ = "eyes"
	w_class = WEIGHT_CLASS_TINY

	var/vision_flags = 0
	var/dark_view = 0
	var/see_invisible = 0
	var/eye_colour = "#000000"
	var/old_eye_colour = "#000000"
	var/flash_protect = 0
	var/aug_message = "Your vision is augmented!"


/obj/item/organ/internal/cyberimp/eyes/insert(var/mob/living/carbon/M, var/special = 0)
	..()
	var/mob/living/carbon/human/H = M
	if(istype(H) && eye_colour)
		H.update_body() //Apply our eye colour to the target.
	if(aug_message && !special)
		to_chat(owner, "<span class='notice'>[aug_message]</span>")
	M.update_sight()

/obj/item/organ/internal/cyberimp/eyes/remove(var/mob/living/carbon/M, var/special = 0)
	. = ..()
	M.update_sight()

/obj/item/organ/internal/cyberimp/eyes/proc/generate_icon(var/mob/living/carbon/human/HA)
	var/mob/living/carbon/human/H = HA
	if(!istype(H))
		H = owner
	var/icon/cybereyes_icon = new /icon('icons/mob/human_face.dmi', H.dna.species.eyes)
	cybereyes_icon.Blend(eye_colour, ICON_ADD) // Eye implants override native DNA eye color

	return cybereyes_icon

/obj/item/organ/internal/cyberimp/eyes/emp_act(severity)
	if(!owner || emp_proof)
		return
	if(severity > 1)
		if(prob(10 * severity))
			return
	to_chat(owner, "<span class='warning'>Static obfuscates your vision!</span>")
	owner.flash_eyes(visual = 1)

/obj/item/organ/internal/cyberimp/eyes/meson
	name = "Meson scanner implant"
	desc = "These cybernetic eyes will allow you to see the structural layout of the station, and, well, everything else."
	eye_colour = "#199900"
	implant_color = "#AEFF00"
	origin_tech = "materials=4;engineering=4;biotech=4;magnets=4"
	vision_flags = SEE_TURFS
	see_invisible = SEE_INVISIBLE_MINIMUM
	aug_message = "Suddenly, you realize how much of a mess the station really is..."

/obj/item/organ/internal/cyberimp/eyes/xray
	name = "X-ray implant"
	desc = "These cybernetic eye implants will give you X-ray vision. Blinking is futile."
	implant_color = "#000000"
	origin_tech = "materials=4;programming=4;biotech=6;magnets=4"
	vision_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	dark_view = 8
	see_invisible = SEE_INVISIBLE_MINIMUM

/obj/item/organ/internal/cyberimp/eyes/thermals
	name = "Thermals implant"
	desc = "These cybernetic eye implants will give you Thermal vision. Vertical slit pupil included."
	eye_colour = "#FFCC00"
	implant_color = "#FFCC00"
	vision_flags = SEE_MOBS
	flash_protect = -1
	origin_tech = "materials=5;programming=4;biotech=4;magnets=4;syndicate=1"
	aug_message = "You see prey everywhere you look..."

// HUD implants
/obj/item/organ/internal/cyberimp/eyes/hud
	name = "HUD implant"
	desc = "These cybernetic eyes will display a HUD over everything you see. Maybe."
	slot = "eye_hud"
	var/HUD_type = 0

/obj/item/organ/internal/cyberimp/eyes/hud/insert(var/mob/living/carbon/M, var/special = 0)
	..()
	if(HUD_type)
		var/datum/atom_hud/H = huds[HUD_type]
		H.add_hud_to(M)
		M.permanent_huds |= H

/obj/item/organ/internal/cyberimp/eyes/hud/remove(var/mob/living/carbon/M, var/special = 0)
	. = ..()
	if(HUD_type)
		var/datum/atom_hud/H = huds[HUD_type]
		M.permanent_huds ^= H
		H.remove_hud_from(M)

/obj/item/organ/internal/cyberimp/eyes/hud/medical
	name = "Medical HUD implant"
	desc = "These cybernetic eye implants will display a medical HUD over everything you see."
	eye_colour = "#0000D0"
	implant_color = "#00FFFF"
	origin_tech = "materials=4;programming=4;biotech=4"
	aug_message = "You suddenly see health bars floating above people's heads..."
	HUD_type = DATA_HUD_MEDICAL_ADVANCED

/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	name = "Diagnostic HUD implant"
	desc = "These cybernetic eye implants will display a diagnostic HUD over everything you see."
	eye_colour = "#723E02"
	implant_color = "#ff9000"
	origin_tech = "materials=4;engineering=4;biotech=4"
	aug_message = "You see the diagnostic information of the synthetics around you..."
	HUD_type = DATA_HUD_DIAGNOSTIC

/obj/item/organ/internal/cyberimp/eyes/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	eye_colour = "#D00000"
	implant_color = "#CC0000"
	origin_tech = "materials=4;programming=4;biotech=3;combat=3"
	aug_message = "Job indicator icons pop up in your vision. That is not a certified surgeon..."
	HUD_type = DATA_HUD_SECURITY_ADVANCED

// Welding shield implant
/obj/item/organ/internal/cyberimp/eyes/shield
	name = "welding shield implant"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	slot = "eye_shield"
	origin_tech = "materials=4;biotech=3;engineering=4;plasmatech=3"
	implant_color = "#101010"
	flash_protect = 2
	// Welding with thermals will still hurt your eyes a bit.

/obj/item/organ/internal/cyberimp/eyes/shield/emp_act(severity)
	return
