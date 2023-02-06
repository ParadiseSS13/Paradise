/obj/item/organ/internal/eyes
	name = "eyeballs"
	icon_state = "eyes"
	gender = PLURAL
	organ_tag = "eyes"
	parent_organ = "head"
	slot = "eyes"
	var/eye_colour = "#000000" // Should never be null
	var/list/colourmatrix = null
	var/list/colourblind_matrix = MATRIX_GREYSCALE //Special colourblindness parameters. By default, it's black-and-white.
	var/list/replace_colours = GREYSCALE_COLOR_REPLACE
	var/dependent_disabilities = list() //Gets set by eye-dependent disabilities such as colourblindness so the eyes can transfer the disability during transplantation.
	var/weld_proof = null //If set, the eyes will not take damage during welding. eg. IPC optical sensors do not take damage when they weld things while all other eyes will.

	var/vision_flags = 0
	var/see_in_dark = 2
	var/see_invisible = SEE_INVISIBLE_LIVING
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE

/obj/item/organ/internal/eyes/proc/update_colour()
	dna.write_eyes_attributes(src)

/obj/item/organ/internal/eyes/proc/generate_icon(var/mob/living/carbon/human/HA)
	var/mob/living/carbon/human/H = HA
	if(!istype(H))
		H = owner
	var/icon/eyes_icon = new /icon('icons/mob/human_face.dmi', H.dna.species.eyes)
	eyes_icon.Blend(eye_colour, ICON_ADD)

	return eyes_icon

/obj/item/organ/internal/eyes/proc/get_colourmatrix() //Returns a special colour matrix if the eyes are organic and the mob is colourblind, otherwise it uses the current one.
	if(!is_robotic() && (COLOURBLIND in owner.mutations))
		return colourblind_matrix
	else
		return colourmatrix

/obj/item/organ/internal/eyes/proc/shine()
	if(is_robotic() || (see_in_dark > EYE_SHINE_THRESHOLD))
		return TRUE

/obj/item/organ/internal/eyes/insert(mob/living/carbon/human/M, special = 0)
	..()
	if(istype(M) && eye_colour)
		M.update_body() //Apply our eye colour to the target.

	if(!(COLOURBLIND in M.mutations) && (COLOURBLIND in dependent_disabilities)) //If the eyes are colourblind and we're not, carry over the gene.
		dependent_disabilities -= COLOURBLIND
		M.dna.SetSEState(GLOB.colourblindblock,1)
		genemutcheck(M,GLOB.colourblindblock,null,MUTCHK_FORCED)
	else
		M.update_client_colour() //If we're here, that means the mob acquired the colourblindness gene while they didn't have eyes. Better handle it.

/obj/item/organ/internal/eyes/remove(mob/living/carbon/human/M, special = 0)
	if(!special && (COLOURBLIND in M.mutations)) //If special is set, that means these eyes are getting deleted (i.e. during set_species())
		if(!(COLOURBLIND in dependent_disabilities)) //We only want to change COLOURBLINDBLOCK and such it the eyes are being surgically removed.
			dependent_disabilities |= COLOURBLIND
		M.dna.SetSEState(GLOB.colourblindblock,0)
		genemutcheck(M,GLOB.colourblindblock,null,MUTCHK_FORCED)
	. = ..()

/obj/item/organ/internal/eyes/surgeryize()
	if(!owner)
		return
	owner.CureNearsighted()
	owner.CureBlind()
	owner.SetEyeBlurry(0)
	owner.SetEyeBlind(0)

/obj/item/organ/internal/eyes/robotize(make_tough)
	colourmatrix = null
	..() //Make sure the organ's got the robotic status indicators before updating the client colour.
	if(owner)
		owner.update_client_colour(0) //Since mechanical eyes give see_in_dark of 2 and full colour vision atm, just having this here is fine.

/obj/item/organ/internal/eyes/cybernetic
	name = "cybernetic eyes"
	icon_state = "eyes-c"
	desc = "An electronic device designed to mimic the functions of a pair of human eyes. It has no benefits over organic eyes, but is easy to produce."
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT

/obj/item/organ/internal/eyes/on_life()
	var/update_flags = STATUS_UPDATE_NONE
	if(owner.glasses)
		var/obj/item/clothing/glasses/G = owner.glasses
		if(G.heal_bodypart == "eyes" && iscarbon(owner))
			var/mob/living/carbon/C = owner
			var/obj/item/organ/internal/eyes/E = C.get_int_organ(/obj/item/organ/internal/eyes)
			if(istype(E))
				E.heal_internal_damage(G.heal_rate)
		update_flags |= owner.AdjustEyeBlurry(-1, FALSE)
	return ..() | update_flags
