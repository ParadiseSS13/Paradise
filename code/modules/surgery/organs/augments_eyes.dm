/obj/item/organ/internal/cyberimp/eyes
	name = "cybernetic eyes"
	desc = "artificial photoreceptors with specialized functionality"
	icon_state = "eye_implant"
	implant_overlay = "eye_implant_overlay"
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
	var/seeshud_trait = null  /// TRAIT_SEESHUD_FOO that would show you the hud icons you want to see.
	/// A list of extension kinds added to the examine text. Things like medical or security records.
	var/list/examine_extensions = null

/obj/item/organ/internal/cyberimp/eyes/hud/insert(mob/living/carbon/M, special = 0)
	..()
	if(seeshud_trait)
		ADD_TRAIT(M, seeshud_trait, "[CLOTHING_TRAIT][UID()]")

/obj/item/organ/internal/cyberimp/eyes/hud/remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(seeshud_trait)
		REMOVE_TRAIT(M, seeshud_trait, "[CLOTHING_TRAIT][UID()]")

/obj/item/organ/internal/cyberimp/eyes/hud/medical
	name = "Medical HUD implant"
	desc = "These cybernetic eye implants will display a medical HUD over everything you see."
	implant_color = "#00FFFF"
	origin_tech = "materials=4;programming=4;biotech=4"
	aug_message = "You suddenly see health bars floating above people's heads..."
	seeshud_trait = TRAIT_SEESHUD_MEDICAL
	examine_extensions = list(EXAMINE_HUD_MEDICAL)

/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	name = "Diagnostic HUD implant"
	desc = "These cybernetic eye implants will display a diagnostic HUD over everything you see."
	implant_color = "#ff9000"
	origin_tech = "materials=4;engineering=4;biotech=4"
	aug_message = "You see the diagnostic information of the synthetics around you..."
	seeshud_trait = TRAIT_SEESHUD_DIAGNOSTIC_ADVANCED

/obj/item/organ/internal/cyberimp/eyes/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	implant_color = "#CC0000"
	origin_tech = "materials=4;programming=4;biotech=3;combat=3"
	aug_message = "Job indicator icons pop up in your vision. That is not a certified surgeon..."
	seeshud_trait = TRAIT_SEESHUD_SECURITY
	examine_extensions = list(EXAMINE_HUD_SECURITY_READ, EXAMINE_HUD_SECURITY_WRITE)
