/obj/item/organ/internal/cyberimp/eyes
	name = "cybernetic eyes"
	desc = "artificial photoreceptors with specialized functionality"
	icon_state = "eye_implant"
	implant_overlay = "eye_implant_overlay"
	slot = "eye_sight"
	parent_organ = "eyes"
	w_class = 1

	var/vision_flags = 0
	var/list/eye_colour = list(0,0,0)
	var/list/old_eye_colour = list(0,0,0)
	var/flash_protect = 0
	var/aug_message = "Your vision is augmented!"


/obj/item/organ/internal/cyberimp/eyes/insert(var/mob/living/carbon/M, var/special = 0)
	..()
	if(aug_message && !special)
		to_chat(owner, "<span class='notice'>[aug_message]</span>")
	M.sight |= vision_flags

/obj/item/organ/internal/cyberimp/eyes/remove(var/mob/living/carbon/M, var/special = 0)
	. = ..()
	M.sight ^= vision_flags

/obj/item/organ/internal/cyberimp/eyes/on_life()
	..()
	owner.sight |= vision_flags

/obj/item/organ/internal/cyberimp/eyes/emp_act(severity)
	if(!owner)
		return
	if(severity > 1)
		if(prob(10 * severity))
			return
	to_chat(owner, "<span class='warning'>Static obfuscates your vision!</span>")
	owner.flash_eyes(visual = 1)



/obj/item/organ/internal/cyberimp/eyes/xray
	name = "X-ray implant"
	desc = "These cybernetic eye implants will give you X-ray vision. Blinking is futile."
	eye_colour = list(0, 0, 0)
	implant_color = "#000000"
	origin_tech = "materials=6;programming=4;biotech=6;magnets=5"
	vision_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS

/obj/item/organ/internal/cyberimp/eyes/thermals
	name = "Thermals implant"
	desc = "These cybernetic eye implants will give you Thermal vision. Vertical slit pupil included."
	eye_colour = list(255, 204, 0)
	implant_color = "#FFCC00"
	vision_flags = SEE_MOBS
	flash_protect = -1
	origin_tech = "materials=6;programming=4;biotech=5;magnets=5;syndicate=4"
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
	eye_colour = list(0,0,208)
	implant_color = "#00FFFF"
	origin_tech = "materials=4;programming=3;biotech=4"
	aug_message = "You suddenly see health bars floating above people's heads..."
	HUD_type = DATA_HUD_MEDICAL_ADVANCED

/obj/item/organ/internal/cyberimp/eyes/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	eye_colour = list(208,0,0)
	implant_color = "#CC0000"
	origin_tech = "materials=4;programming=4;biotech=3;combat=1"
	aug_message = "Job indicator icons pop up in your vision. That is not a certified surgeon..."
	HUD_type = DATA_HUD_SECURITY_ADVANCED

// Welding shield implant
/obj/item/organ/internal/cyberimp/eyes/shield
	name = "welding shield implant"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	slot = "eye_shield"
	origin_tech = "materials=4;biotech=3"
	implant_color = "#101010"
	flash_protect = 2
	// Welding with thermals will still hurt your eyes a bit.

/obj/item/organ/internal/cyberimp/eyes/shield/emp_act(severity)
	return
