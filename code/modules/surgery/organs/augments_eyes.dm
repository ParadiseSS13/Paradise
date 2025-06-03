/obj/item/organ/internal/cyberimp/eyes
	name = "cybernetic eyes"
	desc = "artificial photoreceptors with specialized functionality."
	icon_state = "eye_implant"
	slot = "eye_sight"
	parent_organ = "eyes"
	w_class = WEIGHT_CLASS_TINY
	var/aug_message = "Your vision is augmented!"

/obj/item/organ/internal/cyberimp/eyes/insert(mob/living/carbon/M, special = FALSE)
	..()
	if(aug_message && !special)
		to_chat(owner, "<span class='notice'>[aug_message]</span>")

// HUD implants
/obj/item/organ/internal/cyberimp/eyes/hud
	name = "HUD implant"
	desc = "These cybernetic eyes will display a HUD over everything you see. Maybe."
	slot = "eye_hud"
	var/HUD_type = 0
	/// A list of extension kinds added to the examine text. Things like medical or security records.

/obj/item/organ/internal/cyberimp/eyes/hud/insert(mob/living/carbon/M, special = 0)
	..()
	if(HUD_type)
		var/datum/atom_hud/H = GLOB.huds[HUD_type]
		H.add_hud_to(M)
		M.permanent_huds |= H

/obj/item/organ/internal/cyberimp/eyes/hud/remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(HUD_type)
		var/datum/atom_hud/H = GLOB.huds[HUD_type]
		M.permanent_huds ^= H
		H.remove_hud_from(M)

/obj/item/organ/internal/cyberimp/eyes/hud/medical
	name = "Medical HUD implant"
	desc = "These cybernetic eye implants will display a medical HUD over everything you see."
	icon_state = "eye_implant_medical"
	origin_tech = "materials=4;programming=4;biotech=4"
	aug_message = "You suddenly see health bars floating above people's heads..."
	HUD_type = DATA_HUD_MEDICAL_ADVANCED

/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	name = "Diagnostic HUD implant"
	desc = "These cybernetic eye implants will display a diagnostic HUD over everything you see."
	icon_state = "eye_implant_diagnostic"
	origin_tech = "materials=4;engineering=4;biotech=4"
	aug_message = "You see the diagnostic information of the synthetics around you..."
	HUD_type = DATA_HUD_DIAGNOSTIC_ADVANCED

/obj/item/organ/internal/cyberimp/eyes/hud/skill
	name = "Employment HUD implant"
	desc = "These cybernetic eye implants will display an employment HUD over everything you see."
	icon_state = "eye_implant_skill"
	origin_tech = "materials=4;programming=4;biotech=3"
	aug_message = "Employment records pop up next to everyone. So many cases of surgical malpractice..."
	HUD_type = DATA_HUD_SECURITY_BASIC

/obj/item/organ/internal/cyberimp/eyes/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	icon_state = "eye_implant_security"
	origin_tech = "materials=4;programming=4;biotech=3;combat=3"
	aug_message = "Job indicator icons pop up in your vision. That is not a certified surgeon..."
	HUD_type = DATA_HUD_SECURITY_ADVANCED

/obj/item/organ/internal/cyberimp/eyes/hud/security/hidden
	stealth_level = 4 // Only surgery or a body scanner with the highest tier of stock parts can detect this.

/obj/item/organ/internal/cyberimp/eyes/hud/jani
	name = "Janitor HUD implant"
	desc = "These cybernetic eye implants will display a filth HUD over everything you see."
	icon_state = "eye_implant_janitor"
	origin_tech = "materials=4;engineering=4;biotech=4"
	aug_message = "You scan for filth spots around you..."
	HUD_type = DATA_HUD_JANITOR

/obj/item/organ/internal/cyberimp/eyes/hud/hydroponic
	name = "Hydroponic HUD implant"
	desc = "These cybernetic eye implants will display a botanical HUD over everything you see."
	icon_state = "eye_implant_hydro"
	origin_tech = "materials=4;magnets=4;biotech=4"
	aug_message = "You scan for non-plastic plants around you..."
	HUD_type = DATA_HUD_HYDROPONIC
